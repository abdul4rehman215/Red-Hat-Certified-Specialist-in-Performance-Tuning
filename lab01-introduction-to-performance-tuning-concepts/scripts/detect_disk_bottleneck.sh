#!/bin/bash
echo "=== DISK I/O BOTTLENECK DETECTION ==="

# Check disk space usage
echo "Disk Space Usage:"
df -h | grep -E "^/dev"
echo ""
echo "Disk I/O Statistics (5-second average):"
iostat -x 1 5 | tail -n +4

# Check for high I/O wait
IOWAIT=$(sar -u 1 1 | tail -1 | awk '{print $5}' | cut -d'.' -f1)
echo ""
echo "Current I/O Wait: ${IOWAIT}%"

if [ $IOWAIT -gt 20 ]; then
  echo "WARNING: High I/O wait detected! This may indicate disk bottleneck"
elif [ $IOWAIT -gt 10 ]; then
  echo "CAUTION: Moderate I/O wait detected"
else
  echo "I/O wait is within normal range"
fi

# Show processes causing high I/O
echo ""
echo "Top I/O intensive processes:"
iotop -b -n 1 | head -10
