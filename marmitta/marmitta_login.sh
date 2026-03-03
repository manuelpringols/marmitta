#!/bin/bash
set -e

print_yellow() { echo -e "\e[33m$1\e[0m"; }
print_green()  { echo -e "\e[32m$1\e[0m"; }
print_red()    { echo -e "\e[31m$1\e[0m"; }

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
            ubuntu|debian) PACKAGE_MANAGER="apt" ;;
            fedora)        PACKAGE_MANAGER="dnf" ;;
            centos|rhel)   PACKAGE_MANAGER="yum" ;;
            arch)          PACKAGE_MANAGER="pacman" ;;
            alpine)        PACKAGE_MANAGER="apk" ;;
            *)             PACKAGE_MANAGER="unknown" ;;
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

    echo "$OS_TYPE" "$DISTRO" "$PACKAGE_MANAGER"
}

install_bw() {
    if command -v bw &>/dev/null; then
        print_green "✅ Bitwarden CLI già installato."
        return
    fi

    print_yellow "➡️ Bitwarden CLI non trovato, provo a installarlo..."

    read -r OS DISTRO PKG_MANAGER <<< "$(detect_os_and_package_manager)"
    echo "Rilevato OS: $OS, Distro: $DISTRO, Package manager: $PKG_MANAGER"

    case "$PKG_MANAGER" in
        apt)    sudo apt update && sudo apt install -y bw ;;
        dnf)    sudo dnf install -y bw ;;
        yum)    sudo yum install -y bw ;;
        pacman) sudo pacman -Sy --noconfirm bitwarden-cli ;;
        apk)    sudo apk add bw ;;
        brew)   brew install bitwarden-cli ;;
        choco)  choco install bitwarden-cli -y ;;
        *)
            print_red "❌ Package manager non riconosciuto. Installa Bitwarden CLI manualmente da https://bitwarden.com/download/"
            return 1
            ;;
    esac

    print_green "✅ Bitwarden CLI installato con successo."
}

bw_login_and_unlock() {
    print_yellow "➡️ Verifica login su Bitwarden CLI..."

    if bw login --check &>/dev/null; then
        print_green "✅ Sei già loggato, sessione attiva."

        # Sblocca vault se bloccato
        UNLOCK_OUTPUT=$(bw unlock --raw --session "$BW_SESSION" 2>/dev/null || true)
        if [ -z "$UNLOCK_OUTPUT" ]; then
            print_yellow "🔓 Vault bloccato, inserisci la master password per sbloccare..."
            UNLOCK_OUTPUT=$(bw unlock --raw)
        fi
    else
        print_yellow "🔄 Non sei loggato, eseguo logout (se necessario) e login..."

        # Logout preventivo per evitare errori di cambio server
        bw logout || true

        # Configura server
        bw config server https://vault.bitwarden.eu

        # Esegui login
        UNLOCK_OUTPUT=$(bw login --raw)
        if [ $? -ne 0 ] || [ -z "$UNLOCK_OUTPUT" ]; then
            print_red "❌ Login fallito. Controlla email e password."
            return 1
        fi

        export BW_SESSION="$UNLOCK_OUTPUT"

        # Sblocca vault
        print_yellow "🔓 Sblocco del vault Bitwarden..."
        UNLOCK_OUTPUT=$(bw unlock --raw)
    fi

    if [ -z "$UNLOCK_OUTPUT" ]; then
        print_red "❌ Errore: impossibile sbloccare Bitwarden."
        return 1
    fi

    export BW_SESSION="$UNLOCK_OUTPUT"
    print_green "✅ Vault Bitwarden sbloccato, BW_SESSION impostato."
}


retrieve_github_token() {
    print_yellow "🔍 Recupero del GitHub token da Bitwarden..."
    local token_json
    token_json=$(bw get item "github-token" --session "$BW_SESSION" 2>/dev/null) || {
        print_red "❌ Impossibile recuperare il token da Bitwarden."
        return 1
    }

    # Assumendo che il token sia nella proprietà .notes
    GITHUB_TOKEN=$(echo "$token_json" | jq -r '.notes') || {
        print_red "❌ Errore parsing token GitHub."
        return 1
    }

    if [ -z "$GITHUB_TOKEN" ] || [ "$GITHUB_TOKEN" = "null" ]; then
        print_red "❌ Token GitHub vuoto o non trovato."
        return 1
    fi

    export GITHUB_TOKEN
    print_green "✅ GitHub token recuperato e impostato come variabile d'ambiente."
}

update_shell_rc_with_token() {
    local shell_rc_file

    if [[ $SHELL == */zsh ]]; then
        shell_rc_file="$HOME/.zshrc"
    elif [[ $SHELL == */bash ]]; then
        shell_rc_file="$HOME/.bashrc"
    else
        print_red "❌ Shell non riconosciuta, modifica manuale necessaria."
        return 1
    fi

    if grep -q "^export GITHUB_TOKEN=" "$shell_rc_file"; then
        sed -i.bak "s|^export GITHUB_TOKEN=.*|export GITHUB_TOKEN=\"$GITHUB_TOKEN\"|" "$shell_rc_file"
    else
        echo "export GITHUB_TOKEN=\"$GITHUB_TOKEN\"" >> "$shell_rc_file"
    fi

    print_green "✅ Variabile GITHUB_TOKEN aggiornata in $shell_rc_file"
}


### MAIN

install_bw 
bw_login_and_unlock
retrieve_github_token 
update_shell_rc_with_token 

print_yellow "⚠️ Ora esegui 'source ~/.zshrc' o apri una nuova shell per caricare il token."
