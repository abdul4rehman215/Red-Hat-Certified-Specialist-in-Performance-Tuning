#!/bin/bash
echo "=== CPU Baseline Measurement ==="
echo "Date: $(date)"
echo "System: $(hostname)"
echo ""
echo "=== CPU Architecture ==="
lscpu | grep -E "(Architecture|CPU\(s\)|Thread|Core|Socket)"
echo ""
echo "=== Current CPU Usage (10 second average) ==="
mpstat -P ALL 1 10 | grep "Average"
echo ""
echo "=== System Load ==="
uptime
echo ""
echo "=== Top CPU Consuming Processes ==="
ps aux --sort=-%cpu | head -10
