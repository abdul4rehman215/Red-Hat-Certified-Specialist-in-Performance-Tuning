#!/bin/bash
echo "=== Network Hardware Detection Analysis ==="
echo
echo "1. Network Interface Detection:"
dmesg | grep -E "eth[0-9]|enp|ens" | head -10
echo
echo "2. Network Driver Loading:"
dmesg | grep -i "driver.*net\|net.*driver"
echo
echo "3. Link Status Messages:"
dmesg | grep -i "link.*up\|link.*down"
echo
echo "4. Network Errors/Warnings:"
dmesg | grep -i "network.*error\|net.*fail\|link.*fail"
