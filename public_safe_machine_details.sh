#!/bin/bash
# gather-safe-info.sh
# Collects share-safe summary info about an Ubuntu machine (no IPs, MACs, serials, usernames, or full logs).
# Run WITHOUT sudo. Outputs a single timestamped report in /tmp.

OUT="/tmp/machine-safe-summary-$(hostname 2>/dev/null | sed 's/[^A-Za-z0-9_-]/_/g')-$(date +%Y%m%d%H%M%S).txt"

echo "Machine Safe Summary" > "$OUT"
echo "Generated: $(date -u +"%Y-%m-%d %H:%M:%SZ") (UTC)" >> "$OUT"
echo "" >> "$OUT"

# OS & Kernel (non-identifying)
echo "=== OS & Kernel ===" >> "$OUT"
lsb_release -d 2>/dev/null | sed 's/Description:\s*/OS: /' >> "$OUT"
uname -srmo >> "$OUT"
echo "" >> "$OUT"

# CPU (model & counts only)
echo "=== CPU ===" >> "$OUT"
lscpu | sed -n -e 's/Model name:\s*/Model: /p' -e 's/Architecture:\s*/Architecture: /p' -e 's/CPU(s):\s*/CPUs: /p' -e 's/Thread(s) per core:\s*/Threads\/core: /p' -e 's/Core(s) per socket:\s*/Cores\/socket: /p' >> "$OUT"
echo "" >> "$OUT"

# Memory (totals only)
echo "=== Memory ===" >> "$OUT"
free -h | awk 'NR==2{print "Total: " $2 " | Used: " $3 " | Free: " $4}' >> "$OUT"
echo "" >> "$OUT"

# GPU / Display (vendor/model lines only)
echo "=== GPU / Display ===" >> "$OUT"
lspci 2>/dev/null | egrep -i 'vga|3d|display' | sed -E 's/^[^:]*: //g' >> "$OUT" 2>/dev/null || true
command -v lshw >/dev/null 2>&1 && lshw -C display 2>/dev/null | sed -n 's/^\s*product: /Product: /p; s/^\s*vendor: /Vendor: /p; s/^\s*configuration: /Configuration: /p' >> "$OUT" || true
echo "" >> "$OUT"

# Disks & filesystems (names, sizes, mountpoints only)
echo "=== Disks & Filesystems ===" >> "$OUT"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT -P | sed -E 's/NAME="([^"]+)" SIZE="([^"]+)" TYPE="([^"]+)" MOUNTPOINT="([^"]*)"/\1 \2 \3 \4/' >> "$OUT" 2>/dev/null || true
df -h --output=source,size,used,avail,pcent,target | sed '1d' >> "$OUT" 2>/dev/null || true
echo "" >> "$OUT"

# Top-level directory sizes (safe summaries)
echo "=== Top directory sizes (safe summaries) ===" >> "$OUT"
du -sh /home/* 2>/dev/null | sort -hr | head -n 10 | sed 's/\/home\//HOME: /' >> "$OUT" 2>/dev/null || true
du -sh /var/* 2>/dev/null | sort -hr | head -n 10 | sed 's/\/var\//VAR: /' >> "$OUT" 2>/dev/null || true
echo "" >> "$OUT"

# Network interfaces (names & state only)
echo "=== Network Interfaces (names & state only) ===" >> "$OUT"
ip -o link show 2>/dev/null | awk -F': ' '{print $2}' | awk '{print $1 " | State: " $9}' 2>/dev/null >> "$OUT" || true
echo "" >> "$OUT"

# Listening ports (service:port/proto) - hide IPs
echo "=== Listening ports (service:port/proto) ===" >> "$OUT"
ss -lntup 2>/dev/null | awk 'NR>1{proto=$1; split($4,a,":"); port=a[length(a)]; svc=$6; gsub(",","",svc); if(svc!="-") print svc " : " port " / " proto}' | sed '/^ *: /d' | sort -u >> "$OUT" 2>/dev/null || true
echo "" >> "$OUT"

# Installed packages (counts only)
echo "=== Installed packages (counts) ===" >> "$OUT"
if command -v dpkg >/dev/null 2>&1; then
  echo "dpkg packages: $(dpkg -l 2>/dev/null | grep -c '^ii')" >> "$OUT"
fi
if command -v snap >/dev/null 2>&1; then
  echo "snap packages: $(snap list 2>/dev/null | tail -n +2 | wc -l)" >> "$OUT"
fi
if command -v flatpak >/dev/null 2>&1; then
  echo "flatpak packages: $(flatpak list 2>/dev/null | wc -l)" >> "$OUT"
fi
echo "" >> "$OUT"

# Running services (names only)
echo "=== Running system services (names only) ===" >> "$OUT"
systemctl list-units --type=service --state=running --no-pager --no-legend 2>/dev/null | awk '{print $1}' | head -n 50 >> "$OUT" 2>/dev/null || true
echo "" >> "$OUT"

# Uptime & load
echo "=== Uptime & Load ===" >> "$OUT"
uptime -p >> "$OUT" 2>/dev/null || true
cat /proc/loadavg 2>/dev/null | awk '{print "Load (1/5/15min): " $1 " " $2 " " $3}' >> "$OUT" 2>/dev/null || true
echo "" >> "$OUT"

# Security / Access summaries (counts only)
echo "=== Security / Access summaries ===" >> "$OUT"
echo "Local users count: $(getent passwd | wc -l)" >> "$OUT"
echo "Sudo-enabled users (count): $(getent group sudo 2>/dev/null | awk -F: '{print $4}' | tr ',' '\n' | grep -vc '^$' )" >> "$OUT"
echo "" >> "$OUT"

# Footer note
echo "=== Notes ===" >> "$OUT"
echo "This report omits IPs, MACs, hostnames, serials, full logs and full package lists." >> "$OUT"
echo "Request a specific additional safe summary if needed (e.g., CPU features or disk capacity breakdown)." >> "$OUT"

chmod 644 "$OUT" 2>/dev/null || true
echo "Safe summary written to: $OUT"
