#!/bin/bash
# @desc: Login Bitwarden CLI per ottenere e salvare il GitHub token in modo sicuro

MARMITTA_CONFIG_DIR="$HOME/.config/marmitta"
MARMITTA_CONFIG_FILE="$MARMITTA_CONFIG_DIR/config"

GREEN="\e[92m"
RED="\e[38;5;160m"
CYAN="\e[96m"
YELLOW="\e[93m"
MAGENTA="\e[95m"
DARK_GRAY="\e[90m"
BOLD="\e[1m"
RESET="\e[0m"

print_ok()   { echo -e "${GREEN}✅ $1${RESET}"; }
print_err()  { echo -e "${RED}❌ $1${RESET}"; exit 1; }
print_warn() { echo -e "${YELLOW}⚠️  $1${RESET}"; }
print_info() { echo -e "${CYAN}ℹ️  $1${RESET}"; }
print_step() { echo -e "${MAGENTA}➡️  $1${RESET}"; }

echo -e "\n${CYAN}${BOLD}🔐 Marmitta Login — Bitwarden${RESET}\n"
echo -e "${DARK_GRAY}  Recupera il GitHub token da Bitwarden"
echo -e "  e lo salva nel config di marmitta (chmod 600).${RESET}\n"

# ─────────────────────────────────────────────────────────────
# === VERIFICA BW CLI ===
# ─────────────────────────────────────────────────────────────
if ! command -v bw &>/dev/null; then
  echo -e "${RED}❌ Bitwarden CLI non trovato.${RESET}\n"
  echo -e "${YELLOW}Installalo con uno di questi metodi:${RESET}\n"
  echo -e "  ${CYAN}npm${RESET}     →  npm install -g @bitwarden/cli"
  echo -e "  ${CYAN}Arch${RESET}    →  sudo pacman -S bitwarden-cli"
  echo -e "  ${CYAN}Debian${RESET}  →  sudo apt install bitwarden-cli"
  echo -e "  ${CYAN}Fedora${RESET}  →  sudo dnf install bitwarden-cli"
  echo -e "  ${CYAN}macOS${RESET}   →  brew install bitwarden-cli"
  echo -e "  ${CYAN}Snap${RESET}    →  sudo snap install bw"
  echo -e "\n${DARK_GRAY}Documentazione: https://bitwarden.com/help/cli/${RESET}\n"
  exit 1
fi

BW_VERSION=$(bw --version 2>/dev/null)
print_info "Bitwarden CLI versione: ${BW_VERSION}"

# ─────────────────────────────────────────────────────────────
# === FUNZIONI BW ===
# ─────────────────────────────────────────────────────────────

# Esegue bw login o bw logout con TTY reale ereditato (nessuna pipe).
# Inquirer.js funziona correttamente solo con stdin/stdout collegati al TTY.
_bw_do() {
  local cmd="$1"
  print_step "bw ${cmd} in corso..."
  NODE_NO_WARNINGS=1 bw "$cmd" < /dev/tty > /dev/tty 2>&1
  local exit_code=$?
  if [[ $exit_code -ne 0 ]]; then
    print_err "bw ${cmd} fallito (exit ${exit_code}). Prova: bw logout && bw login manualmente."
    return 1
  fi
  print_ok "bw ${cmd} completato."
}

# Recupera il session token tramite --raw: stampa solo il token grezzo,
# nessun parsing dell'output necessario.
_bw_get_session() {
  print_step "Recupero sessione vault (master password richiesta)..."
  local session
  session=$(NODE_NO_WARNINGS=1 bw unlock --raw < /dev/tty 2>/dev/null)
  if [[ -z "$session" ]]; then
    print_err "Sessione non ottenuta. Prova: bw unlock --raw manualmente."
    return 1
  fi
  BW_SESSION="$session"
  export BW_SESSION
  print_ok "Sessione ottenuta."
}

# ─────────────────────────────────────────────────────────────
# === LOGIN / UNLOCK ===
# ─────────────────────────────────────────────────────────────
BW_STATUS=$(NODE_NO_WARNINGS=1 bw status 2>/dev/null | jq -r '.status // "unauthenticated"')
print_info "Stato vault: ${BW_STATUS}"

case "$BW_STATUS" in
  unauthenticated)
    _bw_do "login" || exit 1
    ;;
  locked|unlocked)
    : # già autenticato — _bw_get_session chiederà la master password se locked
    ;;
  *)
    print_err "Stato Bitwarden sconosciuto: ${BW_STATUS}"
    ;;
esac

# Recupera sempre la sessione via --raw
_bw_get_session || exit 1

# ─────────────────────────────────────────────────────────────
# === CERCA ITEM "github-token" ===
# ─────────────────────────────────────────────────────────────
print_step "Cerco item 'github-token' nel vault..."
print_info "Sessione: ${BW_SESSION:0:10}... (${#BW_SESSION} char)"

ITEM=$(bw get item "github-token" --session "$BW_SESSION" 2>/dev/null)

if [[ -z "$ITEM" || "$ITEM" == "null" ]]; then
  print_warn "Item 'github-token' non trovato. Ricerca manuale..."
  read -rp "$(echo -e "${YELLOW}🔍 Nome esatto item Bitwarden: ${RESET}")" item_name < /dev/tty
  ITEM=$(bw get item "$item_name" --session "$BW_SESSION" < /dev/tty 2>/dev/null)
  [[ -z "$ITEM" || "$ITEM" == "null" ]] && print_err "Item '${item_name}' non trovato."
fi

ITEM_NAME=$(echo "$ITEM" | jq -r '.name')
print_ok "Item trovato: ${CYAN}${ITEM_NAME}${RESET}"

# ─────────────────────────────────────────────────────────────
# === ESTRAI TOKEN (note → password → campi custom hidden) ===
# ─────────────────────────────────────────────────────────────
print_step "Estraggo token..."

# Prende l'ultima riga non vuota delle note — sempre il token più recente
GITHUB_TOKEN=$(echo "$ITEM" | jq -r '.notes // empty' | grep -v '^\s*$' | tail -1 | tr -d '[:space:]')

if [[ -z "$GITHUB_TOKEN" ]]; then
  print_warn "Note vuote — provo campo password..."
  GITHUB_TOKEN=$(echo "$ITEM" | jq -r '.login.password // empty' | tr -d '[:space:]')
fi

if [[ -z "$GITHUB_TOKEN" ]]; then
  print_warn "Password vuota — provo campi custom hidden..."
  GITHUB_TOKEN=$(echo "$ITEM" | jq -r '.fields[]? | select(.type == 1) | .value' 2>/dev/null | head -1 | tr -d '[:space:]')
fi

[[ -z "$GITHUB_TOKEN" ]] && print_err "Token non trovato in note, password né campi custom."

if [[ "$GITHUB_TOKEN" != ghp_* && "$GITHUB_TOKEN" != github_pat_* ]]; then
  print_warn "Il valore non sembra un GitHub PAT (non inizia con ghp_ o github_pat_)."
  read -rp "$(echo -e "${YELLOW}Continuare? [y/N]: ${RESET}")" cont < /dev/tty
  [[ ! "$cont" =~ ^[Yy]$ ]] && exit 1
fi

# ─────────────────────────────────────────────────────────────
# === VALIDA TOKEN ===
# ─────────────────────────────────────────────────────────────
print_info "Token estratto: ${DARK_GRAY}${GITHUB_TOKEN:0:20}...${RESET} (${#GITHUB_TOKEN} char)"
print_step "Valido il token su GitHub..."
GH_USER=$(curl -s --max-time 10   -H "Authorization: token ${GITHUB_TOKEN}"   https://api.github.com/user | jq -r '.login // empty')

if [[ -z "$GH_USER" ]]; then
  echo -e "
${YELLOW}💡 Debug suggerimenti:${RESET}"
  echo -e "  ${DARK_GRAY}1)${RESET} Aggiorna il token in Bitwarden con uno valido"
  echo -e "  ${DARK_GRAY}2)${RESET} Fai bw logout && bw login per forzare un sync completo"
  echo -e "  ${DARK_GRAY}3)${RESET} Verifica il token su: ${CYAN}https://github.com/settings/tokens${RESET}"
  print_err "Token non valido o GitHub non raggiungibile."
fi
print_ok "Token valido — utente: ${CYAN}${GH_USER}${RESET}"

# ─────────────────────────────────────────────────────────────
# === SALVA NEL CONFIG MARMITTA ===
# ─────────────────────────────────────────────────────────────
print_step "Salvo nel config di marmitta..."
mkdir -p "$MARMITTA_CONFIG_DIR"
chmod 700 "$MARMITTA_CONFIG_DIR"

if [[ -f "$MARMITTA_CONFIG_FILE" ]]; then
  if grep -q "^GITHUB_TOKEN=" "$MARMITTA_CONFIG_FILE"; then
    sed -i "s|^GITHUB_TOKEN=.*|GITHUB_TOKEN=\"${GITHUB_TOKEN}\"|" "$MARMITTA_CONFIG_FILE"
  else
    echo "GITHUB_TOKEN=\"${GITHUB_TOKEN}\"" >> "$MARMITTA_CONFIG_FILE"
  fi
else
  cat > "$MARMITTA_CONFIG_FILE" <<EOF
# Marmitta config — generato il $(date)
GITHUB_TOKEN="${GITHUB_TOKEN}"
DEFAULT_BRANCH="master"
EOF
fi

chmod 600 "$MARMITTA_CONFIG_FILE"
print_ok "Token salvato in ${MARMITTA_CONFIG_FILE} ${DARK_GRAY}(chmod 600)${RESET}"
export GITHUB_TOKEN

# ─────────────────────────────────────────────────────────────
# === LOCK VAULT ===
# ─────────────────────────────────────────────────────────────
echo ""
read -rp "$(echo -e "${YELLOW}🔒 Bloccare il vault ora? [Y/n]: ${RESET}")" lock < /dev/tty
if [[ ! "$lock" =~ ^[Nn]$ ]]; then
  bw lock >/dev/null 2>&1
  unset BW_SESSION
  print_ok "Vault bloccato."
fi

echo -e "\n${GREEN}${BOLD}🎉 Login completato!${RESET}"
echo -e "${DARK_GRAY}  Utente GitHub: ${RESET}${GH_USER}"
echo -e "${DARK_GRAY}  Config:        ${RESET}${MARMITTA_CONFIG_FILE}\n"