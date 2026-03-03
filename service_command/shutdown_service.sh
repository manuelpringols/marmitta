#!/bin/bash

# Colori
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
CYAN='\e[36m'
NC='\e[0m'

echo -ne "${CYAN}🔍 Inserisci il nome del processo da cercare: ${NC}"
read nome_proc

# Ottieni lista PID e comandi
process_list=$(ps -e -o pid= -o comm= | grep -i "$nome_proc" | awk '{printf "%s | %s\n", $1, $2}')

# Se nessun processo trovato
if [ -z "$process_list" ]; then
  echo -e "${RED}❌ Nessun processo trovato con nome '$nome_proc'.${NC}"
  exit 1
fi

# Estrai solo i PID (per kill tutti o riavvia)
pids_all=($(echo "$process_list" | awk -F'|' '{print $1}' | xargs))

# Mostra i PID trovati
echo -e "${GREEN}✅ Processi trovati:${NC}"
for pid in "${pids_all[@]}"; do
  pname=$(ps -p "$pid" -o comm=)
  echo -e "  🟢 ${CYAN}PID $pid${NC} → $pname"
done

echo ""
echo -e "${CYAN}Cosa vuoi fare con questi processi?${NC}"
echo -e "  [k] 🔴 Kill TUTTI"
echo -e "  [o] 🟡 Kill UNO specifico"
echo -e "  [r] 🔄 Riavvia (kill + restart)"
echo -e "  [c] ❌ Annulla"

# Prompt scelta
read -rp $'\e[36m👉 Lettera della tua scelta: \e[0m' scelta

case "$scelta" in
  k|K)
    echo -e "${RED}💀 Uccisione di tutti i processi...${NC}"
    for pid in "${pids_all[@]}"; do
      kill "$pid" && echo "✅ Killed PID $pid"
    done
    ;;
  o|O)
    echo -e "${YELLOW}📌 Seleziona un processo da terminare:${NC}"
    selected=$(echo "$process_list" | fzf --prompt="🧠 Seleziona PID: " --header="PID | Comando")

    if [ -z "$selected" ]; then
      echo -e "${YELLOW}⚠️ Nessun processo selezionato. Annullato.${NC}"
      exit 0
    fi

    pid_single=$(echo "$selected" | awk -F'|' '{print $1}' | xargs)
    pname=$(ps -p "$pid_single" -o comm=)

    kill "$pid_single" && echo -e "${GREEN}✅ PID $pid_single ($pname) terminato.${NC}"
    ;;
  r|R)
    echo -e "${YELLOW}🔄 Riavvio dei processi...${NC}"
    for pid in "${pids_all[@]}"; do
      cmd=$(ps -p "$pid" -o args=)
      pname=$(ps -p "$pid" -o comm=)
      kill "$pid" && echo "✅ Killed PID $pid ($pname)"
      eval "$cmd &" && echo "🚀 Restarted: $cmd"
    done
    ;;
  c|C)
    echo -e "${CYAN}❌ Operazione annullata.${NC}"
    ;;
  *)
    echo -e "${RED}❌ Scelta non valida. Uscita.${NC}"
    ;;
esac
