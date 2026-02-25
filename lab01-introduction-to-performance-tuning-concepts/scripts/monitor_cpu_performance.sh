#!/bin/bash
LOG_FILE="/var/log/cpu_performance.log"
INTERVAL=5

echo "=== CPU PERFORMANCE MONITORING ==="
echo "Logging to: $LOG_FILE"
echo "Monitoring interval: $INTERVAL seconds"
echo "Press Ctrl+C to stop monitoring"

# Create log file with headers
echo "Timestamp,CPU_Usage,Load_1min,Load_5min,Load_15min,Context_Switches,Interrupts" | sudo tee "$LOG_FILE" >/dev/null

while true; do
  TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

  # Get CPU usage (100 - idle percentage)
  CPU_USAGE=$(sar -u 1 1 | tail -1 | awk '{print 100-$8}')

  # Get load averages
  LOAD_AVERAGES=$(uptime | awk -F'load average:' '{print $2}' | tr -d ' ')
  LOAD_1MIN=$(echo $LOAD_AVERAGES | cut -d',' -f1)
  LOAD_5MIN=$(echo $LOAD_AVERAGES | cut -d',' -f2)
  LOAD_15MIN=$(echo $LOAD_AVERAGES | cut -d',' -f3)

  # Get context switches and interrupts
  CONTEXT_SWITCHES=$(sar -w 1 1 | tail -1 | awk '{print $2}')
  INTERRUPTS=$(sar -I SUM 1 1 | tail -1 | awk '{print $3}')

  # Log the data
  echo "$TIMESTAMP,$CPU_USAGE,$LOAD_1MIN,$LOAD_5MIN,$LOAD_15MIN,$CONTEXT_SWITCHES,$INTERRUPTS" | sudo tee -a "$LOG_FILE" >/dev/null

  # Display current status
  echo "[$TIMESTAMP] CPU: ${CPU_USAGE}% | Load: $LOAD_1MIN,$LOAD_5MIN,$LOAD_15MIN"

  sleep $INTERVAL
done
