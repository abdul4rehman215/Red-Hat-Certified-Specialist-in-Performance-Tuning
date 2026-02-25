#!/bin/bash
echo "Starting test workload..."
# File operations
for i in {1..100}; do
 echo "Test data $i" > /tmp/test_file_$i.txt
 cat /tmp/test_file_$i.txt > /dev/null
 rm /tmp/test_file_$i.txt
done
# Network operations
ping -c 5 8.8.8.8 > /dev/null 2>&1
# Process operations
ps aux > /dev/null
ls -la /proc/ > /dev/null
echo "Test workload completed"
