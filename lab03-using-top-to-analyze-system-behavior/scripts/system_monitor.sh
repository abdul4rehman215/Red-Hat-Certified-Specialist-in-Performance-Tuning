#!/bin/bash
echo "System Performance Analysis"
echo "=========================="
echo "Date: $(date)"
echo ""
# CPU Information
echo "CPU Information:"
echo "Cores: $(nproc)"
echo "Load Average: $(uptime | awk -F'load average:' '{print $2}')"
echo ""
# Memory Information
echo "Memory Information:"
free -h
echo ""
# Top 10 CPU consuming processes
echo "Top 10 CPU Consuming Processes:"
ps aux --sort=-%cpu | head -11
echo ""
# Top 10 Memory consuming processes
echo "Top 10 Memory Consuming Processes:"
ps aux --sort=-%mem | head -11
echo ""
# Disk I/O
echo "Disk Usage:"
df -h
echo ""
# Network connections
echo "Active Network Connections:"
netstat -tuln | wc -l
echo "Total connections: $(netstat -tuln | wc -l)"
