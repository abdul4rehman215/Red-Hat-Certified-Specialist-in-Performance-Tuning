#!/bin/bash
# Performance monitoring dashboard
while true; do
 clear
 echo "=== REAL-TIME PERFORMANCE DASHBOARD ==="
 echo "Updated: $(date)"
 echo "Press Ctrl+C to exit"
 echo ""

 # CPU Information
 echo "=== CPU USAGE ==="
 top -bn1 | grep "Cpu(s)" | awk '{print "CPU Usage: " $2 " user, " $4 " system, " $8 " idle"}'
 echo "Load Average: $(uptime | awk -F'load average:' '{print $2}')"
 echo ""

 # Memory Information
 echo "=== MEMORY USAGE ==="
 free -h | awk 'NR==2{printf "Memory: %s used / %s total (%.1f%%)\n", $3, $2, $3/$2*100}'
 free -h | awk 'NR==3{printf "Swap: %s used / %s total\n", $3, $2}'
 echo ""

 # Top Processes
 echo "=== TOP 5 PROCESSES BY CPU ==="
 ps aux --sort=-%cpu | head -6 | awk 'NR>1{printf "%-20s %5s%% %5s%%\n", $11, $3, $4}'
 echo ""

 echo "=== TOP 5 PROCESSES BY MEMORY ==="
 ps aux --sort=-%mem | head -6 | awk 'NR>1{printf "%-20s %5s%% %5s%%\n", $11, $3, $4}'
 echo ""

 # Disk Usage
 echo "=== DISK USAGE ==="
 df -h / | awk 'NR==2{printf "Root filesystem: %s used / %s total (%s)\n", $3, $2, $5}'
 echo ""

 sleep 5
done
