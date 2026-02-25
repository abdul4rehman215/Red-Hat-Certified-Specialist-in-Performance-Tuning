#!/bin/bash
# Disk I/O Stress Test Script
TEST_DIR="/tmp/disk_test"
mkdir -p $TEST_DIR
echo "Starting disk I/O stress test..."

# Function for sequential write test
sequential_write_test() {
 local file_size=$1
 local block_size=$2

 echo "Sequential write test: ${file_size}MB with ${block_size} block size"
 dd if=/dev/zero of=${TEST_DIR}/seq_write_test bs=$block_size count=$((file_size*1024/block_size)) conv=fsync
}

# Function for random I/O test
random_io_test() {
 local duration=$1

 echo "Random I/O test for ${duration} seconds"
 timeout $duration dd if=/dev/urandom of=${TEST_DIR}/random_test bs=4k count=10000 oflag=direct &
 timeout $duration dd if=${TEST_DIR}/random_test of=/dev/null bs=4k iflag=direct &
 wait
}

# Phase 1: Sequential I/O patterns
echo "Phase 1: Sequential I/O tests"
sequential_write_test 100 1024
sequential_write_test 200 4096
sequential_write_test 500 8192

# Phase 2: Random I/O patterns
echo "Phase 2: Random I/O tests"
random_io_test 120
sleep 30
random_io_test 180

# Phase 3: Mixed workload
echo "Phase 3: Mixed I/O workload"
for i in {1..3}; do
 dd if=/dev/zero of=${TEST_DIR}/mixed_test_$i bs=1M count=100 &
 dd if=${TEST_DIR}/seq_write_test of=/dev/null bs=4k &
done
wait

# Cleanup
rm -rf $TEST_DIR
echo "Disk stress test completed"
