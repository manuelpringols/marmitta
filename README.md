# MARMITTA 😈

> A terminal-based remote Bash script launcher with interactive navigation, Bitwarden authentication, and GitHub integration.

```
█▀▄▀█ ██   █▄▄▄▄ █▀▄▀█ ▄█    ▄▄▄▄▀    ▄▄▄▄▀ ██
█ █ █ █ █  █  ▄▀ █ █ █ ██ ▀▀▀ █    ▀▀▀ █    █ █
█ ▄ █ █▄▄█ █▀▀▌  █ ▄ █ ██     █        █    █▄▄█
█   █ █  █ █  █  █   █ ▐█    █        █     █  █
   █     █   █      █   ▐   ▀        ▀         █
  ▀     █   ▀      ▀                          ▀
```

---

## What is Marmitta?

Marmitta is a CLI tool that lets you **browse, preview, and execute Bash scripts stored in GitHub repositories** — directly from your terminal, without cloning anything.

It uses `fzf` for interactive navigation, the GitHub API to fetch repo contents, and supports multiple sources (repositories) with optional GitHub token authentication via Bitwarden.

---

## Features

- **Interactive 3-level navigation** — category → subfolder → script, powered by `fzf`
- **Code preview** — inspect any script before running it
- **Multiple sources** — add and switch between different GitHub repos
- **GitHub authentication** — via Bitwarden CLI for secure token retrieval
- **Execution history** — quickly re-run recent scripts
- **Flat search** — search all scripts across the entire repo at once
- **Self-update** — `marmitta -u` fetches and installs the latest version
- **Animated ASCII banner** at startup with neon glow effect

---

## Installation

```bash
sudo curl -fsSL https://raw.githubusercontent.com/manuelpringols/marmitta/master/marmitta.sh \
  -o /usr/local/bin/marmitta && \
  sudo chmod +x /usr/local/bin/marmitta
```

**Dependencies** (auto-installed on first run if missing):

- `jq` — JSON parsing
- `fzf` — interactive fuzzy finder
- `curl` — HTTP requests
- `bw` (Bitwarden CLI) — optional, for authenticated login

---

## First Run

On the first execution, Marmitta detects no existing configuration and starts an onboarding flow:

```
👋 Benvenuto in Marmitta!

  For accessing private repos and increasing the GitHub rate limit,
  you can authenticate with a GitHub token via Bitwarden.

  [l] Login with GitHub (recommended)
  [c] Continue without login (public limit: 60 req/h)
```

- Press `l` to authenticate via Bitwarden (recommended)
- Press `c` to start without authentication (read-only, public repos, 60 API req/h)

After onboarding, you will be prompted to add your first script source (a GitHub repository).

---

## Login & Authentication

Marmitta integrates with **Bitwarden CLI** to securely retrieve a GitHub Personal Access Token — no plain-text tokens in config files.

```bash
marmitta --login
```

The login flow:
1. Checks Bitwarden vault status (`unauthenticated` / `locked` / `unlocked`)
2. Runs `bw login` if needed (full interactive TTY, email and master password prompted)
3. Retrieves the session via `bw unlock --raw`
4. Searches for an item named `github-token` in your vault
5. Extracts the token from notes → password field → custom hidden fields (in order)
6. Validates the token against the GitHub API
7. Saves it to `~/.config/marmitta/config` (chmod 600)
8. Optionally locks the vault again

> The token is stored locally and used automatically on subsequent runs.

---

## Usage

### Launch the main menu

```bash
marmitta
```

Starts the animated banner, then opens the interactive 3-level script browser.

### Navigation keys (script browser)

| Key | Action |
|---|---|
| `↑ / ↓` | Navigate |
| `Enter` | Select |
| `ESC` | Go back one level |

### Script action menu

After selecting a script:

```
[ INVIO ] Esegui   [ i ] Parametri   [ p ] Preview   [ q ] Annulla
```

| Key | Action |
|---|---|
| `Enter` | Run the script |
| `i` | Run with custom arguments |
| `p` | Preview script source code (press `p` again to re-read) |
| `q` | Cancel and go back |

---

## Commands

### Navigation

```bash
marmitta                  # Open interactive browser
marmitta -s, --search     # Flat search across all scripts
marmitta -t, --tree       # Show repo file tree
marmitta -l, --last       # Re-run the last executed script
marmitta -H, --history    # Browse execution history with fzf
```

### Sources

```bash
marmitta --add-source     # Add a GitHub repo as a source
marmitta --remove-source  # Remove a configured source
```

### Authentication & Config

```bash
marmitta --login          # Authenticate via Bitwarden → saves GitHub token
marmitta --setup          # Reconfigure token and default branch
marmitta --gen-desc       # Regenerate script descriptions cache
```

### Update & Reset

```bash
marmitta -u               # Update marmitta to the latest version
marmitta --reset          # Delete all config, sources, and cache
```

### Extras

```bash
marmitta -py              # Launch Python scripts (pitonzi integration)
marmitta -Gsp             # Quick git push helper (slither_push)
marmitta -h, --help       # Show all available commands
```

---

## Source Repositories

A **source** is a GitHub repository that contains Bash scripts organized in folders.

```bash
marmitta --add-source
```

You will be prompted for:
- A label (e.g. `My Scripts`)
- A repository (e.g. `username/scripts`)
- A branch (default: `master`)

Marmitta expects the repo to optionally include:

| File | Purpose |
|---|---|
| `script_desc.txt` | Short descriptions for each script (`path/to/script.sh    # Description`) |
| `category_desc.txt` | Short descriptions for each category folder |

These files are cached locally for 24 hours to minimize API calls.

---

## Configuration

Config is stored in `~/.config/marmitta/`:

| File | Purpose |
|---|---|
| `config` | GitHub token and default branch (chmod 600) |
| `sources` | List of configured repos (`label\|user/repo\|branch`) |
| `cache/` | Cached script and category descriptions (TTL: 24h) |

---

## Authentication Without Bitwarden

If you don't use Bitwarden, you can set the token manually via:

```bash
marmitta --setup
```

Or by editing `~/.config/marmitta/config` directly:

```bash
GITHUB_TOKEN="ghp_yourtoken"
DEFAULT_BRANCH="master"
```

Without a token, Marmitta works with public repositories at the GitHub public API limit (60 requests/hour).

---

## License

MIT
