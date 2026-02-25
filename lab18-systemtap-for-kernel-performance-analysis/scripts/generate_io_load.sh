#!/bin/bash
echo "Generating I/O load for testing..."
# Create multiple processes doing I/O
for i in {1..5}; do
 (
 echo "Starting I/O worker $i"
 # Generate random I/O
 dd if=/dev/urandom of=/tmp/iotest_$i bs=1M count=50 2>/dev/null &

 # Simulate database-like random access
 for j in {1..100}; do
 dd if=/tmp/iotest_$i of=/dev/null bs=4k skip=$((RANDOM % 1000)) count=1 2>/dev/null
 sleep 0.1
 done

 rm -f /tmp/iotest_$i
 ) &
done
# Generate file system stress
find /usr -type f -name "*.so" | head -50 | xargs -I {} cp {} /tmp/ 2>/dev/null &
# Wait for all background jobs
wait
echo "I/O load generation completed"
