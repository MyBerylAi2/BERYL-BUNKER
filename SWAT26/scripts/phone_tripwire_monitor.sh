#!/bin/bash
################################################################################
#                    BERYL'S SWAT26 - PHONE TRIPWIRE MONITOR                   #
#                         Real-time Intrusion Detection                        #
################################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
GOLD='\033[0;33m'
NC='\033[0m'

ADB="/tmp/platform-tools/adb"
DEVICE="MFAIUSYTHYGUMRRC"
LOG_DIR="$HOME/beryl-bunker/SWAT26/tripwire_logs"
ALERT_LOG="$LOG_DIR/alerts_$(date +%Y%m%d).log"

mkdir -p "$LOG_DIR"

echo -e "${GOLD}"
echo "╔════════════════════════════════════════════════════════════════════════╗"
echo "║           BERYL'S SWAT26 - PHONE TRIPWIRE MONITOR                      ║"
echo "║                  Real-time Intrusion Detection                         ║"
echo "╚════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Honeypot files to monitor
HONEYPOTS=(
    "/sdcard/Documents/.system_backup/passwords.txt"
    "/sdcard/Documents/.system_backup/bank_accounts.csv"
    "/sdcard/Documents/.system_backup/crypto_wallet_seed.txt"
    "/sdcard/DCIM/.thumbnails_cache/private_photos.db"
    "/sdcard/Download/.temp_files/credentials.json"
)

# Get initial state
declare -A BASELINE

echo -e "${CYAN}Establishing baseline...${NC}"
for file in "${HONEYPOTS[@]}"; do
    stat_output=$($ADB -s $DEVICE shell "stat -c '%Y' \"$file\" 2>/dev/null")
    BASELINE["$file"]="$stat_output"
    echo "  $file: $stat_output"
done

# Also monitor critical system files
SYSTEM_MONITORS=(
    "/data/misc/adb/adb_keys"
    "/sdcard/.honeypot_baseline.txt"
)

echo ""
echo -e "${GREEN}✓ Baseline established${NC}"
echo -e "${YELLOW}Starting continuous monitoring... (Ctrl+C to stop)${NC}"
echo ""

# Alert function
alert() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${RED}🚨 ALERT [$timestamp]: $message${NC}"
    echo "[$timestamp] ALERT: $message" >> "$ALERT_LOG"

    # Play alert sound if available
    paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga 2>/dev/null &

    # Desktop notification
    notify-send -u critical "🚨 PHONE INTRUSION DETECTED" "$message" 2>/dev/null
}

# Monitor loop
ITERATION=0
while true; do
    ITERATION=$((ITERATION + 1))

    # Check device connection
    if ! $ADB -s $DEVICE shell "echo connected" &>/dev/null; then
        echo -e "${RED}⚠ Device disconnected! Waiting...${NC}"
        sleep 5
        continue
    fi

    # Check honeypot files
    for file in "${HONEYPOTS[@]}"; do
        current_stat=$($ADB -s $DEVICE shell "stat -c '%Y' \"$file\" 2>/dev/null" | tr -d '\r')
        baseline_stat="${BASELINE[$file]}"

        if [ "$current_stat" != "$baseline_stat" ] && [ -n "$current_stat" ]; then
            alert "HONEYPOT ACCESSED: $file"
            alert "Previous: $baseline_stat | Current: $current_stat"
            BASELINE["$file"]="$current_stat"  # Update baseline
        fi
    done

    # Check for new ADB authorizations
    new_keys=$($ADB -s $DEVICE shell "cat /data/misc/adb/adb_keys 2>/dev/null | wc -l" | tr -d '\r')
    if [ "$new_keys" -gt 0 ] 2>/dev/null; then
        alert "NEW ADB AUTHORIZATION DETECTED! $new_keys keys found"
    fi

    # Check for new installed apps (every 10 iterations)
    if [ $((ITERATION % 10)) -eq 0 ]; then
        current_apps=$($ADB -s $DEVICE shell "pm list packages -3 | wc -l" | tr -d '\r')
        if [ -z "$LAST_APP_COUNT" ]; then
            LAST_APP_COUNT="$current_apps"
        elif [ "$current_apps" != "$LAST_APP_COUNT" ]; then
            alert "APP COUNT CHANGED! Was: $LAST_APP_COUNT Now: $current_apps"
            LAST_APP_COUNT="$current_apps"
        fi
    fi

    # Check for enabled accessibility services
    acc_services=$($ADB -s $DEVICE shell "settings get secure enabled_accessibility_services" | tr -d '\r')
    if [ "$acc_services" != "null" ] && [ -n "$acc_services" ]; then
        alert "ACCESSIBILITY SERVICE ENABLED: $acc_services"
    fi

    # Status update every 60 seconds
    if [ $((ITERATION % 12)) -eq 0 ]; then
        echo -e "${GREEN}[$(date '+%H:%M:%S')] Monitoring active - Iteration $ITERATION - No intrusions detected${NC}"
    fi

    sleep 5
done
