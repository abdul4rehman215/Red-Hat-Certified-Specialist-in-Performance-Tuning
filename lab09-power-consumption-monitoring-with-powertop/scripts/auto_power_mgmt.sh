#!/bin/bash
LOG_FILE="/var/log/auto-power-mgmt.log"

log_message() {
 echo "$(date): $1" | sudo tee -a "$LOG_FILE"
}

get_battery_level() {
 if [ -f /sys/class/power_supply/BAT0/capacity ]; then
  cat /sys/class/power_supply/BAT0/capacity
 else
  echo "100" # Assume full if no battery
 fi
}

get_power_status() {
 if [ -f /sys/class/power_supply/ADP1/online ]; then
  cat /sys/class/power_supply/ADP1/online
 elif [ -f /sys/class/power_supply/AC/online ]; then
  cat /sys/class/power_supply/AC/online
 else
  echo "1" # Assume AC power if unknown
 fi
}

apply_power_policy() {
 local battery_level="$1"
 local on_ac="$2"

 if [ "$on_ac" = "1" ]; then
  # On AC power - use performance profile
  log_message "On AC power - applying performance profile"
  /usr/local/bin/power_profiles.sh performance
 elif [ "$battery_level" -gt 50 ]; then
  # High battery - use balanced profile
  log_message "Battery level $battery_level% - applying balanced profile"
  /usr/local/bin/power_profiles.sh balanced
 elif [ "$battery_level" -gt 20 ]; then
  # Medium battery - use power save profile
  log_message "Battery level $battery_level% - applying power save profile"
  /usr/local/bin/power_profiles.sh powersave
 else
  # Low battery - aggressive power saving
  log_message "Low battery $battery_level% - applying aggressive power saving"
  /usr/local/bin/power_profiles.sh powersave

  # Additional aggressive measures
  echo 1 | sudo tee /sys/devices/system/cpu/cpu*/online >/dev/null 2>&1
  echo 30 | sudo tee /sys/devices/system/cpu/intel_pstate/max_perf_pct >/dev/null 2>&1
 fi
}

# Main monitoring loop
while true; do
 battery_level=$(get_battery_level)
 on_ac=$(get_power_status)

 apply_power_policy "$battery_level" "$on_ac"

 # Check every 60 seconds
 sleep 60
done
