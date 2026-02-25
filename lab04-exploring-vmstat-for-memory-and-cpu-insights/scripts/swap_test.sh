#!/bin/bash
echo "Creating memory pressure to trigger swap..."
# Get total RAM in KB
TOTAL_RAM=$(grep MemTotal /proc/meminfo | awk '{print $2}')
# Calculate 80% of RAM
TARGET_SIZE=$((TOTAL_RAM * 80 / 100))
echo "Allocating ${TARGET_SIZE}KB of memory..."
# Use stress tool if available, otherwise use dd
if command -v stress >/dev/null 2>&1; then
 stress --vm 1 --vm-bytes ${TARGET_SIZE}k --timeout 60s
else
 # Alternative method using dd and temporary files
 for i in {1..8}; do
 dd if=/dev/zero of=/tmp/swaptest_$i bs=1M count=$((TARGET_SIZE/8/1024)) 2>/dev/null &
 done
 sleep 60
 killall dd 2>/dev/null
 rm -f /tmp/swaptest_*
fi
