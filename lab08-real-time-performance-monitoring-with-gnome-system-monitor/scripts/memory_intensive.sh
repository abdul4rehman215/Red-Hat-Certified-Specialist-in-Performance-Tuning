#!/bin/bash
echo "Starting memory-intensive process..."
python3 -c "
import time
data = []
for i in range(1000):
 data.append('x' * 1024 * 1024) # 1MB chunks
 time.sleep(0.1)
 if i % 100 == 0:
  print(f'Allocated {i}MB')
"
