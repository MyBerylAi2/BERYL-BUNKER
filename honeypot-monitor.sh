#!/bin/bash
################################################################################
#           BERYL'S HONEYPOT MONITOR - TRIPWIRE DETECTION SYSTEM              #
#     Monitors decoy files and alerts on access attempts                       #
################################################################################

# Configuration
LOG_DIR="$HOME/beryl-bunker/logs"
EVENTS_FILE="$LOG_DIR/honeypot_events.json"
EMAIL="aimasterandjoel@gmail.com"
DASHBOARD="$HOME/beryl-bunker/traps-dashboard/index.html"

# Honeypot files to monitor
HONEYPOTS=(
    "$HOME/beryl-bunker/honeypots/passwords.txt"
    "$HOME/beryl-bunker/honeypots/credentials.json"
    "$HOME/beryl-bunker/honeypots/wallet_backup.txt"
    "$HOME/Documents/.secret_backup.zip.txt"
    "$HOME/.ssh/id_rsa_backup.txt"
)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Initialize
mkdir -p "$LOG_DIR"
touch "$EVENTS_FILE"

# Initialize JSON if empty
if [ ! -s "$EVENTS_FILE" ]; then
    echo "[]" > "$EVENTS_FILE"
fi

echo -e "${CYAN}"
echo "╔════════════════════════════════════════════════════════════════════════╗"
echo "║           BERYL'S HONEYPOT MONITOR - ACTIVE                           ║"
echo "╚════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${GREEN}Monitoring honeypots:${NC}"
for hp in "${HONEYPOTS[@]}"; do
    if [ -f "$hp" ]; then
        echo -e "  ${GREEN}✓${NC} $hp"
    else
        echo -e "  ${RED}✗${NC} $hp (not found)"
    fi
done

echo ""
echo -e "${YELLOW}Dashboard: file://$DASHBOARD${NC}"
echo -e "${YELLOW}Notifications: $EMAIL${NC}"
echo ""
echo -e "${CYAN}Press Ctrl+C to stop monitoring${NC}"
echo ""

# Function to get connection info
get_connection_info() {
    # Get active network connections
    local connections=$(ss -tnp 2>/dev/null | grep ESTAB | head -5)
    local source_ip="Local"

    # Check for any suspicious remote connections
    while IFS= read -r line; do
        local remote=$(echo "$line" | awk '{print $5}' | cut -d':' -f1)
        if [[ ! "$remote" =~ ^(127\.|192\.168\.|10\.|172\.) ]] && [ -n "$remote" ]; then
            source_ip="$remote"
            break
        fi
    done <<< "$connections"

    echo "$source_ip"
}

# Function to log event
log_event() {
    local file="$1"
    local event_type="$2"
    local process="$3"

    local timestamp=$(date -Iseconds)
    local source_ip=$(get_connection_info)
    local device="Lenovo Linux"

    # Determine threat level
    local threat="high"
    if [[ "$file" == *"passwords"* ]] || [[ "$file" == *"credentials"* ]] || [[ "$file" == *"wallet"* ]]; then
        threat="high"
    elif [[ "$file" == *"ssh"* ]]; then
        threat="high"
    else
        threat="medium"
    fi

    # Create JSON event
    local event=$(cat <<EOF
{
    "timestamp": "$timestamp",
    "type": "$event_type",
    "file": "$file",
    "device": "$device",
    "source_ip": "$source_ip",
    "process": "$process",
    "threat": "$threat",
    "blocked": false
}
EOF
)

    # Append to events file
    local current=$(cat "$EVENTS_FILE")
    if [ "$current" = "[]" ]; then
        echo "[$event]" > "$EVENTS_FILE"
    else
        # Remove trailing ] and add new event
        echo "${current%]}, $event]" > "$EVENTS_FILE"
    fi

    # Console alert
    echo ""
    echo -e "${RED}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                    HONEYPOT TRIGGERED!                                ║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${YELLOW}Time:${NC}    $timestamp"
    echo -e "${YELLOW}File:${NC}    $file"
    echo -e "${YELLOW}Event:${NC}   $event_type"
    echo -e "${YELLOW}Process:${NC} $process"
    echo -e "${YELLOW}Source:${NC}  $source_ip"
    echo -e "${YELLOW}Threat:${NC}  ${RED}$threat${NC}"
    echo ""

    # Send email notification
    send_email_alert "$file" "$event_type" "$timestamp" "$source_ip" "$process" "$threat"
}

# Function to send email alert
send_email_alert() {
    local file="$1"
    local event_type="$2"
    local timestamp="$3"
    local source_ip="$4"
    local process="$5"
    local threat="$6"

    local subject="[TRAPS ALERT] Honeypot Triggered - $threat threat"
    local body="HONEYPOT INTRUSION DETECTED

Time: $timestamp
Device: Lenovo Linux
File Accessed: $file
Event Type: $event_type
Source IP: $source_ip
Process: $process
Threat Level: $threat

Dashboard: file://$DASHBOARD

This is an automated alert from Beryl's TRAPS system.
"

    # Try multiple email methods
    if command -v mail &> /dev/null; then
        echo "$body" | mail -s "$subject" "$EMAIL" 2>/dev/null && \
            echo -e "${GREEN}Email sent to $EMAIL${NC}"
    elif command -v sendmail &> /dev/null; then
        echo -e "Subject: $subject\n\n$body" | sendmail "$EMAIL" 2>/dev/null && \
            echo -e "${GREEN}Email sent to $EMAIL${NC}"
    elif command -v msmtp &> /dev/null; then
        echo -e "Subject: $subject\nTo: $EMAIL\n\n$body" | msmtp "$EMAIL" 2>/dev/null && \
            echo -e "${GREEN}Email sent to $EMAIL${NC}"
    elif command -v curl &> /dev/null; then
        # Log that email couldn't be sent but event was recorded
        echo -e "${YELLOW}Email client not configured - event logged to dashboard${NC}"
    fi

    # Also log to separate alert file
    echo "[$timestamp] $threat ALERT: $file accessed from $source_ip" >> "$LOG_DIR/alerts.log"
}

# Build inotifywait watch list
WATCH_LIST=""
for hp in "${HONEYPOTS[@]}"; do
    if [ -f "$hp" ]; then
        WATCH_LIST="$WATCH_LIST $hp"
    fi
done

# Check if inotifywait is available
if ! command -v inotifywait &> /dev/null; then
    echo -e "${YELLOW}Installing inotify-tools...${NC}"
    sudo apt-get install -y inotify-tools 2>/dev/null || {
        echo -e "${RED}Could not install inotify-tools. Please install manually:${NC}"
        echo "  sudo apt-get install inotify-tools"
        exit 1
    }
fi

# Start monitoring
echo -e "${GREEN}Honeypot monitoring ACTIVE${NC}"
echo ""

inotifywait -m -e access,open,modify,attrib $WATCH_LIST 2>/dev/null | while read -r directory event file; do
    # Get the full path
    full_path="${directory}${file}"
    if [ -z "$file" ]; then
        full_path="$directory"
    fi

    # Get process info
    process_info=$(lsof "$full_path" 2>/dev/null | tail -1 | awk '{print $1 " (PID: " $2 ")"}')
    if [ -z "$process_info" ]; then
        process_info="Unknown"
    fi

    # Log the event
    case "$event" in
        ACCESS|OPEN)
            log_event "$full_path" "ACCESS" "$process_info"
            ;;
        MODIFY)
            log_event "$full_path" "MODIFY" "$process_info"
            ;;
        ATTRIB)
            log_event "$full_path" "ATTRIB_CHANGE" "$process_info"
            ;;
    esac
done
