#!/bin/bash
# SEAGATE PERMISSION FIXER - Quick version

echo "Finding Seagate..."
df -h

echo ""
read -p "What's your Seagate mount point? (e.g., /media/beryleden1/Seagate): " SEAGATE

if [ ! -d "$SEAGATE" ]; then
    echo "ERROR: $SEAGATE not found!"
    exit 1
fi

echo ""
echo "Current permissions:"
ls -la "$SEAGATE" | head -5

echo ""
echo "FIXING PERMISSIONS..."
sudo chown -R $USER:$USER "$SEAGATE"
sudo chmod -R 777 "$SEAGATE"

echo ""
echo "Testing write..."
echo "test" > "$SEAGATE/test.txt" 2>/dev/null

if [ -f "$SEAGATE/test.txt" ]; then
    echo "✓✓✓ SUCCESS! You can write to Seagate!"
    rm "$SEAGATE/test.txt"
else
    echo "✗ Still can't write. Try remounting:"
    echo ""
    echo "  sudo umount $SEAGATE"
    echo "  sudo mount -o uid=$(id -u),gid=$(id -g) /dev/sda1 $SEAGATE"
fi

echo ""
echo "Done! Now try saving your file."

