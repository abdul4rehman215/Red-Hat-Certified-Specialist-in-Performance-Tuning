#!/bin/bash
echo "=== Storage Performance Test ==="
TEST_DIR="/tmp/storage_test"
mkdir -p $TEST_DIR
echo "Testing random read performance..."
fio --name=random_read --ioengine=libaio --rw=randread --bs=4k --numjobs=4 \
 --size=100M --runtime=30 --directory=$TEST_DIR --group_reporting
echo "Testing random write performance..."
fio --name=random_write --ioengine=libaio --rw=randwrite --bs=4k --numjobs=4 \
 --size=100M --runtime=30 --directory=$TEST_DIR --group_reporting
echo "Testing sequential read performance..."
fio --name=seq_read --ioengine=libaio --rw=read --bs=64k --numjobs=1 \
 --size=500M --runtime=30 --directory=$TEST_DIR --group_reporting
echo "Testing sequential write performance..."
fio --name=seq_write --ioengine=libaio --rw=write --bs=64k --numjobs=1 \
 --size=500M --runtime=30 --directory=$TEST_DIR --group_reporting
# Cleanup
rm -rf $TEST_DIR
echo "Storage test completed."
