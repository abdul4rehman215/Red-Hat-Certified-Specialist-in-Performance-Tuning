#!/bin/bash
REPORT_FILE="reports/disk-analysis-$(date +%Y%m%d_%H%M%S).txt"
echo "=== Disk I/O Performance Analysis Report ===" > $REPORT_FILE
echo "Generated on: $(date)" >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "1. Current Disk Usage:" >> $REPORT_FILE
df -h >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "2. Disk I/O Statistics:" >> $REPORT_FILE
iostat -x 1 3 >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "3. Recent Disk Activity:" >> $REPORT_FILE
sar -d | tail -10 >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "4. Disk Performance Analysis:" >> $REPORT_FILE
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
echo "Root filesystem usage: ${DISK_USAGE}%" >> $REPORT_FILE
if [ $DISK_USAGE -gt 90 ]; then
 echo "- CRITICAL: Disk usage is very high (${DISK_USAGE}%)" >> $REPORT_FILE
 echo "- Immediate cleanup required" >> $REPORT_FILE
elif [ $DISK_USAGE -gt 80 ]; then
 echo "- WARNING: Disk usage is high (${DISK_USAGE}%)" >> $REPORT_FILE
 echo "- Consider cleanup or expansion" >> $REPORT_FILE
else
 echo "- Disk usage is within acceptable range" >> $REPORT_FILE
fi
echo "" >> $REPORT_FILE

echo "5. I/O Wait Analysis:" >> $REPORT_FILE
IOWAIT=$(sar -u 1 3 | grep Average | awk '{print $6}')
echo "Average I/O Wait: ${IOWAIT}%" >> $REPORT_FILE

echo "Disk analysis completed. Report saved to: $REPORT_FILE"
