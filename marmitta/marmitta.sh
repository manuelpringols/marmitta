#!/bin/bash

# ╔══════════════════════════════════════════════════════════════╗
# ║                 MARMITTA - Script Launcher                   ║
# ║          github.com/manuelpringols/scripts                   ║
# ╚══════════════════════════════════════════════════════════════╝

# ─────────────────────────────────────────────────────────────
# COLORI (palette centralizzata — non ricopiare in ogni funzione)
# ─────────────────────────────────────────────────────────────
RED='\e[38;5;160m'
DARK_RED='\e[38;5;52m'
BLOOD_RED='\e[38;5;124m'
BLACK_PITCH='\e[38;5;234m'
GREEN_NEON='\033[1;92m'
GREEN_TOXIC='\033[0;92m'
GREEN_DARK='\033[0;32m'
GREEN_SLIME='\033[1;32m'
BLUE="\033[1;34m"
GREEN="\e[92m"
CYAN="\e[96m"
YELLOW="\e[93m"
MAGENTA="\e[95m"
BOLD="\e[1m"
ORANGE="\e[38;5;208m"
PURPLE="\e[35m"
DARK_GRAY="\e[90m"
RESET='\e[0m'

# ─────────────────────────────────────────────────────────────
# COSTANTI
# ─────────────────────────────────────────────────────────────
MARMITTA_CONFIG_DIR="$HOME/.config/marmitta"
MARMITTA_CONFIG_FILE="$MARMITTA_CONFIG_DIR/config"
MARMITTA_LAST_SCRIPT="$HOME/.marmitta_last_script"
MARMITTA_INSTALL_PATH="/usr/local/bin/marmitta"

# Variabili che vengono popolate da load_config / ensure_config
GITHUB_USER=""
GITHUB_TOKEN=""
DEFAULT_BRANCH="master"
REPO_API_URL=""
BASE_URL=""
AUTH_HEADER=()
SCRIPT_DESCS=""

# ─────────────────────────────────────────────────────────────
# UTILITY PRINT
# ─────────────────────────────────────────────────────────────
print_ok()      { echo -e "${GREEN}✅ $1${RESET}"; }
print_warn()    { echo -e "${YELLOW}⚠️  $1${RESET}"; }
print_err()     { echo -e "${RED}❌ $1${RESET}"; }
print_info()    { echo -e "${CYAN}ℹ️  $1${RESET}"; }
print_step()    { echo -e "${MAGENTA}➡️  $1${RESET}"; }

# ─────────────────────────────────────────────────────────────
# INTERNET CHECK
# ─────────────────────────────────────────────────────────────
check_internet() {
  if ! ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
    print_err "Connessione Internet assente. Marmitta richiede una connessione attiva."
    exit 1
  fi
}

# ─────────────────────────────────────────────────────────────
# CONFIG — carica, crea interattivo, valida
# ─────────────────────────────────────────────────────────────
load_config() {
  # shellcheck source=/dev/null
  [[ -f "$MARMITTA_CONFIG_FILE" ]] && source "$MARMITTA_CONFIG_FILE"
}

setup_config() {
  echo -e "\n${CYAN}${BOLD}⚙️  Setup di Marmitta${RESET}\n"
  mkdir -p "$MARMITTA_CONFIG_DIR"

  local github_user github_token default_branch

  read -rp "$(echo -e "${YELLOW}👤 GitHub username: ${RESET}")" github_user
  while [[ -z "$github_user" ]]; do
    print_err "Username obbligatorio."
    read -rp "$(echo -e "${YELLOW}👤 GitHub username: ${RESET}")" github_user
  done

  read -rp "$(echo -e "${YELLOW}🔑 GitHub token (vuoto = limite pubblico 60 req/h): ${RESET}")" github_token
  read -rp "$(echo -e "${YELLOW}🌿 Branch di default [master]: ${RESET}")" default_branch
  default_branch="${default_branch:-master}"

  cat > "$MARMITTA_CONFIG_FILE" <<EOF
# Marmitta config — generato il $(date)
# Modifica manualmente o riesegui con: marmitta --setup

GITHUB_USER="${github_user}"
GITHUB_TOKEN="${github_token}"
DEFAULT_BRANCH="${default_branch}"
EOF

  print_ok "Config salvato in ${MARMITTA_CONFIG_FILE}"
  load_config
}

# Chiamata all'avvio: crea il config se non esiste, poi deriva le variabili URL/auth
ensure_config() {
  if [[ ! -f "$MARMITTA_CONFIG_FILE" ]]; then
    echo -e "\n${YELLOW}⚠️  Prima esecuzione: configurazione iniziale richiesta.${RESET}"
    setup_config
  else
    load_config
  fi

  if [[ -z "$GITHUB_USER" ]]; then
    print_err "GITHUB_USER non configurato. Esegui: marmitta --setup"
    exit 1
  fi

  REPO_API_URL="https://api.github.com/repos/${GITHUB_USER}/scripts/contents"
  BASE_URL="https://raw.githubusercontent.com/${GITHUB_USER}/scripts/${DEFAULT_BRANCH}"

  if [[ -n "$GITHUB_TOKEN" ]]; then
    AUTH_HEADER=(-H "Authorization: token ${GITHUB_TOKEN}")
  else
    print_warn "Nessun token GitHub. Limite pubblico: 60 req/h."
    AUTH_HEADER=()
  fi
}

# ─────────────────────────────────────────────────────────────
# DIPENDENZE (jq, fzf)
# ─────────────────────────────────────────────────────────────
install_dependencies() {
  local missing=()
  for cmd in jq fzf; do
    command -v "$cmd" &>/dev/null || missing+=("$cmd")
  done
  [[ ${#missing[@]} -eq 0 ]] && return 0

  print_err "Mancano: ${missing[*]}"
  read -rp "Vuoi installarli ora? [y/N]: " answer
  [[ ! "$answer" =~ ^[Yy]$ ]] && echo "Uscita." && exit 1

  if   [[ "$OSTYPE" == "darwin"* ]];      then brew install "${missing[@]}"
  elif [[ -f /etc/arch-release ]];        then sudo pacman -S --noconfirm "${missing[@]}"
  elif [[ -f /etc/debian_version ]];      then sudo apt update && sudo apt install -y "${missing[@]}"
  elif [[ -f /etc/fedora-release ]];      then sudo dnf install -y "${missing[@]}"
  else
    print_err "Sistema non riconosciuto. Installa manualmente: ${missing[*]}"
    exit 1
  fi
}

# ─────────────────────────────────────────────────────────────
# DESCRIZIONI SCRIPT (script_desc.txt remoto)
# ─────────────────────────────────────────────────────────────
load_script_descs() {
  SCRIPT_DESCS=$(curl -fsSL \
    "${BASE_URL}/marmitta/script_desc.txt" 2>/dev/null || echo "")
}

get_desc() {
  local path="$1"
  local desc
  desc=$(echo "$SCRIPT_DESCS" | grep "^${path}" | sed 's/.*# //' 2>/dev/null || true)
  echo "${desc:-—}"
}

# ─────────────────────────────────────────────────────────────
# CHECK AGGIORNAMENTO
# ─────────────────────────────────────────────────────────────
check_update() {
  [[ ! -f "$MARMITTA_INSTALL_PATH" ]] && return

  local local_sha remote_sha
  local_sha=$(git hash-object "$MARMITTA_INSTALL_PATH" 2>/dev/null || echo "")
  remote_sha=$(curl -s "${AUTH_HEADER[@]}" \
    "https://api.github.com/repos/${GITHUB_USER}/scripts/contents/marmitta/marmitta.sh?ref=${DEFAULT_BRANCH}" \
    | jq -r '.sha // empty' 2>/dev/null || echo "")

  if [[ -z "$remote_sha" ]]; then
    print_warn "Impossibile verificare aggiornamenti (API non raggiunta)."
    return
  fi

  if [[ "$local_sha" == "$remote_sha" ]]; then
    print_ok "Marmitta è aggiornato."
  else
    print_warn "Aggiornamento disponibile. Esegui ${CYAN}marmitta -u${YELLOW} per aggiornare."
  fi
}

# ─────────────────────────────────────────────────────────────
# BANNER ANIMATO
# ─────────────────────────────────────────────────────────────
print_banner() {
  echo -e "${RED}█▀▄▀█${BLOOD_RED} ██   █▄▄▄▄ ${RED}█▀▄▀█${RESET} ${BLACK_PITCH}▄█${RED}    ▄▄▄▄▀${BLACK_PITCH}    ▄▄▄▄▀ ██${BLACK_PITCH}"
  sleep 0.05
  echo -e "${DARK_RED}█ █ █${RED} █ █  █  ▄▀ ${DARK_RED}█ █ █${RED} ██${BLACK_PITCH} ▀▀▀${BLOOD_RED} █${BLACK_PITCH}    ▀▀▀ ${RED}█    █ █${BLOOD_RED}"
  sleep 0.05
  echo -e "${RED}█ ▄ █${BLOOD_RED} █▄▄█ █▀▀▌  █ ▄ █${BLACK_PITCH} ██${RED}     █${BLACK_PITCH}        █    █▄▄█${BLOOD_RED}"
  sleep 0.05
  echo -e "${DARK_RED}█   █${RED} █  █ █  █  █   █${BLACK_PITCH} ▐█${RED}    █${DARK_RED}        █     █  █${RESET}"
  sleep 0.05
  echo -e "   ${RED}█     █   █      █   ▐   ▀        ▀         █${RESET}"
  sleep 0.05
  echo -e "  ${BLOOD_RED}▀     █   ▀      ▀                          █${RESET}"
  sleep 0.1
  echo -e "\n${CYAN}${BOLD}SCRIPT MARMITTA - powered by FATT E CAZZ TUOJ 😈${RESET}"
  echo -e "${DARK_GRAY}user: ${GITHUB_USER} | branch: ${DEFAULT_BRANCH} | repo: ${GITHUB_USER}/scripts${RESET}\n"
}

# ─────────────────────────────────────────────────────────────
# TREE DINAMICO (da GitHub API ricorsiva)
# ─────────────────────────────────────────────────────────────
print_tree() {
  echo -e "\n${MAGENTA}${BOLD}📁 ${GITHUB_USER}/scripts${RESET}\n"

  local tree_data
  tree_data=$(curl -s "${AUTH_HEADER[@]}" \
    "https://api.github.com/repos/${GITHUB_USER}/scripts/git/trees/${DEFAULT_BRANCH}?recursive=1" \
    | jq -r '.tree[] | select(.type == "blob") | .path' 2>/dev/null)

  if [[ -z "$tree_data" ]]; then
    print_err "Impossibile recuperare la struttura del repo."
    return 1
  fi

  local prev_folder=""
  while IFS= read -r path; do
    local folder file desc
    folder=$(dirname "$path")
    file=$(basename "$path")

    if [[ "$folder" != "$prev_folder" ]]; then
      echo -e "\n${MAGENTA}├── ${folder}${RESET}"
      prev_folder="$folder"
    fi

    desc=$(get_desc "$path")
    echo -e "│   └── ${YELLOW}${file}${RESET}  ${DARK_GRAY}${desc}${RESET}"
  done <<< "$tree_data"

  echo ""
}

# ─────────────────────────────────────────────────────────────
# FZF — tema comune
# ─────────────────────────────────────────────────────────────
fzf_select() {
  # $1 = prompt, resto = opzioni via stdin
  local prompt="${1:-> }"
  fzf \
    --height=20 --layout=reverse --border \
    --prompt="$prompt" \
    --color=fg:#d6de35,bg:#121212,hl:#5f87af \
    --color=fg+:#00ffd9,bg+:#5c00e6,hl+:#5fd7ff \
    --color=pointer:green,marker:yellow \
    --ansi
}

# ─────────────────────────────────────────────────────────────
# CORE — navigazione repo con supporto sottocartelle
# ─────────────────────────────────────────────────────────────
browse_and_run() {
  local current_path=""

  while true; do
    # API URL per il path corrente (root o sottocartella)
    local api_url="${REPO_API_URL}"
    [[ -n "$current_path" ]] && api_url="${REPO_API_URL}/${current_path}"

    # Fetch contenuto cartella
    local contents
    contents=$(curl -s "${AUTH_HEADER[@]}" "$api_url")

    if echo "$contents" | grep -q 'API rate limit exceeded'; then
      print_err "API rate limit superato. Aggiungi GITHUB_TOKEN con: marmitta --setup"
      exit 1
    fi

    # Separa cartelle e script .sh
    local dirs
    local scripts_raw
    dirs=$(echo "$contents" | jq -r '.[] | select(.type == "dir") | .name' 2>/dev/null || echo "")
    scripts_raw=$(echo "$contents" | jq -r '.[] | select(.type == "file" and (.name | endswith(".sh"))) | .name' 2>/dev/null || echo "")

    # Costruisci lista con descrizioni (tab-separated: nome \t descrizione)
    local menu_entries=""

    # Prima le cartelle
    while IFS= read -r dir; do
      [[ -z "$dir" ]] && continue
      menu_entries+="📁 ${dir}\t—\n"
    done <<< "$dirs"

    # Poi gli script con descrizione
    while IFS= read -r script; do
      [[ -z "$script" ]] && continue
      local full_path="${current_path:+${current_path}/}${script}"
      local desc
      desc=$(get_desc "$full_path")
      menu_entries+="📜 ${script}\t${desc}\n"
    done <<< "$scripts_raw"

    if [[ -z "$menu_entries" ]]; then
      print_warn "Nessun contenuto trovato in: ${current_path:-root}"
      current_path=$(dirname "$current_path")
      [[ "$current_path" == "." ]] && current_path=""
      continue
    fi

    # Breadcrumb nel prompt
    local prompt_path="${GITHUB_USER}/scripts"
    [[ -n "$current_path" ]] && prompt_path+="/${current_path}"

    # Opzione "torna indietro" se siamo in una sottocartella
    local back_entry=""
    [[ -n "$current_path" ]] && back_entry="🔙 Torna indietro\t\n"

    # Selezione via fzf
    local selected
    selected=$(printf "%b" "${back_entry}${menu_entries}" | \
      fzf \
        --height=22 --layout=reverse --border \
        --prompt="📁 ${prompt_path} > " \
        --with-nth=1 \
        --delimiter="\t" \
        --preview='echo -e "\033[0;96mDescrizione:\033[0m " $(echo {} | cut -f2)' \
        --preview-window=up:3:wrap \
        --color=fg:#d6de35,bg:#121212,hl:#5f87af \
        --color=fg+:#00ffd9,bg+:#5c00e6,hl+:#5fd7ff \
        --color=pointer:green,marker:yellow \
        --ansi \
      | cut -f1)

    # Annullato (Ctrl+C o ESC)
    if [[ -z "$selected" ]]; then
      print_err "Annullato."
      return 1
    fi

    # Torna indietro
    if [[ "$selected" == "🔙 Torna indietro" ]]; then
      current_path=$(dirname "$current_path")
      [[ "$current_path" == "." ]] && current_path=""
      continue
    fi

    # Estrae il nome (rimuove emoji + spazio iniziale → 1 char emoji + 1 spazio = :2)
    local item_name="${selected:2}"

    # Cartella → entra
    if [[ "$selected" == 📁* ]]; then
      current_path="${current_path:+${current_path}/}${item_name}"
      continue
    fi

    # Script → chiede come eseguire
    local script_path="${current_path:+${current_path}/}${item_name}"
    local url_full="${BASE_URL}/${script_path}"

    echo "$url_full" > "$MARMITTA_LAST_SCRIPT"

    echo -e "\n${CYAN}📜 Script:${RESET}  ${YELLOW}${script_path}${RESET}"
    echo -e "${CYAN}🔗 URL:${RESET}     ${DARK_GRAY}${url_full}${RESET}"
    echo -e "\n${CYAN}[ ${GREEN}INVIO${CYAN} ] Esegui   [ ${YELLOW}i${CYAN} ] Passa parametri   [ ${RED}Ctrl+C${CYAN} ] Annulla${RESET}"

    local key
    read -rsn1 key

    case "$key" in
      i|I)
        echo
        read -rp "$(echo -e "${MAGENTA}⌨️  Argomenti: ${RESET}")" user_args
        local tmp
        tmp=$(mktemp)
        echo -e "${GREEN}⬇️  Download in corso...${RESET}"
        if ! curl -fsSL "$url_full" -o "$tmp"; then
          print_err "Errore nel download dello script."
          rm -f "$tmp"
          return 1
        fi
        chmod +x "$tmp"
        echo -e "${GREEN}▶️  Eseguo:${RESET} ${YELLOW}${item_name} ${user_args}${RESET}\n"
        bash "$tmp" $user_args
        rm -f "$tmp"
        ;;
      *)
        echo -e "\n${GREEN}▶️  Eseguo senza parametri...${RESET}\n"
        bash <(curl -fsSL "$url_full")
        ;;
    esac

    return 0
  done
}

# ─────────────────────────────────────────────────────────────
# HANDLER: HELP
# ─────────────────────────────────────────────────────────────
print_help() {
  echo -e "\n${BLUE}m${YELLOW}a${MAGENTA}r${CYAN}m${GREEN}i${PURPLE}t${ORANGE}t${DARK_GRAY}a${RESET} ${BOLD}— launcher di script shell${RESET}\n"
  echo -e "${YELLOW}Uso:${RESET} marmitta [opzione]\n"
  printf "  %-20s %s\n" \
    "${CYAN}-l, --last${RESET}"   "Riesegue l'ultimo script" \
    "${MAGENTA}-t, --tree${RESET}"  "Struttura repo (dinamica, da GitHub API)" \
    "${RED}-h, --help${RESET}"   "Mostra questa guida" \
    "${GREEN}-u${RESET}"          "Aggiorna marmitta all'ultima versione" \
    "${ORANGE}-Gsp${RESET}"       "Push rapido git (slither_push)" \
    "${CYAN}-py${RESET}"          "Launcher script Python (pitonzi)" \
    "${PURPLE}--login${RESET}"    "Login Bitwarden + salva GITHUB_TOKEN" \
    "${YELLOW}--setup${RESET}"    "Riconfigura marmitta (user, token, branch)"
  echo -e "\n${DARK_GRAY}Monitum amicum: usa sempre -h prima di eseguire uno script sconosciuto! 😜${RESET}\n"
}

# ─────────────────────────────────────────────────────────────
# HANDLER: UPDATE
# ─────────────────────────────────────────────────────────────
do_update() {
  local url="${BASE_URL}/marmitta/marmitta_update.sh"
  print_step "Scarico marmitta_update.sh..."
  curl -fsSL "$url" | bash
}

# ─────────────────────────────────────────────────────────────
# HANDLER: LAST SCRIPT
# ─────────────────────────────────────────────────────────────
do_last() {
  local last
  last=$(cat "$MARMITTA_LAST_SCRIPT" 2>/dev/null || echo "")
  if [[ -z "$last" ]]; then
    print_err "Nessuno script eseguito precedentemente."
    exit 1
  fi
  echo -e "${CYAN}▶️  Rieseguo:${RESET} ${YELLOW}${last}${RESET}\n"
  bash <(curl -fsSL "$last")
}

# ─────────────────────────────────────────────────────────────
# HANDLER: LOGIN (Bitwarden + aggiorna sessione corrente)
# ─────────────────────────────────────────────────────────────
do_login() {
  local url="${BASE_URL}/marmitta/marmitta_login.sh"
  print_step "Avvio login da marmitta_login.sh..."
  local tmp
  tmp=$(mktemp)
  curl -s -o "$tmp" "$url"
  chmod +x "$tmp"
  bash "$tmp"
  rm -f "$tmp"

  # Ricarica il token nella sessione corrente dal config aggiornato
  load_config
  if [[ -n "$GITHUB_TOKEN" ]]; then
    export GITHUB_TOKEN
    AUTH_HEADER=(-H "Authorization: token ${GITHUB_TOKEN}")
    print_ok "Token aggiornato nella sessione corrente."
  fi
}

# ─────────────────────────────────────────────────────────────
# HANDLER: PITONZI (launcher script Python)
# ─────────────────────────────────────────────────────────────
call_pitonzi() {
  echo -e "${RED}██████╗ ${BLOOD_RED}██╗████████╗${GREEN_NEON} ██████╗ ${GREEN_TOXIC}███╗   ██╗${RED}███████╗${RESET}"
  sleep 0.05
  echo -e "${DARK_RED}██╔══██╗${RED}██║╚══██╔══╝${GREEN_SLIME} ██╔═══██╗${GREEN_NEON}████╗  ██║${DARK_RED}██╔════╝${RESET}"
  sleep 0.05
  echo -e "${RED}██████╔╝${BLOOD_RED}██║   ██║   ${GREEN_TOXIC}██║   ██║${GREEN_SLIME}██╔██╗ ██║${RED}█████╗${RESET}"
  sleep 0.05
  echo -e "${DARK_RED}██╔═══╝ ${RED}██║   ██║   ${GREEN_TOXIC}██║   ██║${GREEN_DARK}██║╚██╗██║${RED}██╔══╝${RESET}"
  sleep 0.05
  echo -e "${RED}██║     ${BLOOD_RED}██║   ██║  ${GREEN_SLIME}╚██████╔╝${GREEN_TOXIC}██║ ╚████║${GREEN_NEON}██║${RESET}"
  sleep 0.1
  echo -e "${DARK_RED}╚═╝     ${BLACK_PITCH}╚═╝   ╚═╝  ${GREEN_DARK}╚══════╝ ${BLACK_PITCH}╚═════╝ ${GREEN_SLIME}╚═╝${RESET}\n"

  local tmp
  tmp=$(mktemp)
  curl -fsSL "${BASE_URL}/pitonzi/run_pitonzi.sh" -o "$tmp"
  chmod +x "$tmp"
  bash "$tmp" "$@"
  rm -f "$tmp"
}

# ─────────────────────────────────────────────────────────────
# HANDLER: SLITHER PUSH
# ─────────────────────────────────────────────────────────────
do_slither_push() {
  sh -c "$(curl -fsSL "${BASE_URL}/init_git_repo/slither_push_repo.sh")" -- "$@"
}

# ─────────────────────────────────────────────────────────────
# ENTRY POINT
# ─────────────────────────────────────────────────────────────
check_internet
ensure_config

case "${1:-}" in
  -h|--help)   print_help;                          exit 0 ;;
  --setup)     setup_config;                        exit 0 ;;
  --login)     do_login;                            exit 0 ;;
  -l|--last)   do_last;                             exit 0 ;;
  -t|--tree)   load_script_descs; print_tree;       exit 0 ;;
  -u)          do_update;                           exit 0 ;;
  -py)         shift; call_pitonzi "$@";            exit 0 ;;
  -Gsp)        shift; do_slither_push "$@";         exit 0 ;;
  "")          ;;   # menu principale
  *)           print_err "Opzione non riconosciuta: $1"; print_help; exit 1 ;;
esac

# Menu principale
install_dependencies
load_script_descs
print_banner
check_update
echo ""
browse_and_run
