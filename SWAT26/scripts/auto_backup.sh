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
