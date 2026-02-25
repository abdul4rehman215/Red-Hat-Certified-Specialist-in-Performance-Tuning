#!/bin/bash
echo "=== SOSREPORT PERFORMANCE ANALYSIS ==="
echo "Analysis Date: $(date)"
echo "========================================="

# CPU Analysis
echo -e "\n1. CPU ANALYSIS:"
if [ -f proc/cpuinfo ]; then
 CPU_COUNT=$(grep -c processor proc/cpuinfo)
 echo " - CPU Cores: $CPU_COUNT"
fi

if [ -f proc/loadavg ]; then
 LOAD_1MIN=$(awk '{print $1}' proc/loadavg)
 LOAD_5MIN=$(awk '{print $2}' proc/loadavg)
 LOAD_15MIN=$(awk '{print $3}' proc/loadavg)
 echo " - Load Average: $LOAD_1MIN (1min), $LOAD_5MIN (5min), $LOAD_15MIN (15min)"

 # Load analysis
 if (( $(echo "$LOAD_1MIN > $CPU_COUNT" | bc -l 2>/dev/null || echo 0) )); then
  echo " - WARNING: High CPU load detected!"
 fi
fi

# Memory Analysis
echo -e "\n2. MEMORY ANALYSIS:"
if [ -f proc/meminfo ]; then
 TOTAL_MEM=$(grep MemTotal proc/meminfo | awk '{print $2}')
 FREE_MEM=$(grep MemFree proc/meminfo | awk '{print $2}')
 AVAILABLE_MEM=$(grep MemAvailable proc/meminfo | awk '{print $2}')

 echo " - Total Memory: $((TOTAL_MEM/1024)) MB"
 echo " - Free Memory: $((FREE_MEM/1024)) MB"
 echo " - Available Memory: $((AVAILABLE_MEM/1024)) MB"

 # Memory usage percentage
 USED_PERCENT=$(echo "scale=2; (($TOTAL_MEM - $AVAILABLE_MEM) * 100) / $TOTAL_MEM" | bc 2>/dev/null || echo "0")
 echo " - Memory Usage: ${USED_PERCENT}%"

 if (( $(echo "$USED_PERCENT > 90" | bc -l 2>/dev/null || echo 0) )); then
  echo " - WARNING: High memory usage detected!"
 fi
fi

# Disk Analysis
echo -e "\n3. DISK ANALYSIS:"
if [ -f df ]; then
 echo " - Filesystem usage:"
 while read line; do
  if echo "$line" | grep -q "%"; then
   USAGE=$(echo "$line" | awk '{print $5}' | sed 's/%//')
   FILESYSTEM=$(echo "$line" | awk '{print $6}')
   echo " $FILESYSTEM: ${USAGE}%"
   if [ "$USAGE" -gt 90 ] 2>/dev/null; then
    echo " WARNING: High disk usage on $FILESYSTEM!"
   fi
  fi
 done < df
fi

# Network Analysis
echo -e "\n4. NETWORK ANALYSIS:"
if [ -f proc/net/dev ]; then
 echo " - Network interface statistics available"
 echo " - Check for high error rates or dropped packets"
fi

echo -e "\n5. RECOMMENDATIONS:"
echo " - Monitor systems with high CPU load or memory usage"
echo " - Investigate filesystems with >90% usage"
echo " - Review system logs for recurring errors"
echo " - Consider performance tuning for bottlenecked resources"
