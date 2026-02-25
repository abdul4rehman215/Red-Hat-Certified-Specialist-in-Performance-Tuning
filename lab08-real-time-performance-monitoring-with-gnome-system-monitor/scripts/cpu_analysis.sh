#!/bin/bash
echo "=== CPU Analysis Report ==="
echo "Date: $(date)"
echo "System: $(uname -a)"
echo ""

echo "CPU Information:"
lscpu | grep -E "CPU\(s\)|Model name|CPU MHz"
echo ""

echo "Current CPU Usage:"
top -bn1 | head -20
echo ""

echo "Load Average:"
uptime
echo ""

echo "Top 10 CPU-consuming processes:"
ps aux --sort=-%cpu | head -11
