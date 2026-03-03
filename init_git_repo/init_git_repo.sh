#!/bin/bash

# Colori per output
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
NC="\033[0m" # No Color

# Spinner function
spinner() {
  local pid=$1
  local delay=0.1
  local spinstr='|/-\'
  while kill -0 $pid 2>/dev/null; do
    for i in $(seq 0 3); do
      printf "\r${CYAN}⏳ ${spinstr:i:1} Attendi...${NC}"
      sleep $delay
    done
  done
  printf "\r${GREEN}✔ Fatto!           ${NC}\n"
}

echo -e "${CYAN}--- Script completo: crea repo GitHub + aggiungi chiave SSH + inizializza git ---${NC}"
echo -e "Questo script:\n - crea il repo GitHub\n - aggiunge la tua chiave SSH pubblica a GitHub\n - inizializza una repo git locale\n - aggiunge la remote git@github.com:manuelpringols/<repo>.git\n"

if [ -z "$1" ]; then
  echo -e "${RED}❌ Errore: devi passare come argomento solo il nome del repository${NC}"
  echo -e "Esempio: $0 scripts"
  exit 1
fi

if [ -z "$GITHUB_TOKEN" ]; then
  echo -e "${RED}❌ Devi settare la variabile d'ambiente GITHUB_TOKEN con il tuo Personal Access Token GitHub${NC}"
  exit 1
fi

SSH_KEY_PATH="$HOME/.ssh/id_rsa.pub"
if [ ! -f "$SSH_KEY_PATH" ]; then
  echo -e "${RED}❌ Chiave pubblica SSH non trovata in $SSH_KEY_PATH${NC}"
  exit 1
fi

USER="manuelpringols"
REPO_NAME="$1"
FULL_URL="git@github.com:$USER/$REPO_NAME.git"

create_repo() {
  echo -e "${YELLOW}🌱 Creo repository '$REPO_NAME' su GitHub...${NC}"

  response=$(curl -s -w "%{http_code}" -o /tmp/create_repo_response.json \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github+json" \
    -X POST https://api.github.com/user/repos \
    -d "{\"name\":\"$REPO_NAME\"}")

  if [ "$response" = "201" ]; then
    echo -e "${GREEN}✅ Repository creato con successo!${NC}"
  elif [ "$response" = "422" ]; then
    echo -e "${YELLOW}⚠️ Repository già esistente o nome non valido.${NC}"
  else
    echo -e "${RED}❌ Errore nella creazione del repository. Codice HTTP: $response${NC}"
    cat /tmp/create_repo_response.json
    rm /tmp/create_repo_response.json
    exit 1
  fi

  rm /tmp/create_repo_response.json
}

add_ssh_key() {
  KEY_CONTENT=$(cat "$SSH_KEY_PATH")
  KEY_TITLE="Key from script on $(date +'%Y-%m-%d %H:%M:%S')"

  echo -e "${YELLOW}🔐 Aggiungo la chiave SSH a GitHub...${NC}"

  http_code=$(curl -s -w "%{http_code}" -o /tmp/ssh_key_response.json -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github+json" \
    https://api.github.com/user/keys \
    -d "{\"title\":\"$KEY_TITLE\",\"key\":\"$KEY_CONTENT\"}")

  if [ "$http_code" = "201" ]; then
    echo -e "${GREEN}✅ Chiave SSH aggiunta con successo su GitHub!${NC}"
  elif [ "$http_code" = "422" ]; then
    if grep -q "key is already in use" /tmp/ssh_key_response.json; then
      echo -e "${YELLOW}⚠️ Chiave SSH già presente su GitHub, procedo senza errori.${NC}"
    else
      echo -e "${RED}❌ Errore durante l'aggiunta della chiave SSH su GitHub. Codice HTTP: $http_code${NC}"
      cat /tmp/ssh_key_response.json
      rm /tmp/ssh_key_response.json
      exit 1
    fi
  else
    echo -e "${RED}❌ Errore durante l'aggiunta della chiave SSH su GitHub. Codice HTTP: $http_code${NC}"
    cat /tmp/ssh_key_response.json
    rm /tmp/ssh_key_response.json
    exit 1
  fi

  rm /tmp/ssh_key_response.json
}




init_git() {
  echo -e "${CYAN}📦 Inizializzo repository git locale...${NC}"
  echo -e "👤 Utente GitHub: $USER"
  echo -e "📁 Nome repository: $REPO_NAME"
  echo -e "🔗 URL remote: $FULL_URL"

  if [ ! -d "$REPO_NAME" ]; then
    mkdir "$REPO_NAME"
  fi
  cd "$REPO_NAME" || exit 1

  git init
  git remote add origin "$FULL_URL"

  echo -e "${GREEN}✅ Repository git inizializzato e remote 'origin' settato a $FULL_URL${NC}"
}

# Esecuzione passo-passo

create_repo
add_ssh_key
init_git

