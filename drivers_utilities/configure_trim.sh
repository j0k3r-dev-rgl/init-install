#!/bin/bash

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

print_info() { echo -e "${GREEN}[INFO]${NC} $*"; }
die() { echo -e "${RED}Error: $*${NC}" >&2; exit 1; }

[ "${EUID}" -eq 0 ] || exec sudo "$0" "$@"

print_info "Configurando fstrim.timer..."
mkdir -p /etc/systemd/system/fstrim.timer.d
cat > /etc/systemd/system/fstrim.timer.d/override.conf <<'EOF'
[Timer]
OnCalendar=
OnCalendar=daily
Persistent=true
EOF

systemctl daemon-reload
systemctl enable --now fstrim.timer
