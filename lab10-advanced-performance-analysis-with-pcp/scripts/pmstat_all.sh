#!/bin/bash
# Run pmstat on multiple hosts (sequential)

HOSTS=("localhost" "target-1" "target-2")

for host in "${HOSTS[@]}"; do
 echo "=== System Statistics for $host ==="
 pmstat -h "$host" -t 2 -s 3 2>/dev/null
 echo ""
done
