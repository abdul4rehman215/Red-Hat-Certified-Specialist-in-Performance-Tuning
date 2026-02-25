#!/bin/bash
echo "=== Memory Diagnostics ==="
echo
echo "1. Memory errors:"
dmesg | grep -i "memory.*error\|memory.*fail\|bad page" | tail -10
echo
echo "2. Out of memory conditions:"
dmesg | grep -i "out of memory\|oom\|killed process" | tail -10
echo
echo "3. Memory pressure warnings:"
dmesg | grep -i "memory pressure\|low memory" | tail -5
echo
echo "4. Memory hardware detection:"
dmesg | grep -i "memory.*detect\|memory.*found" | head -5
