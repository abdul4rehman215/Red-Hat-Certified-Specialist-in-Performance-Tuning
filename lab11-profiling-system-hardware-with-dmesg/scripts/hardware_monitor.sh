#!/bin/bash
# Configuration
LOG_FILE="/var/log/hardware_monitor.log"
EMAIL_ALERT="admin@company.com" # Change to your email
CHECK_INTERVAL=300 # 5 minutes

# Function to log messages
log_message() {
 echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to check for critical issues
check_critical_issues() {
 local issues_found=0

 # Check for hardware errors
 if dmesg --since="5 minutes ago" | grep -qi "hardware error\|hardware failure"; then
  log_message "CRITICAL: Hardware error detected"
  issues_found=1
 fi

 # Check for I/O errors
 if dmesg --since="5 minutes ago" | grep -qi "i/o error\|input/output error"; then
  log_message "CRITICAL: I/O error detected"
  issues_found=1
 fi

 # Check for memory errors
 if dmesg --since="5 minutes ago" | grep -qi "memory error\|bad page"; then
  log_message "CRITICAL: Memory error detected"
  issues_found=1
 fi

 # Check for thermal issues
 if dmesg --since="5 minutes ago" | grep -qi "thermal.*critical\|overheat"; then
  log_message "CRITICAL: Thermal issue detected"
  issues_found=1
 fi

 # Return SUCCESS if issues found (0), else return 1
 if [ $issues_found -eq 1 ]; then
   return 0
 else
   return 1
 fi
}

# Function to generate summary report
generate_summary() {
 log_message "=== Hardware Status Summary ==="
 log_message "System uptime: $(uptime -p)"
 log_message "Load average: $(uptime | awk -F'load average:' '{print $2}')"

 local error_count=$(dmesg --since="1 hour ago" -l err | wc -l)
 log_message "Errors in last hour: $error_count"

 local warn_count=$(dmesg --since="1 hour ago" -l warn | wc -l)
 log_message "Warnings in last hour: $warn_count"
}

# Main monitoring function
main_monitor() {
 log_message "Starting hardware monitoring..."

 while true; do
  if check_critical_issues; then
   log_message "Critical issues found - generating detailed report"
   dmesg --since="5 minutes ago" -l err,crit,alert >> "$LOG_FILE"
  fi

  # Generate hourly summary
  if [ $(($(date +%M) % 60)) -eq 0 ]; then
   generate_summary
  fi

  sleep $CHECK_INTERVAL
 done
}

# Check if running as daemon or one-time check
if [ "$1" = "daemon" ]; then
 main_monitor
else
 log_message "Performing one-time hardware check..."
 check_critical_issues
 generate_summary
fi
