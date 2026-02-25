#!/bin/bash
echo "=== Memory Channel Configuration Analysis ==="

# Extract memory locator information to determine channel configuration
echo -e "\n--- Memory Slot Population ---"
sudo dmidecode --type 17 | grep -E "(Locator|Size)" | \
while read -r line; do
  if [[ $line == *"Locator:"* ]]; then
    LOCATOR=$line
  elif [[ $line == *"Size:"* ]] && [[ $line != *"No Module Installed"* ]]; then
    echo "$LOCATOR - $line"
  fi
done

# Analyze for dual/quad channel configuration
echo -e "\n--- Channel Configuration Analysis ---"
DIMM_PATTERN=$(sudo dmidecode --type 17 | grep "Locator:" | grep -v "Bank" | awk '{print $2}' | sort)
echo "Memory slot pattern:"
echo "$DIMM_PATTERN"

# Check for optimal memory configuration
POPULATED_DIMMS=$(sudo dmidecode --type 17 | grep "Size:" | grep -v "No Module Installed" | wc -l)
if [ $((POPULATED_DIMMS % 2)) -eq 0 ]; then
  echo "INFO: Even number of memory modules - good for dual channel"
else
  echo "WARNING: Odd number of memory modules - may not utilize dual channel optimally"
fi
