#!/bin/bash
# Advanced system monitoring script
LOG_DIR="monitoring_logs"
mkdir -p $LOG_DIR

# Configuration
MONITOR_DURATION=60 # demo run (original lab target: 3600)
SAMPLE_INTERVAL=10 # 10 seconds
ALERT_CPU_THRESHOLD=80
ALERT_MEM_THRESHOLD=85

# Initialize log files
CPU_LOG="$LOG_DIR/cpu_$(date +%Y%m%d_%H%M%S).log"
MEM_LOG="$LOG_DIR/memory_$(date +%Y%m%d_%H%M%S).log"
PROC_LOG="$LOG_DIR/processes_$(date +%Y%m%d_%H%M%S).log"
ALERT_LOG="$LOG_DIR/alerts_$(date +%Y%m%d_%H%M%S).log"

# Function to log CPU metrics
log_cpu_metrics() {
 local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
 local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')
 local load_avg=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')

 echo "$timestamp,$cpu_usage,$load_avg" >> $CPU_LOG

 # Check for CPU alerts
 if (( $(echo "$cpu_usage > $ALERT_CPU_THRESHOLD" | bc -l) )); then
  echo "$timestamp,CPU,High CPU usage: $cpu_usage%" >> $ALERT_LOG
 fi
}

# Function to log memory metrics
log_memory_metrics() {
 local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
 local mem_info=$(free | awk 'NR==2{printf "%d,%d,%d,%.1f", $2/1024, $3/1024, $4/1024, $3*100/$2}')

 echo "$timestamp,$mem_info" >> $MEM_LOG

 # Check for memory alerts
 local mem_percent=$(echo $mem_info | cut -d',' -f4)
 if (( $(echo "$mem_percent > $ALERT_MEM_THRESHOLD" | bc -l) )); then
  echo "$timestamp,MEMORY,High memory usage: $mem_percent%" >> $ALERT_LOG
 fi
}

# Function to log top processes
log_top_processes() {
 local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
 echo "=== $timestamp ===" >> $PROC_LOG
 ps aux --sort=-%cpu | head -6 >> $PROC_LOG
 echo "" >> $PROC_LOG
}

# Main monitoring loop
echo "Starting advanced monitoring..."
echo "Duration: $MONITOR_DURATION seconds"
echo "Interval: $SAMPLE_INTERVAL seconds"
echo "Logs will be saved in: $LOG_DIR"

# Create log headers
echo "Timestamp,CPU_Usage_Percent,Load_Average" > $CPU_LOG
echo "Timestamp,Total_MB,Used_MB,Free_MB,Usage_Percent" > $MEM_LOG
echo "Advanced Process Monitoring Log" > $PROC_LOG

for ((i=1; i<=MONITOR_DURATION/SAMPLE_INTERVAL; i++)); do
 log_cpu_metrics
 log_memory_metrics
 log_top_processes

 echo "Sample $i/$(($MONITOR_DURATION/$SAMPLE_INTERVAL)) completed"
 sleep $SAMPLE_INTERVAL
done

echo "Monitoring completed. Check logs in $LOG_DIR"
