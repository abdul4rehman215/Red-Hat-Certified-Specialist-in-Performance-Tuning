#!/bin/bash
echo "Performance Impact Test"
echo "======================"
# Function to run CPU benchmark
cpu_benchmark() {
 local nice_value=$1
 local label=$2

 echo "Running $label test (nice: $nice_value)..."

 start_time=$(date +%s.%N)
 nice -n $nice_value bash -c 'for i in {1..1000000}; do echo "scale=100; 4*a(1)" | bc -l > /dev/null 2>&1; done'
 end_time=$(date +%s.%N)

 duration=$(echo "$end_time - $start_time" | bc)
 echo "$label completed in: $duration seconds"
 echo ""
}
# Run benchmarks with different priorities
cpu_benchmark 0 "Normal Priority"
cpu_benchmark 10 "Low Priority"
cpu_benchmark -10 "High Priority" 2>/dev/null || echo "High priority test requires root privileges"
echo "Performance test completed."
