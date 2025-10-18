# edr-scanner.sh
A nmap_scanner_pro script to scan/recon  like a pro

## 📘 README.md — EDR Scanner Tool (Nmap Wrapper)

```markdown
# 🛡️ EDR Scanner Tool

A powerful, Bash-based network scanner built around Nmap — designed for SOC analysts, cybersecurity learners, and EDR developers who need fast, flexible scanning with zero coding experience.

Built by Raven with guidance from Microsoft Copilot.

---

## 🚀 Features

- ✅ Auto-installs Nmap if missing
- 🔍 Scan modes:
  - Aggressive (`-A`): OS detection, versioning, traceroute, default scripts
  - Non-Aggressive (`-sV`): Basic service/version scan
  - Stealth (`-sS -T0`): SYN scan with minimal footprint
- 📁 Input options:
  - Single IP/host/domain
  - Batch scan from text file
- 🧠 Advanced options:
  - Custom port range (`-p`)
  - NSE script selection (`--script`)
- 📂 Output:
  - Creates a timestamped folder per scan
  - Inside each folder:
    - `report.txt`: Normal output
    - `report.xml`: Machine-readable
    - `report.gnmap`: Grep-friendly
    - `summary.txt`: Scan metadata
- 📡 Tracker integration:
  - Sends scan metadata to a webhook endpoint (IP, OS, hostname, scan type)
- 🆘 Built-in Help menu

---

## 🧰 Requirements

- Linux system (Debian/Ubuntu preferred)
- Bash shell
- Root/sudo access (for Nmap installation)
- Internet access (for tracker and IP resolution)
- `curl` installed (for tracker webhook)

---

## 📦 Installation

1. Clone or download this script:
   ```bash
   git clone https://github.com/your-repo/edr-scanner
   cd edr-scanner
   ```

2. Make the script executable:
   ```bash
   chmod +x edr-scanner.sh
   ```

3. (Optional) Set your webhook URL inside the script:
   ```bash
   WEBHOOK_URL="https://your-webhook-endpoint.com"
   ```

---

## ▶️ Execution

Run the script:
```bash
./edr-scanner.sh
```

If prompted for sudo, enter your password to allow Nmap installation.

---

## 🧭 Usage Guide

### 🏠 Main Menu Options

| Option | Description |
|--------|-------------|
| 01     | Aggressive Scan |
| 02     | Non-Aggressive Scan |
| 03     | Stealth Scan |
| 04     | Help |
| 05     | Exit |

---

### 🔍 Scan Submenu Options

| Option | Description |
|--------|-------------|
| 01     | Scan a single target |
| 02     | Scan multiple targets from a text file |
| 08     | Go back |
| 09     | Exit |

---

### 🧠 Advanced Input Prompts

After choosing a scan type, you’ll be asked:

- Target: IP, domain, or hostname
- Port range (optional): e.g., `1-65535`
- NSE script (optional): e.g., `vuln`, `default`, `safe`

---

## 📂 Output Structure

Each scan creates a folder like:
```
scan_aggressive_192.168.1.13_2025-10-19_01-00-45/
├── report.txt
├── report.xml
├── report.gnmap
└── summary.txt
```

Location: same directory as the script.

---

## 🧪 Example NSE Scripts

| Script Name | Purpose |
|-------------|---------|
| `vuln`      | Detect known vulnerabilities |
| `default`   | Run default safe scripts |
| `safe`      | Run only safe scripts |
| `http-enum` | Enumerate web server directories |
| `ftp-anon`  | Check for anonymous FTP access |

---

## 📡 Tracker Integration

Each scan triggers a webhook POST request with:
- Script name
- Scan type
- Public IP
- Hostname
- OS name
- Timestamp

To disable tracking, comment out or remove the `trigger_tracker` function call in the script.

---

## 🛡️ Disclaimer

This tool is intended for authorized security testing and educational use only. Do not scan networks without permission.

---

## 👨‍💻 Author

Built by Raven — Senior SOC Analyst and EDR developer — with guidance from Microsoft Copilot.
```
