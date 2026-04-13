#!/bin/bash

echo "=== Chromebook Firmware Backup (Read‑Only) ==="

# Step 1: Dump firmware to /tmp
echo "[1/3] Reading firmware (this is safe, WP does not block reads)..."
sudo flashrom -p host -r /tmp/bios.bin
if [ $? -ne 0 ]; then
    echo "Error: flashrom could not read the firmware."
    exit 1
fi
echo "Firmware saved to /tmp/bios.bin"

# Step 2: Try to find USB mount point
USB_PATH=$(ls /media/removable 2>/dev/null | head -n 1)

if [ -n "$USB_PATH" ]; then
    FULL_USB_PATH="/media/removable/$USB_PATH"
    echo "[2/3] USB detected at: $FULL_USB_PATH"
    DEST="$FULL_USB_PATH/backup.bin"
else
    echo "[2/3] No USB detected — saving backup to Downloads instead."
    DEST="$HOME/Downloads/backup.bin"
fi

# Step 3: Copy backup to destination
echo "[3/3] Copying backup to: $DEST"
cp /tmp/bios.bin "$DEST"

if [ $? -eq 0 ]; then
    echo "Backup successfully saved to:"
    echo "$DEST"
else
    echo "Error copying backup."
    exit 1
fi

echo "=== Backup Complete ==="
