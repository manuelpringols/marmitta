#!/bin/bash

# Funzione per rilevare OS e package manager
get_package_manager() {
    os_name=$(uname)
    if [[ "$os_name" == "Linux" ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            case "$ID" in
                ubuntu|debian)
                    echo "apt"
                    ;;
                fedora|centos|rhel)
                    echo "dnf"
                    ;;
                arch)
                    echo "pacman"
                    ;;
                opensuse-leap|opensuse-tumbleweed)
                    echo "zypper"
                    ;;
                *)
                    # fallback
                    if command -v apt &>/dev/null; then
                        echo "apt"
                    elif command -v dnf &>/dev/null; then
                        echo "dnf"
                    elif command -v pacman &>/dev/null; then
                        echo "pacman"
                    elif command -v zypper &>/dev/null; then
                        echo "zypper"
                    else
                        echo ""
                    fi
                    ;;
            esac
        else
            echo ""
        fi
    elif [[ "$os_name" == "Darwin" ]]; then
        echo "brew"
    elif [[ "$os_name" == "MINGW"* || "$os_name" == "CYGWIN"* || "$os_name" == "MSYS"* ]]; then
        # Windows con Git Bash
        if command -v choco &>/dev/null; then
            echo "choco"
        elif command -v winget &>/dev/null; then
            echo "winget"
        else
            echo ""
        fi
    else
        echo ""
    fi
}

# Funzione per installare un pacchetto usando il package manager rilevato
install_package() {
    local pkg="$1"
    pm=$(get_package_manager)
    if [[ -z "$pm" ]]; then
        echo "Package manager non rilevato o non supportato. Installa $pkg manualmente."
        return 1
    fi

    echo "Provo a installare $pkg con $pm..."

    case "$pm" in
        apt)
            sudo apt update && sudo apt install -y "$pkg"
            ;;
        dnf)
            sudo dnf install -y "$pkg"
            ;;
        pacman)
            sudo pacman -Sy --noconfirm "$pkg"
            ;;
        zypper)
            sudo zypper install -y "$pkg"
            ;;
        brew)
            brew install "$pkg"
            ;;
        choco)
            choco install "$pkg" -y
            ;;
        winget)
            winget install --id="$pkg" -e --accept-source-agreements --accept-package-agreements
            ;;
        *)
            echo "Package manager $pm non supportato per installazione automatica."
            return 1
            ;;
    esac
}

# Funzione per copiare negli appunti cross-platform
copy_to_clipboard() {
    local text="$1"
    if command -v xclip &>/dev/null; then
        echo -n "$text" | xclip -selection clipboard
        echo "📋 Directory copiata negli appunti con xclip."
    elif command -v pbcopy &>/dev/null; then
        echo -n "$text" | pbcopy
        echo "📋 Directory copiata negli appunti con pbcopy."
    elif command -v clip &>/dev/null; then
        echo -n "$text" | clip
        echo "📋 Directory copiata negli appunti con clip."
    else
        echo "⚠️ Nessun tool clipboard trovato (xclip/pbcopy/clip). Copia manuale richiesta."
    fi
}

# Verifica che fzf sia installato, altrimenti propone di installarlo
if ! command -v fzf &>/dev/null; then
    echo "fzf non è installato."
    read -rp "Vuoi installare fzf? [y/N] " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
        install_package fzf || { echo "Installazione fzf fallita, esco."; exit 1; }
    else
        echo "fzf è necessario per questo script. Esco."
        exit 1
    fi
fi

# Verifica che almeno un tool clipboard sia installato (xclip, pbcopy o clip)
if ! command -v xclip &>/dev/null && ! command -v pbcopy &>/dev/null && ! command -v clip &>/dev/null; then
    echo "Nessun tool per la clipboard (xclip, pbcopy, clip) è installato."
    read -rp "Vuoi installare xclip? [y/N] " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
        install_package xclip || echo "Installazione xclip fallita. Lo script continuerà senza copia automatica."
    else
        echo "Continuerò senza supporto per la clipboard."
    fi
fi

echo -e "\e[1;32mDigita parte del nome del file da cercare \e[1;31m(CRTL+C per uscire)\e[0m:"

while true; do
    read -rp "> " query
    [[ -z "$query" ]] && continue

    # Cerca i file che contengono la query nel nome (limitato alla home per sicurezza)
    mapfile -t results < <(find ~ -type f -iname "*$query*" 2>/dev/null)

    if [[ ${#results[@]} -eq 0 ]]; then
        echo "Nessun file trovato con '$query'. Riprova."
        continue
    fi

    # Passa la lista a fzf per la selezione
    selected=$(printf '%s\n' "${results[@]}" | fzf --height 40% --border --prompt="Seleziona file: ")

    if [[ -z "$selected" ]]; then
        echo "Nessuna selezione fatta, riprova."
        continue
    fi

    dir_path=$(dirname "$selected")

    # Controlla se abbiamo permessi di esecuzione sulla directory per entrare
    if [[ -x "$dir_path" ]]; then
        cd "$dir_path" || { echo "Errore nel cd nella directory $dir_path"; exit 1; }
        echo "Entrato in: $(pwd)"
        copy_to_clipboard "$(pwd)"
        break
    else
        echo "Non hai permesso di entrare in $dir_path"
        echo "Cartella corrente: $(pwd)"
        copy_to_clipboard "$(pwd)"
        break
    fi
done
