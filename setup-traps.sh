#!/bin/bash
################################################################################
#           BERYL'S TRAPS - HONEYPOT SETUP SCRIPT                             #
#     Run this with: bash ~/beryl-bunker/setup-traps.sh                       #
################################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "╔════════════════════════════════════════════════════════════════════════╗"
echo "║           BERYL'S TRAPS - HONEYPOT SETUP                              ║"
echo "╚════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${CYAN}[1/4] Installing inotify-tools...${NC}"
sudo apt-get update && sudo apt-get install -y inotify-tools
echo -e "${GREEN}✓ Installed${NC}"

echo -e "${CYAN}[2/4] Installing mail utilities...${NC}"
sudo apt-get install -y mailutils msmtp msmtp-mta 2>/dev/null || echo "Mail utils optional"
echo -e "${GREEN}✓ Done${NC}"

echo -e "${CYAN}[3/4] Enabling honeypot monitor service...${NC}"
systemctl --user daemon-reload
systemctl --user enable honeypot-monitor.service
systemctl --user start honeypot-monitor.service
echo -e "${GREEN}✓ Service started${NC}"

echo -e "${CYAN}[4/4] Setting up autostart...${NC}"
loginctl enable-linger $USER 2>/dev/null || echo "Linger may need root"
echo -e "${GREEN}✓ Done${NC}"

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║           TRAPS SYSTEM ACTIVE                                         ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Dashboard: ${CYAN}file://$HOME/beryl-bunker/traps-dashboard/index.html${NC}"
echo -e "Logs:      ${CYAN}$HOME/beryl-bunker/logs/${NC}"
echo -e "Monitor:   ${CYAN}systemctl --user status honeypot-monitor${NC}"
echo ""
echo -e "${YELLOW}To view dashboard in browser:${NC}"
echo "  xdg-open ~/beryl-bunker/traps-dashboard/index.html"
echo ""
