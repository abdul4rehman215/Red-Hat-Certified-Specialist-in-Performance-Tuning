#!/bin/bash
LOAD_THRESHOLD=2.0
MEMORY_THRESHOLD=80
CURRENT_LOAD=$(uptime | awk -F'load average:' '{print $2}' | awk -F',' '{print $1}' | tr -d ' ')
MEMORY_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
if (( $(echo "$CURRENT_LOAD > $LOAD_THRESHOLD" | bc -l) )); then
 echo "ALERT: High system load: $CURRENT_LOAD"
fi
if (( $(echo "$MEMORY_USAGE > $MEMORY_THRESHOLD" | bc -l) )); then
 echo "ALERT: High memory usage: $MEMORY_USAGE%"
fi
