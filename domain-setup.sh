#!/bin/bash

# Pastikan skrip dijalankan dengan root
if [ "$EUID" -ne 0 ]; then
    echo "Harap jalankan sebagai root."
    exit 1
fi

echo "Masukkan domain untuk FileBrowser (contoh: file.domain.com):"
read FILEBROWSER_DOMAIN

# Update dan install Nginx & Certbot
echo "Mengupdate dan menginstall Nginx serta Certbot..."
apt update && apt upgrade -y
apt install nginx certbot python3-certbot-nginx -y

# Membuat konfigurasi Nginx untuk FileBrowser
echo "Membuat konfigurasi Nginx untuk $FILEBROWSER_DOMAIN..."
cat <<EOF > /etc/nginx/sites-available/filebrowser
server {
    listen 80;
    server_name $FILEBROWSER_DOMAIN;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

# Aktifkan konfigurasi Nginx
echo "Mengaktifkan konfigurasi Nginx untuk FileBrowser..."
ln -s /etc/nginx/sites-available/filebrowser /etc/nginx/sites-enabled/

# Uji konfigurasi Nginx
echo "Menguji konfigurasi Nginx..."
nginx -t

# Reload Nginx
echo "Reload Nginx untuk menerapkan perubahan..."
systemctl reload nginx

# Dapatkan SSL menggunakan Certbot
echo "Memasang SSL $FILEBROWSER_DOMAIN..."
certbot --nginx -d $FILEBROWSER_DOMAIN -d www.$FILEBROWSER_DOMAIN

# Menyelesaikan konfigurasi
echo "Konfigurasi selesai!"
echo "FileBrowser dapat diakses di: https://$FILEBROWSER_DOMAIN"
echo "SSL telah diterapkan dengan sukses."
