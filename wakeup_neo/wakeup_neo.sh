#!/bin/bash

# Funzione per rilevare OS e package manager
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
        PACKAGE_MANAGER="choco" # o winget, a seconda di cosa usi

    else
        OS_TYPE="unknown"
        PACKAGE_MANAGER="unknown"
    fi

    echo "OS: $OS_TYPE"
    echo "Distro: $DISTRO"
    echo "Package Manager: $PACKAGE_MANAGER"
}

# Controllo se un comando esiste
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Installa pacchetti necessari se non presenti
install_dependencies() {
    local packages_to_install=()

    # Controlla i pacchetti richiesti
    for pkg in pv lolcat cmatrix; do
        if ! command_exists "$pkg"; then
            packages_to_install+=("$pkg")
        fi
    done

    if [ ${#packages_to_install[@]} -eq 0 ]; then
        echo "Tutti i pacchetti necessari sono già installati."
        return
    fi

    echo "Pacchetti da installare: ${packages_to_install[*]}"

    case "$PACKAGE_MANAGER" in
        apt)
            sudo apt update
            sudo apt install -y "${packages_to_install[@]}"
            ;;
        dnf)
            sudo dnf install -y "${packages_to_install[@]}"
            ;;
        yum)
            sudo yum install -y "${packages_to_install[@]}"
            ;;
        pacman)
            sudo pacman -Sy --noconfirm "${packages_to_install[@]}"
            ;;
        apk)
            sudo apk add "${packages_to_install[@]}"
            ;;
        brew)
            brew install "${packages_to_install[@]}"
            ;;
        choco)
            choco install -y "${packages_to_install[@]}"
            ;;
        *)
            echo "Package manager non supportato: $PACKAGE_MANAGER"
            echo "Installa manualmente: ${packages_to_install[*]}"
            ;;
    esac
}

# Funzione da aggiungere a .zshrc
read -r -d '' matrix_func <<'EOF'
matrix_wake() {
  clear
  echo "Wake up, Neo..." | pv -qL 10 | lolcat
  sleep 2
  clear
  cmatrix -b -u 3 -C green -s
}
matrix_wake
EOF

# Main

detect_os_and_package_manager

install_dependencies

# Aggiunge la funzione se manca
if ! grep -q "matrix_wake()" ~/.zshrc; then
  echo -e "\n# Funzione matrix wake up\n$matrix_func" >> ~/.zshrc
  echo "Funzione 'matrix_wake' aggiunta a ~/.zshrc"
fi

# Aggiunge la chiamata esplicita a matrix_wake() in shell interattiva
if ! grep -q "matrix_wake()" ~/.zshrc; then
  echo -e "\n# Avvio matrix_wake() solo in shell interattiva\nif [[ \$- == *i* ]]; then\n  matrix_wake()\nfi" >> ~/.zshrc
  echo "Chiamata a 'matrix_wake()' aggiunta a ~/.zshrc (solo shell interattiva)"
fi

echo "Setup completato! Apri una nuova shell zsh per vedere il risultato."

