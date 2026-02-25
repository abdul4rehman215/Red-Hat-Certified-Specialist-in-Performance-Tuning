#!/bin/bash
DURATION=${1:-30}
INTERVAL=${2:-2}
echo "=== Multi-Core CPU Analysis ==="
echo "Monitoring for $DURATION seconds with $INTERVAL second intervals"
echo "Start time: $(date)"
echo ""

# Start background monitoring
mpstat -P ALL $INTERVAL $((DURATION/INTERVAL)) > cpu_stats.log &
MPSTAT_PID=$!

# Generate different types of load
echo "Generating single-core load..."
stress --cpu 1 --timeout 10s &
sleep 12

echo "Generating multi-core load..."
stress --cpu $(nproc) --timeout 10s &
sleep 12

echo "Generating I/O intensive load..."
stress --io 2 --timeout 8s &

# Wait for monitoring to complete
wait $MPSTAT_PID

echo ""
echo "=== Analysis Results ==="
echo "Average CPU utilization per core:"
grep "Average" cpu_stats.log
echo ""
echo "Peak utilization periods:"
awk '/^[0-9]/ && $3 != "CPU" && $4+$5+$6 > 50 {print $1, $2, "CPU"$3, "Total:", $4+$5+$6"%"}' cpu_stats.log | head -10
