#!/bin/bash

# Colori per animazione
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Funzione barra di caricamento colorata
# Barra di caricamento testuale senza float
# Barra di caricamento testuale senza float
loading_bar() {
  local duration=$1  # deve essere un intero!
  echo -n "Caricamento: ["
  for ((i=0; i<duration; i++)); do
    local color=$((31 + i % 6))
    echo -ne "\e[${color}m#\e[0m"
    sleep 0.1
  done
  echo "]"
}



# Detect distro e package manager
detect_distro() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
      arch)
        PKG_INSTALL="sudo pacman -S --noconfirm"
        ;;
      ubuntu|debian)
        PKG_INSTALL="sudo apt-get install -y"
        ;;
      *)
        PKG_INSTALL=""
        ;;
    esac
  else
    PKG_INSTALL=""
  fi
}

# Check comando, installa se mancante
check_command() {
  local cmd=$1
  local pkg=$2
  if ! command -v $cmd &>/dev/null; then
    read -p "${YELLOW}Il comando '$cmd' non è installato. Vuoi installarlo ora? (s/n): ${NC}" ans
    if [[ "$ans" =~ ^[Ss]$ ]] && [ -n "$PKG_INSTALL" ]; then
      echo "${YELLOW}Installazione di $cmd in corso...${NC}"
      $PKG_INSTALL $pkg
      if [ $? -ne 0 ]; then
        echo "${RED}Errore durante installazione di $cmd. Continua senza.$NC"
      fi
    else
      echo "${YELLOW}Salto installazione di $cmd.${NC}"
    fi
  fi
}

# Ottieni nome canzone random da iTunes API
get_random_song() {
  if command -v curl &>/dev/null && command -v jq &>/dev/null && command -v shuf &>/dev/null; then
    SONG=$(curl -s "https://itunes.apple.com/search?term=rock&limit=50" | jq -r '.results[].trackName' | shuf -n1)
    # Pulizia nome file
    SAFE_SONG=$(echo "$SONG" | tr ' ' '_' | tr -cd '[:alnum:]_')
    if [ -z "$SAFE_SONG" ]; then
      SAFE_SONG=$(date +'%Y%m%d_%H%M%S')
    fi
  else
    SAFE_SONG=$(date +'%Y%m%d_%H%M%S')
  fi
  echo "$SAFE_SONG"
}

# MAIN

echo "==============================="
echo "      GENERATORE REPORT        "
echo "==============================="
echo ""

detect_distro

# Controllo comandi richiesti (usiamo comandi validi per Arch/Debian)
# mpstat e sar spesso non sono su Arch per default, userò alternative

check_command "smartctl" "smartmontools"
check_command "curl" "curl"
check_command "jq" "jq"
check_command "shuf" "coreutils"

echo ""

# Nome file report
SONG_NAME=$(get_random_song)
REPORT_FILE="system_report_${SONG_NAME}.txt"

echo "Generazione report di sistema in corso..."
loading_bar 3
echo "Report salvato in: $REPORT_FILE"
echo ""

# Inizio report
{
  echo "===== REPORT SISTEMA - $(date) ====="
  echo ""

  # CPU info
  echo ">>> CPU INFO"
  echo "Modello CPU:"
  lscpu | grep 'Model name'
  echo ""
  echo "Numero di CPU logiche:"
  lscpu | grep '^CPU(s):'
  echo ""
  echo "Utilizzo CPU (media 5s via top):"
  # alternativa a mpstat (che su Arch non sempre c'è)
  top -bn2 | grep "Cpu(s)" | tail -n1
  echo ""

  # Memoria
  echo ">>> MEMORIA"
  free -h
  echo ""

  # Disco
  echo ">>> DISCO"
  df -h --total
  echo ""

  # Info dischi SMART (se smartctl è installato)
if command -v smartctl &> /dev/null; then
  echo "Controllo accesso sudo per smartctl..."
  if sudo -n true 2>/dev/null; then
    echo "Accesso sudo OK. Eseguo controllo SMART..." >> "$REPORT_FILE"
    for disk in $(lsblk -dno NAME | grep -E '^(sd|nvme|hd)'); do
      echo "SMART check /dev/$disk:" >> "$REPORT_FILE"
      sudo smartctl -H /dev/$disk | grep "SMART overall-health" >> "$REPORT_FILE"
      echo "" >> "$REPORT_FILE"
    done
  else
    echo "Permessi sudo non disponibili o password errata. Salto controllo SMART." >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
  fi
else
  echo "smartctl non installato, salto controllo SMART" >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
fi


  # Rete
  echo ">>> RETE"
  echo "Interfacce di rete e IP:"
  ip -brief addr show
  echo ""
  echo "Statistiche rete (snapshot):"
  # sar potrebbe non esserci, usiamo ip -s link come alternativa
  ip -s link | grep -E '^[0-9]+:|RX:|TX:' -A 5
  echo ""

  # Top process per CPU e memoria
  echo ">>> TOP PROCESS (CPU)"
  ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 10
  echo ""
  echo ">>> TOP PROCESS (MEMORIA)"
  ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 10
  echo ""

} > "$REPORT_FILE"

echo -e "${GREEN}Report creato con successo! 🥳${NC}"
