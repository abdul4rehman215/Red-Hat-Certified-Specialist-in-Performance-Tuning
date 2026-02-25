#!/bin/bash
echo "=== MEMORY CLEANUP SCRIPT ==="

# Check memory before cleanup
echo "Memory usage before cleanup:"
free -h
echo ""

echo "Clearing page cache, dentries, and inodes..."
sudo sync

# Clear caches safely (sudo + redirection fix)
echo 1 | sudo tee /proc/sys/vm/drop_caches >/dev/null
echo 2 | sudo tee /proc/sys/vm/drop_caches >/dev/null
echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null

echo "Cache clearing complete"
echo ""
echo "Memory usage after cleanup:"
free -h
echo ""

echo "Checking for memory leaks in running processes..."
ps aux --sort=-%mem | head -10 | while read line; do
  PID=$(echo $line | awk '{print $2}')
  COMM=$(echo $line | awk '{print $11}')
  MEM=$(echo $line | awk '{print $4}')

  if [ "$PID" != "PID" ] && [ $(echo "$MEM > 10" | bc -l) -eq 1 ]; then
    echo "High memory usage detected: $COMM (PID: $PID) using $MEM% memory"
  fi
done
