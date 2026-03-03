#!/bin/bash

# === 🎨 Colori ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# Gestione Ctrl+C
trap "echo -e '\n${RED}❌ Interrotto dall’utente.${RESET}'; kill $pid 2>/dev/null; exit 1" SIGINT

# === 🔁 Spinner ===
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'

    echo -n " "
    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    echo "    "

    # Reset trap dopo lo spinner
    trap - SIGINT
}

# === 🧠 Introduzione ===
echo -e "${CYAN}${BOLD} ╔══════════════════════════════════════════════════════╗"
echo -e "║       -  SCP Send - Powered by Fatt e cazz tuoj         ║"
echo -e " ╚══════════════════════════════════════════════════════╝${RESET}"
echo

# === 🧑‍💻 Utente locale ===
CURRENT_USER=$(whoami)

# === 🔍 Verifica fzf ===
USE_FZF=false   
if ! command -v fzf >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  fzf non è installato. Vuoi installarlo per abilitare la selezione interattiva? (s/n)${RESET}"
    read INSTALL_FZF 
    if [[ "$INSTALL_FZF" =~ ^[Ss]$ ]]; then
        echo -e "${CYAN}🔧 Installazione fzf...${RESET}"
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo apt update && sudo apt install fzf -y
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            brew install fzf
        fi
    fi
fi

# Verifica post-installazione
if command -v fzf >/dev/null 2>&1; then
    USE_FZF=true
fi

# === 🔒 Mostrare file nascosti? ===
SHOW_HIDDEN=false
if $USE_FZF; then
    echo -ne "${YELLOW}🔍 Vuoi includere i file e le cartelle nascoste (es. .git, .env)? (s/n):${RESET} "
    read INCLUDE_HIDDEN
    if [[ "$INCLUDE_HIDDEN" =~ ^[Ss]$ ]]; then
        SHOW_HIDDEN=true
    fi
fi

# === 📁 Scelta file/cartella ===
while true; do
    if $USE_FZF; then
        echo -e "${YELLOW}📂 Seleziona il file o la cartella da inviare (usa le frecce):${RESET}"
        
        if $SHOW_HIDDEN; then
            FIND_CMD="find . -maxdepth 1 ! -name '.'"
        else
            FIND_CMD="find . -maxdepth 1 ! -name '.' ! -name '.*'"
        fi

        LOCAL_PATH=$(eval "$FIND_CMD -exec basename {} \;" | fzf --height=20 --border  \
            --color=fg:#0ead09,bg:#121212,hl:#5f87af  \
            --color=fg+:#eb26c4,bg+:#5c00e6,hl+:#5fd7ff  \
            --color=fg:#0ead09,bg:#102847,hl:#5f87af \
            --prompt="Seleziona: ")
        
        if [[ $? -ne 0 || -z "$LOCAL_PATH" ]]; then
            echo -e "\n${RED}❌ Operazione annullata dall’utente.${RESET}"
            exit 1
        fi
    else
        echo -ne "${YELLOW}📂 Inserisci il percorso del file o cartella da inviare:${RESET} "
        read LOCAL_PATH
    fi

    if [[ -n "$LOCAL_PATH" && -e "$LOCAL_PATH" ]]; then
        break
    else
        echo -e "${RED}❌ Percorso non valido. Riprova.${RESET}"
    fi
done

# === 👤 Utente remoto ===
echo -ne "${YELLOW}👤 Inserisci il nome utente remoto (default: ${CURRENT_USER}):${RESET} "
read REMOTE_USER
REMOTE_USER=${REMOTE_USER:-$CURRENT_USER}

# === 🌍 Indirizzo ===
while true; do
    echo -ne "${YELLOW}🌍 Inserisci l'indirizzo IP o hostname remoto:${RESET} "
    read REMOTE_HOST
    if [[ -n "$REMOTE_HOST" ]]; then
        break
    else
        echo -e "${RED}❌ Devi inserire un indirizzo valido.${RESET}"
    fi
done

# === 📥 Path remoto ===
echo -e "${CYAN}📍 Di default il file sarà salvato nella home remota (~).${RESET}"
echo -ne "${YELLOW}✅ Va bene? (s/n):${RESET} "
read CONFIRM_PATH

if [[ "$CONFIRM_PATH" =~ ^[Nn]$ ]]; then
    while true; do
        echo -ne "${YELLOW}📂 Inserisci il percorso remoto completo:${RESET} "
        read REMOTE_PATH
        if [[ -n "$REMOTE_PATH" ]]; then
            break
        else
            echo -e "${RED}❌ Percorso non valido.${RESET}"
        fi
    done
else
    REMOTE_PATH="/home/${REMOTE_USER}"
fi

# === 🚀 Avvio ===
FULL_DEST="${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}"
SCP_CMD="scp"
[[ -d "$LOCAL_PATH" ]] && SCP_CMD+=" -r"

echo -e "${GREEN}🚀 Avvio trasferimento verso ${BOLD}${FULL_DEST}${RESET}"
echo

$SCP_CMD "$LOCAL_PATH" "$FULL_DEST" &
PID=$!
spinner $PID
wait $PID
EXIT_CODE=$?

# === ✅ Fine ===
if [[ $EXIT_CODE -eq 0 ]]; then
    echo -e "${GREEN}✅ Trasferimento completato con successo!${RESET}"
else
    echo -e "${RED}❌ Errore durante il trasferimento. Codice: $EXIT_CODE${RESET}"
fi
