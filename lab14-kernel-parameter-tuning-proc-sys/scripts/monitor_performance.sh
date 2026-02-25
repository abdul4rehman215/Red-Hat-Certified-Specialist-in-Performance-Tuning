#!/bin/bash
DURATION=${1:-60}
INTERVAL=${2:-5}

echo "=== System Performance Monitor ==="
echo "Monitoring for $DURATION seconds with $INTERVAL second intervals"
echo "Current kernel parameters:"
echo "vm.swappiness: $(cat /proc/sys/vm/swappiness)"
echo "vm.dirty_ratio: $(cat /proc/sys/vm/dirty_ratio)"
echo "TCP rmem: $(cat /proc/sys/net/ipv4/tcp_rmem)"
echo ""

# Create log file
LOG_FILE="/tmp/performance_$(date +%Y%m%d_%H%M%S).log"
echo "Logging to: $LOG_FILE"

# Monitor system performance
for ((i=0; i<$DURATION; i+=$INTERVAL)); do
  echo "=== Time: $(date) ===" >> $LOG_FILE

  # Memory usage
  echo "Memory Usage:" >> $LOG_FILE
  free -h >> $LOG_FILE

  # CPU usage
  echo "CPU Usage:" >> $LOG_FILE
  top -bn1 | grep "Cpu(s)" >> $LOG_FILE

  # I/O statistics
  echo "I/O Statistics:" >> $LOG_FILE
  iostat -x 1 1 >> $LOG_FILE 2>/dev/null || echo "iostat not available" >> $LOG_FILE

  # Network statistics
  echo "Network Statistics:" >> $LOG_FILE
  cat /proc/net/dev | head -3 >> $LOG_FILE

  echo "" >> $LOG_FILE

  # Display progress
  echo "Monitoring... $((i+$INTERVAL))/$DURATION seconds"
  sleep $INTERVAL
done

echo "Monitoring complete. Log saved to: $LOG_FILE"
echo "Last 20 lines of log:"
tail -20 $LOG_FILE
