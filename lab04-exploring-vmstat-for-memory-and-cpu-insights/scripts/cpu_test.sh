#!/bin/bash
echo "Starting CPU load test..."
# Function to create CPU load
cpu_load() {
 local duration=$1
 local end_time=$((SECONDS + duration))

 while [ $SECONDS -lt $end_time ]; do
 # Perform CPU-intensive calculation
 echo "scale=5000; 4*a(1)" | bc -l > /dev/null 2>&1
 done
}
# Create different types of CPU load
echo "Phase 1: User space CPU load (30 seconds)..."
for i in {1..2}; do
 cpu_load 30 &
done
wait
echo "Phase 2: Mixed load with I/O (30 seconds)..."
for i in {1..2}; do
 (
 while [ $SECONDS -lt 30 ]; do
 dd if=/dev/zero of=/tmp/iotest_$i bs=1M count=10 2>/dev/null
 rm -f /tmp/iotest_$i
 done
 ) &
done
wait
echo "CPU test complete."
