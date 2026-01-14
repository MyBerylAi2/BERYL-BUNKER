#!/bin/bash
# HACKER DETECTOR - Find fake antigravity

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║          HACKER DETECTION - ANTIGRAVITY ANALYSIS               ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

echo -e "${CYAN}[1] Checking for antigravity processes...${NC}"
ANTIGRAV=$(ps aux | grep -i antigravity | grep -v grep)
if [ -n "$ANTIGRAV" ]; then
    echo -e "${RED}⚠ ANTIGRAVITY STILL RUNNING AFTER APP CLOSED!${NC}"
    echo "$ANTIGRAV"
    echo ""
    
    # Get PIDs
    PIDS=$(echo "$ANTIGRAV" | awk '{print $2}')
    echo -e "${CYAN}PIDs found: $PIDS${NC}"
    echo ""
    
    # Check each process
    for PID in $PIDS; do
        echo -e "${YELLOW}Analyzing PID: $PID${NC}"
        echo "Command: $(ps -p $PID -o cmd= 2>/dev/null)"
        echo "Path: $(readlink -f /proc/$PID/exe 2>/dev/null)"
        echo "User: $(ps -p $PID -o user= 2>/dev/null)"
        echo "Started: $(ps -p $PID -o lstart= 2>/dev/null)"
        echo ""
        
        # Check network connections
        CONNS=$(sudo lsof -p $PID 2>/dev/null | grep LISTEN)
        if [ -n "$CONNS" ]; then
            echo -e "${RED}Network connections:${NC}"
            echo "$CONNS"
        fi
        echo ""
        echo "---"
    done
else
    echo -e "${GREEN}✓ No antigravity processes running${NC}"
fi

echo ""
echo -e "${CYAN}[2] Checking ports 9092 and 9101...${NC}"
PORT_9092=$(sudo lsof -i :9092 2>/dev/null)
PORT_9101=$(sudo lsof -i :9101 2>/dev/null)

if [ -n "$PORT_9092" ]; then
    echo -e "${RED}⚠ Port 9092 STILL IN USE:${NC}"
    echo "$PORT_9092"
    echo ""
fi

if [ -n "$PORT_9101" ]; then
    echo -e "${RED}⚠ Port 9101 STILL IN USE:${NC}"
    echo "$PORT_9101"
    echo ""
fi

if [ -z "$PORT_9092" ] && [ -z "$PORT_9101" ]; then
    echo -e "${GREEN}✓ Ports 9092 and 9101 are clear${NC}"
fi

echo ""
echo -e "${CYAN}[3] Checking all suspicious listeners...${NC}"
echo "Listeners on localhost only (should be safe if legitimate):"
sudo netstat -tulpn | grep "127.0.0.1" | grep LISTEN

echo ""
echo "Listeners on ALL interfaces (POTENTIAL BACKDOORS):"
sudo netstat -tulpn | grep "0.0.0.0" | grep LISTEN
sudo netstat -tulpn | grep ":::" | grep LISTEN

echo ""
echo -e "${CYAN}[4] Checking for unusual executables...${NC}"
EXE_PROCS=$(ps aux | grep " exe$" | grep -v grep)
if [ -n "$EXE_PROCS" ]; then
    echo -e "${YELLOW}Processes named 'exe' (suspicious on Linux):${NC}"
    echo "$EXE_PROCS"
    echo ""
    
    # Analyze each exe
    EXE_PIDS=$(echo "$EXE_PROCS" | awk '{print $2}')
    for PID in $EXE_PIDS; do
        echo "PID $PID location: $(readlink -f /proc/$PID/exe 2>/dev/null)"
    done
else
    echo -e "${GREEN}✓ No suspicious 'exe' processes${NC}"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "                    DETECTION COMPLETE"
echo "═══════════════════════════════════════════════════════════════"


