#!/bin/bash
echo "=== SYSTEM OPTIMIZATION SCRIPT ==="

# Function to optimize process priorities
optimize_priorities() {
 echo "Optimizing process priorities..."

 # Lower priority for non-essential processes
 for proc in $(pgrep -f "stress-ng"); do
  if [ -n "$proc" ]; then
   renice +10 $proc 2>/dev/null
   echo "Lowered priority for process $proc"
  fi
 done
}

# Function to clean up system resources
cleanup_resources() {
 echo "Cleaning up system resources..."

 # Clear system caches (be careful in production)
 sync
 echo 1 > /proc/sys/vm/drop_caches 2>/dev/null || echo "Cache cleanup requires root privileges"

 # Remove temporary files
 find /tmp -type f -atime +1 -delete 2>/dev/null

 echo "Resource cleanup completed"
}

# Function to optimize memory usage
optimize_memory() {
 echo "Memory optimization recommendations:"

 # Check for memory-intensive processes
 echo "Top 5 memory consumers:"
 ps aux --sort=-%mem | head -6

 # Check swap usage
 SWAP_USED=$(free | awk 'NR==3{print $3}')
 if [ $SWAP_USED -gt 0 ]; then
  echo "Warning: Swap is being used ($SWAP_USED KB)"
  echo "Consider adding more RAM or optimizing memory usage"
 fi
}

# Function to monitor system health
monitor_health() {
 echo "System health check:"

 # CPU load check
 LOAD_AVG=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
 CPU_CORES=$(nproc)

 if (( $(echo "$LOAD_AVG > $CPU_CORES" | bc -l) )); then
  echo "Warning: High CPU load detected ($LOAD_AVG on $CPU_CORES cores)"
 else
  echo "CPU load is normal ($LOAD_AVG on $CPU_CORES cores)"
 fi

 # Memory usage check
 MEM_USAGE=$(free | awk 'NR==2{printf "%.1f", $3*100/$2}')
 if (( $(echo "$MEM_USAGE > 80" | bc -l) )); then
  echo "Warning: High memory usage ($MEM_USAGE%)"
 else
  echo "Memory usage is normal ($MEM_USAGE%)"
 fi
}

# Main optimization routine
main() {
 echo "Starting system optimization..."
 echo ""

 optimize_priorities
 echo ""

 cleanup_resources
 echo ""

 optimize_memory
 echo ""

 monitor_health
 echo ""

 echo "Optimization completed!"
}

# Run main function
main
