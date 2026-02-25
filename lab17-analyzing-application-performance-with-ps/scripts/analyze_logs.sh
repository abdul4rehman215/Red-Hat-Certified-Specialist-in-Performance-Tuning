#!/bin/bash
LOGFILE="process_resources.log"
if [ ! -f "$LOGFILE" ]; then
 echo "Log file $LOGFILE not found"
 exit 1
fi
echo "=== RESOURCE USAGE ANALYSIS ==="
echo
echo "=== HIGHEST CPU USAGE RECORDED ==="
tail -n +2 "$LOGFILE" | sort -t',' -k4 -nr | head -5
echo
echo "=== HIGHEST MEMORY USAGE RECORDED ==="
tail -n +2 "$LOGFILE" | sort -t',' -k5 -nr | head -5
echo
echo "=== MOST FREQUENT HIGH-RESOURCE PROCESSES ==="
tail -n +2 "$LOGFILE" | awk -F',' '$4>10 || $5>5 {print $8}' | sort | uniq -c | sort -nr
echo
echo "=== RESOURCE USAGE OVER TIME ==="
tail -n +2 "$LOGFILE" | awk -F',' '{
 time=$1; cpu+=$4; mem+=$5; count++
 if (count==5) {
  printf "%s: Avg CPU=%.1f%%, Avg MEM=%.1f%%\n", time, cpu/5, mem/5
  cpu=0; mem=0; count=0
 }
}'
