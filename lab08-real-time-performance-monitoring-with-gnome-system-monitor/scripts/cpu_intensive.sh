#!/bin/bash
echo "Starting CPU-intensive process..."
while true; do
 echo "scale=5000; 4*a(1)" | bc -l > /dev/null
done
