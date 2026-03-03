#!/bin/bash

echo "=========================================="
echo "Script per spegnere un computer remoto via SSH"
echo "Assicurati che:"
echo " - Il computer remoto sia raggiungibile"
echo " - SSH sia abilitato e configurato"
echo " - L'utente remoto abbia i permessi per spegnere"
echo "=========================================="

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

echo "Sistema operativo rilevato: $OS_TYPE"
echo "Package manager rilevato: $PACKAGE_MANAGER"

# Verifica se ssh è installato
if ! command -v ssh &> /dev/null
then
    echo ""
    echo "Errore: il comando 'ssh' non è installato."
    read -rp "Vuoi installarlo ora? (y/n): " risposta

    if [[ "$risposta" =~ ^[Yy]$ ]]; then
        case "$PACKAGE_MANAGER" in
            apt)
                echo "Aggiorno i pacchetti e installo openssh-client con apt..."
                sudo apt update && sudo apt install -y openssh-client
                ;;
            dnf)
                echo "Installo openssh-clients con dnf..."
                sudo dnf install -y openssh-clients
                ;;
            yum)
                echo "Installo openssh-clients con yum..."
                sudo yum install -y openssh-clients
                ;;
            pacman)
                echo "Installo openssh con pacman..."
                sudo pacman -Sy --noconfirm openssh
                ;;
            apk)
                echo "Installo openssh con apk..."
                sudo apk add openssh-client
                ;;
            brew)
                echo "Installo openssh con brew..."
                brew install openssh
                ;;
            *)
                echo "Non è stato possibile rilevare un package manager supportato."
                echo "Installa manualmente il pacchetto 'openssh-client' e rilancia lo script."
                exit 1
                ;;
        esac

        # Verifica l'installazione
        if ! command -v ssh &> /dev/null; then
            echo "Installazione fallita o ssh ancora non disponibile."
            exit 1
        fi
    else
        echo "Installazione annullata dall'utente."
        exit 1
    fi
fi

# Configura utente remoto e host
REMOTE_USER="computer"  # <-- sostituisci con il nome utente remoto corretto
REMOTE_HOST="192.168.1.50"

echo "Sto tentando di spegnere il computer remoto ${REMOTE_USER}@${REMOTE_HOST}..."

# Esegue il comando di spegnimento remoto
ssh ${REMOTE_USER}@${REMOTE_HOST} "shutdown /s /t 0"

if [ $? -eq 0 ]; then
    echo "Comando di spegnimento inviato con successo."
else
    echo "Errore durante l'invio del comando di spegnimento."
fi
