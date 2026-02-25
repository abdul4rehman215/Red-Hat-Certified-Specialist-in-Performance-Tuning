#!/bin/bash
echo "Starting memory allocation test..."
# Allocate memory in chunks
for i in {1..10}; do
 echo "Allocating memory chunk $i"
 # Create a large array in memory
 dd if=/dev/zero of=/tmp/memtest_$i bs=100M count=1 2>/dev/null &
 sleep 2
done
wait
echo "Memory test complete. Cleaning up..."
rm -f /tmp/memtest_*
