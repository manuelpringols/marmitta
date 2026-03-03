#!/bin/bash

# === Colori ANSI ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${CYAN}==============================="
echo -e "🔧 ${BOLD}Inizializzazione VPN Script${RESET}${CYAN}"
echo -e "===============================${RESET}"

# === Funzione per rilevare OS e Package Manager ===
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

    echo -e "${BOLD}Sistema Operativo:${RESET} $OS_TYPE"
    echo -e "${BOLD}Distribuzione:${RESET} $DISTRO"
    echo -e "${BOLD}Package Manager:${RESET} $PACKAGE_MANAGER"
}

# === Controlla se WireGuard è installato ===
check_wireguard_installed() {
    if command -v wg &>/dev/null || command -v wg-quick &>/dev/null; then
        echo -e "✅ ${GREEN}WireGuard è già installato.${RESET}"
        return 0
    else
        echo -e "⚠️  ${YELLOW}WireGuard non è installato.${RESET}"
        return 1
    fi
}

# === Installa WireGuard ===
install_wireguard() {
    case "$PACKAGE_MANAGER" in
        apt)
            sudo apt update && sudo apt install -y wireguard ;;
        dnf)
            sudo dnf install -y wireguard-tools ;;
        yum)
            sudo yum install -y wireguard-tools ;;
        pacman)
            sudo pacman -Sy --noconfirm wireguard-tools ;;
        apk)
            sudo apk add wireguard-tools ;;
        brew)
            brew install wireguard-tools ;;
        choco)
            choco install wireguard ;;
        *)
            echo -e "${RED}❌ Package manager non supportato. Installa manualmente WireGuard.${RESET}"
            exit 1
            ;;
    esac
}

# === MAIN SCRIPT START ===
detect_os_and_package_manager

# Controllo WireGuard
if ! check_wireguard_installed; then
    read -rp "❓ Vuoi installare WireGuard ora? (y/n): " install_choice
    if [[ "$install_choice" =~ ^[Yy]$ ]]; then
        install_wireguard || {
            echo -e "${RED}❌ Installazione fallita. Esci.${RESET}"
            exit 1
        }
    else
        echo -e "${RED}❌ WireGuard è richiesto. Script interrotto.${RESET}"
        exit 1
    fi
fi

# Spostati nella directory dello script
cd "$(dirname "$0")" || {
    echo -e "${RED}❌ Impossibile accedere alla directory dello script.${RESET}"
    exit 1
}

# Step 1: Crea ambiente virtuale
echo -e "➡️  ${CYAN}Creazione ambiente virtuale (venv)...${RESET}"
python3 -m venv venv || {
    echo -e "${RED}❌ Errore nella creazione dell'ambiente virtuale.${RESET}"
    exit 1
}

# Step 2: Attiva ambiente
echo -e "➡️  ${CYAN}Attivazione dell'ambiente virtuale...${RESET}"
source venv/bin/activate || {
    echo -e "${RED}❌ Impossibile attivare l'ambiente virtuale.${RESET}"
    exit 1
}

# Step 3: Installa requirements
echo -e "➡️  ${CYAN}Installazione delle dipendenze...${RESET}"
pip install --upgrade pip
pip install -r requirements.txt || {
    echo -e "${RED}❌ Errore durante l'installazione delle dipendenze.${RESET}"
    deactivate
    exit 1
}

# Step 4: Verifica tkinter
echo -e "➡️  ${CYAN}Verifica della presenza del modulo tkinter...${RESET}"
python -c "import tkinter" 2>/dev/null
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}⚠️  Il modulo tkinter non è disponibile.${RESET}"
    echo -e "   Su Arch Linux puoi installarlo con:"
    echo -e "   👉 ${BOLD}sudo pacman -S tk${RESET}"
    echo -e "${RED}❌ Fermando lo script. Installa 'tk' e riprova.${RESET}"
    deactivate
    exit 1
else
    echo -e "${GREEN}✅ tkinter disponibile.${RESET}"
fi

# Step 5: Esecuzione dello script Python
echo -e "➡️  ${CYAN}Esecuzione dello script: ${BOLD}script_vpn.py${RESET}"
python script_vpn.py
