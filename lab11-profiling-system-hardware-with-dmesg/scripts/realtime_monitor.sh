#!/bin/bash
echo "Starting real-time kernel message monitoring..."
echo "Filtering for hardware-related issues..."
echo "Press Ctrl+C to stop"
echo

# Monitor and filter messages
dmesg -w | while read line; do
 # Check if line contains hardware-related keywords
 if echo "$line" | grep -qi "error\|fail\|warn\|timeout\|hardware\|thermal\|i/o"; then
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[$timestamp] ALERT: $line"
 fi
done
