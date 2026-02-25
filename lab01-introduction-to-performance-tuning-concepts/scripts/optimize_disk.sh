#!/bin/bash
echo "=== DISK I/O OPTIMIZATION ==="

# Function to optimize disk scheduler
optimize_scheduler() {
  local DISK=$1
  local SCHEDULER=$2

  if [ -f /sys/block/$DISK/queue/scheduler ]; then
    echo "Setting $SCHEDULER scheduler for $DISK"
    echo $SCHEDULER | sudo tee /sys/block/$DISK/queue/scheduler

    # Verify the change
    echo "Current scheduler for $DISK:"
    cat /sys/block/$DISK/queue/scheduler
  fi
}

# Get list of block devices
DISKS=$(lsblk -d -n -o NAME | grep -E "^sd|^nvme|^vd")

for DISK in $DISKS; do
  echo "Optimizing disk: $DISK"

  # For SSDs, use noop or deadline
  # For HDDs, use deadline or cfq
  # For NVMe, use none or mq-deadline
  if [[ $DISK == nvme* ]]; then
    optimize_scheduler $DISK "none"
  else
    optimize_scheduler $DISK "deadline"
  fi

  # Optimize read-ahead settings
  if [ -f /sys/block/$DISK/queue/read_ahead_kb ]; then
    echo "Setting read-ahead for $DISK to 128KB"
    echo 128 | sudo tee /sys/block/$DISK/queue/read_ahead_kb
  fi
done

echo ""
echo "Disk optimization complete"
