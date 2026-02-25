#!/bin/bash
BENCHMARK_DIR="/tmp/power_benchmark"
mkdir -p "$BENCHMARK_DIR"
echo "=== Power Consumption Benchmark ==="

# Function to run power test
run_power_test() {
 local test_name="$1"
 local duration="$2"

 echo "Running $test_name test for $duration seconds..."

 # Start background monitoring
 (
  while true; do
   echo "$(date +%s),$(cat /proc/loadavg | cut -d' ' -f1)" >> "$BENCHMARK_DIR/${test_name}_load.csv"
   sleep 1
  done
 ) &
 monitor_pid=$!

 # Run powertop measurement
 sudo powertop --csv="$BENCHMARK_DIR/${test_name}_power.csv" --time="$duration" >/dev/null 2>&1

 # Stop monitoring
 kill $monitor_pid 2>/dev/null

 echo "$test_name test completed"
}

# Baseline test (system idle)
echo "Starting baseline measurement..."
run_power_test "baseline" 30

# Stress test
echo "Starting stress test..."
# Install stress tool if not available
if ! command -v stress >/dev/null 2>&1; then
 sudo dnf install -y stress
fi

stress --cpu 2 --timeout 30s &
run_power_test "stress" 30
wait

# Generate comparison report
echo
echo "=== Benchmark Results ==="
echo "Baseline power data saved to: $BENCHMARK_DIR/baseline_power.csv"
echo "Stress test power data saved to: $BENCHMARK_DIR/stress_power.csv"

# Simple analysis
if [ -f "$BENCHMARK_DIR/baseline_power.csv" ] && [ -f "$BENCHMARK_DIR/stress_power.csv" ]; then
 echo
 echo "Analysis complete. Check CSV files for detailed power consumption data."
fi
