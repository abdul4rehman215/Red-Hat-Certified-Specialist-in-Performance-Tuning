#!/bin/bash
echo "Starting I/O intensive test..."
# Create large files to generate I/O load
for i in {1..5}; do
 echo "Creating I/O load $i..."
 (
 # Write large file
 dd if=/dev/zero of=/tmp/ioload_$i bs=10M count=50 2>/dev/null
 # Read it back
 dd if=/tmp/ioload_$i of=/dev/null bs=10M 2>/dev/null
 # Clean up
 rm -f /tmp/ioload_$i
 ) &
done
wait
echo "I/O test complete."
