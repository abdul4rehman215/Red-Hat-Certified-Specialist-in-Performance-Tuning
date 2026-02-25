#!/bin/bash
# Automated I/O Bottleneck Detection Script
LOGFILE="bottleneck_analysis_$(date +%Y%m%d_%H%M%S).log"
echo "I/O Bottleneck Analysis Report" > $LOGFILE
echo "Generated: $(date)" >> $LOGFILE
echo "================================" >> $LOGFILE
# Collect iostat data for analysis
iostat -x 1 10 > temp_iostat.log
# Analyze the data
echo "" >> $LOGFILE
echo "BOTTLENECK ANALYSIS RESULTS:" >> $LOGFILE
echo "----------------------------" >> $LOGFILE
# Check for high utilization
echo "Devices with high utilization (>80%):" >> $LOGFILE
awk '/^[a-z]/ && $NF > 80 {print $1 ": " $NF "%"}' temp_iostat.log >> $LOGFILE
# Check for high await times
echo "" >> $LOGFILE
echo "Devices with high await times (>20ms):" >> $LOGFILE
awk '/^[a-z]/ && $(NF-1) > 20 {print $1 ": " $(NF-1) "ms"}' temp_iostat.log >> $LOGFILE
# Check for high queue sizes
echo "" >> $LOGFILE
echo "Devices with high average queue sizes (>2):" >> $LOGFILE
awk '/^[a-z]/ && $(NF-2) > 2 {print $1 ": " $(NF-2)}' temp_iostat.log >> $LOGFILE
# Generate recommendations
echo "" >> $LOGFILE
echo "RECOMMENDATIONS:" >> $LOGFILE
echo "----------------" >> $LOGFILE
echo "1. Consider I/O scheduler optimization for high utilization devices" >> $LOGFILE
echo "2. Investigate storage hardware for devices with high await times" >> $LOGFILE
echo "3. Implement I/O throttling for applications causing queue buildup" >> $LOGFILE
# Cleanup
rm temp_iostat.log
echo "Analysis complete. Results saved to: $LOGFILE"
cat $LOGFILE
