#!/bin/bash
echo "Memory Usage Monitoring"
echo "======================="
echo "Timestamp: $(date)"
echo "Swappiness: $(sysctl -n vm.swappiness)"
echo
free -h
echo
echo "Swap Usage:"
cat /proc/swaps
echo
echo "Memory Statistics:"
cat /proc/meminfo | grep -E "(Active|Inactive|Dirty|Writeback)"
