#!/bin/bash
echo "=== CPU Performance Analysis ==="
echo "Current Date: $(date)"
echo
echo "=== CPU Information ==="
lscpu | grep -E "(CPU\(s\)|Model name|CPU MHz|Cache)"
echo
echo "=== Load Average ==="
uptime
echo
echo "=== Current CPU Usage ==="
top -bn1 | grep "Cpu(s)"
echo
echo "=== Top CPU Consuming Processes ==="
ps aux --sort=-%cpu | head -10
echo
echo "=== vmstat CPU Analysis (10 samples, 2 seconds apart) ==="
vmstat 2 10
echo
echo "=== CPU Performance Indicators ==="
echo "High CPU utilization: us + sy > 80%"
echo "I/O bottleneck: wa > 20%"
echo "System overhead: sy > 30%"
echo "CPU contention: r > number of CPUs"
