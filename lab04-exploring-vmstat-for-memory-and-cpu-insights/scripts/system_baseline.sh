#!/bin/bash
BASELINE_FILE="system_baseline_$(date +%Y%m%d_%H%M%S).txt"
echo "=== System Performance Baseline ===" > $BASELINE_FILE
echo "Generated: $(date)" >> $BASELINE_FILE
echo >> $BASELINE_FILE
echo "=== System Information ===" >> $BASELINE_FILE
uname -a >> $BASELINE_FILE
echo >> $BASELINE_FILE
echo "=== CPU Information ===" >> $BASELINE_FILE
lscpu >> $BASELINE_FILE
echo >> $BASELINE_FILE
echo "=== Memory Information ===" >> $BASELINE_FILE
free -h >> $BASELINE_FILE
echo >> $BASELINE_FILE
echo "=== Disk Information ===" >> $BASELINE_FILE
df -h >> $BASELINE_FILE
echo >> $BASELINE_FILE
echo "=== Network Interfaces ===" >> $BASELINE_FILE
ip addr show >> $BASELINE_FILE
echo >> $BASELINE_FILE
echo "=== vmstat Baseline (20 samples, 3 seconds apart) ===" >> $BASELINE_FILE
vmstat 3 20 >> $BASELINE_FILE
echo >> $BASELINE_FILE
echo "=== vmstat Memory Statistics ===" >> $BASELINE_FILE
vmstat -s >> $BASELINE_FILE
echo >> $BASELINE_FILE
echo "=== vmstat Disk Statistics ===" >> $BASELINE_FILE
vmstat -d >> $BASELINE_FILE
echo "Baseline saved to: $BASELINE_FILE"
echo "Use this file to compare against future performance measurements."
