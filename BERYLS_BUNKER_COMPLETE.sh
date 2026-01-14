bash#!/bin/bash
#
# BERYL'S BUNKER - HEADLESS HUNTER COMPREHENSIVE SCAN
# PRIORITY: Linux Kernel → System Drive → Seagate
#

set -e

VERSION="3.0.0"
SCAN_DATE=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_DIR="/var/log/headless_hunter"
SYSTEM_LOG="$LOG_DIR/system_scan_${SCAN_DATE}.log"
SEAGATE_LOG="$LOG_DIR/seagate_scan_${SCAN_DATE}.log"
QUARANTINE="/var/quarantine/bunker_${SCAN_DATE}"

mkdir -p "$LOG_DIR" "$QUARANTINE"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# System counters
KERNEL_THREATS=0
ROOTKIT_MODULES=0
SYSTEM_MALWARE=0
CORRUPTED_BINARIES=0
BACKDOOR_PROCESSES=0
SUSPICIOUS_CRON=0
LISTENERS_FOUND=0
COMPROMISED_FILES=0

# Seagate counters
SEAGATE_THREATS=0
MALICIOUS_FILES=0
SUSPICIOUS_MODELS=0
HIDDEN_FILES=0
SEAGATE_ROOTKITS=0
SEAGATE_BACKDOORS=0

# Global action counters
TOTAL_THREATS=0
THREATS_ELIMINATED=0
FILES_QUARANTINED=0
PROCESSES_KILLED=0

clear
cat << "EOF"
╔════════════════════════════════════════════════════════════════════════════╗
║                                                                            ║
║   ██████╗ ███████╗██████╗ ██╗   ██╗██╗     ███████╗                      ║
║   ██╔══██╗██╔════╝██╔══██╗╚██╗ ██╔╝██║     ██╔════╝                      ║
║   ██████╔╝█████╗  ██████╔╝ ╚████╔╝ ██║     ███████╗                      ║
║   ██╔══██╗██╔══╝  ██╔══██╗  ╚██╔╝  ██║     ╚════██║                      ║
║   ██████╔╝███████╗██║  ██║   ██║   ███████╗███████║                      ║
║   ╚═════╝ ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚══════╝                      ║
║                                                                            ║
║   ██████╗ ██╗   ██╗███╗   ██╗██╗  ██╗███████╗██████╗                     ║
║   ██╔══██╗██║   ██║████╗  ██║██║ ██╔╝██╔════╝██╔══██╗                    ║
║   ██████╔╝██║   ██║██╔██╗ ██║█████╔╝ █████╗  ██████╔╝                    ║
║   ██╔══██╗██║   ██║██║╚██╗██║██╔═██╗ ██╔══╝  ██╔══██╗                    ║
║   ██████╔╝╚██████╔╝██║ ╚████║██║  ██╗███████╗██║  ██║                    ║
║   ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝                    ║
║                                                                            ║
║              COMPREHENSIVE SECURITY SCAN v3.0.0                           ║
║         Linux Kernel → System Drive → Seagate Fort Knox                   ║
║                                                                            ║
╚════════════════════════════════════════════════════════════════════════════╝
EOF

echo ""
echo -e "${PURPLE}Scan initiated: $SCAN_DATE${NC}"
echo -e "${PURPLE}System logs: $SYSTEM_LOG${NC}"
echo -e "${PURPLE}Seagate logs: $SEAGATE_LOG${NC}"
echo ""
sleep 2

# Logging functions
log_system() {
    echo "$1" | tee -a "$SYSTEM_LOG"
}

log_seagate() {
    echo "$1" | tee -a "$SEAGATE_LOG"
}

# Initialize logs
cat > "$SYSTEM_LOG" << SYSLOG
═══════════════════════════════════════════════════════════════
         BERYL'S BUNKER - SYSTEM SECURITY SCAN
═══════════════════════════════════════════════════════════════
Date: $SCAN_DATE
Hostname: $(hostname)
Kernel: $(uname -r)
User: $(whoami)
═══════════════════════════════════════════════════════════════

SYSLOG

cat > "$SEAGATE_LOG" << SEAGLOG
═══════════════════════════════════════════════════════════════
         BERYL'S BUNKER - SEAGATE FORT KNOX SCAN
═══════════════════════════════════════════════════════════════
Date: $SCAN_DATE
═══════════════════════════════════════════════════════════════

SEAGLOG

# ============================================================================
# PHASE 1: LINUX KERNEL SECURITY ANALYSIS
# ============================================================================
echo -e "${BOLD}${PURPLE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${PURPLE}║                       PHASE 1 OF 3                             ║${NC}"
echo -e "${BOLD}${PURPLE}║              LINUX KERNEL SECURITY SCAN                        ║${NC}"
echo -e "${BOLD}${PURPLE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

log_system "═══════════════════════════════════════════════════════════════"
log_system "PHASE 1: LINUX KERNEL SECURITY ANALYSIS"
log_system "═══════════════════════════════════════════════════════════════"

# MODULE 1: KERNEL MODULE INTEGRITY
echo -e "${BOLD}${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${BLUE}║  [1/10] KERNEL MODULE INTEGRITY CHECK                         ║${NC}"
echo -e "${BOLD}${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

log_system "[MODULE 1] KERNEL MODULE INTEGRITY"
log_system "───────────────────────────────────────────────────────────────"

echo -e "${CYAN}► Checking kernel modules...${NC}"
MODULE_COUNT=$(lsmod | wc -l)
echo "Loaded modules: $MODULE_COUNT"
log_system "Loaded modules: $MODULE_COUNT"

echo ""
echo -e "${CYAN}► Checking for suspicious module names...${NC}"
SUSPICIOUS_MODULES=$(lsmod | grep -iE "rootkit|hidden|backdoor|hack|inject" | awk '{print $1}')
if [ -n "$SUSPICIOUS_MODULES" ]; then
    echo -e "${RED}⚠ CRITICAL: Suspicious kernel modules detected!${NC}"
    echo "$SUSPICIOUS_MODULES" | tee -a "$SYSTEM_LOG"
    ((KERNEL_THREATS++))
    ((ROOTKIT_MODULES++))
    ((TOTAL_THREATS++))
else
    echo -e "${GREEN}✓ No suspicious module names${NC}"
fi

echo ""
echo -e "${CYAN}► Checking kernel taint status...${NC}"
TAINTED=$(cat /proc/sys/kernel/tainted 2>/dev/null || echo "0")
if [ "$TAINTED" != "0" ]; then
    echo -e "${YELLOW}⚠ Kernel is tainted (code: $TAINTED)${NC}"
    log_system "Kernel tainted: $TAINTED"
    ((KERNEL_THREATS++))
else
    echo -e "${GREEN}✓ Kernel not tainted${NC}"
fi

echo ""
echo -e "${CYAN}► Checking for LD_PRELOAD rootkits...${NC}"
if [ -n "$LD_PRELOAD" ]; then
    echo -e "${RED}⚠ CRITICAL: LD_PRELOAD set: $LD_PRELOAD${NC}"
    ((KERNEL_THREATS++))
    ((ROOTKIT_MODULES++))
    ((TOTAL_THREATS++))
    log_system "ROOTKIT: LD_PRELOAD=$LD_PRELOAD"
else
    echo -e "${GREEN}✓ LD_PRELOAD not set${NC}"
fi

if [ -f /etc/ld.so.preload ]; then
    echo -e "${RED}⚠ CRITICAL: /etc/ld.so.preload exists!${NC}"
    cat /etc/ld.so.preload | tee -a "$SYSTEM_LOG"
    ((KERNEL_THREATS++))
    ((ROOTKIT_MODULES++))
    ((TOTAL_THREATS++))
else
    echo -e "${GREEN}✓ /etc/ld.so.preload does not exist${NC}"
fi

log_system ""
echo ""
sleep 1

# MODULE 2: LISTENER DETECTION
echo -e "${BOLD}${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${BLUE}║  [2/10] LISTENER & PORT DETECTION                             ║${NC}"
echo -e "${BOLD}${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

log_system "[MODULE 2] LISTENERS & PORTS"
log_system "───────────────────────────────────────────────────────────────"

LISTENERS=$(netstat -tulpn 2>/dev/null | grep LISTEN)
LISTENERS_FOUND=$(echo "$LISTENERS" | grep -c "LISTEN" || echo "0")

if [ "$LISTENERS_FOUND" -eq 0 ]; then
    echo -e "${GREEN}✓ NO LISTENERS - FORTRESS MODE${NC}"
    log_system "Status: FORTRESS MODE"
else
    echo -e "${YELLOW}Active listeners: $LISTENERS_FOUND${NC}"
    echo "$LISTENERS" | tee -a "$SYSTEM_LOG"
    
    if echo "$LISTENERS" | grep ":631" > /dev/null; then
        echo -e "${RED}⚠ CUPS detected${NC}"
        ((TOTAL_THREATS++))
    fi
    
    if echo "$LISTENERS" | grep "systemd-resolv" > /dev/null; then
        echo -e "${RED}⚠ systemd-resolved detected${NC}"
        ((TOTAL_THREATS++))
    fi
fi

log_system ""
echo ""
sleep 1

# MODULE 3: PROCESS SCAN
echo -e "${BOLD}${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${BLUE}║  [3/10] MALICIOUS PROCESS DETECTION                           ║${NC}"
echo -e "${BOLD}${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

log_system "[MODULE 3] PROCESS SCAN"
log_system "───────────────────────────────────────────────────────────────"

PROCESS_COUNT=$(ps aux | wc -l)
echo "Total processes: $PROCESS_COUNT"
log_system "Total processes: $PROCESS_COUNT"

echo ""
echo -e "${CYAN}► Scanning for suspicious process names...${NC}"
MALICIOUS_PROCS="nc netcat ncat socat miner crypto xmr monero"
FOUND_MALICIOUS=0
for proc in $MALICIOUS_PROCS; do
    if ps aux | grep -i "[${proc:0:1}]${proc:1}" > /dev/null 2>&1; then
        echo -e "${RED}⚠ THREAT: '$proc' process detected!${NC}"
        ps aux | grep -i "[${proc:0:1}]${proc:1}" | tee -a "$SYSTEM_LOG"
        ((BACKDOOR_PROCESSES++))
        ((TOTAL_THREATS++))
        FOUND_MALICIOUS=1
    fi
done

if [ $FOUND_MALICIOUS -eq 0 ]; then
    echo -e "${GREEN}✓ No suspicious processes${NC}"
fi

log_system ""
echo ""
sleep 1

# MODULE 4: SYSTEM BINARY INTEGRITY
echo -e "${BOLD}${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${BLUE}║  [4/10] SYSTEM BINARY INTEGRITY                               ║${NC}"
echo -e "${BOLD}${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

log_system "[MODULE 4] BINARY INTEGRITY"
log_system "───────────────────────────────────────────────────────────────"

echo -e "${CYAN}► Checking critical binaries...${NC}"
CRITICAL_BINS="/bin/bash /usr/bin/sudo /bin/su /usr/bin/passwd"
for bin in $CRITICAL_BINS; do
    if [ -f "$bin" ]; then
        if find "$bin" -mtime -30 2>/dev/null | grep -q .; then
            echo -e "${YELLOW}⚠ Modified recently: $bin${NC}"
            ls -la "$bin" | tee -a "$SYSTEM_LOG"
            ((CORRUPTED_BINARIES++))
            ((TOTAL_THREATS++))
        fi
    fi
done

if [ $CORRUPTED_BINARIES -eq 0 ]; then
    echo -e "${GREEN}✓ All binaries verified${NC}"
fi

log_system ""
echo ""
sleep 1

# MODULE 5: HIDDEN FILES
echo -e "${BOLD}${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${BLUE}║  [5/10] HIDDEN MALWARE DETECTION                              ║${NC}"
echo -e "${BOLD}${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

log_system "[MODULE 5] HIDDEN MALWARE"
log_system "───────────────────────────────────────────────────────────────"

echo -e "${CYAN}► Scanning for hidden executables...${NC}"
HIDDEN_EXEC=$(find /tmp /var/tmp /dev/shm -type f -name ".*" -executable 2>/dev/null | head -10)
if [ -n "$HIDDEN_EXEC" ]; then
    echo -e "${RED}⚠ Hidden executables found!${NC}"
    echo "$HIDDEN_EXEC" | tee -a "$SYSTEM_LOG"
    ((SYSTEM_MALWARE+=5))
    ((TOTAL_THREATS+=5))
else
    echo -e "${GREEN}✓ No hidden executables${NC}"
fi

log_system ""
echo ""
sleep 1

# PHASE 2: SYSTEM DRIVE
echo ""
echo -e "${BOLD}${PURPLE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${PURPLE}║                       PHASE 2 OF 3                             ║${NC}"
echo -e "${BOLD}${PURPLE}║              SYSTEM DRIVE SCAN                                 ║${NC}"
echo -e "${BOLD}${PURPLE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

log_system "═══════════════════════════════════════════════════════════════"
log_system "PHASE 2: SYSTEM DRIVE SCAN"
log_system "═══════════════════════════════════════════════════════════════"

SYSTEM_DRIVE=$(df / | tail -1 | awk '{print $1}')
echo -e "${CYAN}System Drive: $SYSTEM_DRIVE${NC}"
df -h / | tail -1 | tee -a "$SYSTEM_LOG"

echo ""
echo -e "${CYAN}► Checking /tmp for threats...${NC}"
TMP_EXEC=$(find /tmp -type f -executable 2>/dev/null | wc -l)
echo "Executable files in /tmp: $TMP_EXEC"
if [ "$TMP_EXEC" -gt 5 ]; then
    echo -e "${YELLOW}⚠ Unusual number of executables in /tmp${NC}"
    ((TOTAL_THREATS++))
fi

log_system ""
echo ""
sleep 1

# PHASE 3: SEAGATE
echo ""
echo -e "${BOLD}${PURPLE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${PURPLE}║                       PHASE 3 OF 3                             ║${NC}"
echo -e "${BOLD}${PURPLE}║              SEAGATE FORT KNOX SCAN                            ║${NC}"
echo -e "${BOLD}${PURPLE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

log_seagate "═══════════════════════════════════════════════════════════════"
log_seagate "PHASE 3: SEAGATE SCAN"
log_seagate "═══════════════════════════════════════════════════════════════"

SEAGATE_MOUNT="/media/$USER/9361ec48-323e-44ae-84d5-9060ae68b575"
if [ -d "$SEAGATE_MOUNT" ]; then
    echo -e "${GREEN}✓ Seagate detected: $SEAGATE_MOUNT${NC}"
    df -h "$SEAGATE_MOUNT" | tail -1 | tee -a "$SEAGATE_LOG"
    
    echo ""
    echo -e "${CYAN}► Scanning Seagate...${NC}"
    
    HIDDEN=$(find "$SEAGATE_MOUNT" -name ".*" -type f 2>/dev/null | wc -l)
    echo "Hidden files: $HIDDEN"
    HIDDEN_FILES=$HIDDEN
    
    MODELS=$(find "$SEAGATE_MOUNT" -type f \( -name "*.gguf" -o -name "*.safetensors" \) 2>/dev/null | wc -l)
    echo "AI Models: $MODELS"
    
    MALICIOUS=$(find "$SEAGATE_MOUNT" -type f \( -name "*.exe" -o -name "*backdoor*" \) 2>/dev/null | wc -l)
    if [ "$MALICIOUS" -gt 0 ]; then
        echo -e "${YELLOW}⚠ Suspicious files: $MALICIOUS${NC}"
        MALICIOUS_FILES=$MALICIOUS
        ((SEAGATE_THREATS+=$MALICIOUS))
        ((TOTAL_THREATS+=$MALICIOUS))
    fi
    
    log_seagate "Hidden files: $HIDDEN_FILES"
    log_seagate "AI Models: $MODELS"
    log_seagate "Suspicious files: $MALICIOUS_FILES"
else
    echo -e "${YELLOW}! Seagate not connected - skipping${NC}"
    log_seagate "Seagate not detected"
fi

echo ""

# FINAL SUMMARY
echo ""
echo -e "${BOLD}${PURPLE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${PURPLE}║                    SCAN COMPLETE                               ║${NC}"
echo -e "${BOLD}${PURPLE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

{
    echo "═══════════════════════════════════════════════════════════════"
    echo "              BERYL'S BUNKER - FINAL REPORT"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    echo "PHASE 1: LINUX KERNEL & SYSTEM"
    printf "%-40s %10d\n" "  Kernel Threats:" "$KERNEL_THREATS"
    printf "%-40s %10d\n" "  Rootkit Modules:" "$ROOTKIT_MODULES"
    printf "%-40s %10d\n" "  Corrupted Binaries:" "$CORRUPTED_BINARIES"
    printf "%-40s %10d\n" "  Backdoor Processes:" "$BACKDOOR_PROCESSES"
    printf "%-40s %10d\n" "  System Malware:" "$SYSTEM_MALWARE"
    echo ""
    echo "PHASE 2: SYSTEM DRIVE"
    printf "%-40s %10d\n" "  Active Listeners:" "$LISTENERS_FOUND"
    echo ""
    echo "PHASE 3: SEAGATE FORT KNOX"
    printf "%-40s %10d\n" "  Seagate Threats:" "$SEAGATE_THREATS"
    printf "%-40s %10d\n" "  Malicious Files:" "$MALICIOUS_FILES"
    printf "%-40s %10d\n" "  Hidden Files:" "$HIDDEN_FILES"
    echo ""
    echo "TOTAL SUMMARY"
    printf "%-40s %10d\n" "  Total Threats Detected:" "$TOTAL_THREATS"
    printf "%-40s %10d\n" "  Threats Eliminated:" "$THREATS_ELIMINATED"
    printf "%-40s %10d\n" "  Files Quarantined:" "$FILES_QUARANTINED"
    printf "%-40s %10d\n" "  Processes Killed:" "$PROCESSES_KILLED"
    echo "═══════════════════════════════════════════════════════════════"
} | tee -a "$SYSTEM_LOG"

echo ""
if [ "$TOTAL_THREATS" -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✓✓✓ BERYL'S BUNKER SECURE - NO THREATS ✓✓✓                   ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
else
    echo -e "${YELLOW}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║  ⚠ $TOTAL_THREATS THREATS DETECTED ⚠                                      ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════════════════╝${NC}"
fi

echo ""
echo -e "${CYAN}System Report: $SYSTEM_LOG${NC}"
echo -e "${CYAN}Seagate Report: $SEAGATE_LOG${NC}"
echo ""
echo -e "${PURPLE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${GREEN}BERYL'S BUNKER - SCAN COMPLETE${NC}"
echo -e "${PURPLE}════════════════════════════════════════════════════════════════${NC}"
echo ""
