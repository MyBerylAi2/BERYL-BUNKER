#!/bin/bash
# BERYL'S BUNKER - FAST SCAN (No Delays)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║              BERYL'S BUNKER - FAST SCAN                        ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# KERNEL
echo -e "${CYAN}[1/5] KERNEL SECURITY${NC}"
echo "Modules: $(lsmod | wc -l)"
TAINT=$(cat /proc/sys/kernel/tainted 2>/dev/null || echo "0")
[ "$TAINT" != "0" ] && echo -e "${YELLOW}⚠ Tainted: $TAINT${NC}" || echo -e "${GREEN}✓ Clean${NC}"
echo ""

# LISTENERS
echo -e "${CYAN}[2/5] NETWORK LISTENERS${NC}"
LISTENERS=$(netstat -tulpn 2>/dev/null | grep -c LISTEN || echo "0")
echo "Listeners: $LISTENERS"
[ "$LISTENERS" -eq 0 ] && echo -e "${GREEN}✓ FORTRESS MODE${NC}" || netstat -tulpn 2>/dev/null | grep LISTEN
echo ""

# PROCESSES
echo -e "${CYAN}[3/5] PROCESSES${NC}"
echo "Total: $(ps aux | wc -l)"
ps aux | grep -iE "nc |netcat|miner|crypto" | grep -v grep && echo -e "${RED}⚠ Suspicious${NC}" || echo -e "${GREEN}✓ Clean${NC}"
echo ""

# SYSTEM
echo -e "${CYAN}[4/5] SYSTEM DRIVE${NC}"
df -h / | tail -1
TMP=$(find /tmp -type f -executable 2>/dev/null | wc -l)
echo "/tmp executables: $TMP"
echo ""

# SEAGATE
echo -e "${CYAN}[5/5] SEAGATE${NC}"
SEAGATE="/media/$USER/9361ec48-323e-44ae-84d5-9060ae68b575"
if [ -d "$SEAGATE" ]; then
    echo -e "${GREEN}✓ Connected${NC}"
    df -h "$SEAGATE" | tail -1
    echo "Hidden: $(find "$SEAGATE" -name ".*" -type f 2>/dev/null | wc -l)"
    echo "Models: $(find "$SEAGATE" -name "*.gguf" -o -name "*.safetensors" 2>/dev/null | wc -l)"
else
    echo -e "${YELLOW}! Not connected${NC}"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo -e "${GREEN}✓✓✓ SCAN COMPLETE ✓✓✓${NC}"
echo ""

