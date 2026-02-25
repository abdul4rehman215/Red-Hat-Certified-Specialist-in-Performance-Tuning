#!/bin/bash
echo "=== Setting up Automated CPU Monitoring ==="

# Create monitoring directory
MONITOR_DIR="$HOME/cpu_monitoring"
mkdir -p "$MONITOR_DIR"
cd "$MONITOR_DIR"

# Create continuous monitoring script
cat > continuous_monitor.sh << 'MONITOR_EOF'
#!/bin/bash
LOG_DIR="$HOME/cpu_monitoring/logs"
mkdir -p "$LOG_DIR"
DATE_STR=$(date +%Y%m%d)
LOG_FILE="$LOG_DIR/cpu_monitor_$DATE_STR.log"

# Function to log with timestamp
log_with_timestamp() {
 echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Function to check CPU thresholds
check_cpu_thresholds() {
 # Get current CPU utilization
 CPU_UTIL=$(mpstat 1 3 | grep "Average" | grep -v "CPU" | awk '{print $4+$6}')

 for util in $CPU_UTIL; do
  if (( $(echo "$util > 80" | bc -l) )); then
   log_with_timestamp "HIGH CPU ALERT: CPU utilization at ${util}%"

   # Log top processes
   echo "[$(date '+%Y-%m-%d %H:%M:%S')] Top CPU processes:" >> "$LOG_FILE"
   ps aux --sort=-%cpu | head -5 >> "$LOG_FILE"
  fi
 done
}

# Main monitoring loop
log_with_timestamp "CPU monitoring started"
while true; do
 # Log current CPU stats
 echo "[$(date '+%Y-%m-%d %H:%M:%S')] CPU Statistics:" >> "$LOG_FILE"
 mpstat -P ALL 1 1 | grep -E "(Average|CPU)" >> "$LOG_FILE"
 echo "" >> "$LOG_FILE"

 # Check thresholds
 check_cpu_thresholds

 # Sleep for 5 minutes
 sleep 300
done
MONITOR_EOF
chmod +x continuous_monitor.sh

# Create log rotation script
cat > rotate_logs.sh << 'ROTATE_EOF'
#!/bin/bash
LOG_DIR="$HOME/cpu_monitoring/logs"
ARCHIVE_DIR="$HOME/cpu_monitoring/archive"
mkdir -p "$ARCHIVE_DIR"

# Compress logs older than 7 days
find "$LOG_DIR" -name "cpu_monitor_*.log" -mtime +7 -exec gzip {} \;

# Move compressed logs to archive
find "$LOG_DIR" -name "cpu_monitor_*.log.gz" -exec mv {} "$ARCHIVE_DIR/" \;

# Remove archives older than 30 days
find "$ARCHIVE_DIR" -name "cpu_monitor_*.log.gz" -mtime +30 -delete

echo "Log rotation completed: $(date)"
ROTATE_EOF
chmod +x rotate_logs.sh

# Create systemd service file (optional)
cat > cpu-monitor.service << 'SERVICE_EOF'
[Unit]
Description=CPU Performance Monitor
After=network.target

[Service]
Type=simple
User=toor
WorkingDirectory=/home/toor/cpu_monitoring
ExecStart=/home/toor/cpu_monitoring/continuous_monitor.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
SERVICE_EOF

echo "Monitoring setup completed!"
echo ""
echo "Files created in $MONITOR_DIR:"
ls -la "$MONITOR_DIR"
echo ""
echo "To start monitoring:"
echo "1. Manual: ./continuous_monitor.sh &"
echo "2. Background: nohup ./continuous_monitor.sh > /dev/null 2>&1 &"
echo ""
echo "To set up log rotation (run weekly):"
echo " ./rotate_logs.sh"
echo ""
echo "Logs will be stored in: $MONITOR_DIR/logs/"
