#!/bin/bash
set -eu
umask 077

backup_dir="/var/backups/linuxsysadminlab"
mkdir -p "$backup_dir"

archive=$(mktemp "$backup_dir/backup-$(date +%Y%m%d-%H%M%S)-XXXXXX.tar.gz")

tar -czf "$archive" -C / var/www/html etc/nginx srv/labshare
gzip -t "$archive"
tar -tzf "$archive" > /dev/null

printf 'Backup verified: %s\n' "$archive"
