#!/bin/bash
# I/O Scheduler Performance Testing Script
if [ $# -ne 1 ]; then
 echo "Usage: $0 <device_name>"
 echo "Example: $0 sda"
 exit 1
fi
DEVICE=$1
TEST_DIR="scheduler_test_$(date +%Y%m%d_%H%M%S)"
mkdir -p $TEST_DIR
# Get available schedulers
SCHEDULERS=$(cat /sys/block/$DEVICE/queue/scheduler | tr -d '[]' | tr ' ' '\n' | grep -v '^$')
echo "Testing I/O schedulers for device: $DEVICE"
echo "Available schedulers: $(echo $SCHEDULERS | tr '\n' ' ')"
echo "Results will be saved in: $TEST_DIR"
# Function to run performance test
run_test() {
 local scheduler=$1
 echo "Testing scheduler: $scheduler"

 # Set scheduler
 echo $scheduler > /sys/block/$DEVICE/queue/scheduler

 # Wait for scheduler change to take effect
 sleep 2

 # Start iostat monitoring
 iostat -x 2 30 > $TEST_DIR/${scheduler}_iostat.log &
 IOSTAT_PID=$!

 # Run test workload
 echo "Running test workload for $scheduler..."
 ./io_workload_generator.sh mixed > $TEST_DIR/${scheduler}_workload.log 2>&1

 # Stop iostat
 kill $IOSTAT_PID 2>/dev/null

 # Extract key metrics
 echo "Scheduler: $scheduler" > $TEST_DIR/${scheduler}_summary.txt
 echo "Average utilization: $(awk '/^[a-z]/ {sum+=$NF; count++} END {if(count>0) print sum/count "%"}' \
$TEST_DIR/${scheduler}_iostat.log)" >> $TEST_DIR/${scheduler}_summary.txt
 echo "Average await: $(awk '/^[a-z]/ {sum+=$(NF-1); count++} END {if(count>0) print sum/count "ms"}' \
$TEST_DIR/${scheduler}_iostat.log)" >> $TEST_DIR/${scheduler}_summary.txt

 echo "Test completed for $scheduler"
 sleep 5
}
# Test each scheduler
for scheduler in $SCHEDULERS; do
 run_test $scheduler
done
# Generate comparison report
echo "Generating comparison report..."
cat > $TEST_DIR/comparison_report.txt << 'REPORT_EOF'
I/O SCHEDULER PERFORMANCE COMPARISON
====================================
Test Configuration:
- Device tested: DEVICE_PLACEHOLDER
- Test duration: 60 seconds per scheduler
- Workload: Mixed read/write operations
Results Summary:
REPORT_EOF
# Add results to report
for scheduler in $SCHEDULERS; do
 if [ -f "$TEST_DIR/${scheduler}_summary.txt" ]; then
 echo "" >> $TEST_DIR/comparison_report.txt
 cat $TEST_DIR/${scheduler}_summary.txt >> $TEST_DIR/comparison_report.txt
 fi
done
# Replace placeholder
sed -i "s/DEVICE_PLACEHOLDER/$DEVICE/g" $TEST_DIR/comparison_report.txt
echo ""
echo "Performance testing completed!"
echo "Results directory: $TEST_DIR"
echo ""
echo "Comparison Report:"
echo "=================="
cat $TEST_DIR/comparison_report.txt
