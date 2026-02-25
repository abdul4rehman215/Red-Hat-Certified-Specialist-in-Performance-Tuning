#!/bin/bash
echo "=== System and Motherboard Analysis Report ==="
echo "Generated on: $(date)"
echo "==============================================="

echo -e "\n--- System Information ---"
sudo dmidecode --type 1 | grep -E "(Manufacturer|Product Name|Version|Serial Number|UUID)"

echo -e "\n--- Motherboard Information ---"
sudo dmidecode --type 2 | grep -E "(Manufacturer|Product Name|Version|Serial Number)"

echo -e "\n--- BIOS Information ---"
sudo dmidecode --type 0 | grep -E "(Vendor|Version|Release Date|BIOS Revision)"

echo -e "\n--- System Enclosure Information ---"
sudo dmidecode --type 3 | grep -E "(Manufacturer|Type|Version|Serial Number)"

# Check for system capabilities
echo -e "\n--- System Capabilities Analysis ---"

# Check for UEFI vs Legacy BIOS
UEFI_CHECK=$(sudo dmidecode --type 0 | grep -i "uefi" | wc -l)
if [ $UEFI_CHECK -gt 0 ]; then
  echo "INFO: UEFI firmware detected"
else
  echo "INFO: Legacy BIOS detected"
fi

# Check BIOS date for updates
BIOS_DATE=$(sudo dmidecode --type 0 | grep "Release Date" | awk '{print $3}')
echo "BIOS Release Date: $BIOS_DATE"

# Convert date and check if older than 2 years
if command -v date >/dev/null 2>&1; then
  BIOS_EPOCH=$(date -d "$BIOS_DATE" +%s 2>/dev/null)
  CURRENT_EPOCH=$(date +%s)
  TWO_YEARS_AGO=$((CURRENT_EPOCH - 63072000))

  if [ "$BIOS_EPOCH" -lt "$TWO_YEARS_AGO" ] 2>/dev/null; then
    echo "WARNING: BIOS is older than 2 years - consider updating"
  else
    echo "INFO: BIOS is relatively recent"
  fi
fi
