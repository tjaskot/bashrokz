
#!/usr/bin/env bash
# --- ON NEW MACHINES ---
# chmod +x fix_docker_permissions.sh
# sudo bash fix_docker_permissions.sh
# newgrp docker  # apply to current session
# docker ps      # verify
# -----------------------

# fix_docker_permissions.sh
# Fixes Docker socket permissions for all non-system users.
# Run with: sudo bash fix_docker_permissions.sh

set -euo pipefail

echo "===================================================="
echo "  Docker Permission Fix"
echo "===================================================="
echo ""

# Must be run as root
if [[ $EUID -ne 0 ]]; then
    echo "✗ Please run as root: sudo bash fix_docker_permissions.sh"
    exit 1
fi

SOCK="/var/run/docker.sock"
DROPIN_DIR="/etc/systemd/system/docker.service.d"
DROPIN_FILE="$DROPIN_DIR/10-socket-perms.conf"

# ── 1. Ensure docker group exists ─────────────────────────────
echo "→ Ensuring docker group exists..."
groupadd -f docker
echo "✓ docker group ready"
echo ""

# ── 2. Add all non-system users to docker group ───────────────
echo "→ Adding all users (UID≥1000) to docker group..."
while IFS=: read -r uname _ uid _; do
    if [[ "$uid" -ge 1000 && "$uname" != "nobody" ]]; then
        usermod -aG docker "$uname"
        echo "  ✓ Added $uname to docker group"
    fi
done < /etc/passwd
echo ""

# ── 3. Fix socket ownership and permissions right now ─────────
echo "→ Fixing Docker socket permissions..."
if [[ -S "$SOCK" ]]; then
    chown root:docker "$SOCK"
    chmod 660 "$SOCK"
    echo "  ✓ $SOCK → root:docker 660"
else
    echo "  ⚠ Socket not found at $SOCK (is Docker running?)"
    echo "    Run: sudo systemctl start docker"
    echo "    Then re-run this script, or manually:"
    echo "    sudo chown root:docker $SOCK && sudo chmod 660 $SOCK"
fi
echo ""

# ── 4. Install systemd drop-in to survive restarts ───────────
echo "→ Installing systemd drop-in for persistent permissions..."
mkdir -p "$DROPIN_DIR"
cat > "$DROPIN_FILE" <<'EOF'
[Service]
ExecStartPost=/bin/bash -c 'sleep 1 && chown root:docker /var/run/docker.sock && chmod 660 /var/run/docker.sock'
EOF
echo "  ✓ Written: $DROPIN_FILE"
echo ""

# ── 5. Reload systemd and restart Docker ─────────────────────
echo "→ Reloading systemd and restarting Docker..."
systemctl daemon-reload
systemctl restart docker
echo "  ✓ Docker restarted"
echo ""

# ── 6. Verify ─────────────────────────────────────────────────
echo "=== Verification ==="

# Socket perms
SOCK_GROUP=$(stat -c '%G' "$SOCK" 2>/dev/null || echo "unknown")
SOCK_PERMS=$(stat -c '%a' "$SOCK" 2>/dev/null || echo "unknown")
echo "Socket: $(ls -la $SOCK)"
[[ "$SOCK_GROUP" == "docker" && "$SOCK_PERMS" == "660" ]] \
    && echo "✓ Socket permissions correct" \
    || echo "✗ Socket permissions unexpected: group=$SOCK_GROUP perms=$SOCK_PERMS"

# Drop-in exists
[[ -f "$DROPIN_FILE" ]] \
    && echo "✓ Systemd drop-in in place" \
    || echo "✗ Drop-in missing"

# Group membership
echo ""
echo "Docker group members (UID≥1000):"
while IFS=: read -r uname _ uid _; do
    if [[ "$uid" -ge 1000 && "$uname" != "nobody" ]]; then
        if groups "$uname" 2>/dev/null | grep -qw docker; then
            echo "  ✓ $uname"
        else
            echo "  ✗ $uname (not in docker group)"
        fi
    fi
done < /etc/passwd

echo ""
echo "===================================================="
echo "✓ Done. For changes to take effect in existing"
echo "  terminal sessions, run:  newgrp docker"
echo "  Or log out and back in."
echo "===================================================="
