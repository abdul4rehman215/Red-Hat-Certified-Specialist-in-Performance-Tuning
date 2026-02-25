#!/bin/bash
echo "=== Memory Pressure Test ==="
echo "Initial memory state:"
free -h
echo ""

echo "Creating memory pressure..."
# Create a process that consumes memory
stress --vm 1 --vm-bytes 512M --timeout 30s &
STRESS_PID=$!

# Monitor memory usage during stress
for i in {1..10}; do
  echo "Time: ${i}0s"
  free -h | grep -E "(Mem:|Swap:)"
  echo "Swappiness: $(cat /proc/sys/vm/swappiness)"
  echo "---"
  sleep 3
done

# Wait for stress test to complete
wait $STRESS_PID
echo "Memory pressure test completed"
