#!/bin/bash
# CPU Performance Analysis Script

# Ubuntu location for SAR binary data:
DATA_FILE="/var/log/sysstat/sa$(date +%d)"
REPORT_FILE="cpu_analysis_report_$(date +%Y%m%d).txt"

echo "CPU Performance Analysis Report" > $REPORT_FILE
echo "Generated on: $(date)" >> $REPORT_FILE
echo "=================================" >> $REPORT_FILE

# Overall CPU utilization
echo -e "\n1. Overall CPU Utilization:" >> $REPORT_FILE
sar -u -f $DATA_FILE | grep -E "(Average|%user|%nice|%system|%iowait|%steal|%idle)" >> $REPORT_FILE

# Peak CPU usage periods
echo -e "\n2. Peak CPU Usage Periods (>80% utilization):" >> $REPORT_FILE
# Ubuntu columns: %user=$3, %system=$5, %idle=$8
sar -u -f $DATA_FILE | awk '$3 != "%user" && NF > 6 {total=$3+$5; if(total > 80) print $1, $2, "Total:", total"%"}' >> $REPORT_FILE

# I/O Wait analysis
echo -e "\n3. High I/O Wait Periods (>10%):" >> $REPORT_FILE
# Ubuntu %iowait column is $6
sar -u -f $DATA_FILE | awk '$6 != "%iowait" && $6 > 10 {print $1, $2, "I/O Wait:", $6"%"}' >> $REPORT_FILE

# CPU efficiency calculation
echo -e "\n4. CPU Efficiency Summary:" >> $REPORT_FILE
sar -u -f $DATA_FILE | awk '
BEGIN {total_samples=0; total_idle=0; total_user=0; total_system=0}
$3 != "%user" && NF > 6 {
 total_samples++;
 total_user+=$3;
 total_system+=$5;
 total_idle+=$8;
}
END {
 if(total_samples > 0) {
 avg_idle = total_idle/total_samples;
 avg_user = total_user/total_samples;
 avg_system = total_system/total_samples;
 efficiency = 100 - avg_idle;
 print "Average CPU Utilization:", efficiency"%";
 print "User processes:", avg_user"%";
 print "System processes:", avg_system"%";
 print "Idle time:", avg_idle"%"
 }
}' >> $REPORT_FILE

echo "CPU analysis complete. Report saved to: $REPORT_FILE"
cat $REPORT_FILE
