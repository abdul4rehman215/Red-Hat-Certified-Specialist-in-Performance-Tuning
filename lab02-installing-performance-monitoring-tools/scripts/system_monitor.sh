#!/bin/bash
LOG_FILE="/tmp/system_monitor_$(date +%Y%m%d_%H%M%S).log"
echo "=== System Performance Monitor ===" | tee $LOG_FILE
echo "Timestamp: $(date)" | tee -a $LOG_FILE
echo "Hostname: $(hostname)" | tee -a $LOG_FILE
echo "" | tee -a $LOG_FILE
echo "=== CPU Information ===" | tee -a $LOG_FILE
sar -u 1 3 | tee -a $LOG_FILE
echo "" | tee -a $LOG_FILE
echo "=== Memory Usage ===" | tee -a $LOG_FILE
free -h | tee -a $LOG_FILE
echo "" | tee -a $LOG_FILE
echo "=== Disk I/O Statistics ===" | tee -a $LOG_FILE
iostat -x 1 3 | tee -a $LOG_FILE
echo "" | tee -a $LOG_FILE
echo "=== Top 10 Processes by CPU ===" | tee -a $LOG_FILE
ps aux --sort=-%cpu | head -11 | tee -a $LOG_FILE
echo "" | tee -a $LOG_FILE
echo "=== Top 10 Processes by Memory ===" | tee -a $LOG_FILE
ps aux --sort=-%mem | head -11 | tee -a $LOG_FILE
echo "" | tee -a $LOG_FILE
echo "=== Load Average ===" | tee -a $LOG_FILE
uptime | tee -a $LOG_FILE
echo "Report saved to: $LOG_FILE"
