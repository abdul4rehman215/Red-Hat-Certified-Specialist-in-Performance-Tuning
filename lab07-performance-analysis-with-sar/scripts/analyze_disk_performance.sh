#!/bin/bash
# Disk Performance Analysis Script
DATA_FILE="/var/log/sysstat/sa$(date +%d)"
REPORT_FILE="disk_analysis_report_$(date +%Y%m%d).txt"

echo "Disk Performance Analysis Report" > $REPORT_FILE
echo "Generated on: $(date)" >> $REPORT_FILE
echo "==================================" >> $REPORT_FILE

# Disk utilization overview
echo -e "\n1. Disk Utilization Overview:" >> $REPORT_FILE
sar -d -f $DATA_FILE | grep -E "(Average|DEV|tps|rkB/s|wkB/s|%util)" | tail -10 >> $REPORT_FILE

# High disk utilization periods
echo -e "\n2. High Disk Utilization Periods (>70%):" >> $REPORT_FILE
sar -d -f $DATA_FILE | awk '$NF != "%util" && $NF > 70 {print $1, $2, "Device:", $3, "Utilization:", $NF"%", "TPS:", $4}' >> $REPORT_FILE

# I/O throughput analysis
echo -e "\n3. I/O Throughput Analysis:" >> $REPORT_FILE
echo "High Read Activity (>1000 KB/s):" >> $REPORT_FILE
sar -d -f $DATA_FILE | awk '$6 != "rkB/s" && $6 > 1000 {print $1, $2, "Device:", $3, "Read:", $6"KB/s"}' >> $REPORT_FILE
echo -e "\nHigh Write Activity (>1000 KB/s):" >> $REPORT_FILE
sar -d -f $DATA_FILE | awk '$7 != "wkB/s" && $7 > 1000 {print $1, $2, "Device:", $3, "Write:", $7"KB/s"}' >> $REPORT_FILE

# Block device statistics
echo -e "\n4. Block Device Statistics:" >> $REPORT_FILE
sar -b -f $DATA_FILE | grep -E "(Average|tps|rtps|wtps|bread|bwrtn)" | tail -5 >> $REPORT_FILE

# Disk performance summary
echo -e "\n5. Disk Performance Summary:" >> $REPORT_FILE
sar -d -f $DATA_FILE | awk '
BEGIN {samples=0; total_tps=0; total_read=0; total_write=0; total_util=0; devices=0}
$4 != "tps" && NF > 9 {
 samples++;
 total_tps += $4;
 total_read += $6;
 total_write += $7;
 total_util += $NF;
 if($3 != prev_device) {devices++; prev_device=$3}
}
END {
 if(samples > 0) {
 avg_tps = total_tps/samples;
 avg_read = total_read/samples;
 avg_write = total_write/samples;
 avg_util = total_util/samples;
 print "Number of devices monitored:", devices;
 print "Average TPS:", avg_tps;
 print "Average Read (kB/s):", avg_read;
 print "Average Write (kB/s):", avg_write;
 print "Average Utilization:", avg_util"%";
 }
}' >> $REPORT_FILE

# I/O wait correlation
echo -e "\n6. I/O Wait Correlation:" >> $REPORT_FILE
echo "Periods with high I/O wait and disk utilization:" >> $REPORT_FILE
join -1 2 -2 2 <(sar -u -f $DATA_FILE | awk '$6 != "%iowait" && $6 > 5 {print $2, $6}' | sort) \
 <(sar -d -f $DATA_FILE | awk '$NF != "%util" && $NF > 50 {print $2, $NF}' | sort) | \
head -10 >> $REPORT_FILE

echo "Disk analysis complete. Report saved to: $REPORT_FILE"
cat $REPORT_FILE
