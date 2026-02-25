#!/bin/bash
echo "=== Memory Hardware Detection Analysis ==="
echo
echo "1. Memory Detection:"
dmesg | grep -i "memory" | grep -v "reserve" | head -10
echo
echo "2. Memory Mapping (E820):"
dmesg | grep -i "e820" | head -5
echo
echo "3. Available Memory:"
dmesg | grep -i "available.*memory\|usable.*memory"
echo
echo "4. Memory Errors/Warnings:"
dmesg | grep -i "memory.*error\|memory.*fail\|memory.*warn"
