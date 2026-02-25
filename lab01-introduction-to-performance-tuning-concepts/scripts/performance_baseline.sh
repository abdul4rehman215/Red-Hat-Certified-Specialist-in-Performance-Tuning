#!/bin/bash
echo "=== SYSTEM PERFORMANCE BASELINE ==="
echo "Date: $(date)"
echo ""
echo "=== CPU Information ==="
lscpu | grep -E "Model name|CPU\(s\)|Thread|Core"
echo ""
echo "=== Memory Information ==="
free -h
echo ""
echo "=== Disk Information ==="
df -h
echo ""
echo "=== Current Load Average ==="
uptime
echo ""
echo "=== Top 5 CPU Consuming Processes ==="
ps aux --sort=-%cpu | head -6
echo ""
echo "=== Top 5 Memory Consuming Processes ==="
ps aux --sort=-%mem | head -6
echo ""
