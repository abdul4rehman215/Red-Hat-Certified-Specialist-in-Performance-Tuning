#!/bin/bash
echo "=== Simulating Performance Issues ==="

echo "1. Simulating excessive file I/O..."
mkdir -p /tmp/io_test
for i in {1..200}; do
 echo "data" > /tmp/io_test/file_$i.txt
 cat /tmp/io_test/file_$i.txt > /dev/null
 rm /tmp/io_test/file_$i.txt
done
rmdir /tmp/io_test

echo "2. Simulating DNS resolution issues..."
for i in {1..5}; do
 nslookup nonexistent$i.invalid.domain.com 2>/dev/null || true
done

echo "3. Simulating rapid process creation..."
for i in {1..20}; do
 /bin/true &
done
wait

echo "4. Simulating system call intensive operations..."
find /proc -type f -name "stat" -exec cat {} \; 2>/dev/null | head -1000 > /dev/null

echo "Performance issue simulation completed"
