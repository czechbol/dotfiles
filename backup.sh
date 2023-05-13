#!/bin/bash
mkdir -p /run/media/aludes/BackupHDD/backups/$(hostname)/{etc,home}
sudo rsync -zavx /etc/ /run/media/aludes/BackupHDD/backups/$(hostname)/etc/
sudo rsync -zavx \
  --exclude .cache/ --exclude .venv/ --exclude __pycache__/ --exclude .mypy_cache/ \
  --exclude ~/.gvfs/ --exclude ~/.thumbnails/ --exclude ~/local/share/containers/ \
  --exclude Trash/ --exclude ~/.Trash/ \
  --delete \
  ~/ /run/media/aludes/BackupHDD/backups/$(hostname)/home/
