#!/bin/bash

TMP_DIR="/tmp/config"

echo "[+] Rimuovo vecchia cartella temporanea..."
rm -rf "$TMP_DIR"
rm -rf /tmp/scripts_temp

echo "[+] Clono solo la cartella config del repo..."
git clone --depth 1 --filter=blob:none --sparse https://github.com/manuelpringols/scripts.git /tmp/scripts_temp
cd /tmp/scripts_temp || exit 1

git sparse-checkout init --cone
git sparse-checkout set setup_vpn/config

echo "[+] Copio tutto il contenuto di config/ in $TMP_DIR"
mkdir -p "$TMP_DIR"
cp -r setup_vpn/config/* "$TMP_DIR/"

echo "[+] Rimuovo la cartella temporanea git clonata..."
rm -rf /tmp/scripts_temp

echo "[+] Entro in $TMP_DIR ed eseguo initialize_script_vpn.sh"
cd "$TMP_DIR" || exit 1
chmod +x initialize_script_vpn.sh
./initialize_script_vpn.sh

