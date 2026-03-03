#!/bin/bash
set -euo pipefail

# === CONFIG ===
GITHUB_USER="manuelpringols"
GITHUB_REPO_PITONZI="pitonzi"
GITHUB_REPO_SH="scripts"

REPO_API_URL="https://api.github.com/repos/$GITHUB_USER/$GITHUB_REPO_PITONZI/contents"
AUTH_HEADER=()
[ -n "${GITHUB_TOKEN:-}" ] && AUTH_HEADER=(-H "Authorization: token $GITHUB_TOKEN")

# === COLORI ===
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

run_resolve_deps() {
  local local_path="./resolve_deps.py"
  local tmp_path="/tmp/resolve_deps.py"

  if [[ -f "$local_path" ]]; then
    python3 "$local_path" "$1"
  else
    echo -e "${CYAN}📥 Scarico resolve_deps.py da remoto...${RESET}" >&2 # manda in stderr
    curl -fsSL "https://raw.githubusercontent.com/manuelpringols/scripts/master/pitonzi/resolve_deps.py?cache_bust=$(date +%s)" -o "$tmp_path" || {
      echo -e "${RED}❌ Download fallito${RESET}"
      return 1
    }
    chmod +x "$tmp_path"
    python3 "$tmp_path" "$1"
  fi
}
run_pitonzi() {
  local repo_user="manuelpringols"
  local repo_name="scripts"
  local file_path="pitonzi/run_pitonzi.sh"
  local tmp_path="/tmp/run_pitonzi.sh"
  local api_url="https://api.github.com/repos/$repo_user/$repo_name/contents/$file_path"

  echo -e "${CYAN}📦 Controllo file remoto: $file_path...${RESET}"

  # Prendi l'URL del file raw via API GitHub
  local file_json
  file_json=$(curl -s "$api_url")
  local script_url
  script_url=$(echo "$file_json" | jq -r .download_url)

  if [[ -z "$script_url" || "$script_url" == "null" ]]; then
    echo -e "${RED}❌ Errore: URL per $file_path non trovato${RESET}"
    return 1
  fi

  echo -e "${CYAN}📥 Scarico run_pitonzi.sh da $script_url...${RESET}"
  curl -fsSL "$script_url" -o "$tmp_path" || {
    echo -e "${RED}❌ Download fallito${RESET}"
    return 1
  }

  chmod +x "$tmp_path"
  echo -e "${GREEN}✅ Esecuzione di run_pitonzi.sh...${RESET}"
  "$tmp_path"
}

while true; do
  echo -e "\n${MAGENTA}📁 Seleziona una cartella:${RESET}"
  folders_json=$(curl -s "${AUTH_HEADER[@]}" "$REPO_API_URL")

  if echo "$folders_json" | grep -q 'API rate limit exceeded'; then
    echo -e "${RED}❌ API rate limit superato. Esporta GITHUB_TOKEN per aumentare il limite.${RESET}"
    exit 1
  fi

   desc_url="https://raw.githubusercontent.com/manuelpringols/scripts/master/pitonzi/script_desc.txt"
 descs=$(curl -fsSL "$desc_url")

  folders=$(echo "$folders_json" | jq -r '.[] | select(.type == "dir") | .name')
  selected_folder=$(echo -e "🔙 Torna indietro\n$folders" | fzf --height=20 --layout=reverse --border --prompt="📁 Cartella > ")

  [[ -z "$selected_folder" || "$selected_folder" == "🔙 Torna indietro" ]] && echo -e "${RED}❌ Annullato.${RESET}" && exit 1
  echo -e "${GREEN}✅ Hai scelto: $selected_folder${RESET}"

  scripts_json=$(curl -s "${AUTH_HEADER[@]}" "$REPO_API_URL/$selected_folder")
  scripts=$(echo "$scripts_json" | jq -r '.[] | select(.name | endswith(".py")) | .name')



  # Preparazione lista con descrizioni
script_list=""
first=true
while IFS= read -r script; do
  desc=$(echo "$descs" | grep "$selected_folder/$script" | sed 's/.*# //')
  desc=${desc:-"Nessuna descrizione disponibile"}

  if [ "$first" = true ]; then
    script_list="$script\t$desc"
    first=false
  else
    script_list="$script_list\n$script\t$desc"
  fi
done <<< "$scripts"
  # selected_script=$(echo -e "🔙 Torna indietro\n$scripts" | fzf --height=20 --layout=reverse --border --prompt=" > ")
selected_script=$(echo -e "🔙 Torna indietro\n$script_list" | \
  fzf --height=15 --layout=reverse --border --prompt="📜 Script > " \
      --with-nth=1 \
      --delimiter="\t" \
      --ansi \
      --preview='echo {} | cut -f2' \
      --color=fg:white,bg:#292929,hl:red,pointer:green,marker:yellow \
      --color=fg:#d6de35,bg:#121212,hl:#5f87af | cut -f1)
  [[ -z "$selected_script" || "$selected_script" == "🔙 Torna indietro" ]] && continue

  # Ottieni URL raw script
  script_url=$(echo "$scripts_json" | jq -r ".[] | select(.name == \"$selected_script\") | .download_url")
  if [[ -z "$script_url" ]]; then
    echo -e "${RED}❌ Impossibile ottenere l'URL dello script selezionato.${RESET}"
    exit 1
  fi

  echo -e "${GREEN}▶️ Script selezionato: $selected_script${RESET}"
  echo -e "${CYAN}▶️ URL script: $script_url${RESET}"

  # Crea ambiente virtuale temporaneo
 venv_dir="/dev/shm/venv_${RANDOM}"
 mkdir "$venv_dir"

  echo -e "${CYAN}🛠 Creo ambiente virtuale in $venv_dir${RESET}"
  python3 -m venv "$venv_dir"
  source "$venv_dir/bin/activate"

  # Aggiorna pip e setuptools nel venv
  pip install --upgrade pip setuptools >/dev/null

  # Scarica lo script in temp file
  temp_script=$(mktemp --suffix=".py")
  curl -fsSL "$script_url" -o "$temp_script"
  chmod +x "$temp_script"

  read -rp $'\033[36mPremi INVIO per eseguire senza argomenti, digita \033[35mi\033[36m per inserire argomenti, oppure \033[35ms\033[36m per salvare l\'env localmente:\033[0m ' key

  script_name_noext=$(basename "$selected_script" .py)
  saved_venv_dir="./venv_${script_name_noext}"

  case "$key" in
  "")
    echo -e "${CYAN}📦 Risolvo e installo dipendenze con resolve_deps.py...${RESET}"
    deps=$(run_resolve_deps "$temp_script" | tail -n1)
    echo "Deps parsed: '$deps'"

    if [[ -n "$deps" ]]; then
      echo -e "${CYAN}📦 Installazione moduli pip: $deps${RESET}"
      pip install $deps
    fi
    echo -e "${GREEN}▶️ Eseguo script senza argomenti...${RESET}"
    python3 "$temp_script"
    deactivate
    rm -rf "$venv_dir" "$temp_script"
    ;;
  i)
    echo -e "\n${MAGENTA}⌨️ Inserisci gli argomenti da passare allo script:${RESET}"
    read -rp "Args: " user_args
    echo -e "${CYAN}📦 Risolvo e installo dipendenze con resolve_deps.py...${RESET}"
    deps=$(run_resolve_deps "$temp_script")
    if [[ -n "$deps" ]]; then
      echo -e "${CYAN}📦 Installazione moduli pip: $deps${RESET}"
      pip install $deps
    fi
    echo -e "${GREEN}▶️ Eseguo script con argomenti:${RESET} $user_args"
    python3 "$temp_script" $user_args
    deactivate
    rm -rf "$venv_dir" "$temp_script"
    ;;
  s)
    echo -e "${CYAN}💾 Creo ambiente virtuale persistente in ${saved_venv_dir}${RESET}"
    python3 -m venv "$saved_venv_dir"
    source "$saved_venv_dir/bin/activate"
    echo -e "${CYAN}📦 Risolvo e installo dipendenze con resolve_deps.py...${RESET}"
    deps=$(run_resolve_deps "$temp_script")
    if [[ -n "$deps" ]]; then
      echo -e "${CYAN}📦 Installazione moduli pip: $deps${RESET}"
      pip install $deps
    fi
    echo -e "${GREEN}▶️ Eseguo script e salvo tutto localmente...${RESET}"
    python3 "$temp_script"
    deactivate
    mv "$temp_script" "./${selected_script}"
    echo -e "${GREEN}✅ Script e venv salvati in: ./${selected_script} e ${saved_venv_dir}${RESET}"
    ;;
  *)
    echo -e "${YELLOW}⚠️ Input non valido. Premi INVIO, digita 'i' oppure 's'.${RESET}"
    rm -rf "$venv_dir" "$temp_script"
    exit 1
    ;;
  esac

  exit 0
done
Deps parsed: 'colorama InquirerPy PIL platform pytesseract'
