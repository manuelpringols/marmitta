# Marmitta

🚀 **marmitta**  
Marmitta è uno script bash interattivo per esplorare, scaricare ed eseguire facilmente gli script presenti in un repository GitHub remoto, con supporto per la selezione tramite `fzf`.

---

## Cosa fa?

- Naviga tra le cartelle del repository
- Seleziona uno script `.sh` da eseguire direttamente da remoto
- Supporta l’autenticazione tramite token GitHub per aumentare il limite di richieste API
- Permette di inserire argomenti per gli script
- Include la funzione "torna indietro" per una navigazione semplice e fluida

---

## Scaricare uno script singolo

Per scaricare e salvare localmente lo script `marmitta.sh` presente nella cartella `marmitta`, usa il seguente comando:

```bash
curl -fsSL https://raw.githubusercontent.com/manuelpringols/scripts/master/marmitta/marmitta.sh -o marmitta.sh
```

---

## Installazione globale

Se vuoi installare lo script **globalmente** e usarlo come un comando da terminale (simile a un binario), esegui:

```bash
curl -fsSL https://raw.githubusercontent.com/manuelpringols/scripts/master/marmitta/marmitta.sh -o marmitta.sh && \
chmod +x marmitta.sh && \
sudo cp marmitta.sh /usr/local/bin/marmitta

```

## Struttura degli script disponibili



📁 accendi_pc
accendi_pc-pisso.sh: accende un PC remoto specifico tramite Wake-on-LAN.

accendi_pc.sh: script generico per accendere un PC remoto via Wake-on-LAN.

spegni_pc_fisso.sh: spegne il PC fisso remoto tramite SSH.

📁 arch_install'l
arch-install'l.sh: installazione automatizzata di Arch Linux in modalità personalizzata.

📁 find_file
find_file.sh: cerca file specifici nel filesystem in base a parametri configurabili.

📁 init_git_repo
init_git_repo.sh: inizializza un repository Git locale con commit iniziale e branch main.

slither_push_repo.sh: esegue linting con Slither su smart contract Solidity e li pusha su Git.

📁 install-dev-tools
install-dev-tools.sh: installa tool di sviluppo comuni su Linux (git, curl, Docker, ecc.).

📁 marmitta
marmitta.sh: script principale per esplorare ed eseguire altri script da GitHub.

marmitta_login.sh: gestisce login GitHub per aumentare il rate limit API.

marmitta_update.sh: aggiorna lo script marmitta all’ultima versione.

📁 pitonzi
resolve_deps.py: risolve dipendenze Python per il progetto pitonzi.

run_pitonzi.sh: esegue il progetto pitonzi con ambiente configurato.

📁 scp_send
scp_send.sh: invia file rapidamente tramite SCP a un server remoto.

📁 service_command
shutdown_service.sh: arresta un servizio di sistema in modo sicuro.

📁 setup_hyprland
setup_hyprland.sh: configura Hyprland su Linux con impostazioni ottimali.

📁 setup_vpn
start_vpn_setups.sh: avvia configurazioni VPN preimpostate.

📂 config
initialize_script_vpn.sh: inizializza lo script VPN.

requirements.txt: dipendenze Python per script VPN.

script_vpn.py: script Python principale per setup VPN.

📁 setup_wezterm
setup_wezterm.sh: installa e configura WezTerm terminal emulator.

📁 setup_zshrc
setup_zshrc.sh: configura zshrc con plugin e theme.

setup_hyprlandzshrc.sh: integra configurazione zshrc con Hyprland.

back_broken: script o file di backup (verificare utilizzo).

📁 spongebob_frames
spongebob_ascii.sh: genera output ASCII art con frame di Spongebob.

📁 system_report
check_fs.sh: controlla lo stato del filesystem.

check_security_problems.sh: verifica vulnerabilità di sicurezza note.

high_consumption_processes.sh: mostra i processi a maggior consumo risorse.

system_report.sh: report completo di sistema.

📁 update-spring-boot-keystore
update-spring-boot-keystore.sh: aggiorna il keystore Spring Boot con nuovo certificato.







