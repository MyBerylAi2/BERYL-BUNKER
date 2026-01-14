#!/bin/bash
################################################################################
#                     BERYL'S SWAT26 - PHONE FORENSICS SCANNER                 #
#                         Deep Scan for Samsung Devices                        #
#                              Commander: TJ                                   #
################################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
GOLD='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
EVIDENCE_DIR="$HOME/beryl-bunker/SWAT26/evidence/phone_scan_$TIMESTAMP"
SEAGATE_EVIDENCE="/media/beryleden1/9361ec48-323e-44ae-84d5-9060ae68b575/BERYL_AI_LABS/SWAT26/evidence_vault/phone"

echo -e "${GOLD}"
echo "╔════════════════════════════════════════════════════════════════════════╗"
echo "║           BERYL'S SWAT26 - PHONE FORENSICS DEEP SCANNER               ║"
echo "║                    Protecting Queen Beryl                              ║"
echo "╚════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Create evidence directory
mkdir -p "$EVIDENCE_DIR"/{apps,network,system,malware,google_sync,permissions,logs}

echo -e "${CYAN}[1/12] Checking Device Connection...${NC}"
DEVICE=$(adb devices | grep -v "List" | grep "device" | head -1 | awk '{print $1}')

if [ -z "$DEVICE" ]; then
    echo -e "${RED}✗ NO DEVICE DETECTED!${NC}"
    echo ""
    echo "Troubleshooting:"
    echo "  1. Enable USB Debugging on phone"
    echo "  2. Set USB mode to 'File Transfer'"
    echo "  3. Accept 'Allow USB Debugging' prompt on phone"
    echo "  4. Run: adb kill-server && adb start-server"
    exit 1
fi

echo -e "${GREEN}✓ Device Connected: $DEVICE${NC}"

# Get device info
echo -e "${CYAN}[2/12] Gathering Device Information...${NC}"
adb shell getprop ro.product.model > "$EVIDENCE_DIR/system/device_model.txt"
adb shell getprop ro.product.brand >> "$EVIDENCE_DIR/system/device_model.txt"
adb shell getprop ro.build.version.release > "$EVIDENCE_DIR/system/android_version.txt"
adb shell getprop ro.build.fingerprint > "$EVIDENCE_DIR/system/build_fingerprint.txt"
MODEL=$(cat "$EVIDENCE_DIR/system/device_model.txt" | head -1)
echo -e "${GREEN}✓ Model: $MODEL${NC}"

# List all installed apps
echo -e "${CYAN}[3/12] Scanning Installed Applications...${NC}"
adb shell pm list packages -f > "$EVIDENCE_DIR/apps/all_packages.txt"
adb shell pm list packages -3 > "$EVIDENCE_DIR/apps/third_party_apps.txt"
adb shell pm list packages -s > "$EVIDENCE_DIR/apps/system_apps.txt"
THIRD_PARTY=$(wc -l < "$EVIDENCE_DIR/apps/third_party_apps.txt")
echo -e "${GREEN}✓ Found $THIRD_PARTY third-party apps${NC}"

# Check for suspicious packages
echo -e "${CYAN}[4/12] Scanning for Known Malware Signatures...${NC}"
MALWARE_PATTERNS="rat|trojan|keylog|spy|hack|exploit|inject|backdoor|remote|vnc|teamviewer|anydesk|screen.?record|screen.?capture|hidden|stealth|daemon|service.?manager|device.?admin"

grep -iE "$MALWARE_PATTERNS" "$EVIDENCE_DIR/apps/all_packages.txt" > "$EVIDENCE_DIR/malware/suspicious_packages.txt" 2>/dev/null
SUSPICIOUS=$(wc -l < "$EVIDENCE_DIR/malware/suspicious_packages.txt")

if [ "$SUSPICIOUS" -gt 0 ]; then
    echo -e "${RED}⚠ ALERT: Found $SUSPICIOUS suspicious packages!${NC}"
    cat "$EVIDENCE_DIR/malware/suspicious_packages.txt"
else
    echo -e "${GREEN}✓ No obvious malware package names detected${NC}"
fi

# Check Device Administrators
echo -e "${CYAN}[5/12] Checking Device Administrators (CRITICAL)...${NC}"
adb shell dumpsys device_policy > "$EVIDENCE_DIR/permissions/device_admins_full.txt" 2>/dev/null
adb shell "dpm list-owners" > "$EVIDENCE_DIR/permissions/device_owners.txt" 2>/dev/null
grep -i "admin" "$EVIDENCE_DIR/permissions/device_admins_full.txt" > "$EVIDENCE_DIR/permissions/admin_apps.txt" 2>/dev/null

echo -e "${YELLOW}Device administrators can:${NC}"
echo "  - Lock your phone remotely"
echo "  - Wipe your data"
echo "  - Install apps silently"
echo "  - Monitor everything"
cat "$EVIDENCE_DIR/permissions/admin_apps.txt" 2>/dev/null | head -10

# Google Account & Sync Analysis
echo -e "${CYAN}[6/12] Auditing Google Sync (BACKDOOR CHECK)...${NC}"
adb shell dumpsys account > "$EVIDENCE_DIR/google_sync/accounts_full.txt" 2>/dev/null
adb shell "content query --uri content://com.google.settings/partner" > "$EVIDENCE_DIR/google_sync/google_settings.txt" 2>/dev/null
grep -i "account" "$EVIDENCE_DIR/google_sync/accounts_full.txt" | head -20 > "$EVIDENCE_DIR/google_sync/account_summary.txt"
echo -e "${GREEN}✓ Google account data captured${NC}"

# Network Connections
echo -e "${CYAN}[7/12] Scanning Active Network Connections...${NC}"
adb shell netstat -an > "$EVIDENCE_DIR/network/netstat.txt" 2>/dev/null || adb shell cat /proc/net/tcp > "$EVIDENCE_DIR/network/tcp_connections.txt" 2>/dev/null
adb shell ip addr > "$EVIDENCE_DIR/network/ip_addresses.txt" 2>/dev/null
adb shell "dumpsys connectivity" > "$EVIDENCE_DIR/network/connectivity.txt" 2>/dev/null

# Check for suspicious outbound connections
grep -E "ESTABLISHED|SYN_SENT" "$EVIDENCE_DIR/network/netstat.txt" > "$EVIDENCE_DIR/network/active_connections.txt" 2>/dev/null
ACTIVE_CONN=$(wc -l < "$EVIDENCE_DIR/network/active_connections.txt" 2>/dev/null || echo "0")
echo -e "${GREEN}✓ Found $ACTIVE_CONN active connections${NC}"

# Running Processes
echo -e "${CYAN}[8/12] Analyzing Running Processes...${NC}"
adb shell ps -A > "$EVIDENCE_DIR/system/all_processes.txt" 2>/dev/null
adb shell "dumpsys activity services" > "$EVIDENCE_DIR/system/running_services.txt" 2>/dev/null

# Check for suspicious processes
grep -iE "rat|spy|keylog|vnc|remote|hidden|inject" "$EVIDENCE_DIR/system/all_processes.txt" > "$EVIDENCE_DIR/malware/suspicious_processes.txt" 2>/dev/null
SUSP_PROC=$(wc -l < "$EVIDENCE_DIR/malware/suspicious_processes.txt")
if [ "$SUSP_PROC" -gt 0 ]; then
    echo -e "${RED}⚠ ALERT: $SUSP_PROC suspicious processes running!${NC}"
else
    echo -e "${GREEN}✓ No obviously suspicious processes${NC}"
fi

# Permissions Audit
echo -e "${CYAN}[9/12] Auditing Dangerous Permissions...${NC}"
DANGEROUS_PERMS="CAMERA|MICROPHONE|RECORD_AUDIO|READ_SMS|RECEIVE_SMS|READ_CONTACTS|READ_CALL_LOG|ACCESS_FINE_LOCATION|BIND_ACCESSIBILITY|SYSTEM_ALERT_WINDOW|BIND_DEVICE_ADMIN"

for pkg in $(adb shell pm list packages -3 | cut -d: -f2); do
    perms=$(adb shell dumpsys package "$pkg" 2>/dev/null | grep -iE "$DANGEROUS_PERMS")
    if [ -n "$perms" ]; then
        echo "$pkg:" >> "$EVIDENCE_DIR/permissions/dangerous_permissions.txt"
        echo "$perms" >> "$EVIDENCE_DIR/permissions/dangerous_permissions.txt"
        echo "---" >> "$EVIDENCE_DIR/permissions/dangerous_permissions.txt"
    fi
done
echo -e "${GREEN}✓ Permission audit complete${NC}"

# Accessibility Services (Often used by spyware)
echo -e "${CYAN}[10/12] Checking Accessibility Services (SPYWARE VECTOR)...${NC}"
adb shell settings get secure enabled_accessibility_services > "$EVIDENCE_DIR/permissions/accessibility_services.txt" 2>/dev/null
ACC_SERVICES=$(cat "$EVIDENCE_DIR/permissions/accessibility_services.txt")
if [ -n "$ACC_SERVICES" ] && [ "$ACC_SERVICES" != "null" ]; then
    echo -e "${RED}⚠ ACCESSIBILITY SERVICES ENABLED:${NC}"
    echo "$ACC_SERVICES"
    echo -e "${YELLOW}These can monitor EVERYTHING you do!${NC}"
else
    echo -e "${GREEN}✓ No suspicious accessibility services${NC}"
fi

# Battery & Usage Stats (Can reveal hidden apps)
echo -e "${CYAN}[11/12] Checking Battery Usage (Hidden App Detection)...${NC}"
adb shell dumpsys batterystats > "$EVIDENCE_DIR/system/battery_stats.txt" 2>/dev/null
adb shell dumpsys usagestats > "$EVIDENCE_DIR/system/usage_stats.txt" 2>/dev/null
echo -e "${GREEN}✓ Usage statistics captured${NC}"

# Extract APKs of suspicious apps
echo -e "${CYAN}[12/12] Extracting Evidence APKs...${NC}"
mkdir -p "$EVIDENCE_DIR/malware/apk_samples"

# Extract APKs from suspicious list if any
if [ -s "$EVIDENCE_DIR/malware/suspicious_packages.txt" ]; then
    while read line; do
        pkg=$(echo "$line" | grep -oP 'package:\K[^=]+' | cut -d'=' -f1)
        if [ -n "$pkg" ]; then
            APK_PATH=$(adb shell pm path "$pkg" 2>/dev/null | cut -d: -f2 | tr -d '\r')
            if [ -n "$APK_PATH" ]; then
                echo "  Extracting: $pkg"
                adb pull "$APK_PATH" "$EVIDENCE_DIR/malware/apk_samples/${pkg}.apk" 2>/dev/null
            fi
        fi
    done < "$EVIDENCE_DIR/malware/suspicious_packages.txt"
fi

# Generate Report
echo ""
echo -e "${GOLD}═══════════════════════════════════════════════════════════════════════${NC}"
echo -e "${GOLD}                         SCAN COMPLETE                                  ${NC}"
echo -e "${GOLD}═══════════════════════════════════════════════════════════════════════${NC}"
echo ""

# Summary Report
REPORT="$EVIDENCE_DIR/FORENSICS_REPORT.txt"
cat > "$REPORT" << EOF
================================================================================
           BERYL'S SWAT26 - PHONE FORENSICS REPORT
================================================================================
Scan Date: $(date)
Device: $MODEL
Evidence Directory: $EVIDENCE_DIR

FINDINGS SUMMARY
================

Third-Party Apps Installed: $THIRD_PARTY
Suspicious Package Names: $SUSPICIOUS
Suspicious Processes: $SUSP_PROC
Active Network Connections: $ACTIVE_CONN

CRITICAL CHECKS
===============

[Device Administrators]
$(cat "$EVIDENCE_DIR/permissions/admin_apps.txt" 2>/dev/null | head -5 || echo "None detected")

[Accessibility Services]
$(cat "$EVIDENCE_DIR/permissions/accessibility_services.txt" 2>/dev/null || echo "None detected")

[Suspicious Packages]
$(cat "$EVIDENCE_DIR/malware/suspicious_packages.txt" 2>/dev/null | head -10 || echo "None detected")

[Active Connections]
$(cat "$EVIDENCE_DIR/network/active_connections.txt" 2>/dev/null | head -10 || echo "None captured")

EVIDENCE LOCATIONS
==================
Apps:        $EVIDENCE_DIR/apps/
Network:     $EVIDENCE_DIR/network/
System:      $EVIDENCE_DIR/system/
Malware:     $EVIDENCE_DIR/malware/
Google Sync: $EVIDENCE_DIR/google_sync/
Permissions: $EVIDENCE_DIR/permissions/

RECOMMENDED ACTIONS
===================
1. Review device administrators - remove any unknown
2. Check accessibility services - disable if suspicious
3. Audit apps with dangerous permissions
4. Review active network connections for backdoors
5. Check Google account sync settings

================================================================================
                    Report Generated by BERYL'S SWAT26
================================================================================
EOF

echo -e "${GREEN}✓ Report saved: $REPORT${NC}"
echo ""

# Copy to Seagate if available
if [ -d "/media/beryleden1" ]; then
    mkdir -p "$SEAGATE_EVIDENCE" 2>/dev/null
    cp -r "$EVIDENCE_DIR" "$SEAGATE_EVIDENCE/" 2>/dev/null && \
    echo -e "${GREEN}✓ Evidence backed up to Seagate${NC}" || \
    echo -e "${YELLOW}⚠ Could not backup to Seagate${NC}"
fi

echo ""
echo -e "${CYAN}View full report:${NC}"
echo "  cat $REPORT"
echo ""
echo -e "${CYAN}Open evidence folder:${NC}"
echo "  nautilus $EVIDENCE_DIR"
echo ""
echo -e "${GOLD}═══════════════════════════════════════════════════════════════════════${NC}"
echo -e "${GOLD}                   QUEEN BERYL PROTECTED                               ${NC}"
echo -e "${GOLD}═══════════════════════════════════════════════════════════════════════${NC}"
