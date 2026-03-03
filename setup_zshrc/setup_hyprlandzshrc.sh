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

# 0. Download del file back_broken come primissima cosa
echo "📥 Scarico file back_broken da GitHub..."
SCRIPTS_DIR="$HOME/.manuel_scripts"
mkdir -p "$SCRIPTS_DIR"
curl -fsSL -o "$SCRIPTS_DIR/back_broken" "https://raw.githubusercontent.com/manuelpringols/scripts/master/setup_zshrc/back_broken" & spinner

if [ ! -s "$SCRIPTS_DIR/back_broken" ]; then
    echo "❌ Download di back_broken fallito o file vuoto."
    exit 1
fi

echo "✅ File back_broken scaricato correttamente."

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

# 4. Crea una cartella per i plugin di zsh
echo "🔧 Crea cartella per i plugin Zsh..."
mkdir -p "$HOME/.zsh/plugins"  # Modificato per usare una cartella personalizzata


# 4bis. Crea la directory di config necessaria a zcompile
mkdir -p "$HOME/.config/zsh"


# 5bis. Installa plugin zsh-history-substring-search
echo "🔧 Installing zsh-history-substring-search plugin..."
(git clone https://github.com/zsh-users/zsh-history-substring-search \
  "$HOME/.zsh/plugins/zsh-history-substring-search") & spinner

# 7. Installa plugin fzf-tab (usa il repository pubblico) nella directory corretta
echo "🔧 Installing fzf-tab plugin..."
(git clone https://github.com/Aloxaf/fzf-tab.git \
  "$HOME/.zsh/plugins/fzf-tab-git") & spinner


# 5. Installa plugin zsh-syntax-highlighting
echo "🔧 Installing zsh-syntax-highlighting plugin..."
(git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
  "$HOME/.zsh/plugins/zsh-syntax-highlighting") & spinner

# 6. Installa plugin zsh-autosuggestions
echo "🔧 Installing zsh-autosuggestions plugin..."
(git clone https://github.com/zsh-users/zsh-autosuggestions \
  "$HOME/.zsh/plugins/zsh-autosuggestions") & spinner

# 7. Installa plugin fzf-tab (usa il repository pubblico)
echo "🔧 Installing fzf-tab plugin..."
(git clone https://github.com/Aloxaf/fzf-tab.git \
  "$HOME/.zsh/plugins/fzf-tab") & spinner

# 8. Copia il file back_broken scaricato in ~/.zshrc
echo "📄 Replacing ~/.zshrc with back_broken..."
cp "$SCRIPTS_DIR/back_broken" ~/.zshrc

echo "✅ Setup completato. Avvia una nuova sessione zsh o esegui 'zsh' ora."
