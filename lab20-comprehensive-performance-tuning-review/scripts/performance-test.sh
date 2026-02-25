#!/bin/bash
TEST_DURATION=300 # 5 minutes
RESULTS_DIR="/opt/performance-review/test-results"
mkdir -p $RESULTS_DIR

echo "=== Performance Testing Framework ==="
echo "Test duration: ${TEST_DURATION} seconds"

run_performance_test() {
 local test_name=$1
 local timestamp=$(date +%Y%m%d_%H%M%S)

 echo "Starting $test_name test at $(date)"

 sar -u -r 5 $((TEST_DURATION/5)) > ${RESULTS_DIR}/${test_name}-sar-${timestamp}.txt &
 iostat -x 5 $((TEST_DURATION/5)) > ${RESULTS_DIR}/${test_name}-iostat-${timestamp}.txt &

 stress-ng --cpu $(nproc) --timeout ${TEST_DURATION}s &
 stress-ng --vm 2 --vm-bytes 256M --timeout ${TEST_DURATION}s &
 stress-ng --hdd 1 --hdd-bytes 1G --timeout ${TEST_DURATION}s &

 wait

 echo "$test_name test completed at $(date)"
}

echo "Running baseline performance test..."
run_performance_test "baseline"
echo "Performance testing completed."
echo "Results saved in: $RESULTS_DIR"
