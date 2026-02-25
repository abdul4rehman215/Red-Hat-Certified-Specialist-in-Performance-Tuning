#!/bin/bash
echo "========================================="
echo " HARDWARE HEALTH CHECK REPORT"
echo "========================================="
echo "Generated on: $(date)"
echo

# Function to check for issues
check_issues() {
 local category=$1
 local pattern=$2
 local description=$3

 echo "--- $description ---"
 local count=$(dmesg | grep -i "$pattern" | wc -l)
 if [ $count -gt 0 ]; then
  echo " Found $count $category issues:"
  dmesg | grep -i "$pattern" | tail -5
 else
  echo " No $category issues found"
 fi
 echo
}

# Check various hardware issues
check_issues "I/O" "i/o error\|input/output error" "I/O Errors"
check_issues "Timeout" "timeout\|timed out" "Device Timeouts"
check_issues "Hardware" "hardware error\|hardware failure" "Hardware Failures"
check_issues "Thermal" "thermal\|temperature\|overheat" "Thermal Issues"
check_issues "Memory" "memory error\|memory fail\|bad page" "Memory Errors"
check_issues "Disk" "disk error\|ata.*error\|scsi.*error" "Disk Errors"
check_issues "Network" "network error\|link fail\|carrier lost" "Network Issues"

echo "--- System Stability Indicators ---"
echo "System uptime: $(uptime -p)"
echo "Load average: $(uptime | awk -F'load average:' '{print $2}')"
echo

echo "--- Recent Critical Messages ---"
dmesg -l crit,alert,emerg --since="24 hours ago" | tail -10
if [ $? -ne 0 ] || [ $(dmesg -l crit,alert,emerg --since="24 hours ago" | wc -l) -eq 0 ]; then
 echo " No critical messages in the last 24 hours"
fi
echo

echo "========================================="
echo " END OF HARDWARE HEALTH CHECK"
echo "========================================="
