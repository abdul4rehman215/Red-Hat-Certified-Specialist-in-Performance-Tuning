#!/bin/bash
LOG_FILE="/var/log/system_performance.log"
echo "$(date): Load: $(uptime | awk -F'load average:' '{print $2}')" >> $LOG_FILE
echo "$(date): Memory: $(free | grep Mem | awk '{print $3/$2 * 100.0}')" >> $LOG_FILE
