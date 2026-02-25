#!/bin/bash
echo "=== Memory Performance Optimization ==="

echo "Clearing system caches..."
sync
echo 3 > /proc/sys/vm/drop_caches
echo "System caches cleared."

echo "Current swappiness value:"
cat /proc/sys/vm/swappiness

echo "Setting optimal swappiness value..."
echo 10 > /proc/sys/vm/swappiness
echo "vm.swappiness = 10" >> /etc/sysctl.conf

echo "Configuring memory overcommit..."
echo 1 > /proc/sys/vm/overcommit_memory
echo "vm.overcommit_memory = 1" >> /etc/sysctl.conf

echo "Analyzing memory usage by processes..."
ps aux --sort=-%mem | head -10 | while read line; do
 if echo "$line" | grep -v "PID" >/dev/null; then
  pid=$(echo "$line" | awk '{print $2}')
  mem_percent=$(echo "$line" | awk '{print $4}')
  command=$(echo "$line" | awk '{print $11}')
  if (( $(echo "$mem_percent > 10" | bc -l) )); then
   echo "High memory usage detected: PID $pid ($command) using ${mem_percent}% memory"
  fi
 fi
done

echo "Memory optimization completed."
