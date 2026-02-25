#!/bin/bash
echo "=== CPU GOVERNOR CONFIGURATION ==="

# Check if running on battery or AC power (for laptops)
if [ -f /sys/class/power_supply/ADP1/online ]; then
  POWER_SOURCE=$(cat /sys/class/power_supply/ADP1/online)
  if [ $POWER_SOURCE -eq 1 ]; then
    echo "AC Power detected - Setting performance governor"
    sudo cpupower frequency-set -g performance
  else
    echo "Battery power detected - Setting powersave governor"
    sudo cpupower frequency-set -g powersave
  fi
else
  echo "Server/Desktop system - Setting performance governor"
  sudo cpupower frequency-set -g performance
fi

echo "Current CPU governor:"
cpupower frequency-info | grep "current policy"
