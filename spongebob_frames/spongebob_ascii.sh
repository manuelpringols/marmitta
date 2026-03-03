#!/bin/bash

# Colori ANSI
RED="\033[0;31m"
GREEN="\033[0;32m"
CYAN="\033[0;36m"
YELLOW="\033[1;33m"
RESET="\033[0m"


# Se viene richiesto --help
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  echo -e "${CYAN}SpongeBob ASCII Tool${RESET} – by You ✨"
  echo -e ""
  echo -e "${YELLOW}Uso:${RESET} ./script.sh [opzioni]"
  echo -e ""
  echo -e "${GREEN}  -m${RESET}         Modalità video: chiede un file video e lo converte in frame PNG in ~/frames"
  echo -e "${GREEN}  -d${RESET}         Scarica i frame predefiniti da GitHub nella cartella ~/frames"
  echo -e "${GREEN}  --help, -h${RESET}  Mostra questo messaggio di aiuto"
  echo -e ""
  echo -e "${CYAN}⚠️  Dopo averlo configurato, puoi eseguire l'animazione con il comando:${RESET} ${YELLOW}spongebob${RESET}"
  echo -e ""
  exit 0
fi


# === GESTIONE ARGOMENTO -d PER SCARICARE I FRAME DA GITHUB ===
if [[ "$1" == "-d" ]]; then
  if [[ -d ~/frames ]]; then
    echo -e "${YELLOW}📁 La cartella ~/frames esiste già. I file verranno salvati lì.${RESET}"
  else
    mkdir ~/frames
    echo -e "${GREEN}📁 Cartella ~/frames creata con successo.${RESET}"
  fi

  echo -e "${CYAN}🌐 Download dei frame da GitHub in corso...${RESET}"
  base_url="https://raw.githubusercontent.com/manuelpringols/scripts/master/spongebob_frames/frames"

  # Tentiamo di scaricare un numero massimo noto, ma controlliamo prima se il file esiste

  for i in $(seq -f "%04g" 1 30); do
  file="dump_$i.png"
  url="$base_url/$file"

  # Controlla se il file esiste su GitHub prima di scaricare
  if curl --silent --head --fail "$url" > /dev/null; then
    echo -e "${YELLOW}⬇️  Scaricando: $file${RESET}"
    wget -q --show-progress -O "$HOME/frames/$file" "$url"
  else
    echo -e "${RED}❌ $file non trovato su GitHub, fermo il download.${RESET}"
    break
  fi
done

echo -e "${GREEN}✅ Download completato. Controlla i frame in ~/frames${RESET}"
exit 0
fi



# === GESTIONE ARGOMENTO -m PER ESTRARRE FRAME DA VIDEO ===
if [[ "$1" == "-m" ]]; then
  mkdir -p ~/frames

  if [[ -n "$2" ]]; then
    video_input="$2"
  else
    echo -e "${YELLOW}🎞️  Modalità video attivata. Inserisci il percorso del file video da scomporre in frame:${RESET}"
    read -r -p "📁 Percorso del video (.webp, .mp4, ecc.): " video_input
  fi

  if [[ ! -f "$video_input" ]]; then
    echo -e "${RED}❌ Il file non esiste: '$video_input'${RESET}"
    exit 1
  fi

  echo -e "${CYAN}📤 Estrazione dei frame in ~/frames/dump%03d.png...${RESET}"
ffmpeg -i "$video_input" -vf "fps=5" -q:v 1 ~/frames/dump_%04d.png

  if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}✅ Frame estratti con successo in ~/frames${RESET}"
  else
    echo -e "${RED}❌ Errore durante l'estrazione dei frame.${RESET}"
    exit 1
  fi
  exit 0
fi


# === VERIFICA PRESENZA CHAFA ===
if ! command -v chafa &> /dev/null; then
  echo -e "${YELLOW}⚠️  'chafa' non è installato.${RESET}"

  read -r -p "🔧 Vuoi installarlo automaticamente? [y/N]: " install_chafa
  if [[ "$install_chafa" =~ ^[Yy]$ ]]; then
    if command -v apt &> /dev/null; then
      sudo apt update && sudo apt install -y chafa
    elif command -v pacman &> /dev/null; then
      sudo pacman -Sy chafa
    elif command -v dnf &> /dev/null; then
      sudo dnf install -y chafa
    elif command -v brew &> /dev/null; then
      brew install chafa
    else
      echo -e "${RED}❌ Impossibile determinare il package manager. Installa 'chafa' manualmente.${RESET}"
      exit 1
    fi
  else
    echo -e "${RED}❌ 'chafa' è richiesto per eseguire l'animazione. Uscita.${RESET}"
    exit 1
  fi
fi

# Directory target per la funzione
mkdir -p ~/frames

# Scrivi la funzione nel file spongebob_ascii.sh
cat > ~/frames/spongebob_ascii.sh << 'EOF'
  for f in ~/frames/dump*.png; do
  echo -en "\033[H"
  chafa --size=56x24 --symbols=ascii --fill=none "$f"
done
EOF

echo -e "${GREEN}✅ Funzione 'spongebob_ascii.sh salvata in ~/frames/spongebob_ascii.sh${RESET}"

# Chiedi se vuoi aggiungere l'import in bashrc o zshrc
echo -e "\n${YELLOW}Vuoi rendere la funzione disponibile automaticamente aggiungendola al tuo .bashrc o .zshrc?${RESET}"
read -r -p "Scrivi 'bash', 'zsh' oppure premi Invio per saltare: " shell_choice

if [[ "$shell_choice" == "bash" ]]; then
  if ! grep -q " ~/frames/spongebob_ascii.sh" ~/.bashrc; then
    echo -e "\n# SpongeBob ASCII function\nsource ~/frames/spongebob_ascii.sh" >> ~/.bashrc
    echo -e "${GREEN}✅ Funzione aggiunta a ~/.bashrc. Esegui 'source ~/.bashrc' per attivarla subito.${RESET}"
  else
    echo -e "${CYAN}ℹ️ Era già presente in ~/.bashrc.${RESET}"
  fi
elif [[ "$shell_choice" == "zsh" ]]; then
  if ! grep -q " ~/frames/spongebob_ascii.sh" ~/.zshrc; then
    echo -e "\n# SpongeBob ASCII function\nsource ~/frames/spongebob_ascii.sh" >> ~/.zshrc
    echo -e "${GREEN}✅ Funzione aggiunta a ~/.zshrc. Esegui 'source ~/.zshrc' per attivarla subito.${RESET}"
  else
    echo -e "${CYAN}ℹ️ Era già presente in ~/.zshrc.${RESET}"
  fi
else
  echo -e "${RED}❌ Nessuna modifica ai file di configurazione. Puoi usare 'source ~/frames/spongebob_ascii.sh' manualmente.${RESET}"
fi

# Messaggio finale
echo -e "\n${CYAN}ℹ️ Ora puoi eseguire l'animazione semplicemente avviando shel:${RESET} ${YELLOW}bash/zsh${RESET}"
