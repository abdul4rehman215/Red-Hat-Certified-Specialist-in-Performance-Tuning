#!/bin/bash
REPORT_FILE="power_optimization_report.txt"
echo "=== POWER OPTIMIZATION REPORT ===" > "$REPORT_FILE"
echo "Generated on: $(date)" >> "$REPORT_FILE"
echo >> "$REPORT_FILE"

# System Information
echo "=== SYSTEM INFORMATION ===" >> "$REPORT_FILE"
echo "Hostname: $(hostname)" >> "$REPORT_FILE"
echo "Kernel: $(uname -r)" >> "$REPORT_FILE"
echo "CPU: $(cat /proc/cpuinfo | grep "model name" | head -1 | cut -d':' -f2 | xargs)" >> "$REPORT_FILE"
echo >> "$REPORT_FILE"

# Power Supply Information
echo "=== POWER SUPPLY STATUS ===" >> "$REPORT_FILE"
for supply in /sys/class/power_supply/*; do
 if [ -d "$supply" ]; then
  name=$(basename "$supply")
  if [ -f "$supply/type" ]; then
   type=$(cat "$supply/type")
   echo "$name ($type):" >> "$REPORT_FILE"

   [ -f "$supply/status" ] && echo " Status: $(cat $supply/status)" >> "$REPORT_FILE"
   [ -f "$supply/capacity" ] && echo " Capacity: $(cat $supply/capacity)%" >> "$REPORT_FILE"
   [ -f "$supply/voltage_now" ] && echo " Voltage: $(cat $supply/voltage_now) µV" >> "$REPORT_FILE"
  fi
 fi
done
echo >> "$REPORT_FILE"

# CPU Governor Settings
echo "=== CPU GOVERNOR SETTINGS ===" >> "$REPORT_FILE"
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
 if [ -f "$cpu" ]; then
  cpu_num=$(echo "$cpu" | grep -o 'cpu[0-9]*' | head -1)
  governor=$(cat "$cpu")
  echo "$cpu_num: $governor" >> "$REPORT_FILE"
 fi
done
echo >> "$REPORT_FILE"

# Power Management Features
echo "=== POWER MANAGEMENT FEATURES ===" >> "$REPORT_FILE"
echo "Laptop Mode: $(cat /proc/sys/vm/laptop_mode 2>/dev/null || echo 'Not available')" >> "$REPORT_FILE"

# USB Power Management
echo "USB Autosuspend Status:" >> "$REPORT_FILE"
for usb in /sys/bus/usb/devices/*/power/control; do
 if [ -f "$usb" ]; then
  device=$(dirname "$usb" | xargs basename)
  control=$(cat "$usb")
  echo " $device: $control" >> "$REPORT_FILE"
 fi
done 2>/dev/null
echo >> "$REPORT_FILE"

# Network Interface Power Management
echo "=== NETWORK POWER MANAGEMENT ===" >> "$REPORT_FILE"
for iface in /sys/class/net/*/device/power/control; do
 if [ -f "$iface" ]; then
  interface=$(echo "$iface" | cut -d'/' -f5)
  control=$(cat "$iface")
  echo "$interface: $control" >> "$REPORT_FILE"
 fi
done 2>/dev/null
echo >> "$REPORT_FILE"

# Recommendations
echo "=== OPTIMIZATION RECOMMENDATIONS ===" >> "$REPORT_FILE"
echo "1. Ensure powersave governor is active during battery operation" >> "$REPORT_FILE"
echo "2. Enable laptop mode for better disk power management" >> "$REPORT_FILE"
echo "3. Configure USB autosuspend for unused devices" >> "$REPORT_FILE"
echo "4. Use powertop regularly to monitor power consumption" >> "$REPORT_FILE"
echo "5. Consider disabling unused hardware components" >> "$REPORT_FILE"

echo "Report generated: $REPORT_FILE"
cat "$REPORT_FILE"
