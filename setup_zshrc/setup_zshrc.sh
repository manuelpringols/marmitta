#!/bin/bash

set -e

# Colori
GREEN="\033[0;32m"
NC="\033[0m" # No Color

# Funzione spinner colorata
spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    while ps -p $pid &> /dev/null; do
        local char=${spinstr:0:1}  # primo carattere
        spinstr=${spinstr:1}${char}  # ruota la stringa
        printf " ${GREEN}[%c]${NC}  " "$char"
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "      \b\b\b\b\b\b"
}

# 0. Download del file spinal come primissima cosa
echo "📥 Scarico file spinal da GitHub..."
SCRIPTS_DIR="$HOME/.manuel_scripts"
mkdir -p "$SCRIPTS_DIR"
curl -fsSL -o "$SCRIPTS_DIR/spinal" "https://raw.githubusercontent.com/manuelpringols/scripts/master/setup_zshrc/spinal" & spinner

if [ ! -s "$SCRIPTS_DIR/spinal" ]; then
    echo "❌ Download di spinal fallito o file vuoto."
    exit 1
fi

echo "✅ File spinal scaricato correttamente."

# 1. Installa zsh
echo "🔧 Installing zsh..."

if ! command -v zsh &> /dev/null; then
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        distro=$ID
    else
        echo "❌ Impossibile determinare la distribuzione."
        exit 1
    fi

    case "$distro" in
        ubuntu|debian|kali)
            (sudo apt update && sudo apt install -y zsh) & spinner
            ;;
        fedora)
            (sudo dnf install -y zsh) & spinner
            ;;
        centos|rhel)
            (sudo yum install -y zsh) & spinner
            ;;
        arch)
            (sudo pacman -Sy --noconfirm zsh) & spinner
            ;;
        opensuse*|suse)
            (sudo zypper install -y zsh) & spinner
            ;;
        raspbian)
            (sudo apt install -y zsh) & spinner
            ;;
        *)
            echo "❌ Distribuzione non supportata: $distro"
            exit 1
            ;;
    esac
else
    echo "✅ zsh is already installed."
fi

# 2. Imposta zsh come shell predefinita
echo "🔧 Setting zsh as default shell..."
(chsh -s "$(which zsh)") & spinner

# 3. Installa Oh My Zsh
echo "✨ Installing Oh My Zsh..."
export RUNZSH=no
export KEEP_ZSHRC=yes
(sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)") & spinner

# 4. Installa plugin zsh-syntax-highlighting
echo "🔧 Installing zsh-syntax-highlighting plugin..."
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
(git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
  "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting") & spinner

# 5. Installa plugin zsh-autosuggestions
echo "🔧 Installing zsh-autosuggestions plugin..."
(git clone https://github.com/zsh-users/zsh-autosuggestions \
  "$ZSH_CUSTOM/plugins/zsh-autosuggestions") & spinner

# 6. Copia il file spinal scaricato in ~/.zshrc
echo "📄 Replacing ~/.zshrc with spinal..."
cp "$SCRIPTS_DIR/spinal" ~/.zshrc

echo "✅ Setup completato. Avvia una nuova sessione zsh o esegui 'zsh' ora."
