#!/bin/bash
echo "=== PERFORMANCE ISSUE IDENTIFICATION ==="
echo
# High CPU usage processes (>50%)
echo "=== HIGH CPU USAGE PROCESSES (>50%) ==="
ps aux | awk 'NR>1 && $3>50 {printf "PID: %s, USER: %s, CPU: %.1f%%, CMD: %s\n", $2, $1, $3, $11}'
echo
# High memory usage processes (>10%)
echo "=== HIGH MEMORY USAGE PROCESSES (>10%) ==="
ps aux | awk 'NR>1 && $4>10 {printf "PID: %s, USER: %s, MEM: %.1f%%, CMD: %s\n", $2, $1, $4, $11}'
echo
# Long-running processes
echo "=== LONG-RUNNING PROCESSES (>1 hour CPU time) ==="
ps aux | awk 'NR>1 {
 split($10, time_parts, ":");
 if (length(time_parts) == 3 && (time_parts[1] > 0 || time_parts[2] > 60)) {
 printf "PID: %s, USER: %s, TIME: %s, CMD: %s\n", $2, $1, $10, $11
 }
}'
echo
# Processes with many threads
echo "=== PROCESSES WITH HIGH THREAD COUNT ==="
ps -eLf | awk 'NR>1 {threads[$2]++} END {for (pid in threads) if (threads[pid] > 10) print "PID:", pid, "Threads:", threads[pid]}' | sort -k4 -nr
