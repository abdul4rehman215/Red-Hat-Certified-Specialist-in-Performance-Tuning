#!/bin/bash
echo "Applying power optimizations..."

# CPU Governor settings
echo "powersave" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Enable laptop mode
echo 5 | sudo tee /proc/sys/vm/laptop_mode

# Optimize disk settings
for disk in /sys/block/sd*; do
 if [ -f "$disk/queue/scheduler" ]; then
  echo "deadline" | sudo tee "$disk/queue/scheduler"
 fi
done

# Network interface power management
for interface in /sys/class/net/*/device/power/control; do
 if [ -f "$interface" ]; then
  echo "auto" | sudo tee "$interface"
 fi
done

# USB autosuspend
echo 'auto' | sudo tee /sys/bus/usb/devices/*/power/control 2>/dev/null

echo "Power optimizations applied successfully!"
