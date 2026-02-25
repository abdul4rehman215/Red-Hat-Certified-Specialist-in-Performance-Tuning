#!/bin/bash
echo "=== MEMORY BOTTLENECK DETECTION ==="

# Get memory information
TOTAL_MEM=$(free -m | awk 'NR==2{print $2}')
USED_MEM=$(free -m | awk 'NR==2{print $3}')
AVAILABLE_MEM=$(free -m | awk 'NR==2{print $7}')
SWAP_USED=$(free -m | awk 'NR==3{print $3}')

# Calculate memory usage percentage
MEM_USAGE_PERCENT=$((USED_MEM * 100 / TOTAL_MEM))

echo "Total Memory: ${TOTAL_MEM}MB"
echo "Used Memory: ${USED_MEM}MB (${MEM_USAGE_PERCENT}%)"
echo "Available Memory: ${AVAILABLE_MEM}MB"
echo "Swap Used: ${SWAP_USED}MB"

# Check for memory bottleneck
if [ $MEM_USAGE_PERCENT -gt 90 ]; then
  echo "CRITICAL: Memory bottleneck detected! Usage above 90%"
elif [ $MEM_USAGE_PERCENT -gt 80 ]; then
  echo "WARNING: High memory usage detected! Usage above 80%"
else
  echo "Memory usage is within normal range"
fi

# Check swap usage
if [ $SWAP_USED -gt 0 ]; then
  echo "WARNING: System is using swap memory ($SWAP_USED MB)"
fi

echo ""
echo "Top 5 memory consuming processes:"
ps aux --sort=-%mem | head -6
