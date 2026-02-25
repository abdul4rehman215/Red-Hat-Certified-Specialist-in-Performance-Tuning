#!/bin/bash
# CPU monitoring script
LOG_FILE="cpu_usage_log.txt"
DURATION=300 # 5 minutes
INTERVAL=5 # 5 seconds

echo "Starting CPU monitoring for $DURATION seconds..."
echo "Timestamp,CPU_Usage_Percent" > $LOG_FILE

for ((i=1; i<=DURATION/INTERVAL; i++)); do
 TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
 CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')
 echo "$TIMESTAMP,$CPU_USAGE" >> $LOG_FILE
 sleep $INTERVAL
done

echo "CPU monitoring completed. Check $LOG_FILE for results."
