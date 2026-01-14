#!/bin/bash
#
# BERYL'S SWAT26 - STORAGE INFRASTRUCTURE SETUP
# Sets up version-controlled storage on Pop!_OS, Seagate 5TB
#

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║     BERYL'S SWAT26 - STORAGE INFRASTRUCTURE SETUP            ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

USER_HOME="/home/beryleden1"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
VERSION="1.0.0"

# Storage locations
LOCAL_BERYL="$USER_HOME/beryl-bunker"
LOCAL_SWAT="$LOCAL_BERYL/SWAT26"
SEAGATE_BASE="/media/beryleden1/9361ec48-323e-44ae-84d5-9060ae68b575"
SEAGATE_BERYL="$SEAGATE_BASE/BERYL_AI_LABS"
SEAGATE_SWAT="$SEAGATE_BERYL/SWAT26"

echo "[1/5] Creating Local Storage..."
mkdir -p "$LOCAL_SWAT/dashboard"
mkdir -p "$LOCAL_SWAT/scripts"
mkdir -p "$LOCAL_SWAT/logs"
mkdir -p "$LOCAL_SWAT/evidence"
mkdir -p "$LOCAL_BERYL/phone_forensics"
mkdir -p "$LOCAL_BERYL/complaints"
echo "✓ Local structure created"

echo ""
echo "[2/5] Setting up Seagate 5TB..."
if [ -d "$SEAGATE_BASE" ]; then
    mkdir -p "$SEAGATE_BERYL"
    mkdir -p "$SEAGATE_SWAT/versions"
    mkdir -p "$SEAGATE_SWAT/backups/daily"
    mkdir -p "$SEAGATE_SWAT/backups/weekly"
    mkdir -p "$SEAGATE_SWAT/evidence_vault/phone"
    mkdir -p "$SEAGATE_SWAT/evidence_vault/network"
    mkdir -p "$SEAGATE_SWAT/evidence_vault/malware"
    mkdir -p "$SEAGATE_SWAT/litigation/complaints"
    mkdir -p "$SEAGATE_SWAT/litigation/evidence_packages"
    mkdir -p "$SEAGATE_SWAT/agents"
    echo "✓ Seagate structure created"
else
    echo "⚠ Seagate not found - connect and retry"
fi

echo ""
echo "[3/5] Creating Version Manifest..."
if [ -d "$SEAGATE_SWAT/versions" ]; then
    cat > "$SEAGATE_SWAT/versions/VERSION_MANIFEST.txt" << MANIFEST
════════════════════════════════════════════════════════════════
         BERYL'S SWAT26 - VERSION CONTROL MANIFEST
════════════════════════════════════════════════════════════════

CURRENT VERSION: $VERSION
CREATED: $TIMESTAMP
AUTHOR: TJ @ Beryl AI Labs

VERSION HISTORY:

v1.0.0 - $TIMESTAMP
  - Initial release
  - System Security Dashboard
  - Phone Forensics Module
  - SWAT-26 Modules (A-Z)
  - Claude Code Security Integration

════════════════════════════════════════════════════════════════
MANIFEST
    echo "✓ Version manifest created"
fi

echo ""
echo "[4/5] Creating Symlinks..."
ln -sf "$SEAGATE_BASE" "$USER_HOME/seagate" 2>/dev/null
ln -sf "$SEAGATE_BERYL" "$USER_HOME/BERYL_BACKUP" 2>/dev/null
echo "✓ Symlinks created"

echo ""
echo "[5/5] Creating Helper Scripts..."

# Auto-backup script
cat > "$LOCAL_SWAT/scripts/auto_backup.sh" << 'BACKUP'
#!/bin/bash
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOCAL="/home/beryleden1/beryl-bunker"
SEAGATE="/media/beryleden1/9361ec48-323e-44ae-84d5-9060ae68b575/BERYL_AI_LABS/SWAT26/backups"

if [ -d "$SEAGATE" ]; then
    tar -czf "$SEAGATE/daily/backup_$TIMESTAMP.tar.gz" "$LOCAL"
    ls -t "$SEAGATE/daily/"*.tar.gz | tail -n +8 | xargs -r rm
    echo "✓ Backup complete: backup_$TIMESTAMP.tar.gz"
else
    echo "✗ Seagate not mounted"
fi
BACKUP
chmod +x "$LOCAL_SWAT/scripts/auto_backup.sh"

# Version bump script
cat > "$LOCAL_SWAT/scripts/bump_version.sh" << 'VBUMP'
#!/bin/bash
SEAGATE_VER="/media/beryleden1/9361ec48-323e-44ae-84d5-9060ae68b575/BERYL_AI_LABS/SWAT26/versions"
LOCAL_DASH="/home/beryleden1/beryl-bunker/SWAT26/dashboard"
TS=$(date +%Y%m%d_%H%M%S)

if [ -z "$1" ]; then
    echo "Usage: ./bump_version.sh <version> [description]"
    exit 1
fi

cp "$LOCAL_DASH/index.html" "$SEAGATE_VER/SWAT26_v${1}_${TS}.html"
echo "v$1 - $TS" >> "$SEAGATE_VER/VERSION_MANIFEST.txt"
echo "  - ${2:-No description}" >> "$SEAGATE_VER/VERSION_MANIFEST.txt"
echo "✓ Version $1 saved"
VBUMP
chmod +x "$LOCAL_SWAT/scripts/bump_version.sh"

echo "✓ Helper scripts created"

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "              STORAGE SETUP COMPLETE"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "LOCAL: $LOCAL_SWAT"
echo "SEAGATE: $SEAGATE_SWAT"
echo ""
echo "SYMLINKS:"
echo "  ~/seagate      → Seagate 5TB"
echo "  ~/BERYL_BACKUP → Seagate SWAT26"
echo ""
echo "COMMANDS:"
echo "  Backup:  bash ~/beryl-bunker/SWAT26/scripts/auto_backup.sh"
echo "  Version: bash ~/beryl-bunker/SWAT26/scripts/bump_version.sh 1.1.0 'description'"
echo ""


