#!/bin/bash
# Function to get battery info
get_battery_info() {
 if [ -f /sys/class/power_supply/BAT0/capacity ]; then
  capacity=$(cat /sys/class/power_supply/BAT0/capacity)
  status=$(cat /sys/class/power_supply/BAT0/status)
  echo "Battery: ${capacity}% (${status})"
 else
  echo "Battery: Not available (AC Power)"
 fi
}

# Function to get CPU frequency
get_cpu_freq() {
 freq=$(cat /proc/cpuinfo | grep "cpu MHz" | head -1 | awk '{print $4}')
 echo "CPU Frequency: ${freq} MHz"
}

# Function to get power consumption estimate
get_power_estimate() {
 if command -v powertop >/dev/null 2>&1; then
  power=$(timeout 10 sudo powertop --csv=/tmp/power_temp.csv --time=5 2>/dev/null && \
   grep "The battery reports" /tmp/power_temp.csv 2>/dev/null | \
   tail -1 | cut -d',' -f2 | tr -d ' ')
  rm -f /tmp/power_temp.csv
  echo "Power Consumption: ${power:-"Calculating..."}"
 else
  echo "Power Consumption: powertop not available"
 fi
}

# Main dashboard loop
while true; do
 clear
 echo "======================================"
 echo " POWER CONSUMPTION DASHBOARD"
 echo "======================================"
 echo "Time: $(date)"
 echo
 get_battery_info
 get_cpu_freq
 get_power_estimate
 echo
 echo "Top 5 CPU consumers:"
 ps aux --sort=-%cpu | head -6 | tail -5 | awk '{printf "%-20s %s%%\n", $11, $3}'
 echo
 echo "Press Ctrl+C to exit"
 echo "======================================"
 sleep 5
done
