#!/bin/bash
# Check I/O Schedulers for All Block Devices
echo "Current I/O Schedulers:"
echo "======================"
for device in /sys/block/*/queue/scheduler; do
 device_name=$(echo $device | cut -d'/' -f4)
 if [[ $device_name =~ ^[a-z]+$ ]]; then
 echo -n "$device_name: "
 cat $device
 fi
done
echo ""
echo "Available schedulers are shown in brackets []"
echo "Current scheduler is shown in square brackets [current]"
