#!/bin/bash
echo "=== CPU Affinity and Load Balancing Test ==="

# Function to run process on specific CPU
test_cpu_affinity() {
 local cpu_num=$1
 local duration=$2

 echo "Testing CPU affinity for CPU $cpu_num"

 # Start monitoring
 mpstat -P $cpu_num 1 $duration > cpu_${cpu_num}_stats.log &
 MPSTAT_PID=$!

 # Run CPU-intensive task on specific CPU
 taskset -c $cpu_num stress --cpu 1 --timeout ${duration}s &
 STRESS_PID=$!

 # Wait for completion
 wait $STRESS_PID
 wait $MPSTAT_PID

 echo "Results for CPU $cpu_num:"
 grep "Average" cpu_${cpu_num}_stats.log
 echo ""
}

# Test each CPU core individually
NUM_CPUS=$(nproc)
echo "System has $NUM_CPUS logical CPUs"
echo ""

for ((i=0; i<NUM_CPUS && i<4; i++)); do
 test_cpu_affinity $i 10
done

echo "=== Load Distribution Summary ==="
for ((i=0; i<NUM_CPUS && i<4; i++)); do
 if [ -f "cpu_${i}_stats.log" ]; then
  echo -n "CPU $i: "
  awk '/Average/ {printf "%.1f%% utilized\n", $4+$6}' cpu_${i}_stats.log
 fi
done
