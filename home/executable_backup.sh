#!/bin/bash

host=$(hostname)

mkdir -p /run/media/aludes/BackupHDD/backups/$host/{etc,home}
sudo rsync -zavx /etc/ /run/media/aludes/BackupHDD/backups/$host/etc/
sudo rsync -zavx \
  --exclude .cache/ --exclude .venv/ --exclude __pycache__/ --exclude .mypy_cache/ \
  --exclude .gvfs/ --exclude .thumbnails/ --exclude .local/share/containers/ \
  --exclude .local/share/Steam/ --exclude Trash/ --exclude .Trash/ \
  --exclude node_modules/ --exclude go/pkg/ \
  ~/ /run/media/aludes/BackupHDD/backups/$host/home/
