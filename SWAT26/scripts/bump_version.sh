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
