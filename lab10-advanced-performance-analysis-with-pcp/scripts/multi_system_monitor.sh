#!/bin/bash
# Multi-system PCP monitoring script (pcp-monitor + target-1 + target-2)

DURATION=60
INTERVAL=5
HOSTS=("localhost" "target-1" "target-2")

echo "Starting multi-system performance monitoring..."
echo "Duration: $DURATION seconds, Interval: $INTERVAL seconds"
echo "=========================================="

for host in "${HOSTS[@]}"; do
 echo "Monitoring $host..."

 echo "CPU Usage on $host:"
 # Collect a few samples for user/sys/idle
 pmval -h "$host" -s 3 -t "$INTERVAL" kernel.all.cpu.user kernel.all.cpu.sys kernel.all.cpu.idle 2>/dev/null | \
  awk 'NF>0 {print}' | head -20

 echo "Memory Usage on $host:"
 pmval -h "$host" -s 1 -t "$INTERVAL" mem.util.used mem.util.free 2>/dev/null | \
  awk 'NF>0 {print}' | head -20

 echo "Load Average on $host:"
 pmval -h "$host" -s 1 -t "$INTERVAL" kernel.all.load 2>/dev/null | \
  awk 'NF>0 {print}' | head -20

 echo "----------------------------------------"
done
