#!/bin/bash
FINAL_REPORT="reports/final-performance-report-$(date +%Y%m%d_%H%M%S).txt"

echo "=== COMPREHENSIVE PERFORMANCE TUNING REPORT ===" > $FINAL_REPORT
echo "Generated on: $(date)" >> $FINAL_REPORT
echo "System: $(hostname)" >> $FINAL_REPORT
echo "Kernel: $(uname -r)" >> $FINAL_REPORT
echo "" >> $FINAL_REPORT

echo "1. SYSTEM SPECIFICATIONS:" >> $FINAL_REPORT
echo "CPU: $(lscpu | grep 'Model name' | cut -d: -f2 | xargs)" >> $FINAL_REPORT
echo "Memory: $(free -h | grep Mem | awk '{print $2}')" >> $FINAL_REPORT
echo "Storage: $(df -h / | tail -1 | awk '{print $2}')" >> $FINAL_REPORT
echo "" >> $FINAL_REPORT

echo "2. PERFORMANCE ANALYSIS SUMMARY:" >> $FINAL_REPORT
echo "" >> $FINAL_REPORT

echo "CPU Performance:" >> $FINAL_REPORT
CURRENT_LOAD=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
echo "- Current Load Average: $CURRENT_LOAD" >> $FINAL_REPORT
echo "- CPU Cores: $(nproc)" >> $FINAL_REPORT
echo "- CPU Governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo 'N/A')" >> $FINAL_REPORT
echo "" >> $FINAL_REPORT

echo "Memory Performance:" >> $FINAL_REPORT
TOTAL_MEM=$(free | grep Mem | awk '{print $2}')
USED_MEM=$(free | grep Mem | awk '{print $3}')
MEM_USAGE_PERCENT=$(echo "scale=2; $USED_MEM * 100 / $TOTAL_MEM" | bc)
echo "- Memory Usage: ${MEM_USAGE_PERCENT}%" >> $FINAL_REPORT
echo "- Swappiness: $(cat /proc/sys/vm/swappiness)" >> $FINAL_REPORT
echo "- Available Memory: $(free -h | grep Mem | awk '{print $7}')" >> $FINAL_REPORT
echo "" >> $FINAL_REPORT

echo "Disk Performance:" >> $FINAL_REPORT
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
echo "- Root Filesystem Usage: ${DISK_USAGE}%" >> $FINAL_REPORT
echo "- I/O Scheduler: $(cat /sys/block/vda/queue/scheduler 2>/dev/null | grep -o '\[.*\]' | tr -d '[]' || echo 'N/A')" >> $FINAL_REPORT
echo "" >> $FINAL_REPORT

echo "3. OPTIMIZATIONS IMPLEMENTED:" >> $FINAL_REPORT
echo "- CPU governor attempted (VM may not support cpufreq)" >> $FINAL_REPORT
echo "- Memory swappiness optimized to 10" >> $FINAL_REPORT
echo "- I/O scheduler checked (mq-deadline preferred)" >> $FINAL_REPORT
echo "- System limits increased for better performance" >> $FINAL_REPORT
echo "- Network parameters tuned for better throughput" >> $FINAL_REPORT
echo "- Temporary files cleaned up" >> $FINAL_REPORT
echo "" >> $FINAL_REPORT

echo "4. RECOMMENDATIONS:" >> $FINAL_REPORT
echo "- Monitor system performance regularly using sar and iostat" >> $FINAL_REPORT
echo "- Set up automated performance monitoring with cron jobs" >> $FINAL_REPORT
echo "- Review and update performance settings quarterly" >> $FINAL_REPORT
echo "- Consider hardware upgrades if bottlenecks persist" >> $FINAL_REPORT
echo "- Implement application-level optimizations where needed" >> $FINAL_REPORT
echo "" >> $FINAL_REPORT

echo "5. MONITORING COMMANDS FOR ONGOING MAINTENANCE:" >> $FINAL_REPORT
echo "- CPU monitoring: sar -u 5 12" >> $FINAL_REPORT
echo "- Memory monitoring: sar -r 5 12" >> $FINAL_REPORT
echo "- Disk I/O monitoring: iostat -x 5 12" >> $FINAL_REPORT
echo "- Process monitoring: top -b -n 1" >> $FINAL_REPORT
echo "- Network monitoring: sar -n DEV 5 12" >> $FINAL_REPORT
echo "" >> $FINAL_REPORT

echo "Report generation completed."
echo "Final report saved to: $FINAL_REPORT"
echo ""
echo "=== REPORT SUMMARY ==="
cat $FINAL_REPORT
