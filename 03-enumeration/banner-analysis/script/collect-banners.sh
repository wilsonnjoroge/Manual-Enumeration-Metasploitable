#!/bin/bash

TARGET=$1

if [ -z "$TARGET" ]; then
    echo "Usage: $0 <target_ip>"
    exit 1
fi

read -p "Enter output directory path: " OUTDIR

# Use current directory if blank
if [ -z "$OUTDIR" ]; then
    OUTDIR="."
fi

# Remove trailing slash if present
OUTDIR="${OUTDIR%/}"

# Create directory if it doesn't exist
mkdir -p "$OUTDIR"

OUTPUT="$OUTDIR/banners-$(date +%Y%m%d).txt"

echo "Collecting banners from $TARGET" > "$OUTPUT"
echo "=================================" >> "$OUTPUT"

PORTS=$(nmap -sS "$TARGET" | grep "open" | awk -F/ '{print $1}')

for port in $PORTS; do
    echo -e "\n=== Port $port ===" >> "$OUTPUT"
    timeout 5 nc -nv "$TARGET" "$port" < /dev/null >> "$OUTPUT" 2>&1
done

echo
echo "================================="
echo "Banner collection complete."
echo "Results saved to:"
echo "  $OUTPUT"
echo "================================="
echo
