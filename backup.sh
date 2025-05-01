#!/bin/bash

# Set timezone (opsional, bisa disesuaikan)
export TZ="Asia/Jakarta"

# Format waktu
TIMESTAMP=$(date +"%d-%m-%Y_%H-%M")

# Paths
SOURCE_DIR="/minecraft"
ZIP_NAME="minecraft-$TIMESTAMP.zip"
ZIP_PATH="/path/to/backups/$ZIP_NAME"  # Ganti dengan path lokal untuk menyimpan zip sementara
MEGA_BACKUP_FOLDER="/backups"

# Zip folder
zip -r "$ZIP_PATH" "$SOURCE_DIR"

# Upload to MEGA
mega-put "$ZIP_PATH" "$MEGA_BACKUP_FOLDER"

# Hapus file lokal yang lebih dari 1 hari
find /path/to/backups -name "minecraft-*.zip" -type f -mmin +1440 -exec rm {} \;

# Hapus file di MEGA yang lebih dari 72 jam
mega-find "$MEGA_BACKUP_FOLDER" | while read -r file; do
    file_time=$(mega-ls -e "$file" | grep -oP '\d{4}-\d{2}-\d{2} \d{2}:\d{2}')
    if [ -n "$file_time" ]; then
        file_epoch=$(date -d "$file_time" +%s)
        now_epoch=$(date +%s)
        diff=$(( (now_epoch - file_epoch) / 3600 ))
        if [ "$diff" -gt 72 ]; then
            mega-rm "$file"
        fi
    fi
done
