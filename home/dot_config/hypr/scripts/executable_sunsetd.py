#!/usr/bin/env python3

import argparse
import datetime
import json
import logging
import os
import sqlite3
import subprocess
import sys
import time
import urllib.parse
import urllib.request
from typing import Optional, Tuple

logger = logging.getLogger(__name__)


# --- Configuration ---
NOMINATIM_API = "https://nominatim.openstreetmap.org/search"
SUNRISE_SUNSET_API = "https://api.sunrise-sunset.org/json"
HYPRSUNSET_COMMAND = "hyprctl hyprsunset temperature"
USER_AGENT = "sunsetd/1.0 (https://github.com/hyprwm)"
DAY_TEMP = 6000
DEFAULT_NIGHT_TEMP = 2500
TRANSITION_PERIOD_MINUTES = 60
TRANSITION_STEPS = 6
CHECK_INTERVAL_SECONDS = 60
CACHE_DIR = os.path.expanduser("~/.cache/sunsetd/")
DATABASE_FILE = CACHE_DIR + "sunsetd.db"
LOG_FILE = CACHE_DIR + "sunsetd.log"
TITLE = r"""                          _      _
                         | |    | |
 ___ _   _ _ __  ___  ___| |_ __| |
/ __| | | | '_ \/ __|/ _ \ __/ _` |
\__ \ |_| | | | \__ \  __/ || (_| |
|___/\__,_|_| |_|___/\___|\__\__,_|"""
# --- End Configuration ---




def _floor_to_hundred(n):
    """Return the input integer floored to the nearest hundred."""
    return (n // 100) * 100

def ensure_cache_dir():
    """Creates the cache directory if it doesn't exist."""
    os.makedirs(CACHE_DIR, exist_ok=True)


def init_database():
    """Creates the database and tables if they don't exist."""
    logger.debug("Creating database")
    conn = sqlite3.connect(DATABASE_FILE)
    cursor = conn.cursor()
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS location (
            city TEXT PRIMARY KEY,
            latitude REAL,
            longitude REAL
        )
    """
    )
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS sun_data (
            date TEXT PRIMARY KEY,
            sunrise TEXT,
            sunset TEXT
        )
    """
    )
    conn.commit()
    conn.close()


def get_cached_location(city: str) -> Optional[Tuple[float, float]]:
    """Gets the location from the cache.

    Args:
        city: The name of the city.

    Returns:
        A tuple containing the latitude and longitude, or None if not found.
    """
    logger.debug(f"Getting cached location for: {city}")
    conn = sqlite3.connect(DATABASE_FILE)
    cursor = conn.cursor()
    cursor.execute("SELECT latitude, longitude FROM location WHERE city=?", (city,))
    result = cursor.fetchone()
    conn.close()
    if result:
        return float(result[0]), float(result[1])
    return None


def cache_location(city: str, latitude: float, longitude: float) -> None:
    """Caches the location in the database.

    Args:
        city: The name of the city.
        latitude: The latitude of the city.
        longitude: The longitude of the city.
    """

    logger.debug(f"Caching location: {city}, {latitude}, {longitude}")
    conn = sqlite3.connect(DATABASE_FILE)
    cursor = conn.cursor()
    cursor.execute(
        "INSERT OR REPLACE INTO location (city, latitude, longitude) VALUES (?, ?, ?)",
        (city, latitude, longitude),
    )
    conn.commit()
    conn.close()


def get_location(city: str) -> Optional[Tuple[float, float]]:
    """Gets the latitude and longitude of a city, using the cache if available.

    Args:
        city: The name of the city.

    Returns:
        A tuple containing the latitude and longitude, or None if an error occurred.
    """
    logger.debug(f"Getting location for: {city}")
    cached_location = get_cached_location(city)
    if cached_location:
        logger.debug(f"Location: ({cached_location[0]}, {cached_location[1]})")
        return cached_location

    try:
        params = {"q": city, "format": "json", "limit": 1}
        url = f"{NOMINATIM_API}?{urllib.parse.urlencode(params)}"
        request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
        with urllib.request.urlopen(request) as response:
            data = json.loads(response.read().decode())
            if data:
                latitude = float(data[0]["lat"])
                longitude = float(data[0]["lon"])
                cache_location(city, latitude, longitude)
                logger.debug(f"Location: ({latitude}, {longitude})")
                return latitude, longitude
            return None
    except (urllib.error.URLError, json.JSONDecodeError) as e:
        logger.error(f"Error getting location: {e}")
        return None


def get_cached_sun_data(
    today: datetime.date,
) -> Optional[Tuple[datetime.datetime, datetime.datetime]]:
    """Gets the sunrise and sunset times from the cache.

    Args:
        today: The current date.

    Returns:
        A tuple containing the sunrise and sunset times, or None if not found.
    """
    logger.debug(f"Getting cached sun data for: {today}")
    conn = sqlite3.connect(DATABASE_FILE)
    cursor = conn.cursor()
    cursor.execute(
        "SELECT sunrise, sunset FROM sun_data WHERE date=?", (today.isoformat(),)
    )
    result = cursor.fetchone()
    conn.close()
    if result:
        sunrise = datetime.datetime.fromisoformat(result[0]).astimezone(datetime.timezone.utc)
        sunset = datetime.datetime.fromisoformat(result[1]).astimezone(datetime.timezone.utc)
        return sunrise, sunset
    return None


def cache_sun_data(
    today: datetime.date, sunrise: datetime.datetime, sunset: datetime.datetime
) -> None:
    """Caches the sunrise and sunset times in the database.

    Args:
        today: The current date.
        sunrise: The sunrise time.
        sunset: The sunset time.
    """
    logger.debug(f"Caching sun data for: {today}")
    conn = sqlite3.connect(DATABASE_FILE)
    cursor = conn.cursor()
    cursor.execute("DELETE FROM sun_data WHERE date < ?", (today.isoformat(),))
    cursor.execute(
        "INSERT OR REPLACE INTO sun_data (date, sunrise, sunset) VALUES (?, ?, ?)",
        (today.isoformat(), sunrise.isoformat(), sunset.isoformat()),
    )
    conn.commit()
    conn.close()


def get_sun_data(
    latitude: float, longitude: float, date: datetime.date = None
) -> Optional[Tuple[datetime.datetime, datetime.datetime]]:
    """Gets the sunrise and sunset times for a location, using the cache if available.

    Args:
        latitude: The latitude of the location.
        longitude: The longitude of the location.

    Returns:
        A tuple containing the sunrise and sunset times, or None if an error occurred.
    """
    logger.debug(
        f"Fetching sun data for: lat={latitude}, lon={longitude}, date={date if date is not None else 'today'}"
    )
    if date is None:
        date = datetime.datetime.now().date()
    cached_sun_data = get_cached_sun_data(date)
    if cached_sun_data:
        return cached_sun_data

    try:
        params = {
            "lat": latitude,
            "lng": longitude,
            "date": date.isoformat(),
            "formatted": 0,  # Get times in ISO 8601 format
        }
        url = f"{SUNRISE_SUNSET_API}?{urllib.parse.urlencode(params)}"
        request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
        with urllib.request.urlopen(request) as response:
            data = json.loads(response.read().decode())
            if data["status"] == "OK":
                sunrise_str = data["results"]["sunrise"]
                sunset_str = data["results"]["sunset"]
                sunrise = datetime.datetime.fromisoformat(sunrise_str).astimezone(datetime.timezone.utc)
                sunset = datetime.datetime.fromisoformat(sunset_str).astimezone(datetime.timezone.utc)
                cache_sun_data(date, sunrise, sunset)
                return sunrise, sunset
            return None
    except (urllib.error.URLError, json.JSONDecodeError) as e:
        logger.error(f"Error getting sun data: {e}")
        return None


def get_current_time() -> datetime.datetime:
    """Gets the current time in UTC."""
    return datetime.datetime.now(datetime.timezone.utc)


def calculate_temp(
    current_time: datetime.datetime,
    sunrise: datetime.datetime,
    sunset: datetime.datetime,
    night_temp: int,
) -> int:
    """Calculates the display temperature based on the current time and sunrise/sunset times.

    Args:
        current_time: The current time.
        sunrise: The sunrise time.
        sunset: The sunset time.
        night_temp: The temperature to use during the night.

    Returns:
        The calculated temperature.
    """
    current_time = current_time.replace(tzinfo=datetime.timezone.utc)
    sunrise = sunrise.replace(tzinfo=datetime.timezone.utc)
    sunset = sunset.replace(tzinfo=datetime.timezone.utc)

    minutes_before_sunset = (sunset - current_time).total_seconds() / 60
    minutes_after_sunrise = (current_time - sunrise).total_seconds() / 60

    if current_time > sunset or current_time < sunrise:
        return night_temp

    if 0 <= minutes_before_sunset <= TRANSITION_PERIOD_MINUTES:
        step = (TRANSITION_PERIOD_MINUTES - minutes_before_sunset) // (
            TRANSITION_PERIOD_MINUTES // TRANSITION_STEPS
        )
        temp_diff = DAY_TEMP - night_temp
        temp = DAY_TEMP - (temp_diff / TRANSITION_STEPS) * step
        return int(max(night_temp, min(DAY_TEMP, temp)))

    if 0 <= minutes_after_sunrise <= TRANSITION_PERIOD_MINUTES:
        step = minutes_after_sunrise // (
            TRANSITION_PERIOD_MINUTES // TRANSITION_STEPS
        )
        temp_diff = DAY_TEMP - night_temp
        temp = night_temp + (temp_diff / TRANSITION_STEPS) * step
        return int(max(night_temp, min(DAY_TEMP, temp)))

    return DAY_TEMP


def set_temperature(temp: int) -> None:
    """Applies the shader with the given temperature.

    Args:
        temp: The temperature to set.
    """
    logger.debug(f"Setting temperature to: {temp}")
    try:
        command = HYPRSUNSET_COMMAND.split() + [str(temp)]
        subprocess.run(command, check=True)
    except subprocess.CalledProcessError as e:
        logger.error(f"Error setting temperature: {e}")


def setup_logging(debug: bool) -> None:
    """Configures the logging system.

    Args:
        debug: Whether to enable debug logging.
    """

    level = logging.DEBUG if debug else logging.INFO

    # Calculate the maximum length of log level names
    max_level_length = max(
        len(level_name) for level_name in logging._levelToName.values()
    )

    # Create a custom format string with padding
    log_format = f"%(asctime)s %(levelname)-{max_level_length}s %(message)s"

    logging.basicConfig(
        level=level,
        format=log_format,
        handlers=[
            logging.FileHandler(LOG_FILE, mode="w", encoding="utf-8", delay=True),
            logging.StreamHandler(stream=sys.stdout),
        ],
        datefmt="%Y-%m-%d %H:%M:%S",
    )


def main() -> None:
    """Main script logic."""
    parser = argparse.ArgumentParser(
        prog="sunsetd",
        description="Daemon to dynamically set the display temperature based on sunrise/sunset times.",
    )
    parser.add_argument(
        "-d",
        "--debug",
        action="store_true",
        help="Enable debug logging. Default is False.",
    )
    parser.add_argument(
        "-c",
        "--city",
        help="The city, town, or village to use for location.",
        required=True,
    )
    parser.add_argument(
        "-t",
        "--night-temp",
        help="The night temperature to use for the shader.",
        type=int,
        default=DEFAULT_NIGHT_TEMP,
    )
    args = parser.parse_args()

    setup_logging(args.debug)

    init_database()

    location = get_location(args.city)
    if location is None:
        logger.error("Could not determine location. Exiting.")
        return
    latitude, longitude = location

    # Poll loop: recompute and re-assert the correct temperature every
    # interval. calculate_temp() returns the correct value for any instant
    # (night, dawn transition, day, dusk transition), so re-applying it on a
    # fixed cadence keeps the display correct even if hyprsunset is reset or a
    # transition step boundary is crossed. get_sun_data caches per-date, so
    # refetching "today" each tick is cheap and auto-refreshes at midnight.
    last_temp = None
    while True:
        today = datetime.datetime.now().date()
        sunrise_sunset = get_sun_data(latitude, longitude, today)
        if sunrise_sunset is None:
            logger.error("Could not determine sunrise/sunset times. Retrying.")
            time.sleep(CHECK_INTERVAL_SECONDS)
            continue
        sunrise, sunset = sunrise_sunset

        temp = _floor_to_hundred(
            calculate_temp(get_current_time(), sunrise, sunset, args.night_temp)
        )
        if temp != last_temp:
            logger.info(f"Setting temperature to {temp}")
            set_temperature(temp)
            last_temp = temp
        else:
            logger.debug(f"Temperature unchanged ({temp})")

        time.sleep(CHECK_INTERVAL_SECONDS)


if __name__ == "__main__":
    ensure_cache_dir()

    # startup delay
    time.sleep(10)

    main()
