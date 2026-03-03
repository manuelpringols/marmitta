#!/bin/bash


# Ottieni nome canzone random da iTunes API
get_random_song() {
  if command -v curl &>/dev/null && command -v jq &>/dev/null && command -v shuf &>/dev/null; then
    SONG=$(curl -s "https://itunes.apple.com/search?term=rock&limit=50" | jq -r '.results[].trackName' | shuf -n1)
    # Pulizia nome file
    SAFE_SONG=$(echo "$SONG" | tr ' ' '_' | tr -cd '[:alnum:]_')
    if [ -z "$SAFE_SONG" ]; then
      SAFE_SONG=$(date +'%Y%m%d_%H%M%S')
    fi
  else
    SAFE_SONG=$(date +'%Y%m%d_%H%M%S')
  fi
  echo "$SAFE_SONG"
}

OK=0; WARN=0; CRIT=0

# Nome file report
SONG_NAME=$(get_random_song)
LOGFILE="security_check_${SONG_NAME}.txt"

# Funzioni colori
red() { echo -e "\e[31m$1\e[0m"; }
green() { echo -e "\e[32m$1\e[0m"; }
yellow() { echo -e "\e[33m$1\e[0m"; }




echo "Generazione report di sistema in corso..."
loading_bar 3
echo "Report salvato in: $LOGFILE"
echo ""





loading_bar() {
  local duration=$1  # deve essere un intero!
  echo -n "Caricamento: ["
  for ((i=0; i<duration; i++)); do
    local color=$((31 + i % 6))
    echo -ne "\e[${color}m#\e[0m"
    sleep 0.1
  done
  echo "]"
}


# Funzione per installare xmlstarlet in base alla distribuzione
install_xmlstarlet() {
    echo "Tentativo di installazione di xmlstarlet..."

    case "$DISTRO" in
        debian|ubuntu)
            sudo apt update && sudo apt install -y xmlstarlet
            ;;
        arch|manjaro)
            sudo pacman -Sy xmlstarlet
            ;;
        fedora)
            sudo dnf install -y xmlstarlet
            ;;
        centos|rhel)
            sudo yum install -y xmlstarlet
            ;;
        alpine)
            sudo apk add xmlstarlet
            ;;
        *)
            echo "Distribuzione non riconosciuta. Installare xmlstarlet manualmente."
            exit 1
            ;;
    esac
}

# Rileva la distribuzione
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$(echo "$ID" | tr '[:upper:]' '[:lower:]')
else
    echo "Impossibile rilevare la distribuzione."
    exit 1
fi

# Controlla se xmlstarlet è installato
if ! command -v xmlstarlet &> /dev/null; then
    echo "xmlstarlet non è installato."

    read -p "Vuoi installarlo ora? (s/n): " risposta
    if [[ "$risposta" == "s" || "$risposta" == "S" ]]; then
        install_xmlstarlet
    else
        echo "Installazione annullata. Il programma non può continuare."
        exit 1
    fi
fi


show_progress() {
    local progress=$1
    local total=$2
    local percent=$(( progress * 100 / total ))
    local done=$(( percent / 2 ))
    local left=$(( 50 - done ))
    local fill=$(printf "%${done}s" | tr ' ' '=')
    local empty=$(printf "%${left}s")
    printf "\r[%s%s] %d%%" "$fill" "$empty" "$percent"
}



log() {
    echo -e "$1" | tee -a "$LOGFILE"
}

section() {
    log ""
    log "$(yellow "== $1 ==")"
}

verdict_ok() {
    log "$(green "OK: $1")"
    ((OK++))
}

verdict_warn() {
    log "$(yellow "WARNING: $1")"
    ((WARN++))
}

verdict_crit() {
    log "$(red "CRITICAL: $1")"
    ((CRIT++))
}

log "$(date) - Avvio controllo di sicurezza avanzato"
log "============================================="

## 1. Utenti con UID 0 (root equivalenti)
section "Utenti con UID 0 (root equivalenti)"
UID0_USERS=$(awk -F: '$3 == 0 {print $1}' /etc/passwd)
EXTRA_UID0=$(echo "$UID0_USERS" | grep -v "^root$")
if [[ -z "$EXTRA_UID0" ]]; then
    verdict_ok "Nessun utente con UID 0 oltre root."
else
    verdict_crit "Trovati utenti con UID 0 oltre root: $EXTRA_UID0"
    verdict_warn "Utenti con UID 0 possono eseguire qualsiasi comando, verifica che siano autorizzati."
fi

## 2. File con permessi SUID/SGID
section "File con permessi SUID/SGID"
SUID_SGID_FILES=$(find / -xdev -type f \( -perm -4000 -o -perm -2000 \) 2>/dev/null)
if [[ -z "$SUID_SGID_FILES" ]]; then
    verdict_ok "Nessun file con permessi SUID/SGID trovato."
else
    verdict_warn "Trovati file con permessi SUID/SGID (potenziale rischio):"
    echo "$SUID_SGID_FILES" | tee -a "$LOGFILE"
    verdict_warn "Verifica che i file SUID/SGID siano legittimi e necessari."
fi

## 3. Porte di rete aperte e servizi in ascolto
section "Porte di rete aperte e servizi in ascolto"
NET_LISTEN=$(ss -tulnp 2>/dev/null)
if [[ -z "$NET_LISTEN" ]]; then
    verdict_warn "Nessun servizio in ascolto rilevato o comando fallito."
else
    verdict_ok "Servizi in ascolto rilevati:"
    echo "$NET_LISTEN" | tee -a "$LOGFILE"
fi

## 4. Processi eseguiti come root
section "Processi eseguiti come root"
ROOT_PROCS=$(ps -U root -u root u)
if [[ -z "$ROOT_PROCS" ]]; then
    verdict_warn "Nessun processo in esecuzione come root (caso raro o errore comando)."
else
    verdict_ok "Processi in esecuzione come root:"
    echo "$ROOT_PROCS" | tee -a "$LOGFILE"
fi

## 5. Script sospetti in /tmp e /dev/shm
section "Script sospetti in /tmp e /dev/shm"
SUS_SCRIPTS=$(find /tmp /dev/shm -type f \( -name "*.sh" -o -name "*.py" -o -name "*.pl" \) 2>/dev/null)
if [[ -z "$SUS_SCRIPTS" ]]; then
    verdict_ok "Nessuno script sospetto trovato in /tmp e /dev/shm."
else
    verdict_crit "Trovati script sospetti in /tmp o /dev/shm (possibile malware/backdoor):"
    echo "$SUS_SCRIPTS" | tee -a "$LOGFILE"
    verdict_crit "Controlla e rimuovi se non necessari."
fi

## 6. Cron job utente e di sistema
section "Cron job utente e di sistema"
log "-- Cron di sistema --"
if cat /etc/crontab &>/dev/null; then
    cat /etc/crontab | tee -a "$LOGFILE"
    verdict_ok "Crontab di sistema letto correttamente."
else
    verdict_warn "Impossibile leggere /etc/crontab."
fi

log "-- Cron dei singoli utenti --"
USERS=$(cut -f1 -d: /etc/passwd)
CRON_FOUND=0
for u in $USERS; do
    CRONTAB_U=$(crontab -l -u "$u" 2>/dev/null)
    if [[ -n "$CRONTAB_U" ]]; then
        log "Crontab per utente: $u"
        echo "$CRONTAB_U" | tee -a "$LOGFILE"
        CRON_FOUND=1
    fi
done
if [[ $CRON_FOUND -eq 0 ]]; then
    verdict_ok "Nessun crontab utente trovato."
else
    verdict_warn "Verifica crontab utente per attività sospette."
fi

## 7. Moduli kernel caricati
section "Moduli del kernel caricati"
KMODS=$(lsmod)
if [[ -z "$KMODS" ]]; then
    verdict_warn "Impossibile leggere moduli kernel o nessun modulo caricato."
else
    verdict_ok "Moduli kernel caricati:"
    echo "$KMODS" | tee -a "$LOGFILE"
fi

## 8. File modificati di recente in /etc (ultimi 7 giorni)
section "File modificati di recente in /etc (ultimi 7 giorni)"
RECENT_ETC=$(find /etc -type f -mtime -7 -exec ls -lh {} + 2>/dev/null)
if [[ -z "$RECENT_ETC" ]]; then
    verdict_ok "Nessun file modificato in /etc negli ultimi 7 giorni."
else
    verdict_warn "Trovati file modificati in /etc negli ultimi 7 giorni:"
    echo "$RECENT_ETC" | tee -a "$LOGFILE"
    verdict_warn "Verifica modifiche recenti in /etc per modifiche non autorizzate."
fi

## 9. Login recenti (ultimi 20)
section "Login recenti (ultimi 20)"
LAST_LOGINS=$(last -n 20)
if [[ -z "$LAST_LOGINS" ]]; then
    verdict_warn "Nessun login recente trovato o comando fallito."
else
    verdict_ok "Ultimi 20 login registrati:"
    echo "$LAST_LOGINS" | tee -a "$LOGFILE"
fi

## 10. Accessi SSH e tentativi
section "Accessi SSH e tentativi di accesso"
SSH_LOGS=$(grep -i ssh /var/log/auth.log 2>/dev/null | tail -40)
if [[ -z "$SSH_LOGS" ]]; then
    verdict_warn "Nessun accesso SSH recente o impossibile leggere /var/log/auth.log."
else
    verdict_ok "Ultimi 40 accessi o tentativi SSH:"
    echo "$SSH_LOGS" | tee -a "$LOGFILE"
fi

## 11. Processi zombie
section "Verifica processi zombie"
ZOMBIES=$(ps aux | awk '$8=="Z"')
if [[ -z "$ZOMBIES" ]]; then
    verdict_ok "Nessun processo zombie rilevato."
else
    verdict_warn "Trovati processi zombie:"
    echo "$ZOMBIES" | tee -a "$LOGFILE"
    verdict_warn "I processi zombie indicano che il processo padre non ha ancora raccolto lo stato dei figli terminati."
fi

## 12. hosts.allow e hosts.deny
section "Controllo file hosts.allow e hosts.deny"
log "hosts.allow:"
HA_CONTENT=$(cat /etc/hosts.allow 2>/dev/null)
if [[ -z "$HA_CONTENT" ]]; then
    verdict_warn "/etc/hosts.allow vuoto o non presente."
else
    verdict_ok "/etc/hosts.allow contiene regole:"
    echo "$HA_CONTENT" | tee -a "$LOGFILE"
fi
log "hosts.deny:"
HD_CONTENT=$(cat /etc/hosts.deny 2>/dev/null)
if [[ -z "$HD_CONTENT" ]]; then
    verdict_warn "/etc/hosts.deny vuoto o non presente."
else
    verdict_ok "/etc/hosts.deny contiene regole:"
    echo "$HD_CONTENT" | tee -a "$LOGFILE"
fi

## 13. Permessi /etc/passwd e /etc/shadow
section "Controllo permessi di /etc/passwd e /etc/shadow"
PERM_PASSWD=$(ls -l /etc/passwd 2>/dev/null)
PERM_SHADOW=$(ls -l /etc/shadow 2>/dev/null)
if [[ -z "$PERM_PASSWD" || -z "$PERM_SHADOW" ]]; then
    verdict_warn "Impossibile leggere permessi di /etc/passwd o /etc/shadow."
else
    verdict_ok "Permessi di /etc/passwd: $PERM_PASSWD"
    verdict_ok "Permessi di /etc/shadow: $PERM_SHADOW"
    # Controlla permessi
    PASSWD_PERM=$(stat -c "%a" /etc/passwd)
    SHADOW_PERM=$(stat -c "%a" /etc/shadow)
    if [[ "$PASSWD_PERM" -gt 644 ]]; then
        verdict_warn "Permessi di /etc/passwd troppo permissivi ($PASSWD_PERM), dovrebbero essere 644."
    fi
    if [[ "$SHADOW_PERM" -gt 640 ]]; then
        verdict_warn "Permessi di /etc/shadow troppo permissivi ($SHADOW_PERM), dovrebbero essere 640 o meno."
    fi
fi

## 14. Account con password vuota
section "Account con password vuota"
EMPTY_PASSWD_USERS=$(awk -F: '($2 == "") {print $1}' /etc/shadow)
if [[ -z "$EMPTY_PASSWD_USERS" ]]; then
    verdict_ok "Nessun account con password vuota."
else
    verdict_crit "Account con password vuota trovati: $EMPTY_PASSWD_USERS"
fi

## 15. File modificati o creati in /tmp nelle ultime 24 ore
section "File modificati o creati in /tmp nelle ultime 24 ore"
TMP_FILES=$(find /tmp -type f -mtime -1 2>/dev/null)
if [[ -z "$TMP_FILES" ]]; then
    verdict_ok "Nessun file modificato o creato in /tmp nelle ultime 24 ore."
else
    verdict_crit "Trovati file modificati o creati in /tmp nelle ultime 24 ore:"
    echo "$TMP_FILES" | tee -a "$LOGFILE"
    verdict_crit "Questi file potrebbero essere backdoor o malware, verificare con attenzione."
fi

## 16. File di log più grandi di 100 MB
section "File di log più grandi di 100 MB"
LARGE_LOGS=$(find /var/log -type f -size +100M 2>/dev/null)
if [[ -z "$LARGE_LOGS" ]]; then
    verdict_ok "Nessun file di log > 100MB."
else
    verdict_warn "File di log > 100MB trovati (potrebbero indicare attività anomale):"
    echo "$LARGE_LOGS" | tee -a "$LOGFILE"
fi

## 17. Versione kernel e vulnerabilità note
TMP_CVE_LIST="/tmp/cve_list.txt"
rm -f "$TMP_CVE_LIST"

echo -e "\n== Scarico e filtro CVE reali da Ubuntu Security Notices ==" | tee -a "$LOGFILE"

# Estrai i primi 10 link ai singoli avvisi USN
uLOGFILE="arch_cve_check.log"
TMP_FEED=$(mktemp)
TMP_CVE_MATCH=$(mktemp)

echo "[*] Pacchetti installati raccolti da pacman..." | tee "$LOGFILE"
mapfile -t installed_packages < <(pacman -Q | awk '{print $1}')

echo "[*] Scarico feed RSS da Arch Security..." | tee -a "$LOGFILE"
curl -s "https://security.archlinux.org/advisory/feed.atom" -o "$TMP_FEED"

echo "[*] Parsing feed per trovare CVE associate a pacchetti..." | tee -a "$LOGFILE"
xmlstarlet sel -t -m "//item" -v "title" -n "$TMP_FEED" |
while read -r title; do
    if grep -qE 'CVE-[0-9]{4}-[0-9]+' <<< "$title"; then
        cve=$(grep -oE 'CVE-[0-9]{4}-[0-9]+' <<< "$title")
        pkg=$(awk -F' ' '{print tolower($NF)}' <<< "$title")

        for installed in "${installed_packages[@]}"; do
            if [[ "$installed" == "$pkg" ]]; then
                echo "$installed è affetto da $cve" | tee -a "$TMP_CVE_MATCH"
            fi
        done
    fi
done

if [[ ! -s "$TMP_CVE_MATCH" ]]; then
    echo -e "\e[32m✔ Nessuna CVE trovata per i pacchetti installati.\e[0m" | tee -a "$LOGFILE"
else
    echo -e "\e[31m⚠ Vulnerabilità trovate:\e[0m" | tee -a "$LOGFILE"
    cat "$TMP_CVE_MATCH" | tee -a "$LOGFILE"
fi

# Cleanup
rm -f "$TMP_FEED" "$TMP_CVE_MATCH"

# Dividi in batch di 5 CVE per chiamata per limitare carico e rate limit
batch_size=2
sleep 5
for ((i=0; i < ${#cves_to_check[@]}; i+=batch_size)); do
    batch=("${cves_to_check[@]:i:batch_size}")
    echo "Batch CVE: ${batch[*]}" | tee -a "$LOGFILE"
    response=$(query_cves_batch "${batch[@]}")

    # Parsing e stampa risultato
    echo "$response" | jq -r '
      .data.attributes.cves_data.cves[] 
      | "\(.title // "N/A"): \(.description // "No description") - Status: \(.current_status // "Unknown")"
    ' | tee -a "$LOGFILE"

    # Delay tra batch per non stressare API
    sleep 5
done

echo -e "\n== Fine controllo CVE ==\n" | tee -a "$LOGFILE"





## 18. File /root/.bash_history e altri utenti
section "File bash_history di root e utenti"
HIST_ROOT="/root/.bash_history"
if [[ -f "$HIST_ROOT" ]]; then
    HIST_SIZE=$(stat -c %s "$HIST_ROOT")
    verdict_ok "File bash_history di root trovato, dimensione: $HIST_SIZE bytes."
else
    verdict_warn "File bash_history di root non trovato."
fi
log "Dimensione bash_history utenti comuni:"
for u in $(cut -f1 -d: /etc/passwd); do
    HIST_USER="/home/$u/.bash_history"
    if [[ -f "$HIST_USER" ]]; then
        SIZE=$(stat -c %s "$HIST_USER")
        log " - $u: $SIZE bytes"
    fi
done

## 19. Sistema con password scadute o utenti disabilitati
section "Utenti con password scadute o disabilitati"
EXPIRED_USERS=$(chage -l $(awk -F: '{print $1}' /etc/passwd) 2>/dev/null | grep -B1 "Password expires" | grep expired | awk '{print $1}')
if [[ -z "$EXPIRED_USERS" ]]; then
    verdict_ok "Nessun utente con password scaduta."
else
    verdict_warn "Utenti con password scaduta: $EXPIRED_USERS"
fi

## 20. Presenza di file .ssh autorizzati nelle home
section "Controllo file .ssh/authorized_keys nelle home utenti"
AUTH_KEYS_FOUND=0
for u in $(cut -f1 -d: /etc/passwd); do
    AUTH_KEYS="/home/$u/.ssh/authorized_keys"
    if [[ -f "$AUTH_KEYS" ]]; then
        AUTH_KEYS_FOUND=1
        log "authorized_keys per $u:"
        cat "$AUTH_KEYS" | tee -a "$LOGFILE"
    fi
done
if [[ $AUTH_KEYS_FOUND -eq 0 ]]; then
    verdict_ok "Nessun authorized_keys trovato nelle home utenti."
else
    verdict_warn "Verifica chi ha accesso SSH autorizzato."
fi

## 21. Presenza di connessioni di rete attive
section "Connessioni di rete attive da processi"

ALLOWED_WITH_CONN=("nginx" "sshd" "curl" "apt")
ALLOWED_NO_CONN=("logrotate" "cron" "rsyslogd")

# Otteniamo le connessioni attive e i relativi processi
ACTIVE_CONNS=$(ss -tunp 2>/dev/null | awk 'NR>1 {print $6,$7}' | sed -E 's/users:\(\("([^"]+)",pid=[0-9]+,fd=[0-9]+\)\)/\1/' | awk '{print $2, $1}' | sort -u)

if [[ -z "$ACTIVE_CONNS" ]]; then
    verdict_warn "Nessuna connessione attiva trovata o comando ss fallito."
else
    while read -r proc ip; do
        # Se mancano dati
        if [[ -z "$proc" || "$proc" == "-" ]]; then
            verdict_warn "Connessione attiva da processo non identificato verso $ip"
            continue
        fi
        if [[ -z "$ip" ]]; then
            verdict_warn "Connessione da '$proc' verso IP sconosciuto"
            continue
        fi
        if [[ "$ip" == "0.0.0.0" || "$ip" == "[::]" ]]; then
            log "INFO: Connessione bind/listen da '$proc' su $ip"  # Non è una connessione uscente
            continue
        fi

        if [[ " ${ALLOWED_NO_CONN[*]} " == *" $proc "* ]]; then
            verdict_crit "Il processo '$proc' non dovrebbe avere connessioni in uscita verso $ip"
        elif [[ " ${ALLOWED_WITH_CONN[*]} " == *" $proc "* ]]; then
            verdict_ok "Connessione lecita da '$proc' verso $ip"
        else
            verdict_warn "Processo sconosciuto '$proc' con connessione verso $ip - verifica necessaria"
        fi
    done <<< "$ACTIVE_CONNS"
fi




## 22. Check integrità binari critici (md5sum)
section "Check integrità binari critici"
BIN_LIST="/bin/ls /bin/bash /bin/ps /bin/netstat /usr/bin/ssh"
for bin in $BIN_LIST; do
    if [[ -f "$bin" ]]; then
        MD5=$(md5sum "$bin" | awk '{print $1}')
        log "$bin - md5: $MD5"
    else
        verdict_warn "Binario critico non trovato: $bin"
    fi
done
verdict_ok "Controlla manualmente confrontando con valori md5 ufficiali."

## 23. Controllo pacchetti installati (apt e rpm)
section "Controllo pacchetti installati"
if command -v dpkg &>/dev/null; then
    PKG_COUNT=$(dpkg -l | wc -l)
    verdict_ok "Sistema Debian/Ubuntu con $PKG_COUNT pacchetti installati."
elif command -v rpm &>/dev/null; then
    PKG_COUNT=$(rpm -qa | wc -l)
    verdict_ok "Sistema RPM con $PKG_COUNT pacchetti installati."
else
    verdict_warn "Sistema non riconosciuto per controllo pacchetti."
fi


## 25. Controllo variabili ambiente sospette
section "Variabili ambiente sospette"
SUSP_ENV=$(env | grep -i -E 'LD_PRELOAD|LD_LIBRARY_PATH|LD_ASSUME_KERNEL|LD_AUDIT')
if [[ -z "$SUSP_ENV" ]]; then
    verdict_ok "Nessuna variabile ambiente sospetta rilevata."
else
    verdict_warn "Variabili ambiente sospette trovate:"
    echo "$SUSP_ENV" | tee -a "$LOGFILE"
fi



## FINE CONTROLLO
log ""
log "=========================================="
log "$(green "Controlli completati.")"
log "Totale OK: $OK"
log "Totale WARNING: $WARN"
log "Totale CRITICAL: $CRIT"
log "Dettagli nel file $LOGFILE"

