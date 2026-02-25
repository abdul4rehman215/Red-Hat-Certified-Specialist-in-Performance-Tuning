#!/bin/bash
echo "=== Hardware Configuration Comparison ==="
echo "Baseline created: $(cat baseline_info.txt)"
echo "Current date: $(date)"
echo ""
echo "Comparing current configuration with baseline..."

# Compare CPU
echo "--- CPU Comparison ---"
BASELINE_CPU=$(grep "Version" cpu_baseline.txt | head -1 | cut -d: -f2 | xargs)
CURRENT_CPU=$(sudo dmidecode --type 4 | grep "Version" | head -1 | cut -d: -f2 | xargs)
if [ "$BASELINE_CPU" = "$CURRENT_CPU" ]; then
  echo " CPU unchanged: $CURRENT_CPU"
else
  echo " CPU changed!"
  echo " Baseline: $BASELINE_CPU"
  echo " Current: $CURRENT_CPU"
fi

# Compare Memory
echo "--- Memory Comparison ---"
BASELINE_MEMORY=$(grep "Size:" memory_baseline.txt | grep -v "No Module Installed" | \
  awk '{sum += $2} END {print sum}')
CURRENT_MEMORY=$(sudo dmidecode --type 17 | grep "Size:" | grep -v "No Module Installed" | \
  awk '{sum += $2} END {print sum}')
if [ "$BASELINE_MEMORY" = "$CURRENT_MEMORY" ]; then
  echo " Memory unchanged: $CURRENT_MEMORY MB"
else
  echo " Memory changed!"
  echo " Baseline: $BASELINE_MEMORY MB"
  echo " Current: $CURRENT_MEMORY MB"
fi
