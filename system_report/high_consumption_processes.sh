#!/bin/bash

# === 🎨 Colori per migliorare l'estetica ===
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # Reset colore

# === 🧠 Introduzione ===
echo -e "${CYAN}📊 Monitoraggio delle risorse di sistema${NC}"
echo "Questo script mostra i processi che stanno consumando più CPU e memoria."
echo ""

# === 🔥 Processi con uso CPU più alto ===
echo -e "${YELLOW}🔥 Processi che consumano più CPU:${NC}"
echo -e "-----------------------------------"
ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%cpu | head -n 15

# === 💤 Pausa tra le due sezioni per migliorare leggibilità ===
sleep 1
echo ""

# === 💾 Processi con uso RAM più alto ===
echo -e "${YELLOW}💾 Processi che consumano più memoria (RAM):${NC}"
echo -e "-------------------------------------------"
ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%mem | head -n 15

# === ✅ Conclusione ===
echo ""
echo -e "${GREEN}✅ Analisi completata.${NC}"
echo "Puoi valutare se ci sono processi inutili da chiudere, ma fai sempre attenzione ai processi di sistema!"
