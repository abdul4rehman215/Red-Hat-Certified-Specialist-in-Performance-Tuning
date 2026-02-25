#!/bin/bash
# CPU Stress Test Script
echo "Starting CPU stress test..."

# Function to create CPU load
cpu_load() {
 local duration=$1
 local cores=$2

 for ((i=1; i<=cores; i++)); do
  yes > /dev/null &
 done

 sleep $duration
 killall yes
}

# Light load - 2 cores for 2 minutes
echo "Phase 1: Light CPU load"
cpu_load 120 2
sleep 30

# Heavy load - 4 cores for 3 minutes
echo "Phase 2: Heavy CPU load"
cpu_load 180 4
sleep 30

# Variable load pattern
echo "Phase 3: Variable load pattern"
for i in {1..5}; do
 cpu_load 30 $i
 sleep 15
done

echo "CPU stress test completed"
