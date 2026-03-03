#!/bin/bash

# === CONFIG ===
DOMAIN="copio.online"
CERT_DIR="/etc/letsencrypt/live/$DOMAIN"
KEYSTORE_PATH="/home/manuelpringols/copio/backend/copio/src/main/resources/keystore.p12"
KEYSTORE_PASSWORD="Jhonnyxvendetta"  # Cambialo se usi un'altra password

DOCKER_PROJECT_DIR="/home/manuelpringols/copio"
DOCKER_SERVICE_NAME="backend"  # Opzionale se vuoi specificare quale servizio riavviare

echo "🔐 Generazione nuovo keystore.p12 per $DOMAIN..."

# Verifica che i certificati esistano
if [[ ! -f "$CERT_DIR/fullchain.pem" || ! -f "$CERT_DIR/privkey.pem" ]]; then
  echo "❌ Certificati mancanti in $CERT_DIR"
  exit 1
fi

# Crea backup vecchio keystore
if [[ -f "$KEYSTORE_PATH" ]]; then
  cp "$KEYSTORE_PATH" "$KEYSTORE_PATH.bak.$(date +%F_%H-%M-%S)"
fi

# Genera nuovo keystore
openssl pkcs12 -export \
  -in "$CERT_DIR/fullchain.pem" \
  -inkey "$CERT_DIR/privkey.pem" \
  -out "$KEYSTORE_PATH" \
  -name "springboot" \
  -passout pass:$KEYSTORE_PASSWORD

if [[ $? -ne 0 ]]; then
  echo "❌ Errore nella creazione del keystore"
  exit 1
fi

echo "✅ Nuovo keystore creato con successo!"

# Vai nella cartella del progetto Docker
cd "$DOCKER_PROJECT_DIR" || {
  echo "❌ Cartella Docker non trovata: $DOCKER_PROJECT_DIR"
  exit 1
}

# Riavvia il container backend
echo "🔄 Ricostruzione e riavvio container backend..."
docker compose down && docker compose up --build -d

if [[ $? -eq 0 ]]; then
  echo "✅ Backend aggiornato e riavviato!"
else
  echo "❌ Errore nel riavvio del backend."
  exit 1
fi
