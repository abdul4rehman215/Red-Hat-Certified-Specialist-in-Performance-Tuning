#!/bin/bash
REPORT_FILE="reports/cpu-analysis-$(date +%Y%m%d_%H%M%S).txt"
echo "=== CPU Performance Analysis Report ===" > $REPORT_FILE
echo "Generated on: $(date)" >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "1. Current CPU Information:" >> $REPORT_FILE
lscpu >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "2. Current Load Average:" >> $REPORT_FILE
uptime >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "3. CPU Utilization Summary (last 24 hours):" >> $REPORT_FILE
sar -u | tail -20 >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "4. Top CPU Consuming Processes:" >> $REPORT_FILE
cat cpu-data/top-cpu-processes.txt >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "5. CPU Performance Recommendations:" >> $REPORT_FILE
LOAD_AVG=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
CPU_CORES=$(nproc)

if (( $(echo "$LOAD_AVG > $CPU_CORES" | bc -l) )); then
 echo "- HIGH LOAD DETECTED: Load average ($LOAD_AVG) exceeds CPU cores ($CPU_CORES)" >> $REPORT_FILE
 echo "- Consider process optimization or hardware upgrade" >> $REPORT_FILE
else
 echo "- CPU load is within acceptable range" >> $REPORT_FILE
fi

echo "CPU analysis completed. Report saved to: $REPORT_FILE"
