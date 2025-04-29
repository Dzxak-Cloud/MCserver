```markdown
# 🧱 Minecraft Server Installer + Auto Backup (Forge / Paper)

Skrip ini membantu kamu:
- Install server Minecraft (Forge atau Paper)
- Jalankan otomatis via `tmux`
- Akses file lewat FileBrowser Web UI
- Backup otomatis ke MEGA tiap malam

---

## 📁 Struktur File
.
├── install.sh # Setup server Minecraft + FileBrowser
├── backup.sh # Backup dunia Minecraft + upload ke MEGA
└── README.md

 ---

## 📦 Prasyarat

Sebelum memulai, pastikan Anda memiliki hal-hal berikut:
- Server Ubuntu (disarankan menggunakan VPS atau dedicated server).
- **Domain** yang sudah diatur dengan **A record** yang mengarah ke IP server Anda.
- **Nginx** dan **Certbot** harus diinstal di server Anda.

```

## 🚀 Cara Instalasi Server Minecraft

### 1. Jalankan `install.sh`

```bash
sudo bash install.sh
```

### 2. Masukkan input sesuai permintaan:
- Pilih server: Forge (1) atau Paper (2)
- Masukkan versi Minecraft (misal: `1.20.1`)
- Alokasi RAM minimal & maksimal (contoh: `1G`, `2G`)
- (Forge) Masukkan versi lengkap (misal: `1.20.1-47.3.5`)

---

### 🔧 Setelah Instalasi:
- Server berjalan di background via `tmux` (`session: minecraft`)
- FileBrowser bisa diakses via:
  ```
  http://<IP-server>:8080
  Login: admin / admin
  ```
- Lihat server:
  ```bash
  tmux attach -t minecraft
  ```
- Stop server:
  ```bash
  tmux kill-session -t minecraft
  ```

---

## ☁️ Auto Backup ke MEGA

### 1. Install `mega-cmd`
Untuk Ubuntu/Debian:
```bash
sudo apt install megacmd
```

### 2. Login ke MEGA
```bash
mega-login email@example.com yourpassword
```

### 3. Jalankan `backup.sh`

```bash
bash backup.sh
```

## 🚀 Domain + SSL 

Sebelum menjalankan skrip, pastikan Anda sudah mengarahkan **domain** Anda ke **IP server** dengan menambahkan **A record** di pengaturan DNS. Anda akan membutuhkan dua domain, satu untuk Minecraft dan satu untuk FileBrowser:
- Minecraft: `mc.domain.com`
- FileBrowser: `file.domain.com`

### 4. Jalankan `domain-setup.sh`

```bash
sudo bash domain-setup.sh
```
Script akan meminta Anda untuk memasukkan domain untuk Minecraft dan FileBrowser:
- Masukkan domain untuk Minecraft (contoh: mc.domain.com):
- Masukkan domain untuk FileBrowser (contoh: file.domain.com):

Setelah itu, Script akan:
- Mengonfigurasi Nginx untuk reverse proxy ke Minecraft (port 25565) dan FileBrowser (port 8080).
- Memasang SSL untuk kedua domain menggunakan Certbot.

### Verifikasi Akses
Setelah proses selesai, Anda dapat mengakses:
- Minecraft server di: https://mc.domain.com:25565
- FileBrowser UI di: https://file.domain.com

SSL telah diterapkan dengan sukses, sehingga koneksi akan aman dengan protokol HTTPS.

---

### Yang dilakukan:
- Membuat ZIP berisi dunia Minecraft, konfigurasi, plugin, dll
- Upload ke MEGA folder `/backups`
- Hapus backup lokal lebih dari 2 hari
- Hapus backup MEGA lebih dari 7 file terbaru

---

## ⏰ Menjadwalkan Backup Otomatis

### Edit crontab:
```bash
crontab -e
```

### Tambahkan baris:
```
0 0 * * * /minecraft/backup.sh >> /minecraft/backups/backup.log 2>&1
```

Backup akan otomatis dijalankan **setiap hari pukul 00:00**.

---

## 📌 Tips Tambahan

- Ubah RAM server di `/minecraft/start.sh`
- Tambah plugin (Paper) di folder `/minecraft/plugins`
- Restore backup? Cukup unzip dan replace folder `world`

---

## 💬 Support
Jika butuh bantuan atau request fitur tambahan, silakan kirim pesan 😄

```

Kalau kamu juga pengen `install.sh` dan `backup.sh` digabung ke dalam satu paket CLI atau dengan menu interaktif, aku bisa bantu juga!
