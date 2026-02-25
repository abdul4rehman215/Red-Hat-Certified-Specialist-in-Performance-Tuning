#!/bin/bash
echo "=== Kernel Parameter Validation ==="
echo "Checking if all tuned parameters are correctly applied..."
echo ""

# Define expected values
declare -A expected_params=(
  ["vm.swappiness"]="10"
  ["vm.dirty_ratio"]="15"
  ["vm.dirty_background_ratio"]="5"
  ["vm.vfs_cache_pressure"]="50"
  ["net.core.rmem_max"]="16777216"
  ["net.core.wmem_max"]="16777216"
  ["fs.file-max"]="1048576"
)

# Check each parameter
all_correct=true
for param in "${!expected_params[@]}"; do
  current_value=$(sysctl -n $param)
  expected_value=${expected_params[$param]}

  if [ "$current_value" = "$expected_value" ]; then
    echo "✓ $param: $current_value (correct)"
  else
    echo "✗ $param: $current_value (expected: $expected_value)"
    all_correct=false
  fi
done

# Check TCP memory parameters separately (they have multiple values)
tcp_rmem_current=$(cat /proc/sys/net/ipv4/tcp_rmem)
tcp_rmem_expected="4096 87380 16777216"
if [ "$tcp_rmem_current" = "$tcp_rmem_expected" ]; then
  echo "✓ net.ipv4.tcp_rmem: $tcp_rmem_current (correct)"
else
  echo "✗ net.ipv4.tcp_rmem: $tcp_rmem_current (expected: $tcp_rmem_expected)"
  all_correct=false
fi

tcp_wmem_current=$(cat /proc/sys/net/ipv4/tcp_wmem)
tcp_wmem_expected="4096 65536 16777216"
if [ "$tcp_wmem_current" = "$tcp_wmem_expected" ]; then
  echo "✓ net.ipv4.tcp_wmem: $tcp_wmem_current (correct)"
else
  echo "✗ net.ipv4.tcp_wmem: $tcp_wmem_current (expected: $tcp_wmem_expected)"
  all_correct=false
fi

echo ""
if [ "$all_correct" = true ]; then
  echo " All kernel parameters are correctly tuned!"
else
  echo " Some parameters need adjustment. Please review the configuration."
fi
