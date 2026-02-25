#!/bin/bash
echo "=== Kernel Parameter Tuning Validation ==="
echo "Timestamp: $(date)"
echo
PASS=0
FAIL=0
# Function to check parameter
check_param() {
 local param=$1
 local expected=$2
 local current=$(sysctl -n $param 2>/dev/null)

 if [ "$current" = "$expected" ]; then
 echo "✓ $param: $current (Expected: $expected)"
 ((PASS++))
 else
 echo "✗ $param: $current (Expected: $expected)"
 ((FAIL++))
 fi
}
echo "Network Parameters:"
check_param "net.core.rmem_max" "16777216"
check_param "net.core.wmem_max" "16777216"
check_param "net.core.netdev_max_backlog" "5000"
echo
echo "Virtual Memory Parameters:"
check_param "vm.dirty_ratio" "10"
check_param "vm.swappiness" "10"
echo
echo "Storage Settings:"
SCHEDULER=$(cat /sys/block/sda/queue/scheduler 2>/dev/null | grep -o '\[.*\]' | tr -d '[]')
if [ "$SCHEDULER" = "deadline" ] || [ "$SCHEDULER" = "mq-deadline" ]; then
 echo "✓ I/O Scheduler: $SCHEDULER"
 ((PASS++))
else
 echo "✗ I/O Scheduler: $SCHEDULER (Expected: deadline or mq-deadline)"
 ((FAIL++))
fi
echo
echo "=== Validation Summary ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"
if [ $FAIL -eq 0 ]; then
 echo "All kernel parameter tuning validated successfully!"
 exit 0
else
 echo "Some parameters need attention."
 exit 1
fi
