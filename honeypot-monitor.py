#!/usr/bin/env python3
"""
BERYL'S TRAPS - Honeypot Monitor
Monitors decoy files and logs access attempts to dashboard
"""

import os
import json
import time
import hashlib
import smtplib
import subprocess
from datetime import datetime
from pathlib import Path
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# Configuration
HOME = os.path.expanduser("~")
LOG_DIR = f"{HOME}/beryl-bunker/logs"
EVENTS_FILE = f"{LOG_DIR}/honeypot_events.json"
EMAIL = "aimasterandjoel@gmail.com"
CHECK_INTERVAL = 2  # seconds

# Honeypot files to monitor
HONEYPOTS = [
    f"{HOME}/beryl-bunker/honeypots/passwords.txt",
    f"{HOME}/beryl-bunker/honeypots/credentials.json",
    f"{HOME}/beryl-bunker/honeypots/wallet_backup.txt",
    f"{HOME}/Documents/.secret_backup.zip.txt",
    f"{HOME}/.ssh/id_rsa_backup.txt",
]

# Colors for terminal
RED = '\033[0;31m'
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
CYAN = '\033[0;36m'
NC = '\033[0m'

class HoneypotMonitor:
    def __init__(self):
        self.file_states = {}
        self.events = []
        self.load_events()
        self.initialize_states()

    def load_events(self):
        """Load existing events from JSON file"""
        try:
            if os.path.exists(EVENTS_FILE):
                with open(EVENTS_FILE, 'r') as f:
                    self.events = json.load(f)
        except:
            self.events = []

    def save_events(self):
        """Save events to JSON file"""
        os.makedirs(LOG_DIR, exist_ok=True)
        with open(EVENTS_FILE, 'w') as f:
            json.dump(self.events, f, indent=2)

    def get_file_state(self, filepath):
        """Get current state of a file (mtime, atime, hash)"""
        try:
            stat = os.stat(filepath)
            with open(filepath, 'rb') as f:
                content_hash = hashlib.md5(f.read()).hexdigest()
            return {
                'mtime': stat.st_mtime,
                'atime': stat.st_atime,
                'size': stat.st_size,
                'hash': content_hash
            }
        except:
            return None

    def initialize_states(self):
        """Initialize file states for all honeypots"""
        for hp in HONEYPOTS:
            if os.path.exists(hp):
                self.file_states[hp] = self.get_file_state(hp)

    def get_connection_info(self):
        """Get active network connections"""
        try:
            result = subprocess.run(
                ['ss', '-tnp'],
                capture_output=True,
                text=True
            )
            for line in result.stdout.split('\n'):
                if 'ESTAB' in line:
                    parts = line.split()
                    if len(parts) >= 5:
                        remote = parts[4].split(':')[0]
                        if not remote.startswith(('127.', '192.168.', '10.', '172.')):
                            return remote
        except:
            pass
        return "Local"

    def log_event(self, filepath, event_type, details=""):
        """Log a honeypot trigger event"""
        timestamp = datetime.now().isoformat()
        source_ip = self.get_connection_info()

        # Determine threat level
        threat = "high"
        if "password" in filepath.lower() or "credential" in filepath.lower():
            threat = "high"
        elif "wallet" in filepath.lower() or "ssh" in filepath.lower():
            threat = "high"
        else:
            threat = "medium"

        event = {
            "timestamp": timestamp,
            "type": event_type,
            "file": filepath,
            "device": "Lenovo Linux",
            "source_ip": source_ip,
            "process": details,
            "threat": threat,
            "blocked": False
        }

        self.events.append(event)
        self.save_events()

        # Print alert
        print(f"\n{RED}╔═══════════════════════════════════════════════════════════════════════╗{NC}")
        print(f"{RED}║                    HONEYPOT TRIGGERED!                                ║{NC}")
        print(f"{RED}╚═══════════════════════════════════════════════════════════════════════╝{NC}")
        print(f"{YELLOW}Time:{NC}    {timestamp}")
        print(f"{YELLOW}File:{NC}    {filepath}")
        print(f"{YELLOW}Event:{NC}   {event_type}")
        print(f"{YELLOW}Source:{NC}  {source_ip}")
        print(f"{YELLOW}Threat:{NC}  {RED}{threat}{NC}")
        print()

        # Try to send email
        self.send_alert_email(event)

        # Log to file
        with open(f"{LOG_DIR}/alerts.log", 'a') as f:
            f.write(f"[{timestamp}] {threat} ALERT: {filepath} - {event_type} from {source_ip}\n")

    def send_alert_email(self, event):
        """Send email notification"""
        try:
            # Try using mail command
            subject = f"[TRAPS ALERT] Honeypot Triggered - {event['threat']} threat"
            body = f"""HONEYPOT INTRUSION DETECTED

Time: {event['timestamp']}
Device: {event['device']}
File Accessed: {event['file']}
Event Type: {event['type']}
Source IP: {event['source_ip']}
Threat Level: {event['threat']}

Dashboard: file://{HOME}/beryl-bunker/traps-dashboard/index.html

This is an automated alert from Beryl's TRAPS system.
"""
            subprocess.run(
                ['mail', '-s', subject, EMAIL],
                input=body,
                text=True,
                capture_output=True
            )
            print(f"{GREEN}Email alert sent to {EMAIL}{NC}")
        except Exception as e:
            print(f"{YELLOW}Email not sent (configure mail client): {e}{NC}")

    def check_honeypots(self):
        """Check all honeypots for changes"""
        for hp in HONEYPOTS:
            if not os.path.exists(hp):
                continue

            current_state = self.get_file_state(hp)
            if current_state is None:
                continue

            old_state = self.file_states.get(hp)
            if old_state is None:
                self.file_states[hp] = current_state
                continue

            # Check for access (atime change)
            if current_state['atime'] != old_state['atime']:
                self.log_event(hp, "ACCESS", "File was read/accessed")

            # Check for modification (mtime or hash change)
            if current_state['mtime'] != old_state['mtime'] or current_state['hash'] != old_state['hash']:
                self.log_event(hp, "MODIFY", "File was modified")

            # Update state
            self.file_states[hp] = current_state

    def run(self):
        """Main monitoring loop"""
        print(f"{CYAN}")
        print("╔════════════════════════════════════════════════════════════════════════╗")
        print("║           BERYL'S TRAPS - HONEYPOT MONITOR ACTIVE                     ║")
        print("╚════════════════════════════════════════════════════════════════════════╝")
        print(f"{NC}")

        print(f"{GREEN}Monitoring honeypots:{NC}")
        for hp in HONEYPOTS:
            if os.path.exists(hp):
                print(f"  {GREEN}✓{NC} {hp}")
            else:
                print(f"  {RED}✗{NC} {hp} (not found)")

        print()
        print(f"{YELLOW}Dashboard:{NC} file://{HOME}/beryl-bunker/traps-dashboard/index.html")
        print(f"{YELLOW}Events:{NC}    {EVENTS_FILE}")
        print(f"{YELLOW}Email:{NC}     {EMAIL}")
        print()
        print(f"{CYAN}Press Ctrl+C to stop monitoring{NC}")
        print()

        try:
            while True:
                self.check_honeypots()
                time.sleep(CHECK_INTERVAL)
        except KeyboardInterrupt:
            print(f"\n{YELLOW}Monitor stopped{NC}")

if __name__ == "__main__":
    monitor = HoneypotMonitor()
    monitor.run()
