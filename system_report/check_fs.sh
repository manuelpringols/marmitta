#!/bin/bash

# === 🎨 Colori ===
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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
    trap - SIGINT
}

# === 📁 Directory da analizzare ===
DIRS_TO_CHECK=(
    "/var/log"
    "/var/tmp"
    "/tmp"
    "/var/cache"
    "/home"
    "/root"
    "/var/lib"
)

echo -e "${CYAN}📦 Inizio analisi dei file più pesanti nelle directory predefinite...${NC}"

for DIR in "${DIRS_TO_CHECK[@]}"; do
    if [ -d "$DIR" ]; then
        echo -e "\n🔍 ${YELLOW}Analisi in:${NC} $DIR"

        {
            find "$DIR" -type f -size +100M -exec du -h {} + 2>/dev/null | sort -hr | head -n 20
        } &

        pid=$!
        spinner $pid

    else
        echo -e "⚠️  ${RED}La directory $DIR non esiste, salto...${NC}"
    fi
done

echo -e "\n${GREEN}✅ Analisi completata.${NC} Valuta se puoi rimuovere qualche file per liberare spazio."
