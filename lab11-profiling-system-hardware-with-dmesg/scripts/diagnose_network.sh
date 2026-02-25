#!/bin/bash
echo "=== Network Diagnostics ==="
echo
echo "1. Network interface status:"
dmesg | grep -E "eth[0-9]|enp|ens" | grep -i "up\|down\|link" | tail -10
echo
echo "2. Network driver issues:"
dmesg | grep -i "network.*error\|driver.*fail" | grep -i "net" | tail -5
echo
echo "3. Link status changes:"
dmesg | grep -i "link.*up\|link.*down\|carrier" | tail -10
echo
echo "4. Network hardware detection:"
dmesg | grep -i "network.*detect\|ethernet.*found" | tail -5
