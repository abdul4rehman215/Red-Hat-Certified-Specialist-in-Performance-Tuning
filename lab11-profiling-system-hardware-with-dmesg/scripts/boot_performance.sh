#!/bin/bash
echo "=== Boot Performance Analysis ==="
echo
echo "1. Boot Process Timeline:"
dmesg -T | grep -i "boot\|init\|start" | head -10
echo
echo "2. Device Initialization Delays:"
dmesg | grep -i "slow\|delay\|wait\|timeout" | head -10
echo
echo "3. Driver Loading Time:"
dmesg | grep -i "driver.*load\|module.*load" | head -10
echo
echo "4. Hardware Detection Time:"
dmesg | grep -i "detect\|found\|discover" | head -10
echo
echo "5. System Ready Indicators:"
dmesg | grep -i "ready\|online\|active" | head -10
