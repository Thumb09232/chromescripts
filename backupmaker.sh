#!/bin/bash

echo "=== Chromebook Firmware Backup (Auto-Install + Retry) ==="

TMP_FILE="/tmp/bios.bin"

# ----------------------------
# Step 1: Ensure flashrom exists
# ----------------------------
echo "[1/5] Checking for flashrom..."

if ! command -v flashrom &> /dev/null; then
    echo "[!] flashrom not found. Attempting install..."

    # Try common ChromeOS/Linux package methods
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y flashrom

    elif command -v dnf &> /dev/null; then
        sudo dnf install -y flashrom

    elif command -v yum &> /dev/null; then
        sudo yum install -y flashrom

    else
        echo "[!] No supported package manager found."
        echo "    Please install flashrom manually."
        exit 1
    fi
fi

# Re-check after install attempt
if ! command -v flashrom &> /dev/null; then
    echo "Error: flashrom still not available."
    exit 1
fi

echo "[✓] flashrom is available"

# ----------------------------
# Step 2: Try primary dump method
# ----------------------------
echo "[2/5] Attempting firmware read (host interface)..."

flashrom -p host -r "$TMP_FILE"
STATUS=$?

# ----------------------------
# Step 3: Fallback if failed
# ----------------------------
if [ $STATUS -ne 0 ]; then
    echo "[!] Host method failed, trying internal interface..."

    flashrom -p internal -r "$TMP_FILE"
    STATUS=$?
fi

# ----------------------------
# Step 4: Final check
# ----------------------------
if [ $STATUS -ne 0 ]; then
    echo "Error: Both flashrom methods failed."
    exit 1
fi

echo "[✓] Firmware dump completed: $TMP_FILE"

# ----------------------------
# Step 5: Save to USB or fallback
# ----------------------------
USB_PATH=$(ls /media/removable 2>/dev/null | head -n 1)

if [ -n "$USB_PATH" ]; then
    DEST="/media/removable/$USB_PATH/backup.bin"
    echo "[3/5] USB detected: $USB_PATH"
else
    DEST="$HOME/Downloads/backup.bin"
    echo "[3/5] No USB detected — using Downloads"
fi

cp "$TMP_FILE" "$DEST"

if [ $? -eq 0 ]; then
    echo "[✓] Backup saved to: $DEST"
else
    echo "Error copying backup."
    exit 1
fi

echo "=== Backup Complete ==="
