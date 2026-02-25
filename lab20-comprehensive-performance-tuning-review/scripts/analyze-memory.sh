#!/bin/bash
REPORT_FILE="reports/memory-analysis-$(date +%Y%m%d_%H%M%S).txt"
echo "=== Memory Performance Analysis Report ===" > $REPORT_FILE
echo "Generated on: $(date)" >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "1. Current Memory Usage:" >> $REPORT_FILE
free -h >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "2. Memory Utilization Trend:" >> $REPORT_FILE
sar -r | tail -10 >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "3. Swap Usage:" >> $REPORT_FILE
swapon --show >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "4. Top Memory Consuming Processes:" >> $REPORT_FILE
cat memory-data/top-memory-processes.txt >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "5. Memory Performance Analysis:" >> $REPORT_FILE
TOTAL_MEM=$(free | grep Mem | awk '{print $2}')
USED_MEM=$(free | grep Mem | awk '{print $3}')
MEM_USAGE_PERCENT=$(echo "scale=2; $USED_MEM * 100 / $TOTAL_MEM" | bc)
echo "Memory Usage: ${MEM_USAGE_PERCENT}%" >> $REPORT_FILE

if (( $(echo "$MEM_USAGE_PERCENT > 90" | bc -l) )); then
 echo "- CRITICAL: Very high memory usage (${MEM_USAGE_PERCENT}%)" >> $REPORT_FILE
 echo "- Immediate action required" >> $REPORT_FILE
elif (( $(echo "$MEM_USAGE_PERCENT > 80" | bc -l) )); then
 echo "- WARNING: High memory usage detected (${MEM_USAGE_PERCENT}%)" >> $REPORT_FILE
 echo "- Consider memory optimization or upgrade" >> $REPORT_FILE
else
 echo "- Memory usage is within acceptable range" >> $REPORT_FILE
fi

echo "Memory analysis completed. Report saved to: $REPORT_FILE"
