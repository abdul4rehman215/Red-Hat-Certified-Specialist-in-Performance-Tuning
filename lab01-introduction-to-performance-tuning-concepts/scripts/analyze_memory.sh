#!/bin/bash
echo "=== MEMORY USAGE ANALYSIS ==="

# Basic memory information
echo "Memory Overview:"
free -h
echo ""
echo "Memory Usage by Type:"
cat /proc/meminfo | grep -E "MemTotal|MemFree|MemAvailable|Buffers|Cached|SwapTotal|SwapFree"
echo ""
echo "Top 10 Memory Consuming Processes:"
ps aux --sort=-%mem | head -11
echo ""
echo "Memory Usage by User:"
ps hax -o rss,user | awk '{a[$2]+=$1;}END{for(i in a)print i" "int(a[i]/1024+0.5)"MB";}' | sort -rnk2
echo ""
echo "Shared Memory Segments:"
ipcs -m
echo ""
echo "Memory Fragmentation Info:"
cat /proc/buddyinfo
echo ""
echo "Slab Memory Usage (top 10):"
sudo slabtop -o | head -15
