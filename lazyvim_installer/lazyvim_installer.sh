#!/bin/bash

# ==========================
# 🌈 Spinner e colori
# ==========================
colors=(31 32 33 34 35 36)
color_index=0
spinner() {
  local pid=$!
  local delay=0.1
  local spinstr='|/-\'
  while kill -0 $pid 2>/dev/null; do
    local color="\e[${colors[$color_index]}m"
    local reset="\e[0m"
    local temp=${spinstr#?}
    printf " [%b%c%b]  \r" "$color" "$spinstr" "$reset"
    spinstr=$temp${spinstr%"$temp"}
    sleep $delay
    color_index=$(((color_index + 1) % ${#colors[@]}))
  done
  printf "    \r"
}

echo -e "\n╔══════════════════════════════════╗"
echo -e "║ 🛠️  Installer LazyVim + Neovim ║"
echo -e "╚══════════════════════════════════╝\n"

# ==========================
# 🌐 Rilevamento OS e package manager
# ==========================

# 📦 Funzio_os_and_package_manager() {

detect_os_and_package_manager() {
  OS="$(uname -s)"
  case "$OS" in
  Linux)
    if [ -f /etc/os-release ]; then
      . /etc/os-release
      DISTRO=$ID
      case "$DISTRO" in
      raspbian | debian | ubuntu)
        PACKAGE_MANAGER="apt"
        ;;
      arch)
        PACKAGE_MANAGER="pacman"
        ;;
      fedora)
        PACKAGE_MANAGER="dnf"
        ;;
      centos)
        PACKAGE_MANAGER="yum"
        ;;
      alpine)
        PACKAGE_MANAGER="apk"
        ;;
      *)
        PACKAGE_MANAGER="unknown"
        ;;
      esac
    else
      PACKAGE_MANAGER="unknown"
    fi
    ;;
  Darwin)
    PACKAGE_MANAGER="brew"
    ;;
  MINGW* | MSYS* | CYGWIN*)
    PACKAGE_MANAGER="choco"
    ;;
  *)
    PACKAGE_MANAGER="unknown"
    ;;
  esac
}

# ==========================
install_package() {
  local name="$1"
  local cmd="$2"
  echo -ne "🔧 Installazione $name...\n"
  (eval "$cmd" &>/dev/null) &
  spinner
  echo -e "✅ $name installato!\n"
}

# ==========================
# 🔍 Rilevamento OS
# ==========================
detect_os_and_package_manager

# ==========================
# 🔄 Aggiornamento sistema
# ==========================
echo "🔄 Aggiornamento sistema..."

# fallback automatico se PACKAGE_MANAGER è unknown
if [ "$PACKAGE_MANAGER" = "unknown" ]; then
  if command -v apt &>/dev/null; then
    PACKAGE_MANAGER="apt"
  elif command -v pacman &>/dev/null; then
    PACKAGE_MANAGER="pacman"
  elif command -v dnf &>/dev/null; then
    PACKAGE_MANAGER="dnf"
  elif command -v yum &>/dev/null; then
    PACKAGE_MANAGER="yum"
  elif command -v apk &>/dev/null; then
    PACKAGE_MANAGER="apk"
  elif command -v brew &>/dev/null; then
    PACKAGE_MANAGER="brew"
  elif command -v choco &>/dev/null; then
    PACKAGE_MANAGER="choco"
  else
    echo "⚠️ Package manager sconosciuto. Aggiornamento saltato."
    PACKAGE_MANAGER="unknown"
  fi
fi

case $PACKAGE_MANAGER in
pacman) sudo pacman -Syu --noconfirm ;;
apt) sudo apt update && sudo apt upgrade -y ;;
dnf) sudo dnf upgrade -y ;;
yum) sudo yum update -y ;;
apk) sudo apk update && sudo apk upgrade ;;
brew) brew update && brew upgrade ;;
choco) choco upgrade all -y ;;
*) echo "⚠️ Package manager sconosciuto. Aggiornamento saltato." ;;
esac

# ==========================
# 🔧 Installazione dipendenze
# ==========================
case $PACKAGE_MANAGER in
pacman) PKG_INSTALL="sudo pacman -S --noconfirm" ;;
apt) PKG_INSTALL="sudo apt install -y" ;;
dnf) PKG_INSTALL="sudo dnf install -y" ;;
yum) PKG_INSTALL="sudo yum install -y" ;;
apk) PKG_INSTALL="sudo apk add" ;;
brew) PKG_INSTALL="brew install" ;;
choco) PKG_INSTALL="choco install -y" ;;
*) 
  echo "⚠️ Package manager sconosciuto. Uscita."
  exit 1
  ;;
esac

install_package "Git" "$PKG_INSTALL git"
install_package "Curl" "$PKG_INSTALL curl"
install_package "NodeJS + npm" "$PKG_INSTALL nodejs npm"
install_package "Python3 + pip" "$PKG_INSTALL python3-pip"
install_package "Ripgrep" "$PKG_INSTALL ripgrep"
install_package "FD" "$PKG_INSTALL fd"
install_package "FZF" "$PKG_INSTALL fzf"
install_package "LazyGit" "$PKG_INSTALL lazygit"

# ==========================
# 🆕 Installazione Neovim AppImage
# ==========================
echo "⚡ Installazione Neovim AppImage ufficiale..."
TMPDIR=$(mktemp -d)
cd $TMPDIR || exit 1
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
chmod u+x nvim-linux-x86_64.appimage
sudo mkdir -p /opt/nvim
sudo mv nvim-linux-x86_64.appimage /opt/nvim/nvim

# Creazione symlink globale
sudo ln -sf /opt/nvim/nvim /usr/local/bin/nvim
echo -e "🌐 Neovim è ora accessibile globalmente come 'nvim'\n"

# Aggiornamento PATH nella shell (sicurezza)
SHELL_RC="$HOME/.bashrc"
if [[ $SHELL == *zsh ]]; then SHELL_RC="$HOME/.zshrc"; fi
if ! grep -q "/opt/nvim" "$SHELL_RC"; then
  echo 'export PATH="/opt/nvim:$PATH"' >>"$SHELL_RC"
  echo -e "\e[33mPATH aggiornato in $SHELL_RC. Riavvia la shell o esegui: source $SHELL_RC\e[0m"
fi
export PATH="/opt/nvim:$PATH"

# Test versione
nvim -v

# ==========================
# 🌟 Installazione LazyVim
# ==========================
echo "🌐 Installazione configurazione LazyVim..."
rm -rf ~/.config/nvim
git clone https://github.com/LazyVim/starter ~/.config/nvim --depth 1 &
spinner
echo -e "✨ LazyVim starter clonato!\n"

echo "🧪 Sincronizzazione plugin Neovim (headless)..."
nvim --headless "+Lazy! sync" +qa &>/dev/null &
spinner
echo -e "\n🎉 LazyVim installato con successo! Digita 'nvim' per iniziare 🚀\n"

echo -e "╔══════════════════════════════════╗"
echo -e "║ ✔ Installazione completata! 🎉 ║"
echo -e "╚══════════════════════════════════╝\n"
