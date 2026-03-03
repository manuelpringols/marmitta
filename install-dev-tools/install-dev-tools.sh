#!/bin/bash

# Colori per lo spinner
colors=(31 32 33 34 35 36)
color_index=0

# Spinner animato colorato
spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    while kill -0 $pid 2>/dev/null; do
        local color="\e[${colors[$color_index]}m"
        local reset="\e[0m"
        local temp=${spinstr#?}
        printf " [%b%c%b]  \r" "$color" "$spinstr" "$reset"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        color_index=$(( (color_index + 1) % ${#colors[@]} ))
    done
    printf "    \r"
}

# Funzione di installazione
install_package() {
    echo -ne "🔧 Installando $1...\n"
    (eval "$2" &> /dev/null) &
    spinner
    echo -e "✅ $1 installato.\n"
}

# Aggiorna pacchetti
sudo pacman -Syu --noconfirm

# --- Installa yay se non presente ---
if ! command -v yay &> /dev/null; then
    echo "📦 yay non trovato. Lo installo..."
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay ||  return 1
    makepkg -si --noconfirm
    cd .. ||  return 1
    rm -rf yay
    echo "✅ yay installato con successo!"
else
    echo "✅ yay già installato."
fi

# Usa yay per i pacchetti AUR (e fallback per quelli ufficiali)
install_package "Visual Studio Code" "yay -S --noconfirm code"
install_package "Docker" "sudo pacman -S --noconfirm docker"
install_package "Docker Compose" "sudo pacman -S --noconfirm docker-compose"
install_package "PostgreSQL" "sudo pacman -S --noconfirm postgresql"
install_package "WezTerm" "yay -S --noconfirm wezterm"
install_package "Spotify" "yay -S --noconfirm spotify"
install_package "Firefox" "sudo pacman -S --noconfirm firefox"
install_package "Discord" "sudo pacman -S --noconfirm discord"
install_package "npm" "sudo pacman -S --noconfirm npm"
install_package "Angular CLI" "sudo npm install -g @angular/cli"
install_package "Micro (editor terminale)" "sudo pacman -S --noconfirm micro"

# Avvio Docker
echo "🔧 Abilitazione e avvio Docker..."
sudo systemctl enable docker
sudo systemctl start docker
echo "✅ Docker abilitato e avviato."

echo -e "\n🎉 Tutti i programmi di sviluppo sono stati installati con successo!"
