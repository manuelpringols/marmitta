#!/bin/bash

# Codici colore
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
RESET="\033[0m"

echo -e "${CYAN}=========================================${RESET}"
echo -e "${CYAN}Script per inviare un pacchetto Wake-on-LAN${RESET}"
echo -e "${CYAN}Questo comando serve a risvegliare un dispositivo sulla rete locale${RESET}"
echo -e "${CYAN}utilizzando il suo MAC address.${RESET}"
echo -e "${CYAN}-----------------------------------------${RESET}"

# Rilevazione sistema operativo e package manager
OS_TYPE="unknown"
PACKAGE_MANAGER="unknown"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS_TYPE="Linux"

    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    else
        DISTRO="unknown"
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
else
    OS_TYPE="unknown"
    PACKAGE_MANAGER="unknown"
fi

echo -e "${YELLOW}Sistema operativo rilevato: ${GREEN}$OS_TYPE${RESET}"
echo -e "${YELLOW}Package manager rilevato: ${GREEN}$PACKAGE_MANAGER${RESET}"

# Controlla se wakeonlan è installato
if ! command -v wakeonlan &> /dev/null
then
    echo ""
    echo -e "${RED}Errore: il comando 'wakeonlan' non è installato.${RESET}"
    read -rp "Vuoi installarlo ora? (y/n): " risposta

    if [[ "$risposta" =~ ^[Yy]$ ]]; then
        case "$PACKAGE_MANAGER" in
            apt)
                echo -e "${CYAN}Aggiorno i pacchetti e installo wakeonlan con apt...${RESET}"
                sudo apt update && sudo apt install -y wakeonlan
                ;;
            dnf)
                echo -e "${CYAN}Installo wakeonlan con dnf...${RESET}"
                sudo dnf install -y wakeonlan
                ;;
            yum)
                echo -e "${CYAN}Installo wakeonlan con yum...${RESET}"
                sudo yum install -y wakeonlan
                ;;
            pacman)
                echo -e "${CYAN}Installo wakeonlan con pacman...${RESET}"
                sudo pacman -Sy --noconfirm wakeonlan
                ;;
            apk)
                echo -e "${CYAN}Installo wakeonlan con apk...${RESET}"
                sudo apk add wakeonlan
                ;;
            brew)
                echo -e "${CYAN}Installo wakeonlan con brew...${RESET}"
                brew install wakeonlan
                ;;
            *)
                echo -e "${RED}Non è stato possibile rilevare un package manager supportato.${RESET}"
                echo "Installa manualmente il pacchetto 'wakeonlan' e rilancia lo script."
                exit 1
                ;;
        esac

        # Verifica l'installazione
        if ! command -v wakeonlan &> /dev/null; then
            echo -e "${RED}Installazione fallita o wakeonlan ancora non disponibile.${RESET}"
            exit 1
        fi
    else
        echo -e "${RED}Installazione annullata dall'utente.${RESET}"
        exit 1
    fi
fi

# Indirizzo MAC del dispositivo da risvegliare
MAC_ADDRESS="b0:41:6f:0f:d6:39"

# Invia il pacchetto Wake-on-LAN sulla broadcast della rete locale
echo -e "${YELLOW}Invio pacchetto Wake-on-LAN a ${GREEN}$MAC_ADDRESS${YELLOW} sulla broadcast 192.168.1.255...${RESET}"
wakeonlan -i 192.168.1.255 $MAC_ADDRESS

echo ""
echo -e "${GREEN}Pacchetto Wake-on-LAN inviato a $MAC_ADDRESS${RESET}"
echo -e "${CYAN}=========================================${RESET}"
