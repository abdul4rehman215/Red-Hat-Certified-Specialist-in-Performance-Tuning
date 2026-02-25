#!/bin/bash
BASELINE_FILE="system_baseline_$(date +%Y%m%d).txt"
echo "Creating system performance baseline: $BASELINE_FILE"
{
 echo "=== SYSTEM PERFORMANCE BASELINE ==="
 echo "Date: $(date)"
 echo "Hostname: $(hostname)"
 echo

 echo "=== SYSTEM INFORMATION ==="
 echo "Kernel: $(uname -r)"
 echo "CPU Info: $(grep 'model name' /proc/cpuinfo | head -1 | cut -d':' -f2 | xargs)"
 echo "CPU Cores: $(nproc)"
 echo "Total Memory: $(free -h | awk '/^Mem:/ {print $2}')"
 echo

 echo "=== CURRENT LOAD ==="
 uptime
 echo

 echo "=== MEMORY USAGE ==="
 free -h
 echo

 echo "=== PROCESS STATISTICS ==="
 echo "Total processes: $(ps aux | wc -l)"
 echo "Running: $(ps aux | awk '$8=="'"R"'" {count++} END {print count+0}')"
 echo "Sleeping: $(ps aux | awk '$8~/^S/ {count++} END {print count+0}')"
 echo "Stopped: $(ps aux | awk '$8=="'"T"'" {count++} END {print count+0}')"
 echo "Zombie: $(ps aux | awk '$8=="'"Z"'" {count++} END {print count+0}')"
 echo

 echo "=== TOP 10 PROCESSES BY CPU ==="
 ps aux --sort=-%cpu | head -11
 echo

 echo "=== TOP 10 PROCESSES BY MEMORY ==="
 ps aux --sort=-%mem | head -11
 echo

 echo "=== PROCESS COUNT BY USER ==="
 ps aux | awk 'NR>1 {users[$1]++} END {for (user in users) printf "%-10s %d\n", user, users[user]}' | sort -k2 -nr

} > "$BASELINE_FILE"
echo "Baseline saved to: $BASELINE_FILE"
echo "Use this file to compare against future system states"
