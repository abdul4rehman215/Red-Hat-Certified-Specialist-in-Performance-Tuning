#!/bin/bash
echo "Starting load test..."

# Memory stress test
stress-ng --vm 2 --vm-bytes 512M --timeout 30s &

# I/O stress test
dd if=/dev/zero of=/tmp/testfile bs=1M count=100 oflag=direct &

# Network test (if netcat is available)
if command -v nc >/dev/null 2>&1; then
  # Simple network load
  for i in {1..10}; do
    echo "Test connection $i" | nc -l -p $((8000+i)) &
  done
fi

wait
rm -f /tmp/testfile
echo "Load test completed"
