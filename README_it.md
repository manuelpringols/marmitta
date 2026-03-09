# MARMITTA 😈

> Un launcher di script Bash remoti con navigazione interattiva, autenticazione Bitwarden e integrazione GitHub.

```
█▀▄▀█ ██   █▄▄▄▄ █▀▄▀█ ▄█    ▄▄▄▄▀    ▄▄▄▄▀ ██
█ █ █ █ █  █  ▄▀ █ █ █ ██ ▀▀▀ █    ▀▀▀ █    █ █
█ ▄ █ █▄▄█ █▀▀▌  █ ▄ █ ██     █        █    █▄▄█
█   █ █  █ █  █  █   █ ▐█    █        █     █  █
   █     █   █      █   ▐   ▀        ▀         █
  ▀     █   ▀      ▀                          ▀
```

---

## Cos'è Marmitta?

Marmitta è uno strumento CLI che ti permette di **sfogliare, visualizzare in anteprima ed eseguire script Bash salvati su repository GitHub** — direttamente dal terminale, senza dover clonare nulla.

Usa `fzf` per la navigazione interattiva, le API GitHub per recuperare i contenuti dei repo, e supporta più sorgenti (repository) con autenticazione opzionale tramite token GitHub via Bitwarden.

---

## Funzionalità

- **Navigazione interattiva a 3 livelli** — categoria → sottocartella → script, con `fzf`
- **Anteprima del codice** — ispeziona qualsiasi script prima di eseguirlo, riapribile più volte
- **Sorgenti multiple** — aggiungi e passa tra diversi repository GitHub
- **Rimozione sorgenti** — rimuovi una sorgente configurata in qualsiasi momento
- **Autenticazione GitHub** — via Bitwarden CLI per recupero sicuro del token
- **Cronologia esecuzioni** — riesegui rapidamente gli script recenti con ricerca `fzf`
- **Ricerca globale** — cerca tra tutti gli script del repo in una sola schermata
- **Aggiornamento automatico** — `marmitta -u` scarica e installa l'ultima versione
- **Banner ASCII animato** all'avvio con effetto glow verde neon

---

## Installazione

```bash
sudo curl -fsSL https://raw.githubusercontent.com/manuelpringols/marmitta/master/marmitta.sh \
  -o /usr/local/bin/marmitta && \
  sudo chmod +x /usr/local/bin/marmitta
```

**Dipendenze** (installate automaticamente al primo avvio se mancanti):

| Strumento | Scopo |
|---|---|
| `jq` | Parsing JSON |
| `fzf` | Ricerca fuzzy interattiva |
| `curl` | Chiamate HTTP alle API GitHub |
| `bw` (Bitwarden CLI) | Opzionale — per il login autenticato |

---

## Prima esecuzione

Al primo avvio, Marmitta rileva l'assenza di configurazione e avvia un flusso di onboarding:

```
👋 Benvenuto in Marmitta!

  Per accedere a repo privati e aumentare il rate limit GitHub,
  puoi autenticarti con un token GitHub tramite Bitwarden.

  [l] Login con GitHub (consigliato)
  [c] Continua senza login (limite pubblico: 60 req/h)
```

- Premi `l` per autenticarti via Bitwarden (consigliato)
- Premi `c` per avviare senza autenticazione (solo repo pubblici, 60 req/h)

Dopo l'onboarding, ti verrà chiesto di aggiungere la prima sorgente (un repository GitHub).

---

## Login e autenticazione

Marmitta si integra con **Bitwarden CLI** per recuperare in modo sicuro un GitHub Personal Access Token — nessun token in chiaro nei profili shell o nelle variabili d'ambiente.

```bash
marmitta --login
```

Il flusso di login:

1. Controlla lo stato del vault Bitwarden (`unauthenticated` / `locked` / `unlocked`)
2. Esegue `bw login` se necessario — TTY reale ereditato, email e master password richiesti correttamente
3. Recupera la sessione vault via `bw unlock --raw`
4. Cerca un item chiamato `github-token` nel vault
5. Estrae il token da: note → campo password → campi custom hidden (in ordine di priorità)
6. Valida il token tramite le API GitHub
7. Salva il token in `~/.config/marmitta/config` con `chmod 600`
8. Blocca opzionalmente il vault al termine

> Nelle esecuzioni successive, il token viene caricato automaticamente dal config locale.

---

## Utilizzo

### Avviare il menu principale

```bash
marmitta
```

Mostra il banner animato, poi apre il browser interattivo a 3 livelli.

### Navigazione

| Tasto | Azione |
|---|---|
| `↑ / ↓` oppure `j / k` | Scorrere la lista |
| `Invio` | Selezionare / confermare |
| `ESC` | Tornare al livello precedente |
| Digitare | Ricerca fuzzy nella lista corrente |

### Menu azione script

Dopo aver selezionato uno script:

```
[ INVIO ] Esegui   [ i ] Parametri   [ p ] Preview   [ q ] Annulla
```

| Tasto | Azione |
|---|---|
| `Invio` | Scarica ed esegui lo script |
| `i` | Esegui con argomenti personalizzati |
| `p` | Anteprima del codice sorgente (premi `p` di nuovo per rileggere) |
| `q` | Annulla e torna alla lista |

---

## Comandi

### Navigazione ed esecuzione

```bash
marmitta                  # Apre il browser interattivo
marmitta -s, --search     # Ricerca globale su tutti gli script
marmitta -t, --tree       # Mostra la struttura completa del repo
marmitta -l, --last       # Riesegue l'ultimo script eseguito
marmitta -H, --history    # Cronologia esecuzioni con fzf
```

### Gestione sorgenti

```bash
marmitta --add-source     # Aggiunge un repo GitHub come sorgente
marmitta --remove-source  # Rimuove una sorgente configurata
```

### Autenticazione e configurazione

```bash
marmitta --login          # Autenticazione via Bitwarden → salva token GitHub
marmitta --setup          # Riconfigura token e branch manualmente
marmitta --gen-desc       # Rigenera la cache delle descrizioni script
```

### Aggiornamento e reset

```bash
marmitta -u               # Aggiorna Marmitta all'ultima versione
marmitta --reset          # Elimina config, sorgenti e cache
marmitta -h, --help       # Mostra tutti i comandi disponibili
```

### Extra

```bash
marmitta -py              # Launcher script Python (integrazione pitonzi)
marmitta -Gsp             # Push git rapido (slither_push)
```

---

## Repository sorgenti

Una **sorgente** è un repository GitHub che contiene script Bash organizzati in cartelle per categoria.

```bash
marmitta --add-source
```

Verranno richiesti:
- Un'etichetta (es. `Script personali`)
- Un repository nel formato `user/repo` (es. `manuelpringols/scripts`)
- Un branch (default: `master`)

Per rimuovere una sorgente:

```bash
marmitta --remove-source
```

Un selettore `fzf` permette di scegliere la sorgente da eliminare, con richiesta di conferma.

### Struttura consigliata del repo

```
my-scripts/
├── category_desc.txt       # Descrizioni delle categorie
├── script_desc.txt         # Descrizioni degli script
├── networking/
│   └── check_ports.sh
├── system/
│   ├── report.sh
│   └── cleanup.sh
└── setup/
    └── install_tools.sh
```

| File | Formato | Scopo |
|---|---|---|
| `script_desc.txt` | `path/to/script.sh    # Descrizione` | Descrizione breve per ogni script |
| `category_desc.txt` | `nome_categoria    # Descrizione` | Descrizione breve per ogni categoria |

Le descrizioni vengono messe in cache localmente per 24 ore per minimizzare le chiamate API GitHub.

---

## Configurazione

Tutta la configurazione è in `~/.config/marmitta/`:

| File/Dir | Scopo |
|---|---|
| `config` | Token GitHub e branch di default (`chmod 600`) |
| `sources` | Lista dei repo configurati (`label\|user/repo\|branch`) |
| `cache/` | Cache descrizioni script e categorie (TTL: 24h) |

### Setup manuale del token (senza Bitwarden)

```bash
marmitta --setup
```

Oppure modifica direttamente `~/.config/marmitta/config`:

```bash
GITHUB_TOKEN="ghp_yourtoken"
DEFAULT_BRANCH="master"
```

Senza token, Marmitta funziona solo con repository pubblici, con il limite pubblico delle API GitHub (60 richieste/ora).

---

## Licenza

MIT
