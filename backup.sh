#!/bin/bash

MC_DIR="/minecraft"
BACKUP_DIR="$MC_DIR/backups"
TIMESTAMP=$(date +"%d-%m-%Y_%H-%M")
ZIP_NAME="minecraft-backup-$TIMESTAMP.zip"
ZIP_PATH="$BACKUP_DIR/$ZIP_NAME"

# === CEK MEGA-CMD TERINSTAL DAN LOGIN ===
command -v mega-put >/dev/null 2>&1 || { echo "mega-cmd tidak ditemukan. Install dulu ya!"; exit 1; }
mega-login -c >/dev/null 2>&1 || { echo "Belum login ke MEGA. Jalankan 'mega-login' dulu."; exit 1; }

# === PERSIAPAN FOLDER BACKUP ===
mkdir -p "$BACKUP_DIR"
cd "$MC_DIR" || exit

# === ZIP FILE ===
ZIP_TARGETS="server.properties eula.txt *.jar start.sh"
[ -d world ] && ZIP_TARGETS="$ZIP_TARGETS world/"
[ -d plugins ] && ZIP_TARGETS="$ZIP_TARGETS plugins/"

zip -r "$ZIP_PATH" $ZIP_TARGETS

# === UPLOAD KE MEGA ===
if mega-put "$ZIP_PATH" /backups/; then
  echo "✅ Backup berhasil diupload ke MEGA"
else
  echo "❌ Upload ke MEGA gagal"
fi

# === HAPUS BACKUP LOKAL LEBIH DARI 2 HARI ===
find "$BACKUP_DIR" -type f -mtime +2 -name '*.zip' -delete

# === HAPUS FILE DI MEGA KECUALI 7 TERBARU ===
mega-ls -c /backups | tail -n +8 | while read -r file; do
  mega-rm "/backups/$file"
done
