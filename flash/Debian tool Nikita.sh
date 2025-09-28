#!/bin/bash

# Colores
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # Sin color

SID_LIST="/etc/apt/sources.list.d/sid.list"
MESA_PREF="/etc/apt/preferences.d/mesa.pref"

function instalar_mesa() {
    echo -e "${GREEN}=== Configurando repositorios de SID ===${NC}"
    if [ ! -f "$SID_LIST" ]; then
        echo "deb http://deb.debian.org/debian sid main contrib non-free non-free-firmware" | sudo tee "$SID_LIST" > /dev/null
        echo -e "${GREEN}[OK] sid.list creado${NC}"
    else
        echo -e "${YELLOW}[INFO] sid.list ya existe, lo dejo igual${NC}"
    fi

    echo -e "${GREEN}=== Configurando pinning ===${NC}"
    if [ ! -f "$MESA_PREF" ]; then
        sudo tee "$MESA_PREF" > /dev/null <<EOF
Package: *
Pin: release a=sid
Pin-Priority: 100
EOF
        echo -e "${GREEN}[OK] mesa.pref creado${NC}"
    else
        echo -e "${YELLOW}[INFO] mesa.pref ya existe, lo dejo igual${NC}"
    fi

    echo -e "${GREEN}=== Actualizando repositorios ===${NC}"
    sudo apt update

    echo -e "${GREEN}=== Instalando/actualizando Mesa desde SID ===${NC}"
    sudo apt install -t sid -y --no-install-recommends \
        mesa-vulkan-drivers mesa-utils vulkan-tools \
        libvulkan1 libglx-mesa0 libgl1-mesa-dri libegl1 \
        libgles2 libgbm1 libdrm2 libdrm-amdgpu1 libdrm-common \
        glmark2 || echo -e "${RED}[ADVERTENCIA] No se pudo instalar algún paquete opcional${NC}"

    echo -e "${GREEN}=== Instalación completa ===${NC}"
}

function eliminar_sid() {
    echo -e "${GREEN}=== Eliminando SID (repositorios y referencias) ===${NC}"
    sudo sed -i.bak '/deb .*sid/ s/^/#/' /etc/apt/sources.list
    sudo rm -f "$SID_LIST"
    sudo apt update
    echo -e "${GREEN}[OK] SID eliminado y respaldo de sources.list creado como sources.list.bak${NC}"
}

function ver_mesa() {
    echo -e "${CYAN}=== Versión de Mesa / OpenGL ===${NC}"
    glxinfo | grep "OpenGL version"
}

function ver_vulkan() {
    echo -e "${CYAN}=== Info de Vulkan ===${NC}"
    vulkaninfo | less
}

function test_vulkan() {
    echo -e "${CYAN}=== Testeando Vulkan con vkcube ===${NC}"
    vkcube
}

function test_glmark2() {
    echo -e "${CYAN}=== Benchmark OpenGL con glmark2 ===${NC}"
    glmark2
}
function instalar_steam_flatpak() {
    echo -e "${GREEN}=== Instalando Flatpak si es necesario ===${NC}"
    if ! command -v flatpak &> /dev/null; then
        sudo apt update
        sudo apt install -y flatpak
        echo -e "${GREEN}[OK] Flatpak instalado${NC}"
    else
        echo -e "${YELLOW}[INFO] Flatpak ya está instalado${NC}"
    fi

    echo -e "${GREEN}=== Agregando repositorio Flathub ===${NC}"
    if ! flatpak remotes | grep -q flathub; then
        sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        echo -e "${GREEN}[OK] Flathub agregado${NC}"
    else
        echo -e "${YELLOW}[INFO] Flathub ya está agregado${NC}"
    fi

    echo -e "${GREEN}=== Instalando Steam desde Flathub ===${NC}"
    sudo flatpak install -y flathub com.valvesoftware.Steam

    echo -e "${GREEN}=== Creando acceso directo en el escritorio ===${NC}"
    # Detectar carpeta de escritorio según XDG (funciona en cualquier idioma)
    DESKTOP_DIR=$(xdg-user-dir DESKTOP)
    if [ -z "$DESKTOP_DIR" ] || [ ! -d "$DESKTOP_DIR" ]; then
        DESKTOP_DIR="$HOME/Desktop"  # fallback
        mkdir -p "$DESKTOP_DIR"
    fi

    DESKTOP_FILE="$DESKTOP_DIR/Steam-Flatpak.desktop"

    # Buscar icono de Steam Flatpak
    ICON_PATH=$(find ~/.local/share/flatpak/exports/share/icons/hicolor/256x256/apps/ -name "steam.png" | head -n1)
    if [ -z "$ICON_PATH" ]; then
        ICON_PATH="steam"  # fallback al icono genérico si no se encuentra
    fi

    cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=Steam
Comment=Steam Flatpak
Exec=flatpak run com.valvesoftware.Steam
Icon=$ICON_PATH
Terminal=false
Type=Application
Categories=Game;
EOF

    chmod +x "$DESKTOP_FILE"
    echo -e "${GREEN}[OK] Acceso directo creado en el escritorio: $DESKTOP_FILE${NC}"
    echo -e "${CYAN}Podés iniciar Steam con: flatpak run com.valvesoftware.Steam o desde el acceso directo${NC}"
}
install_windows10_icons() {
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  RED='\033[0;31m'
  NC='\033[0m' # Sin color

  echo -e "${GREEN}=== Instalando tema de iconos estilo Windows 10 ===${NC}"

  # Instalar Git si no está presente
  if ! command -v git &> /dev/null; then
      echo -e "${YELLOW}Git no está instalado. Instalando Git...${NC}"
      sudo apt update
      sudo apt install -y git
      echo -e "${GREEN}✔ Git instalado.${NC}"
  fi

  # Limpiar carpeta temporal si existe
  rm -rf /tmp/windows10-icons

  # Clonar el repositorio de iconos como usuario normal
  if git clone https://github.com/B00merang-Artwork/Windows-10.git /tmp/windows10-icons; then
      echo -e "${GREEN}✔ Repositorio clonado correctamente${NC}"
  else
      echo -e "${RED}✖ Error al clonar el repositorio. Revisá tu conexión o Git${NC}"
      return 1
  fi

  # Crear carpeta de iconos si no existe
  mkdir -p ~/.icons/Windows-10

  # Copiar solo los archivos necesarios, excluyendo .git
  rsync -av --exclude='.git' /tmp/windows10-icons/ ~/.icons/Windows-10/

  # Confirmar la instalación
  if [ -d ~/.icons/Windows-10 ]; then
    echo -e "${GREEN}✔ Tema de iconos Windows 10 instalado correctamente.${NC}"

    # Aplicar automáticamente el tema de iconos en Cinnamon
    if command -v gsettings &> /dev/null; then
      gsettings set org.cinnamon.desktop.interface icon-theme "Windows-10"
      echo -e "${GREEN}✔ Tema de iconos aplicado automáticamente en Cinnamon.${NC}"
    else
      echo -e "${YELLOW}⚠ No se pudo aplicar automáticamente el tema de iconos (gsettings no disponible).${NC}"
    fi

    # Aplicar también tema GTK Windows 10 si existe
    if [ -d ~/.themes/Windows-10 ]; then
      gsettings set org.cinnamon.desktop.interface gtk-theme "Windows-10"
      gsettings set org.cinnamon.desktop.wm.preferences theme "Windows-10"
      echo -e "${GREEN}✔ Tema GTK Windows 10 aplicado automáticamente en Cinnamon.${NC}"
    fi

    echo -e "${YELLOW}Reinicia la sesión para que todos los cambios surtan efecto.${NC}"
  else
    echo -e "${RED}✖ Hubo un problema al instalar el tema de iconos.${NC}"
  fi
}
install_windows11_icons() {
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  RED='\033[0;31m'
  NC='\033[0m'

  echo -e "${GREEN}=== Instalando tema de iconos estilo Windows 11 (Seguro) ===${NC}"

  # Instalar Git si no está presente
  if ! command -v git &> /dev/null; then
      echo -e "${YELLOW}Git no está instalado. Instalando Git...${NC}"
      sudo apt update
      sudo apt install -y git
      echo -e "${GREEN}✔ Git instalado.${NC}"
  fi

  rm -rf /tmp/windows11-icons

  # Clonar repositorio
  if git clone https://github.com/yeyushengfan258/Win11-icon-theme.git /tmp/windows11-icons; then
      echo -e "${GREEN}✔ Repositorio clonado correctamente${NC}"
  else
      echo -e "${RED}✖ Error al clonar el repositorio${NC}"
      return 1
  fi

  # Detectar carpeta principal
  ICON_SRC_DIR=$(find /tmp/windows11-icons -maxdepth 2 -type f -name "index.theme" -exec dirname {} \;)
  if [ -z "$ICON_SRC_DIR" ]; then
      echo -e "${RED}✖ No se encontró la carpeta principal del tema${NC}"
      return 1
  fi

  mkdir -p ~/.icons/Windows-11

  # Copiar los iconos
  rsync -av --exclude='.git' "$ICON_SRC_DIR"/ ~/.icons/Windows-11/

  # Actualizar caché
  if command -v gtk-update-icon-cache &> /dev/null; then
      gtk-update-icon-cache -f -t ~/.icons/Windows-11
  fi

  # Aplicar tema de iconos
  if command -v gsettings &> /dev/null; then
      gsettings set org.cinnamon.desktop.interface icon-theme "Windows-11"
      echo -e "${GREEN}✔ Tema de iconos aplicado automáticamente en Cinnamon${NC}"
  fi

  echo -e "${YELLOW}⚠ Para el icono del menú inicio estilo Windows 11, se recomienda usar un applet o dock. No reemplaces el menú principal.${NC}"
  echo -e "${YELLOW}Reinicia la sesión para que los cambios surtan efecto.${NC}"
}


install_heroic_flatpak() {
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  RED='\033[0;31m'
  NC='\033[0m'

  echo -e "${GREEN}=== Instalando Flatpak si es necesario ===${NC}"
  if ! command -v flatpak &> /dev/null; then
      sudo apt update
      sudo apt install -y flatpak
      echo -e "${GREEN}[OK] Flatpak instalado${NC}"
  else
      echo -e "${YELLOW}[INFO] Flatpak ya está instalado${NC}"
  fi

  echo -e "${GREEN}=== Agregando repositorio Flathub ===${NC}"
  if ! flatpak remotes | grep -q flathub; then
      sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
      echo -e "${GREEN}[OK] Flathub agregado${NC}"
  else
      echo -e "${YELLOW}[INFO] Flathub ya está agregado${NC}"
  fi

  echo -e "${GREEN}=== Instalando Heroic Games Launcher desde Flathub ===${NC}"
  if ! flatpak install -y flathub com.heroicgameslauncher.hgl; then
      echo -e "${RED}✖ No se pudo instalar Heroic desde Flathub. Verifica tu conexión.${NC}"
      return 1
  fi

  echo -e "${GREEN}✔ Heroic instalado correctamente en Flatpak.${NC}"
  echo -e "${YELLOW}Se agregó automáticamente al menú de aplicaciones en la categoría 'Juegos'.${NC}"
  echo -e "${CYAN}Podés iniciar Heroic con: flatpak run com.heroicgameslauncher.hgl${NC}"
}
autologin() {
  CURRENT_USER=$(whoami)

  echo "Se te pedirá la contraseña de root para configurar el autologin..."

  su -c "
    /usr/sbin/usermod -aG sudo $CURRENT_USER && echo '✔ Usuario agregado al grupo sudo.'
    mkdir -p /etc/lightdm/lightdm.conf.d
    cat > /etc/lightdm/lightdm.conf.d/50-autologin.conf <<EOF
[Seat:*]
autologin-user=$CURRENT_USER
autologin-user-timeout=0
EOF
    echo '✔ Autologin configurado para $CURRENT_USER.'
  "

  echo "⚠ Para que los cambios surtan efecto, cerrá sesión o reiniciá el sistema."
}



while true; do
    clear
    echo -e "${GREEN}=====Debian toool Nikita Edition =====${NC}"
    echo -e "${YELLOW}Seguinos en youtube/@tipitochen${NC}"
    echo
    echo -e "${CYAN}1) Instalar/actualizar drivers Mesa desde SID${NC}"
    echo -e "${CYAN}2) Ver versión de Mesa/OpenGL${NC}"
    echo -e "${CYAN}3) Ver información de Vulkan${NC}"
    echo -e "${CYAN}4) Test Vulkan (vkcube)${NC}"
    echo -e "${CYAN}5) Benchmark OpenGL (glmark2)${NC}"
    echo -e "${CYAN}6) Eliminar repositorio SID (desactivar actualizaciones de SID)${NC}"
     echo -e "${GREEN}===== Herramientas Cinnamon=====${NC}"
    echo -e "${CYAN}7) Instalar Steam desde Flatpak${NC}"
    echo -e "${CYAN}8) Instalar Tema windows 10(git -B00merang-Artwork) ${NC}"
    echo -e "${CYAN}9) Instalar Tema windows 11 (git - yeyushengfan258)${NC}"
    echo -e "${CYAN}10) Habilitar autologin de usuario actual${NC}"
    echo -e "${RED}0) Salir${NC}"
    echo "====================="
    read -p "Elegí una opción: " opcion

    case $opcion in
        1) instalar_mesa ;;
        2) ver_mesa ;;
        3) ver_vulkan ;;
        4) test_vulkan ;;
        5) test_glmark2 ;;
        6) eliminar_sid ;;
        7) instalar_steam_flatpak ;;
        8) install_windows10_icons ;;
        9) install_windows11_icons ;;
        10) autologin ;;
        0) echo -e "${RED}Saliendo...${NC}"; exit 0 ;;
        *) echo -e "${RED}Opción inválida${NC}"; sleep 1 ;;
    esac

    echo
    read -p "Presioná ENTER para volver al menú..."
done

