#!/bin/bash
echo "=== CPU Performance Analysis Report ==="
echo "Generated on: $(date)"
echo "========================================="

# Extract CPU model and specifications
echo -e "\n--- CPU Model Information ---"
sudo dmidecode --type processor | grep -E "(Family|Model|Stepping|Signature)"

echo -e "\n--- CPU Speed and Cache Information ---"
sudo dmidecode --type processor | grep -E "(Current Speed|Max Speed|L1|L2|L3)"

echo -e "\n--- CPU Core and Thread Information ---"
sudo dmidecode --type processor | grep -E "(Core Count|Thread Count|Core Enabled|Thread Enabled)"

echo -e "\n--- CPU Capabilities and Features ---"
sudo dmidecode --type processor | grep -A 20 "Characteristics:"

echo -e "\n--- CPU Socket and Upgrade Information ---"
sudo dmidecode --type processor | grep -E "(Socket|Upgrade|Status)"

# Performance recommendations
echo -e "\n--- Performance Analysis ---"
CURRENT_SPEED=$(sudo dmidecode --type processor | grep "Current Speed" | head -1 | awk '{print $3}')
MAX_SPEED=$(sudo dmidecode --type processor | grep "Max Speed" | head -1 | awk '{print $3}')

if [ "$CURRENT_SPEED" != "$MAX_SPEED" ]; then
  echo "WARNING: CPU not running at maximum speed"
  echo "Current: $CURRENT_SPEED, Maximum: $MAX_SPEED"
  echo "Recommendation: Check power management settings"
fi

CORE_COUNT=$(sudo dmidecode --type processor | grep "Core Count" | head -1 | awk '{print $3}')
THREAD_COUNT=$(sudo dmidecode --type processor | grep "Thread Count" | head -1 | awk '{print $3}')

if [ "$THREAD_COUNT" -gt "$CORE_COUNT" ]; then
  echo "INFO: Hyperthreading is enabled"
  echo "Cores: $CORE_COUNT, Threads: $THREAD_COUNT"
fi
