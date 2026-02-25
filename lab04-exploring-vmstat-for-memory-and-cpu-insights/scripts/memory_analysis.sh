#!/bin/bash
echo "=== Memory Analysis Report ==="
echo "Current Date: $(date)"
echo
echo "=== Basic Memory Information ==="
free -h
echo
echo "=== Swap Information ==="
swapon --show
echo
echo "=== Memory Usage Breakdown ==="
cat /proc/meminfo | grep -E "(MemTotal|MemFree|MemAvailable|Buffers|Cached|SwapTotal|SwapFree)"
echo
echo "=== Top Memory Consuming Processes ==="
ps aux --sort=-%mem | head -10
echo
echo "=== vmstat Summary (5 samples, 1 second apart) ==="
vmstat 1 5
