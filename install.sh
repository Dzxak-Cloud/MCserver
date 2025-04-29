#!/bin/bash

# Pastikan skrip berjalan dengan izin root
if [ "$EUID" -ne 0 ]; then
  echo "Harap jalankan sebagai root."
  exit 1
fi

# 1. Install Java JDK dan tmux
echo "Menginstall Java JDK dan tmux..."
apt update
apt install -y openjdk-17-jdk tmux curl unzip

# Verifikasi instalasi Java
java -version || { echo "Java gagal diinstal. Keluar."; exit 1; }

# 2. Membuat folder Minecraft
echo "Membuat folder /minecraft..."
mkdir -p /minecraft
cd /minecraft

# 3. Pilihan server: Forge atau Paper
echo "Pilih jenis server Minecraft:"
echo "1) Forge"
echo "2) PaperMC"
read -p "Masukkan pilihan (1 atau 2): " server_type

read -p "Masukkan versi Minecraft (contoh: 1.20.1): " MC_VERSION
read -p "Alokasi minimum RAM (contoh: 1G): " RAM_MIN
read -p "Alokasi maksimum RAM (contoh: 2G): " RAM_MAX

if [ "$server_type" == "1" ]; then
  read -p "Masukkan versi lengkap Forge (contoh: 1.20.1-47.3.5): " FORGE_VERSION
  FORGE_INSTALLER="forge-$FORGE_VERSION-installer.jar"
  echo "Mengunduh Forge installer..."
  curl -O https://maven.minecraftforge.net/net/minecraftforge/forge/$FORGE_VERSION/$FORGE_INSTALLER

  [[ -f "$FORGE_INSTALLER" ]] || { echo "Unduhan gagal. Cek versi Forge."; exit 1; }

  echo "Menjalankan Forge installer..."
  java -jar $FORGE_INSTALLER --installServer || { echo "Instalasi Forge gagal."; exit 1; }

  SERVER_JAR=$(ls forge-*-universal.jar | head -n1)

elif [ "$server_type" == "2" ]; then
  echo "Mendeteksi versi build PaperMC..."
  BUILD=$(curl -s https://api.papermc.io/v2/projects/paper/versions/$MC_VERSION | grep -oP '"builds":\[\K[^\]]+' | tr ',' '\n' | tail -1)

  [[ -z "$BUILD" ]] && { echo "Versi $MC_VERSION tidak ditemukan untuk Paper."; exit 1; }

  PAPER_JAR="paper-$MC_VERSION-$BUILD.jar"
  echo "Mengunduh PaperMC build $BUILD..."
  curl -o paper.jar https://api.papermc.io/v2/projects/paper/versions/$MC_VERSION/builds/$BUILD/downloads/$PAPER_JAR

  [[ -f "paper.jar" ]] || { echo "Gagal mengunduh PaperMC."; exit 1; }

  SERVER_JAR="paper.jar"
else
  echo "Pilihan tidak valid."
  exit 1
fi

# 4. Menyetujui EULA
echo "Menyetujui EULA..."
echo "eula=true" > eula.txt

# 5. Membuat skrip start.sh
echo "Membuat start.sh..."
cat <<EOF > start.sh
#!/bin/bash
java -Xms$RAM_MIN -Xmx$RAM_MAX -jar $SERVER_JAR nogui
EOF
chmod +x start.sh

# 6. Jalankan server Minecraft di tmux
echo "Menjalankan server Minecraft di background (tmux: minecraft)..."
tmux has-session -t minecraft 2>/dev/null && tmux kill-session -t minecraft
tmux new-session -d -s minecraft "/minecraft/start.sh"

# 7. Install FileBrowser
echo "Menginstall FileBrowser..."
curl -fsSL https://filebrowser.org/install.sh | bash

mkdir -p /etc/filebrowser
filebrowser config init -d /etc/filebrowser/filebrowser.db
filebrowser config set --database /etc/filebrowser/filebrowser.db --root /minecraft
filebrowser users add admin admin --perm.admin

# 8. Jalankan FileBrowser di tmux
echo "Menjalankan FileBrowser di background (tmux: filebrowser)..."
tmux has-session -t filebrowser 2>/dev/null && tmux kill-session -t filebrowser
tmux new-session -d -s filebrowser "filebrowser -d /etc/filebrowser/filebrowser.db"

# Done!
echo ""
echo "✅ Instalasi selesai!"
echo "🌐 Akses FileBrowser: http://<IP-server>:8080 (admin / admin)"
echo "🟢 Minecraft berjalan di tmux: minecraft"
echo "🔧 Cek: tmux attach -t minecraft"
echo "🛑 Stop: tmux kill-session -t minecraft"
