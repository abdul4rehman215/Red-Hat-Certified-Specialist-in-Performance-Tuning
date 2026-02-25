#!/bin/bash
LOG_FILE="/tmp/performance_log_$(date +%Y%m%d_%H%M%S).txt"
echo "Performance Monitoring Started: $(date)" | tee $LOG_FILE
echo "=========================================" | tee -a $LOG_FILE
echo

echo "=== SYSTEM LOAD ===" | tee -a $LOG_FILE
uptime | tee -a $LOG_FILE
echo | tee -a $LOG_FILE

echo "=== MEMORY USAGE ===" | tee -a $LOG_FILE
free -h | tee -a $LOG_FILE
echo | tee -a $LOG_FILE

echo "=== DISK I/O ===" | tee -a $LOG_FILE
iostat -x 1 1 | tee -a $LOG_FILE
echo | tee -a $LOG_FILE

echo "=== NETWORK STATISTICS ===" | tee -a $LOG_FILE
ss -tuln | wc -l | awk '{print "Active connections: " $1}' | tee -a $LOG_FILE
cat /proc/net/sockstat | tee -a $LOG_FILE
echo | tee -a $LOG_FILE

echo "=== CURRENT SYSCTL SETTINGS ===" | tee -a $LOG_FILE
echo "vm.swappiness = $(sysctl -n vm.swappiness)" | tee -a $LOG_FILE
echo "vm.dirty_ratio = $(sysctl -n vm.dirty_ratio)" | tee -a $LOG_FILE
echo "vm.vfs_cache_pressure = $(sysctl -n vm.vfs_cache_pressure)" | tee -a $LOG_FILE
echo "net.ipv4.tcp_congestion_control = $(sysctl -n net.ipv4.tcp_congestion_control)" | tee -a $LOG_FILE
echo "net.core.somaxconn = $(sysctl -n net.core.somaxconn)" | tee -a $LOG_FILE
echo | tee -a $LOG_FILE

echo "Log saved to: $LOG_FILE"
