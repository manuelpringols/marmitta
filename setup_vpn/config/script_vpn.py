import subprocess
import customtkinter as ctk
from tkinter import messagebox  # Per i popup standard
import requests
import segno
import os

# Configurazioni statiche
SERVER_PUBLIC_KEY = "LYClLwCrPU/yPQWSyjfdWWu5/HiBKsdnvvC6QoISX14="
SERVER_ENDPOINT = "46.38.237.139:51820"
VPN_SUBNET = "10.0.0.1/24"
API_URL = "http://46.38.237.139:5301/add-client"  # URL del server REST


def send_to_server(client_ip, public_key,server_name):
    """Invia i dati al server REST per aggiornare wg0.conf."""
    try:
        payload = {
            "address": client_ip,
            "public_key": public_key,
            "server_name" : server_name
        }
        response = requests.post(API_URL, json=payload, timeout=5)
        response.raise_for_status()  # Solleva un'eccezione per errori HTTP

        if response.status_code == 200:
            messagebox.showinfo("Successo", "Configurazione inviata al server con successo!")
        else:
            messagebox.showerror("Errore", f"Errore dal server: {response.text}")
    except requests.exceptions.ConnectionError:
        messagebox.showerror("Errore", "Il server non è raggiungibile. Controlla la connessione.")
    except requests.exceptions.Timeout:
        messagebox.showerror("Errore", "La richiesta al server è scaduta. Riprova più tardi.")
    except Exception as e:
        messagebox.showerror("Errore", f"Errore imprevisto: {e}")


def generate_client_config():
    client_ip = ip_entry.get().strip()
    client_name = ip_entry2.get().strip()

    if not client_ip:
        messagebox.showerror("Errore", "L'IP privato è richiesto!")
        return
    if not client_name:
        messagebox.showerror("Errore", "Il nome è richiesto!")
        return

    try:
        private_key = subprocess.check_output(["wg", "genkey"]).decode().strip()
        public_key = subprocess.check_output(["wg", "pubkey"], input=private_key.encode()).decode().strip()
    except subprocess.CalledProcessError as e:
        messagebox.showerror("Errore", f"Errore nel generare le chiavi: {e}")
        return

    client_config = f"""    
[Interface]
PrivateKey = {private_key}
Address = {client_ip}/24
DNS = 8.8.8.8, 1.1.1.1

[Peer]
PublicKey = {SERVER_PUBLIC_KEY}
Endpoint = {SERVER_ENDPOINT}
AllowedIPs = {client_ip}/24, 0.0.0.0/0, ::/0
PersistentKeepalive = 25
    """

    # Crea la cartella "config" se non esiste
    os.makedirs("config", exist_ok=True)

    # Percorsi dei file
    conf_path = os.path.join("config", f"{client_name}.conf")
    qr_path = os.path.join("config", f"{client_name}_qr.png")

    try:
        # Salva il file di configurazione
        with open(conf_path, "w") as conf_file:
            conf_file.write(client_config.strip())
        
        # Genera il QR code
        qr = segno.make(client_config.strip())
        qr.save(qr_path, scale=10)  # scale=10 per dimensioni maggiori


        messagebox.showinfo("Successo", f"File di configurazione e QR salvati in: config/")
        print(f"File: {conf_path}\nQR: {qr_path}")

    except Exception as e:
        messagebox.showerror("Errore", f"Errore nel salvare il file o QR: {e}")
        return

    # Invia i dati al server
    send_to_server(client_ip, public_key, client_name)


# Imposta la finestra principale
root = ctk.CTk()
root.title("Generatore File Configurazione WireGuard")
root.geometry("400x300")

# Crea un'etichetta per l'IP
ip_label = ctk.CTkLabel(root, text="Inserisci l'IP privato del client (es. 10.0.0.2):")
ip_label.pack(pady=10)

# Crea un campo di inserimento per l'IP
ip_entry = ctk.CTkEntry(root)
ip_entry.pack(pady=5)

# Crea un'etichetta per il nome del file
ip_label2 = ctk.CTkLabel(root, text="Inserisci il tuo nome:")
ip_label2.pack(pady=10)

# Crea un campo di inserimento per il nome
ip_entry2 = ctk.CTkEntry(root)
ip_entry2.pack(pady=5)

# Crea un bottone per generare il file di configurazione
generate_button = ctk.CTkButton(root, text="Genera Configurazione", command=generate_client_config)
generate_button.pack(pady=20)

# Avvia l'interfaccia grafica
root.mainloop()
