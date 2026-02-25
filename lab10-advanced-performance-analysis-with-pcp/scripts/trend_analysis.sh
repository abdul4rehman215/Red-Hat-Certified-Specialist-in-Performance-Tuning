#!/bin/bash
# Trend analysis using PCP archive for localhost

ARCHIVE="/var/log/pcp/pmlogger/localhost/$(date +%Y%m%d)"
echo "Analyzing trends from: $ARCHIVE"
echo "======================================"

echo "CPU Usage Trends:"
CPU_AVG=$(pmdumptext -a "$ARCHIVE" -t 60 kernel.all.cpu.user kernel.all.cpu.sys 2>/dev/null | \
 awk 'NR>1 {u+=$2; s+=$3; c++} END {if(c>0) printf "Average CPU User: %.2f%%, System: %.2f%%\n", u/c, s/c}')
echo "$CPU_AVG"

echo "Memory Usage Trends:"
MEM_AVG=$(pmdumptext -a "$ARCHIVE" -t 60 mem.util.used mem.physmem 2>/dev/null | \
 awk 'NR>1 {used=$2; phys=$3; if(phys>0){pct=(used/phys)*100; sum+=pct; c++}} END {if(c>0) printf "Average Memory Usage: %.2f%%\n", sum/c}')
echo "$MEM_AVG"

echo "Load Average Trends:"
LOAD_AVG=$(pmdumptext -a "$ARCHIVE" -t 60 kernel.all.load 2>/dev/null | \
 awk 'NR>1 {sum+=$2; c++} END {if(c>0) printf "Average Load: %.2f\n", sum/c}')
echo "$LOAD_AVG"

echo "Trend analysis complete!"
