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
- **Code preview** — inspect any script before running it, re-open preview as many times as needed
- **Multiple sources** — add and switch between different GitHub repos
- **Remove source** — remove a configured repo from the source list at any time
- **GitHub authentication** — via Bitwarden CLI for secure, password-manager-backed token retrieval
- **Execution history** — quickly re-run recent scripts with `fzf` search
- **Flat search** — search all scripts across the entire repo at once
- **Self-update** — `marmitta -u` fetches and installs the latest version automatically
- **Animated ASCII banner** at startup with neon green glow effect

---

## Installation

```bash
sudo curl -fsSL https://raw.githubusercontent.com/manuelpringols/marmitta/master/marmitta.sh \
  -o /usr/local/bin/marmitta && \
  sudo chmod +x /usr/local/bin/marmitta
```

**Dependencies** (auto-installed on first run if missing):

| Tool | Purpose |
|---|---|
| `jq` | JSON parsing |
| `fzf` | Interactive fuzzy finder |
| `curl` | HTTP requests to GitHub API |
| `bw` (Bitwarden CLI) | Optional — for authenticated login |

---

## First Run

On the first execution, Marmitta detects no existing configuration and starts an onboarding flow:

```
👋 Welcome to Marmitta!

  To access private repos and increase the GitHub rate limit,
  you can authenticate with a GitHub token via Bitwarden.

  [l] Login with GitHub (recommended)
  [c] Continue without login (public limit: 60 req/h)
```

- Press `l` to authenticate via Bitwarden (recommended)
- Press `c` to start without authentication (public repos only, 60 API req/h)

After onboarding, you will be prompted to add your first script source (a GitHub repository).

---

## Login & Authentication

Marmitta integrates with **Bitwarden CLI** to securely retrieve a GitHub Personal Access Token — no plain-text tokens stored in shell profiles or environment variables.

```bash
marmitta --login
```

The login flow:

1. Checks Bitwarden vault status (`unauthenticated` / `locked` / `unlocked`)
2. Runs `bw login` if needed — full interactive TTY, email and master password prompted correctly
3. Retrieves the vault session via `bw unlock --raw`
4. Searches for an item named `github-token` in your vault
5. Extracts the token from: notes → password field → custom hidden fields (in priority order)
6. Validates the token against the GitHub API
7. Saves it to `~/.config/marmitta/config` with `chmod 600`
8. Optionally locks the vault again when done

> On subsequent runs, the token is loaded automatically from the local config.

---

## Usage

### Launch the main menu

```bash
marmitta
```

Opens the animated banner, then the interactive 3-level script browser.

### Navigation

| Key | Action |
|---|---|
| `↑ / ↓` or `j / k` | Move through the list |
| `Enter` | Select item / confirm |
| `ESC` | Go back one level |
| Type to filter | Fuzzy search within the current list |

### Script action menu

After selecting a script, a menu appears:

```
[ ENTER ] Run   [ i ] Parameters   [ p ] Preview   [ q ] Cancel
```

| Key | Action |
|---|---|
| `Enter` | Download and run the script |
| `i` | Run with custom arguments |
| `p` | Preview source code (press `p` again to re-read) |
| `q` | Cancel and go back to the list |

---

## Commands

### Navigation & Execution

```bash
marmitta                  # Open interactive browser
marmitta -s, --search     # Flat search across all scripts
marmitta -t, --tree       # Show full repo file tree
marmitta -l, --last       # Re-run the last executed script
marmitta -H, --history    # Browse execution history with fzf
```

### Source Management

```bash
marmitta --add-source     # Add a GitHub repo as a source
marmitta --remove-source  # Remove a configured source
```

### Authentication & Configuration

```bash
marmitta --login          # Authenticate via Bitwarden → save GitHub token
marmitta --setup          # Reconfigure token and default branch manually
marmitta --gen-desc       # Regenerate script descriptions cache
```

### Update & Reset

```bash
marmitta -u               # Update Marmitta to the latest version
marmitta --reset          # Delete all config, sources, and cache
marmitta -h, --help       # Show all available commands
```

### Extras

```bash
marmitta -py              # Launch Python scripts (pitonzi integration)
marmitta -Gsp             # Quick git push helper (slither_push)
```

---

## Source Repositories

A **source** is a GitHub repository containing Bash scripts organized in category folders.

```bash
marmitta --add-source
```

You will be prompted for:
- A label (e.g. `My Scripts`)
- A repository in `user/repo` format (e.g. `manuelpringols/scripts`)
- A branch (default: `master`)

To remove a source:

```bash
marmitta --remove-source
```

An `fzf` picker lets you select the source to delete, with a confirmation prompt.

### Recommended repo structure

```
my-scripts/
├── category_desc.txt       # Category descriptions
├── script_desc.txt         # Script descriptions
├── networking/
│   └── check_ports.sh
├── system/
│   ├── report.sh
│   └── cleanup.sh
└── setup/
    └── install_tools.sh
```

| File | Format | Purpose |
|---|---|---|
| `script_desc.txt` | `path/to/script.sh    # Description` | Short description per script |
| `category_desc.txt` | `category_name    # Description` | Short description per category |

Descriptions are cached locally for 24 hours to minimize GitHub API calls.

---

## Configuration

All config is stored in `~/.config/marmitta/`:

| File/Dir | Purpose |
|---|---|
| `config` | GitHub token and default branch (`chmod 600`) |
| `sources` | List of configured repos (`label\|user/repo\|branch`) |
| `cache/` | Cached script and category descriptions (TTL: 24h) |

### Manual token setup (without Bitwarden)

```bash
marmitta --setup
```

Or edit `~/.config/marmitta/config` directly:

```bash
GITHUB_TOKEN="ghp_yourtoken"
DEFAULT_BRANCH="master"
```

Without a token, Marmitta works with public repositories only, at the GitHub public rate limit (60 requests/hour).

---

## License

MIT
