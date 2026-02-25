#!/bin/bash
echo "=== FILE SYSTEM TUNING ==="

# Function to tune ext4 file systems
tune_ext4() {
  local DEVICE=$1
  echo "Tuning ext4 file system on $DEVICE"

  # Check current settings
  sudo tune2fs -l $DEVICE | grep -E "Reserved block count|Block size"

  # Reduce reserved blocks for non-root file systems
  if [[ $DEVICE != *"root"* ]] && [[ $DEVICE != *"/"* ]]; then
    echo "Reducing reserved blocks to 1%"
    sudo tune2fs -m 1 $DEVICE
  fi

  # Enable dir_index for better directory performance
  sudo tune2fs -O dir_index $DEVICE
}

# Function to tune XFS file systems
tune_xfs() {
  local DEVICE=$1
  echo "XFS file system detected on $DEVICE"
  echo "XFS is already well-optimized by default"

  # Show XFS information
  sudo xfs_info $DEVICE 2>/dev/null || echo "XFS tools not available"
}

# Get mounted file systems
echo "Analyzing mounted file systems:"
df -T | grep -E "ext4|xfs" | while read line; do
  DEVICE=$(echo $line | awk '{print $1}')
  FSTYPE=$(echo $line | awk '{print $2}')
  MOUNTPOINT=$(echo $line | awk '{print $7}')

  echo ""
  echo "Processing: $DEVICE ($FSTYPE) mounted on $MOUNTPOINT"

  case $FSTYPE in
    ext4)
      tune_ext4 $DEVICE
      ;;
    xfs)
      tune_xfs $DEVICE
      ;;
    *)
      echo "File system type $FSTYPE not supported for tuning"
      ;;
  esac
done

echo ""
echo "File system tuning complete"
