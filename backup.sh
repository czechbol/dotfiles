#!/bin/bash
mkdir -p /run/media/aludes/BackupHDD/backups/$(hostname)/{etc,home}
sudo rsync -zavx /etc/ /run/media/aludes/BackupHDD/backups/$(hostname)/etc/
rsync -zavx \
  --exclude .cache/ --exclude .venv/ --exclude __pycache__/ --exclude .mypy_cache/ \
  --exclude .gvfs/ --exclude .thumbnails/ --exclude .local/share/containers/ \
  --exclude .local/share/Steam/ --exclude Trash/ --exclude .Trash/ \
  --exclude node_modules/ --exclude go/pkg/ \
  ~/ /run/media/aludes/BackupHDD/backups/$(hostname)/home/
