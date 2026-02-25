#!/bin/bash
# Comparative snapshot across systems (single quick sample)

HOSTS=("localhost" "target-1" "target-2")

echo "Comparative Performance Analysis"
echo "==============================="
echo

print_metric() {
 local metric="$1"
 echo "Metric: $metric"
 echo "=================================================="
 for host in "${HOSTS[@]}"; do
  val=$(pmval -h "$host" -s 1 -t 1 "$metric" 2>/dev/null | tail -1 | sed 's/^[[:space:]]*//')
  printf "%-12s: %s\n" "$host" "${val:-N/A}"
 done
 echo
}

print_metric "kernel.all.cpu.user"
print_metric "mem.util.used"
print_metric "kernel.all.load"

echo "Analysis complete!"
