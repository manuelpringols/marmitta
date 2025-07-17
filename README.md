<div id="top">

<!-- HEADER STYLE: COMPACT -->
<img src="readmeai/assets/logos/ice.svg" width="30%" align="left" style="margin-right: 15px">

# MARMITTA
<em></em>

<!-- BADGES -->
<img src="https://img.shields.io/github/license/manuelpringols/scripts?style=flat-square&logo=opensourceinitiative&logoColor=white&color=E92063" alt="license">
<img src="https://img.shields.io/github/last-commit/manuelpringols/scripts?style=flat-square&logo=git&logoColor=white&color=E92063" alt="last-commit">
<img src="https://img.shields.io/github/languages/top/manuelpringols/scripts?style=flat-square&color=E92063" alt="repo-top-language">
<img src="https://img.shields.io/github/languages/count/manuelpringols/scripts?style=flat-square&color=E92063" alt="repo-language-count">

<em>Built with the tools and technologies:</em>

<img src="https://img.shields.io/badge/GNU%20Bash-4EAA25.svg?style=flat-square&logo=GNU-Bash&logoColor=white" alt="GNU%20Bash">
<img src="https://img.shields.io/badge/Python-3776AB.svg?style=flat-square&logo=Python&logoColor=white" alt="Python">

<br clear="left"/>

## 🌈 Table of Contents

<details>
<summary>Table of Contents</summary>

- [🌈 Table of Contents](#-table-of-contents)
- [🔴 Overview](#-overview)
- [🟠 Features](#-features)
- [🟡 Project Structure](#-project-structure)
    - [🟢 Project Index](#-project-index)
- [🔵 Getting Started](#-getting-started)
    - [🟣 Prerequisites](#-prerequisites)
    - [⚫ Installation](#-installation)
    - [⚪ Usage](#-usage)
    - [🟤 Testing](#-testing)
- [🌟 Roadmap](#-roadmap)
- [🤝 Contributing](#-contributing)
- [📜 License](#-license)
- [✨ Acknowledgments](#-acknowledgments)

</details>

---

## 🔴 Overview



---

## 🟠 Features

<code>❯ REPLACE-ME</code>

---

## 🟡 Project Structure

```sh
## 🟡 Project Structure



sh
└── scripts/
    ├── README.md
    ├── accendi_pc
    │   ├── accendi_pc-pisso.sh           # Accende un PC remoto specifico tramite Wake-on-LAN
    │   ├── accendi_pc.sh                 # Script generico per accendere un PC remoto via Wake-on-LAN
    │   ├── spegni_pc.sh                  # Spegne un PC remoto tramite SSH (generico)
    │   └── spegni_pc_fisso.sh            # Spegne il PC fisso remoto tramite SSH
    ├── arch_install'l
    │   └── arch-install'l.sh             # Installazione automatizzata e personalizzata di Arch Linux
    ├── find_file
    │   └── find_file.sh                  # Cerca file specifici nel filesystem in base a parametri configurabili
    ├── init_git_repo
    │   ├── init_git_repo.sh              # Inizializza un repository Git locale con commit iniziale e branch main
    │   └── slither_push_repo.sh          # Esegue linting con Slither su smart contract Solidity e li pusha su Git
    ├── install-dev-tools
    │   └── install-dev-tools.sh          # Installa tool di sviluppo comuni su Linux (git, curl, Docker, ecc.)
    ├── marmitta
    │   ├── marmitta.sh                   # Script principale per esplorare ed eseguire altri script da GitHub
    │   ├── marmitta_login.sh             # Gestisce login GitHub per aumentare il rate limit API
    │   └── marmitta_update.sh            # Aggiorna lo script marmitta all’ultima versione
    ├── pitonzi
    │   ├── resolve_deps.py               # Risolve dipendenze Python per il progetto pitonzi
    │   └── run_pitonzi.sh                # Esegue il progetto pitonzi con ambiente configurato
    ├── scp_send
    │   └── scp_send.sh                   # Invia file rapidamente tramite SCP a un server remoto
    ├── service_command
    │   └── shutdown_service.sh           # Arresta un servizio di sistema in modo sicuro
    ├── setup_hyprland
    │   └── setup_hyprland.sh             # Configura Hyprland su Linux con impostazioni ottimali
    ├── setup_vpn
    │   ├── config                        # Configurazioni e dipendenze per setup VPN
    │   │   ├── initialize_script_vpn.sh  # Inizializza lo script VPN
    │   │   ├── requirements.txt          # Dipendenze Python per lo script VPN
    │   │   └── script_vpn.py             # Script Python principale per setup VPN
    │   └── start_vpn_setups.sh           # Avvia configurazioni VPN preimpostate
    ├── setup_wezterm
    │   └── setup_wezterm.sh              # Installa e configura WezTerm terminal emulator
    ├── setup_zshrc
    │   ├── back_broken                   # File di backup o script broken (verificare utilizzo)
    │   ├── setup_hyprlandzshrc.sh        # Integra configurazione .zshrc con Hyprland
    │   ├── setup_zshrc.sh                # Configura .zshrc con plugin e theme
    │   └── spinal                        # File di supporto (verificare scopo specifico)
    ├── spongebob_frames
    │   ├── frames                        # Contiene i frame ASCII art di Spongebob
    │   └── spongebob_ascii.sh            # Genera output ASCII art con frame di Spongebob
    ├── system_report
    │   ├── check_fs.sh                   # Controlla lo stato del filesystem
    │   ├── check_security_problems.sh    # Verifica vulnerabilità di sicurezza note
    │   ├── high_consumption_processes.sh # Mostra i processi a maggior consumo risorse
    │   └── system_report.sh              # Report completo di sistema
    └── update-spring-boot-keystore
        └── update-spring-boot-keystore.sh # Aggiorna il keystore Spring Boot con nuovo certificato

```

### 🟢 Project Index

<details open>
	<summary><b><code>SCRIPTS/</code></b></summary>
	<!-- __root__ Submodule -->
	<details>
		<summary><b>__root__</b></summary>
		<blockquote>
			<div class='directory-path' style='padding: 8px 0; color: #666;'>
				<code><b>⦿ __root__</b></code>
			<table style='width: 100%; border-collapse: collapse;'>
			<thead>
				<tr style='background-color: #f8f9fa;'>
					<th style='width: 30%; text-align: left; padding: 8px;'>File Name</th>
					<th style='text-align: left; padding: 8px;'>Summary</th>
				</tr>
			</thead>
			</table>
		</blockquote>
	</details>
	<!-- update-spring-boot-keystore Submodule -->
	<details>
		<summary><b>update-spring-boot-keystore</b></summary>
		<blockquote>
			<div class='directory-path' style='padding: 8px 0; color: #666;'>
				<code><b>⦿ update-spring-boot-keystore</b></code>
			<table style='width: 100%; border-collapse: collapse;'>
			<thead>
				<tr style='background-color: #f8f9fa;'>
					<th style='width: 30%; text-align: left; padding: 8px;'>File Name</th>
					<th style='text-align: left; padding: 8px;'>Summary</th>
				</tr>
			</thead>
				<tr style='border-bottom: 1px solid #eee;'>
					<td style='padding: 8px;'><b><a href='https://github.com/manuelpringols/scripts/blob/master/update-spring-boot-keystore/update-spring-boot-keystore.sh'>update-spring-boot-keystore.sh</a></b></td>
					<td style='padding: 8px;'>Code>❯ REPLACE-ME</code></td>
				</tr>
			</table>
		</blockquote>
	</details>
	<!-- system_report Submodule -->
	<details>
		<summary><b>system_report</b></summary>
		<blockquote>
			<div class='directory-path' style='padding: 8px 0; color: #666;'>
				<code><b>⦿ system_report</b></code>
			<table style='width: 100%; border-collapse: collapse;'>
			<thead>
				<tr style='background-color: #f8f9fa;'>
					<th style='width: 30%; text-align: left; padding: 8px;'>File Name</th>
					<th style='text-align: left; padding: 8px;'>Summary</th>
				</tr>
			</thead>
				<tr style='border-bottom: 1px solid #eee;'>
					<td style='padding: 8px;'><b><a href='https://github.com/manuelpringols/scripts/blob/master/system_report/system_report.sh'>system_report.sh</a></b></td>
					<td style='padding: 8px;'>Code>❯ REPLACE-ME</code></td>
				</tr>
				<tr style='border-bottom: 1px solid #eee;'>
					<td style='padding: 8px;'><b><a href='https://github.com/manuelpringols/scripts/blob/master/system_report/high_consumption_processes.sh'>high_consumption_processes.sh</a></b></td>
					<td style='padding: 8px;'>Code>❯ REPLACE-ME</code></td>
				</tr>
				<tr style='border-bottom: 1px solid #eee;'>
					<td style='padding: 8px;'><b><a href='https://github.com/manuelpringols/scripts/blob/master/system_report/check_security_problems.sh'>check_security_problems.sh</a></b></td>
					<td style='padding: 8px;'>Code>❯ REPLACE-ME</code></td>
				</tr>
				<tr style='border-bottom: 1px solid #eee;'>
					<td style='padding: 8px;'><b><a href='https://github.com/manuelpringols/scripts/blob/master/system_report/check_fs.sh'>check_fs.sh</a></b></td>
					<td style='padding: 8px;'>Code>❯ REPLACE-ME</code></td>
				</tr>
			</table>
		</blockquote>
	</details>
	<!-- spongebob_frames Submodule -->
	<details>
		<summary><b>spongebob_frames</b></summary>
		<blockquote>
			<div class='directory-path' style='padding: 8px 0; color: #666;'>
				<code><b>⦿ spongebob_frames</b></code>
			<table style='width: 100%; border-collapse: collapse;'>
			<thead>
				<tr style='background-color: #f8f9fa;'>
					<th style='width: 30%; text-align: left; padding: 8px;'>File Name</th>
					<th style='text-align: left; padding: 8px;'>Summary</th>
				</tr>
			</thead>
				<tr style='border-bottom: 1px solid #eee;'>
					<td style='padding: 8px;'><b><a href='https://github.com/manuelpringols/scripts/blob/master/spongebob_frames/spongebob_ascii.sh'>spongebob_ascii.sh</a></b></td>
					<td style='padding: 8px;'>Code>❯ REPLACE-ME</code></td>
				</tr>
			</table>
		</blockquote>
	</details>
	<!-- setup_zshrc Submodule -->
	<details>
		<summary><b>setup_zshrc</b></summary>
		<blockquote>
			<div class='directory-path' style='padding: 8px 0; color: #666;'>
				<code><b>⦿ setup_zshrc</b></code>
			<table style='width: 100%; border-collapse: collapse;'>
			<thead>
				<tr style='background-color: #f8f9fa;'>
					<th style='width: 30%; text-align: left; padding: 8px;'>File Name</th>
					<th style='text-align: left; padding: 8px;'>Summary</th>
				</tr>
			</thead>
				<tr style='border-bottom: 1px solid #eee;'>
					<td style='padding: 8px;'><b><a href='https://github.com/manuelpringols/scripts/blob/master/setup_zshrc/spinal'>spinal</a></b></td>
					<td style='padding: 8px;'>Code>❯ REPLACE-ME</code></td>
				</tr>
				<tr style='border-bottom: 1px solid #eee;'>
					<td style='padding: 8px;'><b><a href='https://github.com/manuelpringols/scripts/blob/master/setup_zshrc/setup_zshrc.sh'>setup_zshrc.sh</a></b></td>
					<td style='padding: 8px;'>Code>❯ REPLACE-ME</code></td>
				</tr>
				<tr style='border-bottom: 1px solid #eee;'>
					<td style='padding: 8px;'><b><a href='https://github.com/manuelpringols/scripts/blob/master/setup_zshrc/setup_hyprlandzshrc.sh'>setup_hyprlandzshrc.sh</a></b></td>
					<td style='padding: 8px;'>Code>❯ REPLACE-ME</code></td>
				</tr>
				<tr style='border-bottom: 1px solid #eee;'>
					<td style='padding: 8px;'><b><a href='https://github.com/manuelpringols/scripts/blob/master/setup_zshrc/back_broken'>back_broken</a></b></td>
					<td style='padding: 8px;'>Code>❯ REPLACE-ME</code></td>
				</tr>
			</table>
		</blockquote>
	</details>
	<!-- setup_wezterm Submodule -->
	<details>
		<summary><b>setup_wezterm</b></summary>
		<blockquote>
			<div class='directory-path' style='padding: 8px 0; color: #666;'>
				<code><b>⦿ setup_wezterm</b></code>
			<table style='width: 100%; border-collapse: collapse;'>
			<thead>
				<tr style='background-color: #f8f9fa;'>
					<th style='width: 30%; text-align: left; padding: 8px;'>File Name</th>
					<th style='text-align: left; padding: 8px;'>Summary</th>
				</tr>
			</thead>
				<tr style='border-bottom: 1px solid #eee;'>
					<td style='padding: 8px;'><b><a href='https://github.com/manuelpringols/scripts/blob/master/setup_wezterm/setup_wezterm.sh'>setup_wezterm.sh</a></b></td>
					<td style='padding: 8px;'>Code>❯ REPLACE-ME</code></td>
				</tr>
			</table>
		</blockquote>
	</details>
	<!-- setup_vpn Submodule -->
	<details>
		<summary><b>setup_vpn</b></summary>
		<blockquote>
			<div class='directory-path' style='padding: 8px 0; color: #666;'>
				<code><b>⦿ setup_vpn</b></code>
			<table style='width: 100%; border-collapse: collapse;'>
			<thead>
				<tr style='background-color: #f8f9fa;'>
					<th style='width: 30%; text-align: left; padding: 8px;'>File Name</th>
					<th style='text-align: left; padding: 8px;'>Summary</th>
				</tr>
			</thead>
				<tr style='border-bottom: 1px solid #eee;'>
					<td style='padding: 8px;'><b><a href='https://github.com/manuelpringols/scripts/blob/master/setup_vpn/start_vpn_setups.sh'>start_vpn_setups.sh</a></b></td>
					<td style='padding: 8px;'>Code>❯ REPLACE-ME</code></td>
				</tr>
			</table>
			<!-- config Submodule -->
			<details>
				<summary><b>config</b></summary>
				<blockquote>
					<div class='directory-path' style='padding: 8px 0; color: #666;'>
						<code><b>⦿ setup_vpn.config</b></code>
					<table style='width: 100%; border-collapse: collapse;'>
					<thead>
						<tr style='background-color: #f8f9fa;'>
							<th style='width: 30%; text-align: left; padding: 8px;'>File Name</th>
							<th style='text-align: left; padding: 8px;'>Summary</th>
						</tr>
					</thead>
						<tr style='border-bottom: 1px solid #eee;'>
							<td style='padding: 8px;'><b><a href='https://github.com/manuelpringols/scripts/blob/master/setup_vpn/config/script_vpn.py'>script_vpn.py</a></b></td>
							<td style='padding: 8px;'>Code>❯ REPLACE-ME</code></td>
						</tr>
						<tr style='border-bottom: 1px solid #eee;'>
							<td style='padding: 8px;'><b><a href='https://github.com/manuelpringols/scripts/blob/master/setup_vpn/config/requirements.txt'>requirements.txt</a></b></td>
							<td style='padding: 8px;'>Code>❯ REPLACE-ME</code></td>
						</tr>
						<tr style='border-bottom: 1px solid #eee;'>
							<td style='padding: 8px;'><b><a href='https://github.com/manuelpringols/scripts/blob/master/setup_vpn/config/initialize_script_vpn.sh'>initialize_script_vpn.sh</a></b></td>
							<td style='padding: 8px;'>Code>❯ REPLACE-ME</code></td>
						</tr>
					</table>
				</blockquote>
			</details>
		</blockquote>
	</details>
	<!-- setup_hyprland Submodule -->
	<details>
		<summary><b>setup_hyprland</b></summary>
		<blockquote>
			<div class='directory-path' style='padding: 8px 0; color: #666;'>
				<code><b>⦿ setup_hyprland</b></code>
			<table style='width: 100%; border-collapse: collapse;'>
			<thead>
				<tr style='background-color: #f8f9fa;'>
					<th style='width: 30%; text-align: left; padding: 8px;'>File Name</th>
					<th style='text-align: left; padding: 8px;'>Summary</th>
				</tr>
			</thead>
				<tr style='border-bottom: 1px solid #eee;'>
					<td style='padding: 8px;'><b><a href='https://github.com/manuelpringols/scripts/blob/master/setup_hyprland/setup_hyprland.sh'>setup_hyprland.sh</a></b></td>
					<td style='padding: 8px;'>Code>❯ REPLACE-ME</code></td>
				</tr>
			</table>
		</blockquote>
	</details>
	<!-- service_command Submodule -->
	<details>
		<summary><b>service_command</b></summary>
		<blockquote>
			<div class='directory-path' style='padding: 8px 0; color: #666;'>
				<code><b>⦿ service_command</b></code>
			<table style='width: 100%; border-collapse: collapse;'>
			<thead>
				<tr style='background-color: #f8f9fa;'>
					<th style='width: 30%; text-align: left; padding: 8px;'>File Name</th>
					<th style='text-align: left; padding: 8px;'>Summary</th>
				</tr>
			</thead>
				<tr style='border-bottom: 1px solid #eee;'>
					<td style='padding: 8px;'><b><a href='https://github.com/manuelpringols/scripts/blob/master/service_command/shutdown_service.sh'>shutdown_service.sh</a></b></td>
					<td style='padding: 8px;'>Code>❯ REPLACE-ME</code></td>
				</tr>
			</table>
		</blockquote>
	</details>
	<!-- scp_send Submodule -->
	<details>
		<summary><b>scp_send</b></summary>
		<blockquote>
			<div class='directory-path' style='padding: 8px 0; color: #666;'>
				<code><b>⦿ scp_send</b></code>
			<table style='width: 100%; border-collapse: collapse;'>
			<thead>
				<tr style='background-color: #f8f9fa;'>
					<th style='width: 30%; text-align: left; padding: 8px;'>File Name</th>
					<th style='text-align: left; padding: 8px;'>Summary</th>
				</tr>
			</thead>
				<tr style='border-bottom: 1px solid #eee;'>
					<td style='padding: 8px;'><b><a href='https://github.com/manuelpringols/scripts/blob/master/scp_send/scp_send.sh'>scp_send.sh</a></b></td>
					<td style='padding: 8px;'>Code>❯ REPLACE-ME</code></td>
				</tr>
			</table>
		</blockquote>
	</details>
	<!-- pitonzi Submodule -->
	<details>
		<summary><b>pitonzi</b></summary>
		<blockquote>
			<div class='directory-path' style='padding: 8px 0; color: #666;'>
				<code><b>⦿ pitonzi</b></code>
			<table style='width: 100%; border-collapse: collapse;'>
			<thead>
				<tr style='background-color: #f8f9fa;'>
					<th style='width: 30%; text-align: left; padding: 8px;'>File Name</th>
					<th style='text-align: left; padding: 8px;'>Summary</th>
				</tr>
			</thead>
				<tr style='border-bottom: 1px solid #eee;'>
					<td style='padding: 8px;'><b><a href='https://github.com/manuelpringols/scripts/blob/master/pitonzi/run_pitonzi.sh'>run_pitonzi.sh</a></b></td>
					<td style='padding: 8px;'>Code>❯ REPLACE-ME</code></td>
				</tr>
				<tr style='border-bottom: 1px solid #eee;'>
					<td style='padding: 8px;'><b><a href='https://github.com/manuelpringols/scripts/blob/master/pitonzi/resolve_deps.py'>resolve_deps.py</a></b></td>
					<td style='padding: 8px;'>Code>❯ REPLACE-ME</code></td>
				</tr>
			</table>
		</blockquote>
	</details>
	<!-- marmitta Submodule -->
	<details>
		<summary><b>marmitta</b></summary>
		<blockquote>
			<div class='directory-path' style='padding: 8px 0; color: #666;'>
				<code><b>⦿ marmitta</b></code>
			<table style='width: 100%; border-collapse: collapse;'>
			<thead>
				<tr style='background-color: #f8f9fa;'>
					<th style='width: 30%; text-align: left; padding: 8px;'>File Name</th>
					<th style='text-align: left; padding: 8px;'>Summary</th>
				</tr>
			</thead>
				<tr style='border-bottom: 1px solid #eee;'>
					<td style='padding: 8px;'><b><a href='https://github.com/manuelpringols/scripts/blob/master/marmitta/marmitta_update.sh'>marmitta_update.sh</a></b></td>
					<td style='padding: 8px;'>Code>❯ REPLACE-ME</code></td>
				</tr>
				<tr style='border-bottom: 1px solid #eee;'>
					<td style='padding: 8px;'><b><a href='https://github.com/manuelpringols/scripts/blob/master/marmitta/marmitta_login.sh'>marmitta_login.sh</a></b></td>
					<td style='padding: 8px;'>Code>❯ REPLACE-ME</code></td>
				</tr>
				<tr style='border-bottom: 1px solid #eee;'>
					<td style='padding: 8px;'><b><a href='https://github.com/manuelpringols/scripts/blob/master/marmitta/marmitta.sh'>marmitta.sh</a></b></td>
					<td style='padding: 8px;'>Code>❯ REPLACE-ME</code></td>
				</tr>
			</table>
		</blockquote>
	</details>
	<!-- install-dev-tools Submodule -->
	<details>
		<summary><b>install-dev-tools</b></summary>
		<blockquote>
			<div class='directory-path' style='padding: 8px 0; color: #666;'>
				<code><b>⦿ install-dev-tools</b></code>
			<table style='width: 100%; border-collapse: collapse;'>
			<thead>
				<tr style='background-color: #f8f9fa;'>
					<th style='width: 30%; text-align: left; padding: 8px;'>File Name</th>
					<th style='text-align: left; padding: 8px;'>Summary</th>
				</tr>
			</thead>
				<tr style='border-bottom: 1px solid #eee;'>
					<td style='padding: 8px;'><b><a href='https://github.com/manuelpringols/scripts/blob/master/install-dev-tools/install-dev-tools.sh'>install-dev-tools.sh</a></b></td>
					<td style='padding: 8px;'>Code>❯ REPLACE-ME</code></td>
				</tr>
			</table>
		</blockquote>
	</details>
	<!-- init_git_repo Submodule -->
	<details>
		<summary><b>init_git_repo</b></summary>
		<blockquote>
			<div class='directory-path' style='padding: 8px 0; color: #666;'>
				<code><b>⦿ init_git_repo</b></code>
			<table style='width: 100%; border-collapse: collapse;'>
			<thead>
				<tr style='background-color: #f8f9fa;'>
					<th style='width: 30%; text-align: left; padding: 8px;'>File Name</th>
					<th style='text-align: left; padding: 8px;'>Summary</th>
				</tr>
			</thead>
				<tr style='border-bottom: 1px solid #eee;'>
					<td style='padding: 8px;'><b><a href='https://github.com/manuelpringols/scripts/blob/master/init_git_repo/slither_push_repo.sh'>slither_push_repo.sh</a></b></td>
					<td style='padding: 8px;'>Code>❯ REPLACE-ME</code></td>
				</tr>
				<tr style='border-bottom: 1px solid #eee;'>
					<td style='padding: 8px;'><b><a href='https://github.com/manuelpringols/scripts/blob/master/init_git_repo/init_git_repo.sh'>init_git_repo.sh</a></b></td>
					<td style='padding: 8px;'>Code>❯ REPLACE-ME</code></td>
				</tr>
			</table>
		</blockquote>
	</details>
	<!-- find_file Submodule -->
	<details>
		<summary><b>find_file</b></summary>
		<blockquote>
			<div class='directory-path' style='padding: 8px 0; color: #666;'>
				<code><b>⦿ find_file</b></code>
			<table style='width: 100%; border-collapse: collapse;'>
			<thead>
				<tr style='background-color: #f8f9fa;'>
					<th style='width: 30%; text-align: left; padding: 8px;'>File Name</th>
					<th style='text-align: left; padding: 8px;'>Summary</th>
				</tr>
			</thead>
				<tr style='border-bottom: 1px solid #eee;'>
					<td style='padding: 8px;'><b><a href='https://github.com/manuelpringols/scripts/blob/master/find_file/find_file.sh'>find_file.sh</a></b></td>
					<td style='padding: 8px;'>Code>❯ REPLACE-ME</code></td>
				</tr>
			</table>
		</blockquote>
	</details>
	<!-- arch_install'l Submodule -->
	<details>
		<summary><b>arch_install'l</b></summary>
		<blockquote>
			<div class='directory-path' style='padding: 8px 0; color: #666;'>
				<code><b>⦿ arch_install'l</b></code>
			<table style='width: 100%; border-collapse: collapse;'>
			<thead>
				<tr style='background-color: #f8f9fa;'>
					<th style='width: 30%; text-align: left; padding: 8px;'>File Name</th>
					<th style='text-align: left; padding: 8px;'>Summary</th>
				</tr>
			</thead>
				<tr style='border-bottom: 1px solid #eee;'>
					<td style='padding: 8px;'><b><a href='https://github.com/manuelpringols/scripts/blob/master/arch_install'l/arch-install'l.sh'>arch-install'l.sh</a></b></td>
					<td style='padding: 8px;'>Code>❯ REPLACE-ME</code></td>
				</tr>
			</table>
		</blockquote>
	</details>
	<!-- accendi_pc Submodule -->
	<details>
		<summary><b>accendi_pc</b></summary>
		<blockquote>
			<div class='directory-path' style='padding: 8px 0; color: #666;'>
				<code><b>⦿ accendi_pc</b></code>
			<table style='width: 100%; border-collapse: collapse;'>
			<thead>
				<tr style='background-color: #f8f9fa;'>
					<th style='width: 30%; text-align: left; padding: 8px;'>File Name</th>
					<th style='text-align: left; padding: 8px;'>Summary</th>
				</tr>
			</thead>
				<tr style='border-bottom: 1px solid #eee;'>
					<td style='padding: 8px;'><b><a href='https://github.com/manuelpringols/scripts/blob/master/accendi_pc/spegni_pc_fisso.sh'>spegni_pc_fisso.sh</a></b></td>
					<td style='padding: 8px;'>Code>❯ REPLACE-ME</code></td>
				</tr>
				<tr style='border-bottom: 1px solid #eee;'>
					<td style='padding: 8px;'><b><a href='https://github.com/manuelpringols/scripts/blob/master/accendi_pc/spegni_pc.sh'>spegni_pc.sh</a></b></td>
					<td style='padding: 8px;'>Code>❯ REPLACE-ME</code></td>
				</tr>
				<tr style='border-bottom: 1px solid #eee;'>
					<td style='padding: 8px;'><b><a href='https://github.com/manuelpringols/scripts/blob/master/accendi_pc/accendi_pc.sh'>accendi_pc.sh</a></b></td>
					<td style='padding: 8px;'>Code>❯ REPLACE-ME</code></td>
				</tr>
				<tr style='border-bottom: 1px solid #eee;'>
					<td style='padding: 8px;'><b><a href='https://github.com/manuelpringols/scripts/blob/master/accendi_pc/accendi_pc-pisso.sh'>accendi_pc-pisso.sh</a></b></td>
					<td style='padding: 8px;'>Code>❯ REPLACE-ME</code></td>
				</tr>
			</table>
		</blockquote>
	</details>
</details>

---

## 🔵 Getting Started

### 🟣 Prerequisites

This project requires the following dependencies:

- **Programming Language:** Shell
- **Package Manager:** Pip

### ⚫ Installation

Build scripts from the source and intsall dependencies:

1. **Clone the repository:**

    ```sh
    ❯ git clone https://github.com/manuelpringols/scripts
    ```

2. **Navigate to the project directory:**

    ```sh
    ❯ cd scripts
    ```

3. **Install the dependencies:**

<!-- SHIELDS BADGE CURRENTLY DISABLED -->
	<!-- [![pip][pip-shield]][pip-link] -->
	<!-- REFERENCE LINKS -->
	<!-- [pip-shield]: None -->
	<!-- [pip-link]: None -->

	**Using [pip](None):**

	```sh
	❯ echo 'INSERT-INSTALL-COMMAND-HERE'
	```

### ⚪ Usage

Run the project with:

**Using [pip](None):**
```sh
echo 'INSERT-RUN-COMMAND-HERE'
```

### 🟤 Testing

Scripts uses the {__test_framework__} test framework. Run the test suite with:

**Using [pip](None):**
```sh
echo 'INSERT-TEST-COMMAND-HERE'
```

---

## 🌟 Roadmap

- [X] **`Task 1`**: <strike>Implement feature one.</strike>
- [ ] **`Task 2`**: Implement feature two.
- [ ] **`Task 3`**: Implement feature three.

---

## 🤝 Contributing

- **💬 [Join the Discussions](https://github.com/manuelpringols/scripts/discussions)**: Share your insights, provide feedback, or ask questions.
- **🐛 [Report Issues](https://github.com/manuelpringols/scripts/issues)**: Submit bugs found or log feature requests for the `scripts` project.
- **💡 [Submit Pull Requests](https://github.com/manuelpringols/scripts/blob/main/CONTRIBUTING.md)**: Review open PRs, and submit your own PRs.

<details closed>
<summary>Contributing Guidelines</summary>

1. **Fork the Repository**: Start by forking the project repository to your github account.
2. **Clone Locally**: Clone the forked repository to your local machine using a git client.
   ```sh
   git clone https://github.com/manuelpringols/scripts
   ```
3. **Create a New Branch**: Always work on a new branch, giving it a descriptive name.
   ```sh
   git checkout -b new-feature-x
   ```
4. **Make Your Changes**: Develop and test your changes locally.
5. **Commit Your Changes**: Commit with a clear message describing your updates.
   ```sh
   git commit -m 'Implemented new feature x.'
   ```
6. **Push to github**: Push the changes to your forked repository.
   ```sh
   git push origin new-feature-x
   ```
7. **Submit a Pull Request**: Create a PR against the original project repository. Clearly describe the changes and their motivations.
8. **Review**: Once your PR is reviewed and approved, it will be merged into the main branch. Congratulations on your contribution!
</details>

<details closed>
<summary>Contributor Graph</summary>
<br>
<p align="left">
   <a href="https://github.com{/manuelpringols/scripts/}graphs/contributors">
      <img src="https://contrib.rocks/image?repo=manuelpringols/scripts">
   </a>
</p>
</details>

---

## 📜 License

Scripts is protected under the [LICENSE](https://choosealicense.com/licenses) License. For more details, refer to the [LICENSE](https://choosealicense.com/licenses/) file.

---

## ✨ Acknowledgments

- Credit `contributors`, `inspiration`, `references`, etc.

<div align="right">

[![][back-to-top]](#top)

</div>


[back-to-top]: https://img.shields.io/badge/-BACK_TO_TOP-151515?style=flat-square


---
