#!/bin/bash

# ╔══════════════════════════════════════════════════════════════╗
# ║                 MARMITTA - Script Launcher                   ║
# ║          github.com/manuelpringols/marmitta                  ║
# ║                                                              ║
# ║  Installazione:                                              ║
# ║    sudo curl -fsSL <raw_url>/marmitta.sh \                   ║
# ║      -o /usr/local/bin/marmitta && \                         ║
# ║      sudo chmod +x /usr/local/bin/marmitta                   ║
# ╚══════════════════════════════════════════════════════════════╝

# ─────────────────────────────────────────────────────────────
# === PALETTE COLORI (centralizzata) ===
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
# === COSTANTI ===
# ─────────────────────────────────────────────────────────────
MARMITTA_CONFIG_DIR="$HOME/.config/marmitta"
MARMITTA_CONFIG_FILE="$MARMITTA_CONFIG_DIR/config"
MARMITTA_SOURCES_FILE="$MARMITTA_CONFIG_DIR/sources"
MARMITTA_LAST_SCRIPT="$HOME/.marmitta_last_script"
MARMITTA_INSTALL_PATH="/usr/local/bin/marmitta"
MARMITTA_REPO="manuelpringols/marmitta"
MARMITTA_RAW="https://raw.githubusercontent.com/${MARMITTA_REPO}/master"

# Variabili runtime
GITHUB_TOKEN=""
DEFAULT_BRANCH="master"
AUTH_HEADER=()

# Source corrente (popolata da select_source)
CURRENT_SOURCE_LABEL=""
CURRENT_SOURCE_REPO=""
CURRENT_SOURCE_BRANCH=""
CURRENT_BASE_URL=""
CURRENT_API_URL=""
SCRIPT_DESCS=""

# ─────────────────────────────────────────────────────────────
# === UTILITY PRINT ===
# ─────────────────────────────────────────────────────────────
print_ok()   { echo -e "${GREEN}✅ $1${RESET}"; }
print_warn() { echo -e "${YELLOW}⚠️  $1${RESET}"; }
print_err()  { echo -e "${RED}❌ $1${RESET}"; }
print_info() { echo -e "${CYAN}ℹ️  $1${RESET}"; }
print_step() { echo -e "${MAGENTA}➡️  $1${RESET}"; }

# ─────────────────────────────────────────────────────────────
# === INTERNET CHECK ===
# ─────────────────────────────────────────────────────────────
check_internet() {
  if ! ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
    print_err "Connessione Internet assente. Marmitta richiede una connessione attiva."
    exit 1
  fi
}

# ─────────────────────────────────────────────────────────────
# === DIPENDENZE (jq, fzf) ===
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

  if   [[ "$OSTYPE" == "darwin"* ]];     then brew install "${missing[@]}"
  elif [[ -f /etc/arch-release ]];       then sudo pacman -S --noconfirm "${missing[@]}"
  elif [[ -f /etc/debian_version ]];     then sudo apt update && sudo apt install -y "${missing[@]}"
  elif [[ -f /etc/fedora-release ]];     then sudo dnf install -y "${missing[@]}"
  else
    print_err "Sistema non riconosciuto. Installa manualmente: ${missing[*]}"
    exit 1
  fi
}

# ─────────────────────────────────────────────────────────────
# === CONFIG ===
# ─────────────────────────────────────────────────────────────
load_config() {
  # shellcheck source=/dev/null
  [[ -f "$MARMITTA_CONFIG_FILE" ]] && source "$MARMITTA_CONFIG_FILE"
  _setup_auth
}

# Valida il token e imposta AUTH_HEADER — se invalido lo ignora
_setup_auth() {
  AUTH_HEADER=()
  [[ -z "$GITHUB_TOKEN" ]] && return

  local login
  login=$(curl -s --max-time 5     -H "Authorization: token ${GITHUB_TOKEN}"     https://api.github.com/user | jq -r '.login // empty' 2>/dev/null)

  if [[ -n "$login" ]]; then
    AUTH_HEADER=(-H "Authorization: token ${GITHUB_TOKEN}")
  else
    print_warn "Token GitHub non valido o scaduto — uso senza autenticazione (60 req/h)."
    echo -e "${DARK_GRAY}Aggiorna il token con: marmitta --config${RESET}"
    GITHUB_TOKEN=""
  fi
}

setup_config() {
  echo -e "\n${CYAN}${BOLD}⚙️  Setup iniziale di Marmitta${RESET}\n"
  mkdir -p "$MARMITTA_CONFIG_DIR"

  local github_token default_branch
  read -rp "$(echo -e "${YELLOW}🔑 GitHub token (vuoto = limite pubblico 60 req/h): ${RESET}")" github_token
  read -rp "$(echo -e "${YELLOW}🌿 Branch di default [master]: ${RESET}")" default_branch
  default_branch="${default_branch:-master}"

  cat > "$MARMITTA_CONFIG_FILE" <<EOF
# Marmitta config — generato il $(date)
GITHUB_TOKEN="${github_token}"
DEFAULT_BRANCH="${default_branch}"
EOF

  print_ok "Config salvato in ${MARMITTA_CONFIG_FILE}"

  if [[ ! -f "$MARMITTA_SOURCES_FILE" ]]; then
    cat > "$MARMITTA_SOURCES_FILE" <<'EOF'
# Marmitta sources — una per riga: label|user/repo|branch
# Esempio: Scripts personali|manuelpringols/scripts|master
EOF
    print_info "File sources creato in ${MARMITTA_SOURCES_FILE}"
    echo -e "${YELLOW}Aggiungi almeno una source con: ${CYAN}marmitta --add-source${RESET}\n"
  fi

  load_config
}

ensure_config() {
  if [[ ! -f "$MARMITTA_CONFIG_FILE" ]]; then
    echo -e "\n${YELLOW}⚠️  Prima esecuzione rilevata.${RESET}"
    setup_config
  else
    load_config
  fi

  if [[ ! -f "$MARMITTA_SOURCES_FILE" ]] || ! grep -qv '^#' "$MARMITTA_SOURCES_FILE" 2>/dev/null; then
    echo -e "\n${YELLOW}⚠️  Nessuna source configurata.${RESET}"
    read -rp "Vuoi aggiungerne una ora? [y/N]: " ans
    [[ "$ans" =~ ^[Yy]$ ]] && do_add_source || exit 0
  fi
}

# ─────────────────────────────────────────────────────────────
# === SOURCES ===
# ─────────────────────────────────────────────────────────────
get_sources() {
  grep -v '^#' "$MARMITTA_SOURCES_FILE" 2>/dev/null | grep -v '^$' || true
}

do_add_source() {
  echo -e "\n${CYAN}${BOLD}➕ Aggiungi source${RESET}\n"
  mkdir -p "$MARMITTA_CONFIG_DIR"
  [[ ! -f "$MARMITTA_SOURCES_FILE" ]] && touch "$MARMITTA_SOURCES_FILE"

  # ── Token mancante → chiedi subito ──
  if [[ -z "$GITHUB_TOKEN" ]]; then
    print_warn "Nessun token GitHub configurato."
    echo -e "${DARK_GRAY}Senza token sei limitato a 60 req/h e i repo privati non sono accessibili.${RESET}"
    read -rsp "$(echo -e "${YELLOW}🔑 GitHub token (vuoto = salta): ${RESET}")" input_token
    echo
    if [[ -n "$input_token" ]]; then
      GITHUB_TOKEN="$input_token"
      AUTH_HEADER=(-H "Authorization: token ${GITHUB_TOKEN}")
      if [[ -f "$MARMITTA_CONFIG_FILE" ]]; then
        sed -i "s|^GITHUB_TOKEN=.*|GITHUB_TOKEN=\"${GITHUB_TOKEN}\"|" "$MARMITTA_CONFIG_FILE"
        print_ok "Token salvato nel config."
      fi
    fi
  fi

  local label user_repo branch
  read -rp "$(echo -e "${YELLOW}🏷️  Label (es: Scripts personali): ${RESET}")" label
  while [[ -z "$label" ]]; do
    print_warn "Label obbligatoria."
    read -rp "$(echo -e "${YELLOW}🏷️  Label: ${RESET}")" label
  done

  read -rp "$(echo -e "${YELLOW}📦 Repo (es: manuelpringols/scripts o URL GitHub): ${RESET}")" user_repo
  user_repo=$(echo "$user_repo" | sed 's|https://github.com/||;s|http://github.com/||;s|github.com/||;s|\.git$||' | xargs)
  while [[ -z "$user_repo" || "$user_repo" != */* ]]; do
    print_warn "Formato non valido. Usa: username/repo"
    read -rp "$(echo -e "${YELLOW}📦 Repo: ${RESET}")" user_repo
    user_repo=$(echo "$user_repo" | sed 's|https://github.com/||;s|\.git$||' | xargs)
  done

  read -rp "$(echo -e "${YELLOW}🌿 Branch [${DEFAULT_BRANCH}]: ${RESET}")" branch
  branch="${branch:-${DEFAULT_BRANCH}}"

  # Verifica opzionale — salta se non abbiamo token (rate limit facile da esaurire)
  local status="skip"
  if [[ -n "$GITHUB_TOKEN" ]]; then
    print_step "Verifico accesso al repo ${user_repo}..."
    status=$(curl -s -o /dev/null -w "%{http_code}" "${AUTH_HEADER[@]}"       "https://api.github.com/repos/${user_repo}")
  else
    print_info "Verifica saltata (nessun token) — la source verrà aggiunta direttamente."
  fi

  case "$status" in
    200|skip)
      echo "${label}|${user_repo}|${branch}" >> "$MARMITTA_SOURCES_FILE"
      print_ok "Source '${label}' aggiunta → ${user_repo}@${branch}"
      ;;
    401|403|429)
      # Con token → invalido/scaduto/rate limit
      print_warn "Accesso negato (HTTP $status) — token non valido, scaduto o rate limit."
      print_info "Aggiorna il token con: marmitta --config"
      # Aggiungiamo la source comunque, l'utente sa cosa sta facendo
      echo "${label}|${user_repo}|${branch}" >> "$MARMITTA_SOURCES_FILE"
      print_ok "Source '${label}' aggiunta → ${user_repo}@${branch}"
      ;;
    404)
      print_warn "Repo non trovato (HTTP 404). Controlla il nome: ${user_repo}"
      read -rp "$(echo -e "${YELLOW}Aggiungere la source lo stesso? [y/N]: ${RESET}")" force
      if [[ "$force" =~ ^[Yy]$ ]]; then
        echo "${label}|${user_repo}|${branch}" >> "$MARMITTA_SOURCES_FILE"
        print_ok "Source '${label}' aggiunta (non verificata) → ${user_repo}@${branch}"
      else
        print_warn "Source non aggiunta."
        return 1
      fi
      ;;
    *)
      print_warn "Risposta inattesa (HTTP $status) — la source verrà aggiunta lo stesso."
      echo "${label}|${user_repo}|${branch}" >> "$MARMITTA_SOURCES_FILE"
      print_ok "Source '${label}' aggiunta → ${user_repo}@${branch}"
      ;;
  esac
}


select_source() {
  local sources
  sources=$(get_sources)
  local count
  count=$(echo "$sources" | grep -c '.' 2>/dev/null || echo 0)

  local chosen
  if [[ "$count" -le 1 ]]; then
    chosen="$sources"
  else
    # Passa le righe originali (label|repo|branch) a fzf
    # --with-nth=1 mostra solo la label, --nth=1 cerca solo nella label
    # La riga completa viene restituita da fzf invariata
    chosen=$(echo "$sources" | \
      fzf \
        --height=14 --layout=reverse --border \
        --prompt="🌐 Source > " \
        --delimiter="|" \
        --with-nth=1,2 \
        --preview='echo {} | awk -F"|" '"'"'{printf "Repo:   %s\nBranch: %s", $2, $3}'"'"'' \
        --preview-window=up:3:wrap \
        --header="  Seleziona il repo da cui caricare gli script" \
        --color=fg:#d6de35,bg:#121212,hl:#5f87af \
        --color=fg+:#00ffd9,bg+:#5c00e6,hl+:#5fd7ff \
        --color=pointer:green,header:italic \
        --ansi)

    [[ -z "$chosen" ]] && print_err "Annullato." && exit 1
  fi

  # Parse diretto dalla riga originale — nessun re-match necessario
  CURRENT_SOURCE_LABEL=$(echo "$chosen" | cut -d'|' -f1 | xargs)
  CURRENT_SOURCE_REPO=$(echo "$chosen"  | cut -d'|' -f2 | xargs)
  CURRENT_SOURCE_BRANCH=$(echo "$chosen" | cut -d'|' -f3 | xargs)
  CURRENT_SOURCE_BRANCH="${CURRENT_SOURCE_BRANCH:-${DEFAULT_BRANCH}}"
  CURRENT_BASE_URL="https://raw.githubusercontent.com/${CURRENT_SOURCE_REPO}/${CURRENT_SOURCE_BRANCH}"
  CURRENT_API_URL="https://api.github.com/repos/${CURRENT_SOURCE_REPO}/contents"
}

# ─────────────────────────────────────────────────────────────
# === DESCRIZIONI SCRIPT (@desc: convention + cache locale) ===
# ─────────────────────────────────────────────────────────────
# ─────────────────────────────────────────────────────────────
# === DESCRIZIONI da script_desc.txt (1 sola chiamata API) ===
# ─────────────────────────────────────────────────────────────
# Formato script_desc.txt nel repo:
#   categoria/sottocartella/script.sh    # Descrizione breve
#
# Aggiornalo a mano quando aggiungi/modifichi script.
# Una riga per script, separatore: 4 spazi + # + spazio

_cache_file() {
  local cache_dir="$MARMITTA_CONFIG_DIR/cache"
  mkdir -p "$cache_dir"
  echo "${cache_dir}/$(echo "$CURRENT_SOURCE_REPO" | tr '/' '_')_${CURRENT_SOURCE_BRANCH}.desc"
}

# Scarica script_desc.txt dal repo e lo salva in cache
# 1 sola chiamata API invece di 1+N
gen_desc() {
  local cache_file
  cache_file=$(_cache_file)
  local desc_url="${CURRENT_BASE_URL}/script_desc.txt"

  print_step "Scarico script_desc.txt da ${CURRENT_SOURCE_REPO}..."

  local content
  content=$(curl -fsSL "$desc_url" 2>/dev/null || echo "")

  if [[ -z "$content" ]]; then
    print_warn "script_desc.txt non trovato nel repo."
    print_info "Crea il file ${CURRENT_SOURCE_REPO}/script_desc.txt con il formato:"
    print_info "  categoria/subdir/script.sh    # Descrizione breve"
    # Scrive file vuoto con timestamp — evita rigenerazione loop
    echo "# generated: $(date) — script_desc.txt assente" > "$cache_file"
    return 0
  fi

  # Salva in cache filtrando righe commento e vuote
  echo "$content" | grep -v '^\s*#' | grep -v '^\s*$' > "$cache_file"
  echo "# generated: $(date)" >> "$cache_file"
  local count
  count=$(grep -c '.' "$cache_file" 2>/dev/null || echo 0)
  print_ok "Descrizioni caricate (${count} script)."
}

load_script_descs() {
  local cache_file
  cache_file=$(_cache_file)

  local should_gen=0
  if [[ ! -f "$cache_file" ]]; then
    should_gen=1
  elif [[ -n "$(find "$cache_file" -mmin +1440 2>/dev/null)" ]]; then
    # Cache scaduta dopo 24h
    should_gen=1
  fi

  if [[ "$should_gen" -eq 1 ]]; then
    gen_desc
  fi

  SCRIPT_DESCS=$(cat "$cache_file" 2>/dev/null || echo "")
}

get_desc() {
  local path="$1"
  local desc
  desc=$(echo "$SCRIPT_DESCS" | grep "^${path}" | sed 's/.*# //' 2>/dev/null || true)
  echo "${desc:----}"
}

# ─────────────────────────────────────────────────────────────
# === CHECK AGGIORNAMENTO ===
# ─────────────────────────────────────────────────────────────
check_update() {
  [[ ! -f "$MARMITTA_INSTALL_PATH" ]] && return
  local local_sha remote_sha
  local_sha=$(git hash-object "$MARMITTA_INSTALL_PATH" 2>/dev/null || echo "")
  remote_sha=$(curl -s "${AUTH_HEADER[@]}" \
    "https://api.github.com/repos/${MARMITTA_REPO}/contents/marmitta.sh?ref=master" \
    | jq -r '.sha // empty' 2>/dev/null || echo "")
  [[ -z "$remote_sha" ]] && return

  if [[ "$local_sha" == "$remote_sha" ]]; then
    print_ok "Marmitta è aggiornato."
  else
    print_warn "Aggiornamento disponibile → ${CYAN}marmitta -u${RESET}"
  fi
}

# ─────────────────────────────────────────────────────────────
# === BANNER ===
# ─────────────────────────────────────────────────────────────
print_banner() {
  echo -e "${RED}█▀▄▀█${BLOOD_RED} ██   █▄▄▄▄ ${RED}█▀▄▀█${RESET} ${BLACK_PITCH}▄█${RED}    ▄▄▄▄▀${BLACK_PITCH}    ▄▄▄▄▀ ██${BLACK_PITCH}"
  sleep 0.04
  echo -e "${DARK_RED}█ █ █${RED} █ █  █  ▄▀ ${DARK_RED}█ █ █${RED} ██${BLACK_PITCH} ▀▀▀${BLOOD_RED} █${BLACK_PITCH}    ▀▀▀ ${RED}█    █ █${BLOOD_RED}"
  sleep 0.04
  echo -e "${RED}█ ▄ █${BLOOD_RED} █▄▄█ █▀▀▌  █ ▄ █${BLACK_PITCH} ██${RED}     █${BLACK_PITCH}        █    █▄▄█${BLOOD_RED}"
  sleep 0.04
  echo -e "${DARK_RED}█   █${RED} █  █ █  █  █   █${BLACK_PITCH} ▐█${RED}    █${DARK_RED}        █     █  █${RESET}"
  sleep 0.04
  echo -e "   ${RED}█     █   █      █   ▐   ▀        ▀         █${RESET}"
  sleep 0.04
  echo -e "  ${BLOOD_RED}▀     █   ▀      ▀                          ▀${RESET}"
  sleep 0.08
  echo -e "\n${CYAN}${BOLD}  MARMITTA — Script Launcher 😈${RESET}"
  echo -e "${DARK_GRAY}  source: ${CURRENT_SOURCE_LABEL} (${CURRENT_SOURCE_REPO}@${CURRENT_SOURCE_BRANCH})${RESET}\n"
}

# ─────────────────────────────────────────────────────────────
# === TREE DINAMICO ===
# ─────────────────────────────────────────────────────────────
print_tree() {
  echo -e "\n${MAGENTA}${BOLD}📁 ${CURRENT_SOURCE_REPO}${RESET}\n"
  local tree_data
  tree_data=$(curl -s "${AUTH_HEADER[@]}" \
    "https://api.github.com/repos/${CURRENT_SOURCE_REPO}/git/trees/${CURRENT_SOURCE_BRANCH}?recursive=1" \
    | jq -r '.tree[] | select(.type == "blob") | .path' 2>/dev/null)

  [[ -z "$tree_data" ]] && print_err "Impossibile recuperare struttura repo." && return 1

  local prev_folder=""
  while IFS= read -r path; do
    local folder file desc
    folder=$(dirname "$path")
    file=$(basename "$path")
    [[ "$folder" == "." ]] && folder="root"

    if [[ "$folder" != "$prev_folder" ]]; then
      [[ -n "$prev_folder" ]] && echo ""
      echo -e "${MAGENTA}├── ${folder}/${RESET}"
      prev_folder="$folder"
    fi

    desc=$(get_desc "$path")
    echo -e "│   └── ${YELLOW}${file}${RESET}  ${DARK_GRAY}${desc}${RESET}"
  done <<< "$tree_data"
  echo ""
}

# ─────────────────────────────────────────────────────────────
# === FZF: selettore script con preview descrizione ===
# ─────────────────────────────────────────────────────────────
fzf_scripts() {
  local prompt="$1"
  # Riceve le righe via stdin: "nome\tdescrizione"
  fzf \
    --height=20 --layout=reverse --border \
    --prompt="$prompt" \
    --with-nth=1 \
    --delimiter="\t" \
    --preview='echo -e "\033[0;96mℹ️  \033[0m" $(echo {} | cut -f2)' \
    --preview-window=up:3:wrap \
    --color=fg:#d6de35,bg:#121212,hl:#5f87af \
    --color=fg+:#00ffd9,bg+:#5c00e6,hl+:#5fd7ff \
    --color=pointer:green \
    --ansi | cut -f1
}

# ─────────────────────────────────────────────────────────────
# === ESECUZIONE SCRIPT (dopo selezione) ===
# ─────────────────────────────────────────────────────────────
run_script() {
  local chosen_path="$1"
  local chosen_name
  chosen_name=$(basename "$chosen_path")

  local url_full="${CURRENT_BASE_URL}/${chosen_path}"
  echo "$url_full" > "$MARMITTA_LAST_SCRIPT"

  echo -e "\n${CYAN}📜 Script:${RESET} ${YELLOW}${chosen_path}${RESET}"
  echo -e "${CYAN}🔗 URL:${RESET}    ${DARK_GRAY}${url_full}${RESET}"
  echo -e "\n${DARK_GRAY}[ ${GREEN}INVIO${DARK_GRAY} ] Esegui   [ ${YELLOW}i${DARK_GRAY} ] Parametri   [ ${RED}q${DARK_GRAY} ] Annulla${RESET}"

  local key
  read -rsn1 key

  case "$key" in
    i|I)
      echo
      read -rp "$(echo -e "${MAGENTA}⌨️  Argomenti: ${RESET}")" user_args
      local tmp
      tmp=$(mktemp)
      print_step "Download..."
      curl -fsSL "$url_full" -o "$tmp" || { print_err "Download fallito."; rm -f "$tmp"; return 1; }
      chmod +x "$tmp"
      echo -e "${GREEN}▶️  Eseguo:${RESET} ${YELLOW}${chosen_name} ${user_args}${RESET}\n"
      bash "$tmp" $user_args
      local exit_code=$?
      rm -f "$tmp"
      _post_run_pause "$exit_code"
      ;;
    q|Q)
      return 1   # torna indietro senza uscire
      ;;
    *)
      echo -e "\n${GREEN}▶️  Eseguo...${RESET}\n"
      bash <(curl -fsSL "$url_full")
      _post_run_pause $?
      ;;
  esac
}

# Pausa dopo esecuzione — mostra exit code e aspetta input prima di tornare al menu
_post_run_pause() {
  local exit_code="${1:-0}"
  echo ""
  if [[ "$exit_code" -eq 0 ]]; then
    echo -e "${GREEN}✅ Script terminato con successo (exit 0)${RESET}"
  else
    echo -e "${RED}⚠️  Script terminato con errore (exit ${exit_code})${RESET}"
  fi
  echo -e "${DARK_GRAY}─────────────────────────────────────────${RESET}"
  echo -e "${DARK_GRAY}[ INVIO ] Torna al menu   [ q ] Esci da marmitta${RESET}"
  local k
  read -rsn1 k
  [[ "$k" == "q" || "$k" == "Q" ]] && echo -e "
${DARK_GRAY}Uscita da marmitta.${RESET}" && exit 0
}

# ─────────────────────────────────────────────────────────────
# === NAVIGAZIONE 3 LIVELLI con loop (back a ogni livello) ===
# ─────────────────────────────────────────────────────────────
browse_and_run() {

  # Fetch categorie una volta sola (non cambiano durante la sessione)
  local categories
  categories=$(curl -s "${AUTH_HEADER[@]}" "$CURRENT_API_URL" \
    | jq -r '.[] | select(.type == "dir") | .name' 2>/dev/null || echo "")
  [[ -z "$categories" ]] && print_err "Nessuna categoria trovata." && return 1

  # ── Loop esterno: torna qui dopo ogni esecuzione o back ──
  while true; do

    # ── Livello 1: categorie ──
    local chosen_category
    chosen_category=$(echo "$categories" | \
      fzf \
        --height=18 --layout=reverse --border \
        --prompt="📁 Categoria > " \
        --header="  ${CURRENT_SOURCE_LABEL} — [ESC] esci" \
        --color=fg:#d6de35,bg:#121212,hl:#5f87af \
        --color=fg+:#00ffd9,bg+:#5c00e6,hl+:#5fd7ff \
        --color=pointer:green,header:italic \
        --ansi)

    # ESC / Ctrl+C al livello 1 → uscita da marmitta
    if [[ -z "$chosen_category" ]]; then
      echo -e "\n${DARK_GRAY}Uscita da marmitta.${RESET}"
      return 0
    fi

    # ── Loop medio: torna alla lista categorie con ESC ──
    while true; do

      local cat_json
      cat_json=$(curl -s "${AUTH_HEADER[@]}" "${CURRENT_API_URL}/${chosen_category}")

      local subdirs direct_scripts
      subdirs=$(echo "$cat_json" | jq -r \
        '.[] | select(.type == "dir") | .name' 2>/dev/null || echo "")
      direct_scripts=$(echo "$cat_json" | jq -r \
        '.[] | select(.type == "file" and (.name | endswith(".sh"))) | .name' 2>/dev/null || echo "")

      if [[ -n "$subdirs" ]]; then
        # ── Livello 2: subdir + script diretti ──
        local menu=""
        while IFS= read -r d; do
          [[ -z "$d" ]] && continue
          menu+="📁 ${d}\t—\n"
        done <<< "$subdirs"
        while IFS= read -r s; do
          [[ -z "$s" ]] && continue
          menu+="📜 ${s}\t$(get_desc "${chosen_category}/${s}")\n"
        done <<< "$direct_scripts"

        local chosen_l2
        chosen_l2=$(printf "%b" "$menu" | \
          fzf_scripts "📂 ${chosen_category} > [ESC] torna")

        # ESC → torna alle categorie
        [[ -z "$chosen_l2" ]] && break

        local item_name="${chosen_l2:2}"

        if [[ "$chosen_l2" == 📁* ]]; then
          # ── Loop interno: torna al livello 2 con ESC ──
          while true; do
            local sub_scripts
            sub_scripts=$(curl -s "${AUTH_HEADER[@]}" \
              "${CURRENT_API_URL}/${chosen_category}/${item_name}" \
              | jq -r '.[] | select(.type == "file" and (.name | endswith(".sh"))) | .name' \
              2>/dev/null || echo "")

            [[ -z "$sub_scripts" ]] && \
              print_warn "Nessuno script in ${chosen_category}/${item_name}" && break

            local script_menu=""
            while IFS= read -r s; do
              [[ -z "$s" ]] && continue
              script_menu+="${s}\t$(get_desc "${chosen_category}/${item_name}/${s}")\n"
            done <<< "$sub_scripts"

            local chosen_script
            chosen_script=$(printf "%b" "$script_menu" | \
              fzf_scripts "📜 ${chosen_category}/${item_name} > [ESC] torna")

            # ESC → torna al livello 2
            [[ -z "$chosen_script" ]] && break

            run_script "${chosen_category}/${item_name}/${chosen_script}"
            # Dopo esecuzione resta nel loop interno → può scegliere un altro script
          done

        else
          # Script diretto nel livello 2
          run_script "${chosen_category}/${item_name}"
        fi

      else
        # ── Livello 2 senza subdir: solo script diretti ──
        [[ -z "$direct_scripts" ]] && \
          print_warn "Nessuno script in ${chosen_category}" && break

        local script_menu=""
        while IFS= read -r s; do
          [[ -z "$s" ]] && continue
          script_menu+="${s}\t$(get_desc "${chosen_category}/${s}")\n"
        done <<< "$direct_scripts"

        local chosen_script
        chosen_script=$(printf "%b" "$script_menu" | \
          fzf_scripts "📜 ${chosen_category} > [ESC] torna")

        # ESC → torna alle categorie
        [[ -z "$chosen_script" ]] && break

        run_script "${chosen_category}/${chosen_script}"
        # Dopo esecuzione resta nel loop → può scegliere un altro script
      fi

    done
    # Fine loop medio — si torna alla selezione categoria

  done
}

# ─────────────────────────────────────────────────────────────
# === HANDLER: RESET ===
# ─────────────────────────────────────────────────────────────
do_reset() {
  echo -e "
${RED}${BOLD}⚠️  RESET MARMITTA${RESET}
"
  echo -e "Questa operazione eliminerà:"
  echo -e "  ${DARK_GRAY}•${RESET} Config:  ${YELLOW}${MARMITTA_CONFIG_FILE}${RESET}"
  echo -e "  ${DARK_GRAY}•${RESET} Sources: ${YELLOW}${MARMITTA_SOURCES_FILE}${RESET}"
  echo -e "  ${DARK_GRAY}•${RESET} Cache:   ${YELLOW}${MARMITTA_CONFIG_DIR}/cache/${RESET}"
  echo -e "
${RED}Tutto il setup verrà cancellato. Al prossimo avvio ripartirà da zero.${RESET}
"

  read -rp "$(echo -e "${YELLOW}Sei sicuro? [y/N]: ${RESET}")" confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    print_warn "Reset annullato."
    return 0
  fi

  # Seconda conferma per sicurezza
  read -rp "$(echo -e "${RED}Conferma definitiva — scrivi 'reset': ${RESET}")" confirm2
  if [[ "$confirm2" != "reset" ]]; then
    print_warn "Reset annullato."
    return 0
  fi

  rm -f  "$MARMITTA_CONFIG_FILE"
  rm -f  "$MARMITTA_SOURCES_FILE"
  rm -rf "${MARMITTA_CONFIG_DIR}/cache"
  print_ok "Reset completato. Esegui marmitta per riconfigurare."
}

# ─────────────────────────────────────────────────────────────
# === HANDLER: HELP ===
# ─────────────────────────────────────────────────────────────
print_help() {
  echo -e "\n${BOLD}${CYAN}MARMITTA${RESET} — Script Launcher\n"
  echo -e "${YELLOW}Uso:${RESET} marmitta [opzione]\n"
  printf "  %-30s %s\n" \
    "${CYAN}-l, --last${RESET}"      "Riesegue l'ultimo script" \
    "${MAGENTA}-t, --tree${RESET}"   "Struttura repo (source corrente)" \
    "${GREEN}-u${RESET}"             "Aggiorna marmitta all'ultima versione" \
    "${ORANGE}-Gsp${RESET}"          "Push rapido git (slither_push)" \
    "${CYAN}-py${RESET}"             "Launcher script Python (pitonzi)" \
    "${PURPLE}--login${RESET}"       "Login Bitwarden + salva GITHUB_TOKEN" \
    "${YELLOW}--setup, --config${RESET}"  "Riconfigura marmitta (token, branch)" \
    "${YELLOW}--add-source${RESET}"  "Aggiungi una source (repo GitHub)" \
    "${YELLOW}--gen-desc${RESET}"    "Rigenera cache descrizioni" \
    "${RED}--reset${RESET}"          "Cancella config, sources e cache" \
    "${RED}-h, --help${RESET}"       "Mostra questa guida"
  echo -e "\n${DARK_GRAY}Monitum amicum: usa -h prima di eseguire uno script sconosciuto! 😜${RESET}\n"
}

# ─────────────────────────────────────────────────────────────
# === HANDLER: UPDATE ===
# ─────────────────────────────────────────────────────────────
do_update() {
  print_step "Aggiornamento da ${MARMITTA_REPO}..."
  local tmp
  tmp=$(mktemp)
  curl -fsSL "${MARMITTA_RAW}/marmitta_update.sh" -o "$tmp" \
    || { print_err "Download fallito."; rm -f "$tmp"; exit 1; }
  chmod +x "$tmp"
  bash "$tmp"
  rm -f "$tmp"
}

# ─────────────────────────────────────────────────────────────
# === HANDLER: LAST ===
# ─────────────────────────────────────────────────────────────
do_last() {
  local last
  last=$(cat "$MARMITTA_LAST_SCRIPT" 2>/dev/null || echo "")
  [[ -z "$last" ]] && print_err "Nessuno script eseguito precedentemente." && exit 1
  echo -e "${CYAN}▶️  Rieseguo:${RESET} ${YELLOW}${last}${RESET}\n"
  bash <(curl -fsSL "$last")
}

# ─────────────────────────────────────────────────────────────
# === HANDLER: LOGIN ===
# ─────────────────────────────────────────────────────────────
do_login() {
  local tmp
  tmp=$(mktemp)
  print_step "Scarico marmitta_login.sh..."
  curl -fsSL "${MARMITTA_RAW}/marmitta_login.sh" -o "$tmp" \
    || { print_err "Download fallito."; rm -f "$tmp"; exit 1; }
  chmod +x "$tmp"
  bash "$tmp"
  rm -f "$tmp"
  load_config
  [[ -n "$GITHUB_TOKEN" ]] && export GITHUB_TOKEN && print_ok "Token aggiornato nella sessione."
}

# ─────────────────────────────────────────────────────────────
# === HANDLER: PITONZI ===
# ─────────────────────────────────────────────────────────────
call_pitonzi() {
  echo -e "${RED}██████╗ ${BLOOD_RED}██╗████████╗${GREEN_NEON} ██████╗ ${GREEN_TOXIC}███╗   ██╗${RED}███████╗${RESET}"
  sleep 0.04
  echo -e "${DARK_RED}██╔══██╗${RED}██║╚══██╔══╝${GREEN_SLIME} ██╔═══██╗${GREEN_NEON}████╗  ██║${DARK_RED}██╔════╝${RESET}"
  sleep 0.04
  echo -e "${RED}██████╔╝${BLOOD_RED}██║   ██║   ${GREEN_TOXIC}██║   ██║${GREEN_SLIME}██╔██╗ ██║${RED}█████╗${RESET}"
  sleep 0.04
  echo -e "${DARK_RED}██╔═══╝ ${RED}██║   ██║   ${GREEN_TOXIC}██║   ██║${GREEN_DARK}██║╚██╗██║${RED}██╔══╝${RESET}"
  sleep 0.08
  echo -e "${RED}██║     ${BLOOD_RED}██║   ██║  ${GREEN_SLIME}╚██████╔╝${GREEN_TOXIC}██║ ╚████║${GREEN_NEON}██║${RESET}\n"

  local first_source repo branch
  first_source=$(get_sources | head -1)
  repo=$(echo "$first_source"   | cut -d'|' -f2 | xargs)
  branch=$(echo "$first_source" | cut -d'|' -f3 | xargs)
  branch="${branch:-${DEFAULT_BRANCH}}"

  local tmp
  tmp=$(mktemp)
  curl -fsSL "https://raw.githubusercontent.com/${repo}/${branch}/ai/pitonzi/run_pitonzi.sh" -o "$tmp"
  chmod +x "$tmp"
  bash "$tmp" "$@"
  rm -f "$tmp"
}

# ─────────────────────────────────────────────────────────────
# === HANDLER: SLITHER PUSH ===
# ─────────────────────────────────────────────────────────────
do_slither_push() {
  local first_source repo branch
  first_source=$(get_sources | head -1)
  repo=$(echo "$first_source"   | cut -d'|' -f2 | xargs)
  branch=$(echo "$first_source" | cut -d'|' -f3 | xargs)
  branch="${branch:-${DEFAULT_BRANCH}}"

  sh -c "$(curl -fsSL "https://raw.githubusercontent.com/${repo}/${branch}/git/push/slither_push_repo.sh")" -- "$@"
}

# ─────────────────────────────────────────────────────────────
# === ENTRY POINT ===
# ─────────────────────────────────────────────────────────────
check_internet
install_dependencies

# Flag che non richiedono config né sources — gestiti PRIMA di ensure_config
case "${1:-}" in
  -h|--help)        print_help;    exit 0 ;;
  --reset)          do_reset;      exit 0 ;;
  -u)               do_update;     exit 0 ;;
esac

ensure_config

# Flag che richiedono config ma non source
case "${1:-}" in
  --setup|--config) setup_config;  exit 0 ;;
  --login)          do_login;      exit 0 ;;
  --add-source)     do_add_source; exit 0 ;;
  -l|--last)        do_last;       exit 0 ;;
esac

# Selezione source (fzf se più d'una, automatica se unica)
select_source

# Flag con source
case "${1:-}" in
  -t|--tree)    load_script_descs; print_tree;                  exit 0 ;;
  --gen-desc)   gen_desc;                                        exit 0 ;;
  -py)          shift; call_pitonzi "$@";                        exit 0 ;;
  -Gsp)         shift; do_slither_push "$@";                     exit 0 ;;
esac

# Menu principale
load_script_descs
print_banner
check_update
echo ""
browse_and_run