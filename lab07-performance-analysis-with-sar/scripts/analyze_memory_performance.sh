#!/bin/bash
# Memory Performance Analysis Script
DATA_FILE="/var/log/sysstat/sa$(date +%d)"
REPORT_FILE="memory_analysis_report_$(date +%Y%m%d).txt"

echo "Memory Performance Analysis Report" > $REPORT_FILE
echo "Generated on: $(date)" >> $REPORT_FILE
echo "===================================" >> $REPORT_FILE

# Memory utilization overview
echo -e "\n1. Memory Utilization Overview:" >> $REPORT_FILE
sar -r -f $DATA_FILE | grep -E "(Average|kbmemfree|kbmemused|%memused)" | tail -5 >> $REPORT_FILE

# High memory usage periods
echo -e "\n2. High Memory Usage Periods (>80%):" >> $REPORT_FILE
# Ubuntu sar -r columns: time, AM/PM, kbmemfree, kbavail, kbmemused, %memused, kbbuffers, kbcached...
sar -r -f $DATA_FILE | awk '$6 != "%memused" && $6 > 80 {print $1, $2, "Memory Used:", $6"%", "Available:", $4"KB"}' >> $REPORT_FILE

# Swap usage analysis
echo -e "\n3. Swap Usage Analysis:" >> $REPORT_FILE
sar -S -f $DATA_FILE | grep -E "(Average|kbswpfree|kbswpused|%swpused)" | tail -5 >> $REPORT_FILE

# Memory pressure indicators
echo -e "\n4. Memory Pressure Indicators:" >> $REPORT_FILE
echo "Paging Activity:" >> $REPORT_FILE
sar -B -f $DATA_FILE | awk '$3 != "pgpgin/s" && ($3 > 100 || $4 > 100) {print $1, $2, "Pages in/s:", $3, "Pages out/s:", $4}' >> $REPORT_FILE

# Memory efficiency calculation
echo -e "\n5. Memory Efficiency Summary:" >> $REPORT_FILE
sar -r -f $DATA_FILE | awk '
BEGIN {samples=0; total_used=0; total_free=0; total_buffer=0; total_cache=0}
$6 != "%memused" && NF > 8 {
 samples++;
 total_free += $3;
 total_used += $6;
 total_buffer += $7;
 total_cache += $8;
}
END {
 if(samples > 0) {
 avg_used = total_used/samples;
 avg_free = total_free/samples;
 avg_buffer = total_buffer/samples;
 avg_cache = total_cache/samples;
 print "Average Memory Usage:", avg_used"%";
 print "Average Free Memory:", avg_free"KB";
 print "Average Buffer Usage:", avg_buffer"KB";
 print "Average Cache Usage:", avg_cache"KB";
 }
}' >> $REPORT_FILE

echo "Memory analysis complete. Report saved to: $REPORT_FILE"
cat $REPORT_FILE
