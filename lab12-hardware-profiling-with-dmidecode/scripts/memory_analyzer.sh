#!/bin/bash
echo "=== Memory Performance Analysis Report ==="
echo "Generated on: $(date)"
echo "==========================================="

# Memory array information
echo -e "\n--- Memory Array Configuration ---"
sudo dmidecode --type 16 | grep -E "(Location|Use|Maximum Capacity|Number Of Devices)"

# Individual memory module analysis
echo -e "\n--- Installed Memory Modules ---"
MEMORY_SLOTS=$(sudo dmidecode --type 17 | grep "Size:" | wc -l)
echo "Total memory slots: $MEMORY_SLOTS"

POPULATED_SLOTS=$(sudo dmidecode --type 17 | grep "Size:" | grep -v "No Module Installed" | wc -l)
echo "Populated slots: $POPULATED_SLOTS"

echo -e "\n--- Memory Module Details ---"
sudo dmidecode --type 17 | grep -E "(Locator|Size|Speed|Type:|Manufacturer|Part Number)" | \
while read line; do
  if [[ $line == *"Locator:"* ]]; then
    echo -e "\n$line"
  else
    echo " $line"
  fi
done

# Memory performance analysis
echo -e "\n--- Memory Performance Analysis ---"

# Check for memory speed consistency
SPEEDS=$(sudo dmidecode --type 17 | grep "Speed:" | grep -v "Unknown" | awk '{print $2}' | sort -u)
SPEED_COUNT=$(echo "$SPEEDS" | wc -l)

if [ $SPEED_COUNT -gt 1 ]; then
  echo "WARNING: Mixed memory speeds detected"
  echo "Speeds found: $(echo $SPEEDS | tr '\n' ' ')"
  echo "Recommendation: Use identical speed modules for optimal performance"
else
  echo "INFO: Consistent memory speed across all modules"
fi

# Check for ECC support
ECC_SUPPORT=$(sudo dmidecode --type 17 | grep "Type Detail" | grep -i ecc | wc -l)
if [ $ECC_SUPPORT -gt 0 ]; then
  echo "INFO: ECC memory detected - enhanced reliability"
else
  echo "INFO: Non-ECC memory in use"
fi

# Calculate total installed memory
TOTAL_MEMORY=$(sudo dmidecode --type 17 | grep "Size:" | grep -v "No Module Installed" | \
  awk '{sum += $2} END {print sum}')
echo "Total installed memory: ${TOTAL_MEMORY} MB"

# Memory upgrade recommendations
MAX_CAPACITY=$(sudo dmidecode --type 16 | grep "Maximum Capacity" | awk '{print $3 $4}')
echo "Maximum supported memory: $MAX_CAPACITY"

EMPTY_SLOTS=$((MEMORY_SLOTS - POPULATED_SLOTS))
if [ $EMPTY_SLOTS -gt 0 ]; then
  echo "Available expansion slots: $EMPTY_SLOTS"
  echo "Recommendation: Consider memory upgrade for better performance"
fi
