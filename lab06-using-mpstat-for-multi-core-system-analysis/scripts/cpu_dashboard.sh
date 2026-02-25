#!/bin/bash

# Function to display CPU dashboard
display_dashboard() {
 while true; do
  clear
  echo "=========================================="
  echo " Multi-Core CPU Performance Dashboard"
  echo "=========================================="
  echo "Time: $(date)"
  echo ""

  # System overview
  echo "=== System Overview ==="
  echo "Hostname: $(hostname)"
  echo "Uptime: $(uptime | awk -F'up ' '{print $2}' | awk -F',' '{print $1}')"
  echo "Load Average: $(uptime | awk -F'load average:' '{print $2}')"
  echo ""

  # CPU utilization
  echo "=== CPU Utilization (Last 5 seconds) ==="
  mpstat -P ALL 1 5 | grep "Average" | while read line; do
   if echo "$line" | grep -q "CPU"; then
    echo "$line" | awk '{printf "%-8s %6s %6s %6s %6s %6s\n", $3, $4"%", $6"%", $7"%", $11"%", $12"%"}'
   else
    echo "$line" | awk '{printf "%-8s %6.1f %6.1f %6.1f %6.1f %6.1f\n", "CPU"$3, $4, $6, $7, $11, $12}'
   fi
  done
  echo ""

  # Top processes
  echo "=== Top CPU Consuming Processes ==="
  ps aux --sort=-%cpu | head -6 | awk 'NR==1 {print $0} NR>1 {printf "%-10s %5s %5s %s\n", $1, $3"%", $4"%", $11}'
  echo ""

  echo "Press Ctrl+C to exit..."
  sleep 5
 done
}

# Check if running in interactive mode
if [ -t 0 ]; then
 display_dashboard
else
 echo "This script requires interactive terminal. Run directly: ./cpu_dashboard.sh"
fi
