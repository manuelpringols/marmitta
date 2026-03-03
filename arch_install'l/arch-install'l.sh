#!/bin/bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

errore() {
  echo -e "${RED}❌ Errore: $1${NC}"
  exit 1
}

ok() {
  echo -e "${GREEN}✅ $1${NC}"
}

scegli_disco() {
  # Controlla che fzf sia installato
  if ! command -v fzf &>/dev/null; then
    errore "fzf non è installato, installalo con 'pacman -Sy fzf' prima di eseguire lo script"
  fi

  # Prendi i dischi fisici (non loop)
  mapfile -t disks < <(lsblk -dpno NAME,SIZE,MODEL | grep -v loop)

  if [[ ${#disks[@]} -eq 0 ]]; then
    errore "Nessun disco rilevato"
  fi

  echo "Seleziona il disco su cui installare Arch (usa frecce e invio):"
  local selected=$(printf "%s\n" "${disks[@]}" | fzf --height=10 --border --ansi --prompt="Disco: ")

  if [[ -z "$selected" ]]; then
    errore "Nessun disco selezionato"
  fi

  # Estraggo solo il nome dispositivo (prima colonna)
  local disk=$(echo "$selected" | awk '{print $1}')
  echo "$disk"
}


conferma_distruzione() {
  local disk=$1
  echo -e "${RED}ATTENZIONE: Tutto il contenuto di $disk sarà distrutto!${NC}"
  read -rp "Scrivi 'CONFERMO' per procedere: " conferma
  [[ "$conferma" == "CONFERMO" ]] || errore "Installazione annullata"
}

richiedi_dimensione() {
  local label=$1
  local size
  while true; do
    read -rp "Inserisci la dimensione della partizione $label (es: 20G o 100% per tutto lo spazio rimanente): " size
    if [[ "$size" =~ ^[0-9]+[GM]$ ]] || [[ "$size" == "100%" ]]; then
      echo "$size"
      break
    else
      echo "Formato non valido. Usa es: 20G, 50G o 100%"
    fi
  done
}

# --- INIZIO SCRIPT PRINCIPALE ---

echo "----- INSTALLAZIONE ARCH LINUX AUTOMATICA -----"
disk=$(scegli_disco)
conferma_distruzione "$disk"

echo "Pulizia tabelle partizioni su $disk"
sgdisk --zap-all "$disk" || errore "Fallita pulizia partizioni"

BOOT_SIZE="512MiB"
ROOT_SIZE=$(richiedi_dimensione "ROOT")
HOME_SIZE=$(richiedi_dimensione "HOME")

echo "Creo partizioni su $disk..."
(
echo g   # GPT
echo n   # partizione 1 EFI
echo     # default primo settore
echo +512M
echo t   # cambia tipo
echo 1   # EFI System
echo n   # partizione 2 ROOT
echo     # default primo settore
echo +$ROOT_SIZE
echo n   # partizione 3 HOME
echo     # default primo settore
echo $HOME_SIZE
echo w   # scrivi
) | fdisk "$disk" || errore "Fallito partizionamento"

sleep 1
partprobe "$disk" || errore "partprobe fallito"

if [ -b "${disk}p1" ]; then
  PART_BOOT="${disk}p1"
  PART_ROOT="${disk}p2"
  PART_HOME="${disk}p3"
else
  PART_BOOT="${disk}1"
  PART_ROOT="${disk}2"
  PART_HOME="${disk}3"
fi

echo "Formatto partizioni..."
mkfs.fat -F32 "$PART_BOOT" || errore "Formattazione EFI fallita"
mkfs.ext4 "$PART_ROOT" || errore "Formattazione ROOT fallita"
mkfs.ext4 "$PART_HOME" || errore "Formattazione HOME fallita"
ok "Formattazione completata"

echo "Monto partizioni..."
mount "$PART_ROOT" /mnt || errore "Mount root fallito"
mkdir -p /mnt/boot /mnt/home
mount "$PART_BOOT" /mnt/boot || errore "Mount boot fallito"
mount "$PART_HOME" /mnt/home || errore "Mount home fallito"
ok "Partizioni montate correttamente"

echo "Avvio installazione sistema base Arch Linux..."
pacstrap /mnt base linux linux-firmware vim nano sudo || errore "Installazione base fallita"
ok "Sistema base installato"

echo "Generazione fstab..."
genfstab -U /mnt >> /mnt/etc/fstab || errore "genfstab fallito"
ok "fstab generato"

# Chiedo hostname e username
read -rp "Inserisci hostname (nome computer): " hostname
read -rp "Inserisci username (utente standard): " username
read -rsp "Inserisci password per $username: " userpass
echo
read -rsp "Conferma password per $username: " userpass2
echo
[[ "$userpass" == "$userpass2" ]] || errore "Password non coincidono"

# Configurazione dentro chroot
echo "Configuro sistema base dentro chroot..."

arch-chroot /mnt /bin/bash -e <<EOF

# Imposto hostname
echo "$hostname" > /etc/hostname

# Hosts di base
cat <<HOSTS > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   $hostname.localdomain $hostname
HOSTS

# Imposto fuso orario Europa/Roma
ln -sf /usr/share/zoneinfo/Europe/Rome /etc/localtime

# Sincronizzo l'orologio hardware
hwclock --systohc

# Configuro localizzazione
sed -i 's/^#\(it_IT.UTF-8\)/\1/' /etc/locale.gen
sed -i 's/^#\(en_US.UTF-8\)/\1/' /etc/locale.gen
locale-gen

echo "LANG=it_IT.UTF-8" > /etc/locale.conf

# Configuro tastiera italiana (console)
echo "KEYMAP=it" > /etc/vconsole.conf

# Imposto password root
echo "root:$userpass" | chpasswd

# Creo utente e setto password
useradd -m -G wheel -s /bin/bash "$username"
echo "$username:$userpass" | chpasswd

# Abilito sudo per gruppo wheel
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Installa e configura GRUB EFI
pacman -Sy --noconfirm grub efibootmgr

mkdir -p /boot/efi
mount | grep efi || mount $PART_BOOT /boot/efi || true

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB || { echo "Errore grub-install"; exit 1; }
grub-mkconfig -o /boot/grub/grub.cfg

EOF

ok "Configurazione completata dentro chroot"

echo -e "${GREEN}🎉 INSTALLAZIONE FINITA! Riavvia e rimuovi il supporto d'installazione.${NC}"
