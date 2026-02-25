#!/usr/bin/env python3
import time

def memory_leak_simulation():
    """Simulate a memory leak by continuously allocating memory"""
    memory_hog = []
    iteration = 0

    print("Starting memory leak simulation...")
    print("Monitor this process in gnome-system-monitor")
    print("Press Ctrl+C to stop")

    try:
        while True:
            # Allocate 10MB of memory each iteration
            chunk = 'x' * (10 * 1024 * 1024)
            memory_hog.append(chunk)
            iteration += 1

            if iteration % 10 == 0:
                print(f"Iteration {iteration}: Allocated ~{iteration * 10}MB")

            time.sleep(2)
    except KeyboardInterrupt:
        print("\nMemory leak simulation stopped")
        print(f"Total allocated: ~{iteration * 10}MB")

if __name__ == "__main__":
    memory_leak_simulation()
