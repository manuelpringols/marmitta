#!/bin/bash
# @desc: Aggiorna marmitta all'ultima versione dal repo ufficiale

MARMITTA_REPO="manuelpringols/marmitta"
MARMITTA_RAW="https://raw.githubusercontent.com/${MARMITTA_REPO}/master"
MARMITTA_INSTALL_PATH="/usr/local/bin/marmitta"

GREEN="\e[92m"
RED="\e[38;5;160m"
CYAN="\e[96m"
YELLOW="\e[93m"
DARK_GRAY="\e[90m"
BOLD="\e[1m"
RESET="\e[0m"

print_ok()   { echo -e "${GREEN}✅ $1${RESET}"; }
print_err()  { echo -e "${RED}❌ $1${RESET}"; exit 1; }
print_warn() { echo -e "${YELLOW}⚠️  $1${RESET}"; }
print_info() { echo -e "${CYAN}ℹ️  $1${RESET}"; }
print_step() { echo -e "${YELLOW}➡️  $1${RESET}"; }

echo -e "\n${CYAN}${BOLD}🔄 Aggiornamento Marmitta${RESET}\n"

# ── Versione locale ──
if [[ ! -f "$MARMITTA_INSTALL_PATH" ]]; then
  print_info "Marmitta non trovata in ${MARMITTA_INSTALL_PATH}, eseguo installazione."
  LOCAL_SHA=""
else
  LOCAL_SHA=$(git hash-object "$MARMITTA_INSTALL_PATH" 2>/dev/null || echo "")
fi

# ── Versione remota (opzionale — se fallisce scarica comunque) ──
print_step "Controllo versione remota..."
REMOTE_SHA=$(curl -s --max-time 10 \
  "https://api.github.com/repos/${MARMITTA_REPO}/contents/marmitta.sh?ref=master" \
  | jq -r '.sha // empty' 2>/dev/null || echo "")

if [[ -z "$REMOTE_SHA" ]]; then
  print_warn "SHA remoto non disponibile (repo non ancora creato o connessione lenta) — procedo con il download diretto."
elif [[ -n "$LOCAL_SHA" && "$LOCAL_SHA" == "$REMOTE_SHA" ]]; then
  print_ok "Marmitta è già all'ultima versione."
  exit 0
fi

# ── Download ──
print_step "Download nuova versione da ${MARMITTA_RAW}/marmitta.sh ..."
TMP=$(mktemp)
if ! curl -fsSL "${MARMITTA_RAW}/marmitta.sh" -o "$TMP"; then
  rm -f "$TMP"
  print_err "Download fallito. Controlla che il repo ${MARMITTA_REPO} esista e sia pubblico."
fi

# ── Installa ──
print_step "Installazione in ${MARMITTA_INSTALL_PATH}..."
if sudo mv "$TMP" "$MARMITTA_INSTALL_PATH" && sudo chmod +x "$MARMITTA_INSTALL_PATH"; then
  print_ok "Marmitta aggiornata con successo!"
  echo -e "${DARK_GRAY}  Percorso: ${MARMITTA_INSTALL_PATH}${RESET}\n"
else
  rm -f "$TMP"
  print_err "Installazione fallita. Prova: sudo cp marmitta.sh ${MARMITTA_INSTALL_PATH}"
fi