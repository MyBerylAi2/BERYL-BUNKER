#!/bin/bash
# NUCLEAR OPTION - Kill all port holders and ban their IPs

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

BAN_LOG="/var/log/headless_hunter/banned_attackers.log"
COMPLAINT_FILE="/var/log/headless_hunter/complaint_report_$(date +%Y%m%d_%H%M%S).txt"

mkdir -p /var/log/headless_hunter

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║          NUCLEAR STRIKE - KILL & BAN ALL ATTACKERS            ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Get ALL listeners
echo -e "${CYAN}[1] Identifying all port holders...${NC}"
netstat -tulpn 2>/dev/null | grep LISTEN

echo ""
echo -e "${RED}[2] Extracting attacker IPs and processes...${NC}"

# Get PIDs of all listeners
PIDS=$(netstat -tulpn 2>/dev/null | grep LISTEN | awk '{print $7}' | cut -d'/' -f1 | sort -u)

for PID in $PIDS; do
    if [ "$PID" != "-" ] && [ -n "$PID" ]; then
        PROC_NAME=$(ps -p $PID -o comm= 2>/dev/null)
        PROC_CMD=$(ps -p $PID -o cmd= 2>/dev/null)
        PROC_USER=$(ps -p $PID -o user= 2>/dev/null)
        
        echo ""
        echo "=== PID: $PID | Process: $PROC_NAME | User: $PROC_USER ==="
        
        # Get network connections for this PID
        CONNECTIONS=$(lsof -p $PID -i 2>/dev/null | grep -E "ESTABLISHED|LISTEN")
        if [ -n "$CONNECTIONS" ]; then
            echo "$CONNECTIONS"
            
            # Extract remote IPs
            REMOTE_IPS=$(echo "$CONNECTIONS" | awk '{print $9}' | grep '->' | cut -d'>' -f2 | cut -d':' -f1 | sort -u)
            
            if [ -n "$REMOTE_IPS" ]; then
                echo ""
                echo -e "${RED}Remote IPs connected to this process:${NC}"
                for IP in $REMOTE_IPS; do
                    echo "  • $IP"
                    
                    # Log and ban
                    echo "[$(date)] PID:$PID | Process:$PROC_NAME | Remote IP:$IP | BANNED" >> "$BAN_LOG"
                    
                    # Ban the IP
                    iptables -A INPUT -s $IP -j DROP 2>/dev/null
                    iptables -A OUTPUT -d $IP -j DROP 2>/dev/null
                    ufw deny from $IP 2>/dev/null
                    
                    # Get WHOIS info
                    echo "Getting server info for $IP..."
                    WHOIS_INFO=$(whois $IP 2>/dev/null | grep -iE "abuse|OrgName|NetName")
                    echo "$WHOIS_INFO"
                    
                    # Add to complaint
                    {
                        echo "═══════════════════════════════════════════════════════════════"
                        echo "COMPLAINT AGAINST: $IP"
                        echo "DATE: $(date)"
                        echo "═══════════════════════════════════════════════════════════════"
                        echo "ATTACKING PROCESS: PID:$PID | $PROC_NAME | $PROC_CMD"
                        echo "WHOIS: $WHOIS_INFO"
                        echo ""
                    } >> "$COMPLAINT_FILE"
                done
            fi
        fi
        
        echo ""
        echo -e "${RED}>>> KILLING PID $PID <<<${NC}"
        kill -9 $PID 2>/dev/null
    fi
done

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "                    ATTACK TERMINATED"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Banned IPs: $BAN_LOG"
echo "Complaint: $COMPLAINT_FILE"
echo ""
echo -e "${GREEN}✓ All attackers killed and banned${NC}"

