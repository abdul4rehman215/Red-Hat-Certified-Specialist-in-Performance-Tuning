#!/bin/bash
echo "=== CPU Power Management Configuration ==="

# Check available CPU governors
echo "Available CPU governors:"
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors

# Set powersave governor for all CPUs
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
 echo "powersave" | sudo tee "$cpu"
done

# Configure CPU frequency scaling
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do
 if [ -f "$cpu" ]; then
  # Reduce maximum frequency to 80% for power saving
  max_freq=$(cat "${cpu%/*}/cpuinfo_max_freq")
  new_max=$((max_freq * 80 / 100))
  echo "$new_max" | sudo tee "$cpu"
 fi
done

# Enable Intel P-State driver optimizations (if available)
if [ -f /sys/devices/system/cpu/intel_pstate/max_perf_pct ]; then
 echo 80 | sudo tee /sys/devices/system/cpu/intel_pstate/max_perf_pct
 echo 20 | sudo tee /sys/devices/system/cpu/intel_pstate/min_perf_pct
fi

echo "CPU power management configured successfully!"
