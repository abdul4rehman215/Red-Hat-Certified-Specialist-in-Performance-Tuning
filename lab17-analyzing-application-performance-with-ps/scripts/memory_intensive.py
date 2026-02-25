#!/usr/bin/env python3
import time
import sys

print("Starting memory-intensive process...")

# Allocate memory gradually
memory_blocks = []
try:
    for i in range(1000):
        # Allocate 1MB blocks
        block = bytearray(1024 * 1024)
        memory_blocks.append(block)
        time.sleep(0.1)
        if i % 100 == 0:
            print(f"Allocated {i} MB")
except KeyboardInterrupt:
    print("Process interrupted")
    sys.exit(0)
