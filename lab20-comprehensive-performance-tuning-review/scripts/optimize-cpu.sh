#!/bin/bash
echo "=== CPU Performance Optimization ==="

echo "Current CPU governor:"
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "N/A (cpufreq not available in this VM)"

echo "Setting CPU governor to performance mode..."
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
 echo performance > $cpu 2>/dev/null || echo "Could not set governor for $cpu"
done

echo "Optimizing process priorities..."
for pid in $(ps aux --sort=-%cpu | head -10 | awk 'NR>1 {print $2}'); do
 current_nice=$(ps -o pid,ni -p $pid | tail -1 | awk '{print $2}')
 if [ "$current_nice" -gt 0 ]; then
  renice -5 $pid 2>/dev/null && echo "Reniced process $pid"
 fi
done

echo "Checking for unnecessary services..."
systemctl list-unit-files --type=service --state=enabled | grep -E "(bluetooth|cups)" | while read service; do
 service_name=$(echo $service | awk '{print $1}')
 echo "Consider disabling: $service_name"
done

echo "CPU optimization completed."
