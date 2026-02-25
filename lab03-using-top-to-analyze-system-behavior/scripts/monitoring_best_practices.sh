#!/bin/bash
echo "System Performance Best Practices"
echo "================================="
# 1. Regular monitoring
echo "1. Setting up regular monitoring..."
cat > /tmp/system_check.sh << 'INNER_EOF'
#!/bin/bash
LOG_FILE="/var/log/system_performance.log"
echo "$(date): Load: $(uptime | awk -F'load average:' '{print $2}')" >> $LOG_FILE
echo "$(date): Memory: $(free | grep Mem | awk '{print $3/$2 * 100.0}')" >> $LOG_FILE
INNER_EOF
# 2. Process priority guidelines
echo "2. Process Priority Guidelines:"
echo " - Interactive applications: nice 0 to -5"
echo " - Background tasks: nice 10 to 19"
echo " - System critical: nice -10 to -20 (root only)"
echo ""
# 3. Resource thresholds
echo "3. Resource Alert Thresholds:"
echo " - CPU Load > Number of cores: Investigation needed"
echo " - Memory usage > 80%: Monitor closely"
echo " - Memory usage > 90%: Take action"
echo ""
# 4. Automated alerts
echo "4. Setting up automated monitoring..."
cat > /tmp/resource_alert.sh << 'INNER_EOF'
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
INNER_EOF
chmod +x /tmp/system_check.sh
chmod +x /tmp/resource_alert.sh
echo "Best practices scripts created in /tmp/"
echo "Consider adding system_check.sh to crontab for regular monitoring"
EOF
