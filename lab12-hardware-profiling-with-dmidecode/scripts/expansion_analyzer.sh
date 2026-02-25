#!/bin/bash
echo "=== Hardware Expansion Analysis ==="

# Check for available slots and ports
echo -e "\n--- System Slots Information ---"
sudo dmidecode --type 9 | grep -E "(Designation|Type|Current Usage|Length)"

# Check for onboard devices
echo -e "\n--- Onboard Devices ---"
sudo dmidecode --type 10,41 | grep -E "(Description|Type|Status)"

# Port connector information
echo -e "\n--- Port Connectors ---"
sudo dmidecode --type 8 | grep -E "(Internal Reference|External Reference|Port Type)"

# System configuration options
echo -e "\n--- System Configuration Options ---"
sudo dmidecode --type 12 | grep -E "(Option)"
