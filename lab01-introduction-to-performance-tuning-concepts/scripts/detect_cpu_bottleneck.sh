#!/bin/bash
echo "=== CPU BOTTLENECK DETECTION ==="
# Get number of CPU cores
CPU_CORES=$(nproc)
echo "System has $CPU_CORES CPU cores"

# Get current load average
LOAD_1MIN=$(uptime | awk -F'load average:' '{print $2}' | awk -F',' '{print $1}' | tr -d ' ')
LOAD_5MIN=$(uptime | awk -F'load average:' '{print $2}' | awk -F',' '{print $2}' | tr -d ' ')
echo "Current load average: 1min=$LOAD_1MIN, 5min=$LOAD_5MIN"

# Check if load exceeds CPU cores
if (( $(echo "$LOAD_1MIN > $CPU_CORES" | bc -l) )); then
  echo "WARNING: CPU bottleneck detected! Load ($LOAD_1MIN) exceeds CPU cores ($CPU_CORES)"
else
  echo "CPU load is within normal range"
fi

# Show top CPU consuming processes
echo ""
echo "Top 5 CPU consuming processes:"
ps aux --sort=-%cpu | head -6
