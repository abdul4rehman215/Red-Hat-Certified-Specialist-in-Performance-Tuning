#!/bin/bash
echo "=== CPU Bottleneck Detection ==="

# Function to analyze CPU metrics
analyze_cpu_metrics() {
 local logfile=$1

 echo "Analyzing CPU metrics from $logfile"
 echo ""

 # Calculate average utilization per CPU
 echo "=== Average CPU Utilization per Core ==="
 awk '
 /Average/ && $3 ~ /^[0-9]+$/ {
 cpu = $3
 usr = $4
 sys = $6
 total = usr + sys
 printf "CPU %s: User=%.1f%% System=%.1f%% Total=%.1f%%\n", cpu, usr, sys, total
 }
 ' $logfile

 echo ""

 # Identify imbalanced cores
 echo "=== Load Imbalance Detection ==="
 awk '
 /Average/ && $3 ~ /^[0-9]+$/ {
 cpu = $3
 total = $4 + $6 # usr + sys
 if (total > 80) print "HIGH LOAD: CPU " cpu " at " total "%"
 else if (total < 10) print "LOW LOAD: CPU " cpu " at " total "%"
 }
 ' $logfile

 echo ""

 # Check for I/O wait issues
 echo "=== I/O Wait Analysis ==="
 awk '
 /Average/ && $3 ~ /^[0-9]+$/ {
 cpu = $3
 iowait = $7
 if (iowait > 20) print "HIGH I/O WAIT: CPU " cpu " at " iowait "%"
 }
 ' $logfile
}

# Run analysis on existing log
if [ -f "cpu_stats.log" ]; then
 analyze_cpu_metrics "cpu_stats.log"
else
 echo "No existing log found. Generating new data..."
 mpstat -P ALL 2 15 > temp_cpu_stats.log
 analyze_cpu_metrics "temp_cpu_stats.log"
fi
