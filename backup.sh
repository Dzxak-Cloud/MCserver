#!/bin/bash

# === CONFIG ===
SOURCE_DIR="/minecraft"
LOCAL_BACKUP_DIR="/backups"
MEGA_DIR="/backups"

# Buat folder lokal kalau belum ada
mkdir -p "$LOCAL_BACKUP_DIR"

# === TIME FORMAT ===
TIMESTAMP=$(date +"%d-%m-%Y_%H-%M")
ZIP_NAME="minecraft-$TIMESTAMP.zip"
ZIP_PATH="$LOCAL_BACKUP_DIR/$ZIP_NAME"

# === ZIP FOLDER ===
echo "[$(date)] Zipping $SOURCE_DIR to $ZIP_PATH..."
zip -r "$ZIP_PATH" "$SOURCE_DIR"

# === UPLOAD TO MEGA ===
echo "[$(date)] Uploading to MEGA: $ZIP_NAME..."
mega-put "$ZIP_PATH" "$MEGA_DIR"

# === DELETE LOCAL FILES OLDER THAN 24 HOURS ===
echo "[$(date)] Cleaning up local files older than 24h..."
find "$LOCAL_BACKUP_DIR" -name "minecraft-*.zip" -type f -mmin +1440 -exec rm -f {} \;

# === DELETE MEGA FILES OLDER THAN 72 HOURS ===
echo "[$(date)] Cleaning up MEGA files older than 72h..."
mega-find "$MEGA_DIR" | while read -r FILE; do
    CREATED_TIME=$(mega-ls -l "$FILE" 2>/dev/null | awk '{print $(NF-1), $NF}')
    if [[ "$CREATED_TIME" != "" ]]; then
        FILE_EPOCH=$(date -d "$CREATED_TIME" +%s 2>/dev/null)
        NOW_EPOCH=$(date +%s)
        if [[ "$FILE_EPOCH" != "" && "$FILE_EPOCH" =~ ^[0-9]+$ ]]; then
            AGE_HOURS=$(( (NOW_EPOCH - FILE_EPOCH) / 3600 ))
            if [ "$AGE_HOURS" -gt 72 ]; then
                echo "Deleting $FILE from MEGA (age: $AGE_HOURS hours)..."
                mega-rm "$FILE"
            fi
        fi
    fi
done
