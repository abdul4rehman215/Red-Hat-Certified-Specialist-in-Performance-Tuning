#!/bin/bash
echo "=== CPU Hardware Detection Analysis ==="
echo
echo "1. CPU Detection Messages:"
dmesg | grep -i "cpu" | head -10
echo
echo "2. CPU Features:"
dmesg | grep -i "cpu.*feature" | head -5
echo
echo "3. CPU Frequency Information:"
dmesg | grep -i "cpufreq\|scaling" | head -5
echo
echo "4. CPU Cache Information:"
dmesg | grep -i "cache" | head -5
