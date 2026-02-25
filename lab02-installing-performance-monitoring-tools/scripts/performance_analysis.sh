#!/bin/bash
echo "=== SYSTEM PERFORMANCE ANALYSIS ==="
echo "Analysis Date: $(date)"
echo ""
# System Information
echo "=== SYSTEM INFORMATION ==="
echo "Hostname: $(hostname)"
echo "OS Version: $(cat /etc/redhat-release)"
echo "Kernel: $(uname -r)"
echo "Uptime: $(uptime)"
echo ""
# CPU Analysis
echo "=== CPU ANALYSIS ==="
echo "CPU Cores: $(nproc)"
echo "Current Load Average: $(uptime | awk -F'load average:' '{print $2}')"
echo ""
echo "CPU Usage (5 samples):"
sar -u 1 5 | tail -1
echo ""
# Memory Analysis
echo "=== MEMORY ANALYSIS ==="
echo "Total Memory: $(free -h | awk '/^Mem:/ {print $2}')"
echo "Used Memory: $(free -h | awk '/^Mem:/ {print $3}')"
echo "Available Memory: $(free -h | awk '/^Mem:/ {print $7}')"
echo "Memory Usage Percentage: $(free | awk '/^Mem:/ {printf "%.1f%%", $3/$2 * 100.0}')"
echo ""
# Disk Analysis
echo "=== DISK ANALYSIS ==="
echo "Disk Usage:"
df -h | grep -E '^/dev/'
echo ""
echo "Disk I/O Statistics:"
iostat -x 1 1 | grep -E '^[a-z]'
echo ""
# Top Processes
echo "=== TOP PROCESSES ==="
echo "Top 5 CPU consumers:"
ps aux --sort=-%cpu | head -6 | tail -5
echo ""
echo "Top 5 Memory consumers:"
ps aux --sort=-%mem | head -6 | tail -5
echo ""
# Performance Recommendations
echo "=== PERFORMANCE RECOMMENDATIONS ==="
LOAD_AVG=$(uptime | awk -F'load average:' '{print $2}' | awk -F',' '{print $1}' | tr -d ' ')
CPU_CORES=$(nproc)
MEM_USAGE=$(free | awk '/^Mem:/ {printf "%.0f", $3/$2 * 100.0}')
if (( $(echo "$LOAD_AVG > $CPU_CORES" | bc -l) )); then
 echo "- HIGH LOAD: Load average ($LOAD_AVG) exceeds CPU cores ($CPU_CORES)"
fi
if [ $MEM_USAGE -gt 80 ]; then
 echo "- HIGH MEMORY USAGE: Memory usage is ${MEM_USAGE}%"
fi
echo "- Monitor disk I/O if %util consistently > 80%"
echo "- Check for zombie processes regularly"
echo "- Consider load balancing if CPU usage consistently > 70%"
