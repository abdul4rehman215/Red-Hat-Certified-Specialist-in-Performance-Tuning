#!/bin/bash
echo "=== System Process Analysis Report ==="
echo "Generated on: $(date)"
echo
echo "=== TOP 10 CPU CONSUMERS ==="
ps aux --sort=-%cpu | head -11
echo
echo "=== TOP 10 MEMORY CONSUMERS ==="
ps aux --sort=-%mem | head -11
echo
echo "=== PROCESS COUNT BY USER ==="
ps aux | awk 'NR>1 {users[$1]++} END {for (user in users) print user, users[user]}' | sort -k2 -nr
echo
echo "=== ZOMBIE PROCESSES ==="
ps aux | awk '$8 ~ /^Z/ {print $2, $11}'
echo
echo "=== SYSTEM LOAD AVERAGE ==="
uptime
