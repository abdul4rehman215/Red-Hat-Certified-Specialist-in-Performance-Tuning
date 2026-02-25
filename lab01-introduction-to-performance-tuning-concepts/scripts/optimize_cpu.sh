#!/bin/bash
echo "=== CPU OPTIMIZATION SCRIPT ==="

# Function to optimize a process
optimize_process() {
  local PROCESS_NAME=$1
  local NICE_VALUE=$2
  local CPU_CORES=$3

  # Find process PID
  PID=$(pgrep $PROCESS_NAME | head -1)

  if [ -n "$PID" ]; then
    echo "Optimizing process: $PROCESS_NAME (PID: $PID)"

    # Set process priority
    sudo renice $NICE_VALUE $PID
    echo "Set nice value to $NICE_VALUE"

    # Set CPU affinity if specified
    if [ -n "$CPU_CORES" ]; then
      sudo taskset -cp $CPU_CORES $PID
      echo "Set CPU affinity to cores: $CPU_CORES"
    fi
  else
    echo "Process $PROCESS_NAME not found"
  fi
}

# Example optimizations
echo "Available CPU cores: $(nproc)"
echo ""
# optimize_process "httpd" "-5" "0,1" # High priority web server
# optimize_process "mysqld" "-3" "2,3" # Database server
# optimize_process "backup" "10" "0" # Low priority backup process
echo "CPU optimization complete"
