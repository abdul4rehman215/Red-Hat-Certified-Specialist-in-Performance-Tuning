#!/bin/bash
LOG_FILE="/var/log/disk_io_performance.log"
INTERVAL=5

echo "=== DISK I/O PERFORMANCE MONITORING ==="
echo "Logging to: $LOG_FILE"
echo "Monitoring interval: $INTERVAL seconds"
echo "Press Ctrl+C to stop monitoring"

# Create log file with headers
echo "Timestamp,Device,Read_KB/s,Write_KB/s,Read_IOPS,Write_IOPS,Util%" | sudo tee "$LOG_FILE" >/dev/null

while true; do
  TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

  # Get I/O statistics
  iostat -x 1 1 | grep -E "^sd|^nvme|^vd" | while read line; do
    DEVICE=$(echo $line | awk '{print $1}')
    READ_KBS=$(echo $line | awk '{print $6}')
    WRITE_KBS=$(echo $line | awk '{print $7}')
    READ_IOPS=$(echo $line | awk '{print $4}')
    WRITE_IOPS=$(echo $line | awk '{print $5}')
    UTIL=$(echo $line | awk '{print $10}')

    # Log the data
    echo "$TIMESTAMP,$DEVICE,$READ_KBS,$WRITE_KBS,$READ_IOPS,$WRITE_IOPS,$UTIL" | sudo tee -a "$LOG_FILE" >/dev/null

    # Display current status
    echo "[$TIMESTAMP] $DEVICE: R=${READ_KBS}KB/s W=${WRITE_KBS}KB/s Util=${UTIL}%"
  done

  sleep $INTERVAL
done
