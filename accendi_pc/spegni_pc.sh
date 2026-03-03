#!/bin/bash

echo "=========================================="
echo "Script per spegnere un computer remoto via SSH"
echo "Assicurati che:"
echo " - Il computer remoto sia raggiungibile"
echo " - SSH sia abilitato e configurato"
echo " - L'utente remoto abbia i permessi per spegnere (sudo)"
echo "=========================================="

# Controlla sistema operativo locale
OS=$(uname)
echo "Sistema operativo rilevato: $OS"

# Verifica se il comando ssh è disponibile
if ! command -v ssh &> /dev/null
then
    echo ""
    echo "Errore: il comando 'ssh' non è installato."
    echo "Per far funzionare questo script, devi installarlo."
    echo ""

    if [[ "$OS" == "Linux" ]]; then
        echo "Su Linux (Debian/Ubuntu) puoi installarlo con:"
        echo "    sudo apt update && sudo apt install openssh-client"
    elif [[ "$OS" == "Darwin" ]]; then
        echo "Su macOS SSH è generalmente preinstallato."
    else
        echo "Per il tuo sistema operativo, cerca come installare 'ssh'."
    fi
    exit 1
fi

# Configura utente remoto e host
REMOTE_USER="manuel"  # <-- sostituisci con il nome utente remoto corretto
REMOTE_HOST="10.0.0.37"

echo "Sto tentando di spegnere il computer remoto ${REMOTE_USER}@${REMOTE_HOST}..."

# Esegue il comando di spegnimento remoto
ssh ${REMOTE_USER}@${REMOTE_HOST} "sudo shutdown now"

if [ $? -eq 0 ]; then
    echo "Comando di spegnimento inviato con successo."
else
    echo "Errore durante l'invio del comando di spegnimento."
fi
