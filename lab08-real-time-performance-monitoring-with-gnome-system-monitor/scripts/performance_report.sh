#!/bin/bash
REPORT_FILE="performance_report_$(date +%Y%m%d_%H%M%S).txt"
{
 echo "=== SYSTEM PERFORMANCE REPORT ==="
 echo "Generated: $(date)"
 echo "Hostname: $(hostname)"
 echo "Uptime: $(uptime)"
 echo ""

 echo "=== SYSTEM INFORMATION ==="
 echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'\"' -f2)"
 echo "Kernel: $(uname -r)"
 echo "Architecture: $(uname -m)"
 echo ""

 echo "=== CPU INFORMATION ==="
 lscpu | grep -E "CPU\(s\)|Model name|CPU MHz|Cache"
 echo ""
 echo "Current CPU Usage:"
 top -bn1 | grep "Cpu(s)"
 echo ""

 echo "=== MEMORY INFORMATION ==="
 free -h
 echo ""

 echo "=== TOP PROCESSES BY CPU ==="
 ps aux --sort=-%cpu | head -10
 echo ""

 echo "=== TOP PROCESSES BY MEMORY ==="
 ps aux --sort=-%mem | head -10
 echo ""

 echo "=== DISK USAGE ==="
 df -h
 echo ""

 echo "=== NETWORK CONNECTIONS ==="
 echo "Total network connections: $(netstat -tuln | wc -l)"
 echo ""

 echo "=== LOAD AVERAGE HISTORY ==="
 uptime
 echo ""

} > $REPORT_FILE

echo "Performance report generated: $REPORT_FILE"
cat $REPORT_FILE
