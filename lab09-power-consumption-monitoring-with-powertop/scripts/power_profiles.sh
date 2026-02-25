#!/bin/bash
PROFILE_DIR="/etc/power-profiles"
sudo mkdir -p "$PROFILE_DIR"

# Performance Profile
sudo tee "$PROFILE_DIR/performance.conf" << 'PERF_EOF'
# Performance Power Profile
CPU_GOVERNOR=performance
CPU_MAX_FREQ=100
LAPTOP_MODE=0
USB_AUTOSUSPEND=0
WIFI_POWER_SAVE=off
PERF_EOF

# Balanced Profile
sudo tee "$PROFILE_DIR/balanced.conf" << 'BAL_EOF'
# Balanced Power Profile
CPU_GOVERNOR=ondemand
CPU_MAX_FREQ=80
LAPTOP_MODE=1
USB_AUTOSUSPEND=1
WIFI_POWER_SAVE=on
BAL_EOF

# Power Save Profile
sudo tee "$PROFILE_DIR/powersave.conf" << 'SAVE_EOF'
# Power Save Profile
CPU_GOVERNOR=powersave
CPU_MAX_FREQ=50
LAPTOP_MODE=5
USB_AUTOSUSPEND=1
WIFI_POWER_SAVE=on
SAVE_EOF

# Profile switcher function
switch_profile() {
 local profile="$1"
 local config_file="$PROFILE_DIR/${profile}.conf"

 if [ ! -f "$config_file" ]; then
  echo "Profile $profile not found!"
  return 1
 fi

 echo "Switching to $profile profile..."
 source "$config_file"

 # Apply CPU governor
 for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
  echo "$CPU_GOVERNOR" | sudo tee "$cpu" >/dev/null 2>&1
 done

 # Apply CPU frequency limit
 if [ -f /sys/devices/system/cpu/intel_pstate/max_perf_pct ]; then
  echo "$CPU_MAX_FREQ" | sudo tee /sys/devices/system/cpu/intel_pstate/max_perf_pct >/dev/null
 fi

 # Apply laptop mode
 echo "$LAPTOP_MODE" | sudo tee /proc/sys/vm/laptop_mode >/dev/null

 # Apply USB autosuspend
 if [ "$USB_AUTOSUSPEND" = "1" ]; then
  echo 'auto' | sudo tee /sys/bus/usb/devices/*/power/control >/dev/null 2>&1
 else
  echo 'on' | sudo tee /sys/bus/usb/devices/*/power/control >/dev/null 2>&1
 fi

 echo "Profile $profile applied successfully!"
}

# Command line interface
case "$1" in
 performance|balanced|powersave)
  switch_profile "$1"
  ;;
 list)
  echo "Available profiles:"
  ls "$PROFILE_DIR"/*.conf 2>/dev/null | xargs -n1 basename | sed 's/.conf$//'
  ;;
 *)
  echo "Usage: $0 {performance|balanced|powersave|list}"
  echo "Current profile settings:"
  echo "CPU Governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)"
  echo "Laptop Mode: $(cat /proc/sys/vm/laptop_mode 2>/dev/null)"
  ;;
esac
