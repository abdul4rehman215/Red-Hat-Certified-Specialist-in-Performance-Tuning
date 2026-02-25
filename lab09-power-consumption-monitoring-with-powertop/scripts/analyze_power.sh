#!/bin/bash
echo "=== Power Consumption Analysis ==="
echo "Date: $(date)"
echo

# Check battery status
if [ -f /sys/class/power_supply/BAT0/capacity ]; then
 echo "Battery Level: $(cat /sys/class/power_supply/BAT0/capacity)%"
 echo "Battery Status: $(cat /sys/class/power_supply/BAT0/status)"
else
 echo "System running on AC power"
fi

echo
echo "=== Top CPU Consuming Processes ==="
ps aux --sort=-%cpu | head -10
echo
echo "=== Current CPU Frequency ==="
cat /proc/cpuinfo | grep "cpu MHz" | head -4
echo
echo "=== Active Network Interfaces ==="
ip link show | grep "state UP"
echo
echo "=== Disk Activity ==="
iostat -x 1 1 | tail -n +4
