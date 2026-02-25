#!/bin/bash
echo "=== Advanced dmesg Filtering ==="
echo
echo "1. Recent Error Messages (Last 2 hours):"
dmesg --since="2 hours ago" -l err,crit,alert
echo
echo "2. Hardware-Related Warnings:"
dmesg -l warn | grep -i "hardware\|device\|driver"
echo
echo "3. Recent Boot Messages:"
dmesg | grep -i "boot\|init" | tail -10
echo
echo "4. USB Device Messages:"
dmesg | grep -i "usb" | tail -5
