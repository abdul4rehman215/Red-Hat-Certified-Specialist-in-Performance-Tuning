#!/bin/bash
# Memory Stress Test Script
echo "Starting memory stress test..."

# Function to allocate memory
allocate_memory() {
 local size_mb=$1
 local duration=$2

 echo "Allocating ${size_mb}MB of memory for ${duration} seconds"

 # Use dd to create memory pressure
 dd if=/dev/zero of=/dev/null bs=1M count=$size_mb &
 local pid=$!

 sleep $duration
 kill $pid 2>/dev/null
}

# Phase 1: Gradual memory allocation
echo "Phase 1: Gradual memory increase"
for size in 100 200 400 800; do
 allocate_memory $size 60
 sleep 30
done

# Phase 2: Memory pressure simulation
echo "Phase 2: Memory pressure simulation"
# Create multiple processes consuming memory
for i in {1..5}; do
 dd if=/dev/zero of=/tmp/memtest_$i bs=1M count=200 &
done
sleep 180

# Cleanup
rm -f /tmp/memtest_*
killall dd 2>/dev/null
echo "Memory stress test completed"
