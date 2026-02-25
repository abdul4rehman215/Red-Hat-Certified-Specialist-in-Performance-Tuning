#!/bin/bash
REPORT_FILE="hardware_profile_$(date +%Y%m%d_%H%M%S).txt"
echo "Generating comprehensive hardware profile report..."
echo "Report will be saved to: $REPORT_FILE"
{
 echo "========================================="
 echo " COMPREHENSIVE HARDWARE PROFILE"
 echo "========================================="
 echo "Generated on: $(date)"
 echo "Hostname: $(hostname)"
 echo "Kernel: $(uname -r)"
 echo "Architecture: $(uname -m)"
 echo
 echo "--- CPU INFORMATION ---"
 dmesg | grep -i "cpu" | grep -E "detect|found|MHz|cache" | head -10
 echo
 echo "--- MEMORY INFORMATION ---"
 dmesg | grep -i "memory" | grep -E "detect|available|usable" | head -10
 echo
 echo "--- STORAGE DEVICES ---"
 dmesg | grep -E "sd[a-z]|nvme|ata.*dev" | head -15
 echo
 echo "--- NETWORK INTERFACES ---"
 dmesg | grep -E "eth[0-9]|enp|ens.*up" | head -10
 echo
 echo "--- USB DEVICES ---"
 dmesg | grep -i "usb.*new\|usb.*connect" | head -10
 echo
 echo "--- PCI DEVICES ---"
 dmesg | grep -i "pci" | grep -E "found|detect" | head -10
 echo
 echo "--- GRAPHICS/VIDEO ---"
 dmesg | grep -i "video\|graphics\|drm\|fb" | head -10
 echo
 echo "--- AUDIO DEVICES ---"
 dmesg | grep -i "audio\|sound\|alsa" | head -5
 echo
 echo "--- POWER MANAGEMENT ---"
 dmesg | grep -i "acpi\|power\|battery" | head -10
 echo
 echo "--- RECENT ERRORS/WARNINGS ---"
 dmesg -l err,warn --since="24 hours ago" | tail -20
 echo
 echo "--- SYSTEM HEALTH SUMMARY ---"
 echo "Boot messages: $(dmesg | grep -i boot | wc -l)"
 echo "Error messages: $(dmesg -l err | wc -l)"
 echo "Warning messages: $(dmesg -l warn | wc -l)"
 echo "Hardware-related messages: $(dmesg | grep -i hardware | wc -l)"
 echo
 echo "========================================="
 echo " END OF HARDWARE PROFILE"
 echo "========================================="
} > "$REPORT_FILE"
echo "Hardware profile report generated: $REPORT_FILE"
echo "You can view it with: cat $REPORT_FILE"
