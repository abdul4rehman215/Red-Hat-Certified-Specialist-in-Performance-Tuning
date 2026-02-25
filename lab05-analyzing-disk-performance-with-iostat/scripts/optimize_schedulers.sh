#!/bin/bash
# I/O Scheduler Optimization Script
echo "I/O Scheduler Optimization Tool"
echo "==============================="
# Function to detect storage type
detect_storage_type() {
 local device=$1
 if [ -f "/sys/block/$device/queue/rotational" ]; then
 if [ "$(cat /sys/block/$device/queue/rotational)" = "0" ]; then
 echo "SSD"
 else
 echo "HDD"
 fi
 else
 echo "UNKNOWN"
 fi
}
# Function to recommend scheduler
recommend_scheduler() {
 local device=$1
 local storage_type=$(detect_storage_type $device)

 case $storage_type in
 "SSD")
 echo "kyber"
 ;;
 "HDD")
 echo "mq-deadline"
 ;;
 *)
 echo "mq-deadline"
 ;;
 esac
}
# Function to apply optimization
apply_optimization() {
 local device=$1
 local scheduler=$2

 echo "Applying optimization to $device..."
 echo "Current scheduler: $(cat /sys/block/$device/queue/scheduler | grep -o '\[.*\]' | tr -d '[]')"
 echo "Recommended scheduler: $scheduler"

 # Apply scheduler
 echo $scheduler > /sys/block/$device/queue/scheduler

 # Verify change
 if [ "$(cat /sys/block/$device/queue/scheduler | grep -o '\[.*\]' | tr -d '[]')" = "$scheduler" ]; then
 echo "✓ Successfully applied $scheduler to $device"

 # Apply additional optimizations based on scheduler
 case $scheduler in
 "kyber")
 # Optimize for latency
 echo 2 > /sys/block/$device/queue/kyber/read_lat_nsec 2>/dev/null || true
 echo 10 > /sys/block/$device/queue/kyber/write_lat_nsec 2>/dev/null || true
 ;;
 "mq-deadline")
 # Optimize queue depth
 echo 32 > /sys/block/$device/queue/nr_requests 2>/dev/null || true
 ;;
 esac
 else
 echo "✗ Failed to apply $scheduler to $device"
 fi
}
# Main optimization logic
echo "Scanning block devices..."
for device_path in /sys/block/*; do
 device=$(basename $device_path)

 # Skip loop devices and other virtual devices
 if [[ $device =~ ^(loop|ram|dm-) ]]; then
 continue
 fi

 storage_type=$(detect_storage_type $device)
 recommended=$(recommend_scheduler $device)

 echo ""
 echo "Device: $device"
 echo "Type: $storage_type"
 echo "Recommended scheduler: $recommended"

 read -p "Apply optimization to $device? (y/n): " -n 1 -r
 echo
 if [[ $REPLY =~ ^[Yy]$ ]]; then
 apply_optimization $device $recommended
 fi
done
echo ""
echo "Optimization completed!"
echo "Current scheduler configuration:"
./check_schedulers.sh
