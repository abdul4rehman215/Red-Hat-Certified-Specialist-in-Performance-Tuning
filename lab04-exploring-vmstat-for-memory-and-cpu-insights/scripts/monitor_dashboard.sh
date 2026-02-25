#!/bin/bash
# Function to display colored output
print_colored() {
 local color=$1
 local text=$2
 case $color in
 red) echo -e "\033[31m$text\033[0m" ;;
 green) echo -e "\033[32m$text\033[0m" ;;
 yellow) echo -e "\033[33m$text\033[0m" ;;
 blue) echo -e "\033[34m$text\033[0m" ;;
 *) echo "$text" ;;
 esac
}
# Function to analyze vmstat output
analyze_performance() {
 local vmstat_line=$1
 local r b us sy id wa

 read r b swpd free buff cache si so bi bo in cs us sy id wa st <<< "$vmstat_line"

 echo "=== Performance Analysis ==="

 # CPU Analysis
 if [ "$us" -gt 80 ]; then
 print_colored red "HIGH USER CPU: $us%"
 elif [ "$us" -gt 50 ]; then
 print_colored yellow "MODERATE USER CPU: $us%"
 else
 print_colored green "NORMAL USER CPU: $us%"
 fi

 if [ "$sy" -gt 30 ]; then
 print_colored red "HIGH SYSTEM CPU: $sy%"
 elif [ "$sy" -gt 15 ]; then
 print_colored yellow "MODERATE SYSTEM CPU: $sy%"
 else
 print_colored green "NORMAL SYSTEM CPU: $sy%"
 fi

 if [ "$wa" -gt 20 ]; then
 print_colored red "HIGH I/O WAIT: $wa%"
 elif [ "$wa" -gt 10 ]; then
 print_colored yellow "MODERATE I/O WAIT: $wa%"
 else
 print_colored green "NORMAL I/O WAIT: $wa%"
 fi

 # Memory Analysis
 if [ "$si" -gt 0 ] || [ "$so" -gt 0 ]; then
 print_colored red "SWAP ACTIVITY DETECTED: SI=$si SO=$so"
 else
 print_colored green "NO SWAP ACTIVITY"
 fi

 # Process Analysis
 local cpu_count=$(nproc)
 if [ "$r" -gt $((cpu_count * 2)) ]; then
 print_colored red "HIGH PROCESS QUEUE: $r processes"
 elif [ "$r" -gt "$cpu_count" ]; then
 print_colored yellow "MODERATE PROCESS QUEUE: $r processes"
 else
 print_colored green "NORMAL PROCESS QUEUE: $r processes"
 fi

 if [ "$b" -gt 5 ]; then
 print_colored red "HIGH BLOCKED PROCESSES: $b"
 elif [ "$b" -gt 0 ]; then
 print_colored yellow "SOME BLOCKED PROCESSES: $b"
 else
 print_colored green "NO BLOCKED PROCESSES"
 fi

 echo "=========================="
}
echo "Real-time Performance Monitor"
echo "Press Ctrl+C to stop"
echo
# Skip the header line and process vmstat output
vmstat 2 | tail -n +4 | while read line; do
 clear
 echo "=== System Performance Dashboard ==="
 echo "Time: $(date)"
 echo
 echo "Raw vmstat output:"
 echo "$line"
 echo
 analyze_performance "$line"
 echo
 echo "Legend: Green=Normal, Yellow=Warning, Red=Critical"
done
