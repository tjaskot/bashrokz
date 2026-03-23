#!/usr/bin/env bash
# Vast.ai Host Post-Reboot Verification Script
# Modes: default = high-level overview | detailed = full diagnostics
# Usage: ./vastai_services_test.sh [detailed | -d]

set -euo pipefail

MODE="overview"  # default
if [[ $# -ge 1 ]]; then
    if [[ "$1" == "detailed" || "$1" == "-d" || "$1" == "--detailed" ]]; then
        MODE="detailed"
    fi
fi

DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "===================================================="
echo "  Vast.ai Host Check - $DATE  (mode: $MODE)"
echo "===================================================="
echo ""

# ──────────────────────────────────────────────────────────────
# Helper functions
# ──────────────────────────────────────────────────────────────

check_service() {
    local svc="$1"
    local label="$2"
    if systemctl is-active --quiet "$svc" 2>/dev/null; then
        echo "✓ $label is active"
    else
        echo "✗ $label is NOT active!"
    fi
}

check_nvidia() {
    if command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi >/dev/null 2>&1; then
        echo "✓ nvidia-smi works → Drivers/GPUs appear healthy"
    else
        echo "✗ nvidia-smi failed → Drivers not loaded or broken"
    fi
}

get_port_count() {
    local file="/var/lib/vastai_kaalia/host_port_range"
    if [[ -f "$file" ]]; then
        local range=$(cat "$file" 2>/dev/null)
        if [[ "$range" =~ ^([0-9]+)-([0-9]+)$ ]]; then
            local start=${BASH_REMATCH[1]}
            local end=${BASH_REMATCH[2]}
            local count=$((end - start + 1))
            echo "$range ($count ports)"
            return
        fi
        echo "$range (could not parse count)"
    else
        echo "NOT FOUND"
    fi
}

show_machines_quick() {
    if command -v uv >/dev/null 2>&1; then
        uv run vastai show machines 2>/dev/null | head -n 5 || echo "(uv run vastai show machines failed – check uv install/API key)"
    else
        echo "(uv command not found – cannot run Vast.ai CLI)"
    fi
}

run_vastai() {
    if command -v uv >/dev/null 2>&1; then
        uv run vastai "$@" 2>/dev/null || echo "(vastai command via uv failed – check API key or uv install)"
    else
        echo "(uv not found – Vast.ai CLI unavailable)"
    fi
}

check_api_key() {
    local key_file="$HOME/.vast_api_key"
    local auth_test=$(run_vastai show user 2>/dev/null)

    if [[ -n "$auth_test" && "$auth_test" != *"(vastai command via uv failed"* ]]; then
        echo "✓ API key authentication works (show user succeeded)"
        if [[ -f "$key_file" && -s "$key_file" ]]; then
            echo "  File exists: $key_file"
            echo "  Active key (redacted): $(head -c 4 "$key_file")...$(tail -c 4 "$key_file")"
        else
            echo "  Note: Key file missing/empty, but CLI auth succeeded (possibly using cache/env/other method)"
        fi
    else
        echo "✗ API key authentication failed (show user did not return valid data)"
        if [[ -f "$key_file" && -s "$key_file" ]]; then
            echo "  File exists but appears invalid/expired/revoked"
            echo "  Active key (redacted): $(head -c 4 "$key_file")...$(tail -c 4 "$key_file")"
        else
            echo "  File MISSING or empty"
        fi
        echo ""
        echo "Guidance to set/refresh API key:"
        echo "1. Log in to https://console.vast.ai/ → Account → API Keys"
        echo "2. Reset an existing key or + New (full permissions for host tasks)"
        echo "3. Copy the new key string"
        echo "4. Run: uv run vastai set api-key YOUR_NEW_KEY_HERE"
        echo "5. Verify: uv run vastai show user   (should show your user details)"
        echo "Note: For hosts, rentals can continue via the daemon even without CLI auth. Self-test and other write actions need valid key."
    fi
}

check_hotspot_priority() {
    if ! command -v nmcli >/dev/null 2>&1; then
        echo "✗ ⚠ nmcli missing"
        return 1
    fi

    nmcli -t -f DEVICE,TYPE device status | awk -F: '$2=="wifi"{print $1}' | while read -r iface; do
        local conn_line conn_name pri

        conn_line=$(nmcli -t -f GENERAL.CONNECTION device show "$iface" 2>/dev/null || true)
        conn_name="${conn_line#*:}"

        if [[ -z "$conn_name" || "$conn_name" == "$conn_line" ]]; then
            echo "✗ ⚠ No active connection on $iface"
            continue
        fi

        pri=$(nmcli -t -g connection.autoconnect-priority connection show "$conn_name" 2>/dev/null || echo "UNKNOWN")

        if [[ "$pri" == "-100" ]]; then
            echo "✓ Hotspot '$conn_name' (on $iface) correct"
        else
            echo "✗ ⚠ '$conn_name' (on $iface) priority = $pri (want -100)"
	    echo "Fix: nmcli connection modify \"$conn_name\" connection.autoconnect-priority -100"
        fi
    done
}

# ──────────────────────────────────────────────────────────────
# High-level Overview (default)
# ──────────────────────────────────────────────────────────────

if [[ "$MODE" == "overview" ]]; then

    echo "=== Quick Verdict Summary ==="

    check_service "docker" "Docker"
    check_service "vastai" "Vast.ai daemon"
    check_nvidia

    echo ""
    echo "Port range configured:"
    get_port_count

    echo ""
    echo "Vast.ai machines (top lines):"
    show_machines_quick

    echo ""
    echo "API key status:"
    check_api_key

    echo ""
    echo "Check nmcli priority"
    check_hotspot_priority

    echo ""
    echo "Recommendation:"
    if systemctl is-active --quiet docker && systemctl is-active --quiet vastai && command -v nvidia-smi >/dev/null 2>&1; then
        echo "→ Core services look healthy"
        echo "→ Next: check dashboard for Verified / recent heartbeat / green Listed"
    else
        echo "→ Issues detected — run './vastai_services_test.sh detailed' for more info"
    fi

    echo ""
    echo "Full check: ./vastai_services_test.sh detailed"
    echo "===================================================="

    exit 0
fi

# ──────────────────────────────────────────────────────────────
# Detailed Mode
# ──────────────────────────────────────────────────────────────

echo "=== System & Hardware Overview ==="
hostnamectl 2>/dev/null || hostname && uname -a
echo ""
echo "Uptime: $(uptime)"
echo ""
echo "CPU:"
lscpu | grep -E "Model name|Socket|Core|Thread" || echo "(lscpu details limited)"
echo ""
echo "Memory:"
free -h
echo ""
echo "Disk (focus /var/lib/docker):"
df -h / /var/lib/docker 2>/dev/null || df -h /
echo ""

echo "=== NVIDIA / GPU ==="
nvidia-smi || echo "nvidia-smi FAILED"
echo ""

echo "=== Docker ==="
systemctl status docker --no-pager -l | head -n 15 || echo "Docker status not available"
echo ""
docker --version 2>/dev/null || echo "docker command not found"
echo "Running containers: $(docker ps -q | wc -l 2>/dev/null || echo '?')"
echo ""

echo "=== Vast.ai Daemon (vastai.service) ==="
systemctl status vastai --no-pager -l | head -n 20 || echo "Service not found"
echo ""
echo "Recent logs:"
journalctl -u vastai -n 20 --no-pager 2>/dev/null || echo "No logs found"
echo ""

echo "=== Vast.ai Port Range ==="
PORT_FILE="/var/lib/vastai_kaalia/host_port_range"
if [[ -f "$PORT_FILE" ]]; then
    echo "File: $PORT_FILE"
    cat "$PORT_FILE"
    echo ""
    get_port_count
else
    echo "Port range file NOT found → Vast.ai may use default or fail rentals"
fi
echo ""

echo "=== Vast.ai Machines (CLI) ==="
run_vastai show machines
echo ""

echo "=== API Key Status (Detailed) ==="
check_api_key
echo ""

echo "=== Verify Hotspot Priority ==="
check_hotspot_priority
echo ""

echo "===================================================="
echo "Detailed check complete."
echo "If issues: check dashboard → https://cloud.vast.ai/ → Hosting → Machines"
echo "Common fixes: sudo systemctl restart vastai, clean containers, unlist/relist machine"
echo "===================================================="
