#!/bin/bash
# Lab 14 - Kernel Parameter Tuning with /proc/sys
# Commands Executed During Lab (sequential, no explanations)

# ----------------------------------------
# Task 1.1: Explore /proc/sys structure
# ----------------------------------------

cd /proc/sys
ls -la
ls -la kernel/
ls -la vm/
ls -la net/
ls -la fs/

# ----------------------------------------
# Task 1.2: View current kernel parameter values
# ----------------------------------------

cat /proc/sys/vm/swappiness
cat /proc/sys/net/ipv4/tcp_rmem
cat /proc/sys/net/ipv4/tcp_wmem
cat /proc/sys/fs/file-max

# ----------------------------------------
# Task 1.2: View parameters via sysctl
# ----------------------------------------

sysctl -a | head -20
sysctl vm.swappiness
sysctl vm. | head -10
sysctl net.ipv4. | head -10

# ----------------------------------------
# Task 1.3: Create baseline documentation script
# ----------------------------------------

mkdir -p ~/lab14 && cd ~/lab14
nano baseline_check.sh
chmod +x baseline_check.sh
./baseline_check.sh

# ----------------------------------------
# Task 2.1: Understand current memory usage
# ----------------------------------------

free -h
swapon --show
cat /proc/meminfo | grep -E "(MemTotal|MemFree|SwapTotal|SwapFree)"

# ----------------------------------------
# Task 2.1: Tune vm.swappiness (runtime)
# ----------------------------------------

echo "Current swappiness: $(cat /proc/sys/vm/swappiness)"
echo 10 > /proc/sys/vm/swappiness
cat /proc/sys/vm/swappiness

sysctl vm.swappiness=20
sysctl vm.swappiness

# ----------------------------------------
# Task 2.1: Prepare memory pressure test tool + script
# ----------------------------------------

command -v stress || echo "stress not found"
sudo dnf install stress -y
nano memory_test.sh
chmod +x memory_test.sh

# ----------------------------------------
# Task 2.2: Inspect TCP buffer parameters
# ----------------------------------------

echo "TCP receive memory (min default max): $(cat /proc/sys/net/ipv4/tcp_rmem)"
echo "TCP send memory (min default max): $(cat /proc/sys/net/ipv4/tcp_wmem)"
echo "Max receive buffer: $(cat /proc/sys/net/core/rmem_max)"
echo "Max send buffer: $(cat /proc/sys/net/core/wmem_max)"

# ----------------------------------------
# Task 2.2: Tune TCP memory parameters (runtime)
# ----------------------------------------

echo "4096 87380 16777216" > /proc/sys/net/ipv4/tcp_rmem
echo "4096 65536 16777216" > /proc/sys/net/ipv4/tcp_wmem
echo 16777216 > /proc/sys/net/core/rmem_max
echo 16777216 > /proc/sys/net/core/wmem_max

echo "New TCP rmem: $(cat /proc/sys/net/ipv4/tcp_rmem)"
echo "New TCP wmem: $(cat /proc/sys/net/ipv4/tcp_wmem)"
echo "New rmem_max: $(cat /proc/sys/net/core/rmem_max)"
echo "New wmem_max: $(cat /proc/sys/net/core/wmem_max)"

# ----------------------------------------
# Task 2.3: Tune additional parameters
# ----------------------------------------

echo 1048576 > /proc/sys/fs/file-max
echo 15 > /proc/sys/vm/dirty_ratio
echo 5 > /proc/sys/vm/dirty_background_ratio
echo 50 > /proc/sys/vm/vfs_cache_pressure

echo "=== Updated Parameters ==="
echo "fs.file-max: $(cat /proc/sys/fs/file-max)"
echo "vm.dirty_ratio: $(cat /proc/sys/vm/dirty_ratio)"
echo "vm.dirty_background_ratio: $(cat /proc/sys/vm/dirty_background_ratio)"
echo "vm.vfs_cache_pressure: $(cat /proc/sys/vm/vfs_cache_pressure)"

# ----------------------------------------
# Task 3.1: Create performance testing scripts
# ----------------------------------------

nano network_test.sh
chmod +x network_test.sh

nano io_test.sh
chmod +x io_test.sh

nano monitor_performance.sh
chmod +x monitor_performance.sh

# ----------------------------------------
# Task 3.3: Baseline vs optimized performance testing
# ----------------------------------------

# Reset to defaults for baseline test
echo 60 > /proc/sys/vm/swappiness
echo "4096 87380 6291456" > /proc/sys/net/ipv4/tcp_rmem
echo "4096 16384 4194304" > /proc/sys/net/ipv4/tcp_wmem

echo "=== Baseline Performance Test ==="
echo "Running with default parameters..."

./baseline_check.sh > baseline_results.txt
./io_test.sh > baseline_io_results.txt

# Realistic fix for permission denied case
chmod +x io_test.sh
./io_test.sh > baseline_io_results.txt

# Apply tuned values for optimized test
echo 10 > /proc/sys/vm/swappiness
echo "4096 87380 16777216" > /proc/sys/net/ipv4/tcp_rmem
echo "4096 65536 16777216" > /proc/sys/net/ipv4/tcp_wmem
echo 16777216 > /proc/sys/net/core/rmem_max
echo 16777216 > /proc/sys/net/core/wmem_max
echo 15 > /proc/sys/vm/dirty_ratio
echo 5 > /proc/sys/vm/dirty_background_ratio

echo "=== Optimized Performance Test ==="
echo "Running with tuned parameters..."

./baseline_check.sh > optimized_results.txt
./io_test.sh > optimized_io_results.txt

# ----------------------------------------
# Task 3.4: Persist sysctl settings
# ----------------------------------------

sudo nano /etc/sysctl.d/99-performance-tuning.conf
sysctl -p /etc/sysctl.d/99-performance-tuning.conf

echo "=== Persistent Configuration Applied ==="
sysctl -p /etc/sysctl.d/99-performance-tuning.conf

# ----------------------------------------
# Task 3.4: Validation script
# ----------------------------------------

nano validate_tuning.sh
chmod +x validate_tuning.sh
./validate_tuning.sh

# ----------------------------------------
# Troubleshooting: permission denied for /proc/sys writes
# ----------------------------------------

sudo su -
echo 10 > /proc/sys/vm/swappiness

# ----------------------------------------
# Troubleshooting: persistence after reboot
# ----------------------------------------

nano /etc/sysctl.d/99-custom-tuning.conf

# ----------------------------------------
# Troubleshooting: invalid parameter placeholder example
# ----------------------------------------

sysctl -a | grep parameter_name

# ----------------------------------------
# Troubleshooting: testing tools not available
# ----------------------------------------

sudo yum install iperf3 fio sysstat
sudo dnf install fio sysstat -y
