#!/bin/bash

# Colori per testo (foreground)
GREEN="\e[1;32m"
CYAN="\e[1;36m"
YELLOW="\e[1;33m"
RED="\e[1;31m"
RESET="\e[0m"
MAGENTA="\e[1;35m"

loading_bar() {
  local duration=$1
  echo -n -e "\n🚀  Caricamento: ["
  for ((i=0; i<duration; i++)); do
    local color=$((31 + i % 6))
    echo -ne "\e[48;5;${color}m \e[0m"
    sleep 0.1
  done
  echo -e "]\n"
}

# Detect distro e comando per installare pacchetti
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

# Funzione per ottenere il messaggio di commit interattivo
read_commit_msg() {
  if command -v rlwrap &>/dev/null; then
    commit_msg=$(rlwrap -p bash -c 'read -e -p "👉 Inserisci il messaggio di commit: " msg; echo "$msg"')
  else
    echo -e "${YELLOW}⚠️  Il comando ${MAGENTA}rlwrap${YELLOW} non è installato.${RESET}"
    detect_distro
    if [ -n "$PKG_INSTALL" ]; then
      read -p "Vuoi installare rlwrap con '$PKG_INSTALL rlwrap'? [y/N]: " answer
      case "$answer" in
        y|Y )
          echo -e "${CYAN}⏳ Installazione di rlwrap in corso...${RESET}"
          $PKG_INSTALL rlwrap
          if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ rlwrap installato correttamente.${RESET}"
            commit_msg=$(rlwrap -p bash -c 'read -e -p "👉 Inserisci il messaggio di commit: " msg; echo "$msg"')
          else
            echo -e "${RED}❌ Installazione fallita. Procedo con input standard.${RESET}"
            read -e -p "👉 Inserisci il messaggio di commit: " commit_msg
          fi
        ;;
        * )
          echo -e "${CYAN}ℹ️  Procedo con input standard senza rlwrap.${RESET}"
          read -e -p "👉 Inserisci il messaggio di commit: " commit_msg
        ;;
      esac
    else
      echo -e "${RED}❌ rlwrap non installabile automaticamente.${RESET}"
      read -e -p "👉 Inserisci il messaggio di commit: " commit_msg
    fi
  fi
}

# === LOGICA ===

# Se viene passato almeno un argomento, usalo come messaggio
if [ $# -gt 0 ]; then
  commit_msg="$*"
else
  read_commit_msg
fi

# Controlla se è ancora vuoto
if [ -z "$commit_msg" ]; then
  echo -e "${RED}❌ Errore: messaggio di commit vuoto. Uscita.${RESET}"
  exit 1
fi

echo -e "\n${YELLOW}📝 Aggiungo tutti i file modificati...${RESET}"
git add .

echo -e "${YELLOW}💾 Commit in corso con il messaggio:${RESET} \"${GREEN}$commit_msg${RESET}\""
git commit -m "$commit_msg"
if [ $? -ne 0 ]; then
  echo -e "${RED}❌ Commit fallito. Uscita.${RESET}"
  exit 1
fi

echo -e "${CYAN}🌐 Invio delle modifiche al repository remoto...${RESET}"
loading_bar 15

git push origin master
if [ $? -ne 0 ]; then
  echo -e "${RED}❌ Push fallito. Controlla la connessione o i permessi.${RESET}"
  exit 1
fi

echo -e "\n${GREEN}🎉 Operazione completata con successo!${RESET}\n"
