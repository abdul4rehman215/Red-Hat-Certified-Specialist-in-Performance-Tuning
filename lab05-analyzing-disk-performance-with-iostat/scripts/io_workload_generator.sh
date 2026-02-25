#!/bin/bash
# I/O Workload Generator for Testing
TESTDIR="/tmp/iostest"
mkdir -p $TESTDIR
echo "Generating I/O workload patterns..."
# Function to generate random read workload
generate_read_load() {
 echo "Starting random read workload..."
 dd if=/dev/urandom of=$TESTDIR/testfile bs=1M count=1000 2>/dev/null

 for i in {1..100}; do
 dd if=$TESTDIR/testfile of=/dev/null bs=4k skip=$((RANDOM % 250000)) count=1 2>/dev/null &
 done
}
# Function to generate sequential write workload
generate_write_load() {
 echo "Starting sequential write workload..."
 for i in {1..50}; do
 dd if=/dev/zero of=$TESTDIR/writefile_$i bs=1M count=100 2>/dev/null &
 done
}
# Function to generate mixed workload
generate_mixed_load() {
 echo "Starting mixed I/O workload..."
 generate_read_load &
 generate_write_load &
}
case "$1" in
 "read")
 generate_read_load
 ;;
 "write")
 generate_write_load
 ;;
 "mixed")
 generate_mixed_load
 ;;
 *)
 echo "Usage: $0 {read|write|mixed}"
 exit 1
 ;;
esac
echo "Workload generation started. Monitor with iostat in another terminal."
wait
echo "Workload generation completed."
# Cleanup
rm -rf $TESTDIR
