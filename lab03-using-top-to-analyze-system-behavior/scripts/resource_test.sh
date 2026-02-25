#!/bin/bash
# Function to create CPU load
cpu_hog() {
 echo "Starting CPU intensive task..."
 while true; do
 echo "scale=5000; 4*a(1)" | bc -l > /dev/null 2>&1
 done
}
# Function to create memory load
memory_hog() {
 echo "Starting memory intensive task..."
 python3 -c "
import time
data = []
for i in range(1000000):
 data.append('x' * 1000)
 if i % 10000 == 0:
 print(f'Allocated {i * 1000} bytes')
time.sleep(300)
"
}
# Function to create I/O load
io_hog() {
 echo "Starting I/O intensive task..."
 dd if=/dev/zero of=/tmp/testfile bs=1M count=1000 2>/dev/null
 for i in {1..100}; do
 cat /tmp/testfile > /dev/null
 done
 rm -f /tmp/testfile
}
case $1 in
 cpu) cpu_hog ;;
 memory) memory_hog ;;
 io) io_hog ;;
 *) echo "Usage: $0 {cpu|memory|io}" ;;
esac
