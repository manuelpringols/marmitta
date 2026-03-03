f#!/usr/bin/env bash

# ─── Messaggio Corato ────────────────────────────────────────────────

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " 🖥️  Benvenuto nel setup di Hyprland!"
echo " Creato con ❤️ per velocizzare il tuo flusso."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ─── Funzione per rilevare OS e package manager ──────────────────────

detect_os_and_package_manager() {
    OS_TYPE=""
    DISTRO=""
    PACKAGE_MANAGER=""

    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS_TYPE="Linux"

        if [ -f /etc/os-release ]; then
            . /etc/os-release
            DISTRO=$ID
        elif [ -f /etc/lsb-release ]; then
            . /etc/lsb-release
            DISTRO=$DISTRIB_ID
        fi

        case "$DISTRO" in
            ubuntu|debian)
                PACKAGE_MANAGER="apt"
                ;;
            fedora)
                PACKAGE_MANAGER="dnf"
                ;;
            centos|rhel)
                PACKAGE_MANAGER="yum"
                ;;
            arch)
                PACKAGE_MANAGER="pacman"
                ;;
            alpine)
                PACKAGE_MANAGER="apk"
                ;;
            *)
                PACKAGE_MANAGER="unknown"
                ;;
        esac

    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS_TYPE="macOS"
        PACKAGE_MANAGER="brew"

    elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" ]]; then
        OS_TYPE="Windows"
        PACKAGE_MANAGER="choco"

    else
        OS_TYPE="unknown"
        PACKAGE_MANAGER="unknown"
    fi

    echo "───────────────────────────────────────"
    echo " Sistema operativo: $OS_TYPE"
    echo " Distro: $DISTRO"
    echo " Package Manager: $PACKAGE_MANAGER"
    echo "───────────────────────────────────────"
}

# ─── Esegui rilevamento ──────────────────────────────────────────────

detect_os_and_package_manager

# ─── Verifica se il package manager è supportato ─────────────────────

if [ "$PACKAGE_MANAGER" == "unknown" ]; then
    echo "❌ Package manager non supportato. Esco."
    exit 1
fi

# ─── Chiedi se installare Hyprland ───────────────────────────────────

read -rp "Vuoi installare Hyprland con i pacchetti minimi necessari? (s/n): " choice

if [[ "$choice" == [sS] ]]; then
    echo "✅ Inizio installazione Hyprland..."

    case "$PACKAGE_MANAGER" in
        apt)
            sudo apt update
            sudo apt install -y hyprland wayland wlroots xwayland
            ;;
        pacman)
            sudo pacman -Sy --noconfirm  wlroots xorg-xwayland
            yay -S hyprland
            ;;
        dnf)
            sudo dnf install -y hyprland wlroots xorg-x11-server-Xwayland
            ;;
        yum)
            sudo yum install -y hyprland wlroots xorg-x11-server-Xwayland
            ;;
        apk)
            sudo apk add hyprland wlroots xwayland
            ;;
        brew)
            brew install hyprland
            ;;
        choco)
            choco install hyprland
            ;;
        *)
            echo "❌ Installazione automatica non supportata per questo package manager."
            exit 1
            ;;
    esac

    echo "🎉 Hyprland e pacchetti minimi installati."

    # ─── Scarica e lancia script di configurazione ─────────────────────

    echo "───────────────────────────────────────?"
    echo "✨ Avvio configurazione JaKooLit Hyprland Dots..."
    echo "✨ Repository Ufficiale JakooLit https://github.com/JaKooLit"
    echo ""
    sh <(curl -L https://raw.githubusercontent.com/JaKooLit/Hyprland-Dots/main/Distro-Hyprland.sh)

else
    echo "ℹ️ Installazione annullata. Esco."
fi
