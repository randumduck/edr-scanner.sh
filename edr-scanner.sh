#!/bin/bash

# EDR Scanner Tool - Final Version
# Author: Raven

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
WEBHOOK_URL="YOUR_WEBHOOK_URL_HERE"  # ← Replace with your actual webhook URL

check_nmap() {
    if ! command -v nmap &> /dev/null; then
        echo "Nmap not found. Installing..."
        sudo apt update && sudo apt install -y nmap
    fi
}

trigger_tracker() {
    ip_address=$(curl -s https://api.ipify.org)
    os_name=$(uname -s)
    hostname=$(hostname)
    script_name="edr-scanner.sh"
    scan_type="$1"
    curl -s -X POST "$WEBHOOK_URL" \
        -H "Content-Type: application/json" \
        -d "{\"script_name\":\"$script_name\",\"scan_type\":\"$scan_type\",\"ip_address\":\"$ip_address\",\"os_name\":\"$os_name\",\"hostname\":\"$hostname\",\"timestamp\":\"$TIMESTAMP\"}" >/dev/null
}

get_scan_options() {
    read -p "Enter target (IP/host/domain): " target
    read -p "Enter port range (e.g., 1-1000 or leave blank): " ports
    read -p "Enter NSE script name (e.g., vuln, default, safe or leave blank): " script
    OUTPUT_DIR="$SCRIPT_DIR/scan_${scan_type}_${target}_${TIMESTAMP}"
    mkdir -p "$OUTPUT_DIR"
}

run_scan() {
    local scan_type="$1"
    get_scan_options
    trigger_tracker "$scan_type"
    echo "Running $scan_type scan on $target..."
    start_time=$(date +%s)

    cmd="nmap"
    case $scan_type in
        aggressive) cmd+=" -A" ;;
        non_aggressive) cmd+=" -sV" ;;
        stealth) cmd+=" -sS -T0" ;;
    esac
    [[ -n "$ports" ]] && cmd+=" -p $ports"
    [[ -n "$script" ]] && cmd+=" --script $script"
    cmd+=" $target -oN \"$OUTPUT_DIR/report.txt\" -oX \"$OUTPUT_DIR/report.xml\" -oG \"$OUTPUT_DIR/report.gnmap\""

    # Spinner while scan runs
    echo -n "Scanning in progress "
    ( eval "$cmd" ) &
    pid=$!
    spin='-\|/'
    i=0
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) %4 ))
        printf "\b${spin:$i:1}"
        sleep 0.5
    done

    end_time=$(date +%s)
    duration=$((end_time - start_time))
    echo -e "\n✅ Scan complete in ${duration}s"
    echo "Reports saved to $OUTPUT_DIR"

    # Summary
    open_ports=$(grep -c "open" "$OUTPUT_DIR/report.gnmap")
    echo "Scan Summary for $target" > "$OUTPUT_DIR/summary.txt"
    echo "Scan Type: $scan_type" >> "$OUTPUT_DIR/summary.txt"
    echo "Port Range: ${ports:-default}" >> "$OUTPUT_DIR/summary.txt"
    echo "NSE Script: ${script:-none}" >> "$OUTPUT_DIR/summary.txt"
    echo "Open Ports Found: $open_ports" >> "$OUTPUT_DIR/summary.txt"
    echo "Duration: ${duration}s" >> "$OUTPUT_DIR/summary.txt"
}

scan_file_targets() {
    read -p "Enter path to text file with targets: " file
    if [[ ! -f "$file" ]]; then
        echo "❌ File not found: $file"
        return
    fi
    read -p "Enter port range (optional): " ports
    read -p "Enter NSE script name (optional): " script
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ -z "$line" ]] && continue
        OUTPUT_DIR="$SCRIPT_DIR/scan_${scan_type}_${line}_${TIMESTAMP}"
        mkdir -p "$OUTPUT_DIR"
        trigger_tracker "$scan_type"
        cmd="nmap"
        case $scan_type in
            aggressive) cmd+=" -A" ;;
            non_aggressive) cmd+=" -sV" ;;
            stealth) cmd+=" -sS -T0" ;;
        esac
        [[ -n "$ports" ]] && cmd+=" -p $ports"
        [[ -n "$script" ]] && cmd+=" --script $script"
        cmd+=" $line -oN \"$OUTPUT_DIR/report.txt\" -oX \"$OUTPUT_DIR/report.xml\" -oG \"$OUTPUT_DIR/report.gnmap\""

        echo "Scanning $line..."
        ( eval "$cmd" ) &
        pid=$!
        spin='-\|/'
        i=0
        while kill -0 $pid 2>/dev/null; do
            i=$(( (i+1) %4 ))
            printf "\b${spin:$i:1}"
            sleep 0.5
        done
        echo -e "\n✅ Scan complete for $line"
        open_ports=$(grep -c "open" "$OUTPUT_DIR/report.gnmap")
        echo "Scan Summary for $line" > "$OUTPUT_DIR/summary.txt"
        echo "Scan Type: $scan_type" >> "$OUTPUT_DIR/summary.txt"
        echo "Port Range: ${ports:-default}" >> "$OUTPUT_DIR/summary.txt"
        echo "NSE Script: ${script:-none}" >> "$OUTPUT_DIR/summary.txt"
        echo "Open Ports Found: $open_ports" >> "$OUTPUT_DIR/summary.txt"
    done < "$file"
}

scan_menu() {
    scan_type="$1"
    while true; do
        echo -e "\n$scan_type Scan Options:"
        echo "01) Scan single target"
        echo "02) Scan from text file"
        echo "08) Go back"
        echo "09) Exit"
        read -p "Choose an option: " opt
        case $opt in
            01) run_scan "$scan_type" ;;
            02) scan_file_targets ;;
            08) break ;;
            09) exit ;;
            *) echo "Invalid option." ;;
        esac
    done
}

show_help() {
    echo -e "\n📘 Help - How to Use EDR Scanner:"
    echo "1. Choose scan type: Aggressive, Non-Aggressive, Stealth"
    echo "2. Enter target (IP, domain, or host)"
    echo "3. Optional: Specify port range (e.g., 1-65535)"
    echo "4. Optional: Choose NSE script (e.g., vuln, default, safe)"
    echo "5. Reports are saved in a timestamped folder next to the script"
    echo "6. Each folder contains .txt, .xml, .gnmap, and summary.txt"
    echo "7. You can also scan multiple targets from a text file"
}

main_menu() {
    check_nmap
    while true; do
        echo -e "\n🔍 EDR Scanner Main Menu:"
        echo "01) Aggressive Scan"
        echo "02) Non-Aggressive Scan"
        echo "03) Stealth Scan"
        echo "04) Help"
        echo "05) Exit"
        read -p "Choose an option: " choice
        case $choice in
            01) scan_menu "aggressive" ;;
            02) scan_menu "non_aggressive" ;;
            03) scan_menu "stealth" ;;
            04) show_help ;;
            05) exit ;;
            *) echo "Invalid option." ;;
        esac
    done
}

main_menu
