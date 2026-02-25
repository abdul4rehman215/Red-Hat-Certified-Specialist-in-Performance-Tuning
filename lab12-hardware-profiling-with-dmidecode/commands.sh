#!/bin/bash
# Lab 12 - Hardware Profiling with dmidecode
# Commands Executed During Lab (sequential, no explanations)

# ----------------------------------------
# Task 1: Verify dmidecode + basic usage
# ----------------------------------------

which dmidecode
dmidecode --version
dmidecode --help

# ----------------------------------------
# Task 1.2: Gather complete system information
# ----------------------------------------

sudo dmidecode > /tmp/complete_hardware_report.txt
less /tmp/complete_hardware_report.txt
echo "Exited less viewer"
sudo dmidecode | grep "Handle" | wc -l

# ----------------------------------------
# Task 1.3: Explore DMI types
# ----------------------------------------

sudo dmidecode --type

# ----------------------------------------
# Task 2.1: CPU hardware analysis
# ----------------------------------------

sudo dmidecode --type processor
sudo dmidecode --type 4
sudo dmidecode --type processor > /tmp/cpu_analysis.txt

# ----------------------------------------
# Task 2.2: CPU performance analyzer script
# ----------------------------------------

nano /tmp/cpu_analyzer.sh
chmod +x /tmp/cpu_analyzer.sh
/tmp/cpu_analyzer.sh

# ----------------------------------------
# Task 2.3: Multi-CPU system analysis
# ----------------------------------------

CPU_COUNT=$(sudo dmidecode --type processor | grep "Socket Designation" | wc -l)
echo "Number of physical CPUs: $CPU_COUNT"

for i in $(seq 1 $CPU_COUNT); do
  echo "=== CPU $i Analysis ==="
  sudo dmidecode --type processor | sed -n "${i}p;/^$/q" | head -20
  echo ""
done

# ----------------------------------------
# Task 3.1: Memory configuration analysis
# ----------------------------------------

sudo dmidecode --type memory
sudo dmidecode --type 17
sudo dmidecode --type 17 > /tmp/memory_analysis.txt

# ----------------------------------------
# Task 3.2: Memory performance analyzer script
# ----------------------------------------

nano /tmp/memory_analyzer.sh
chmod +x /tmp/memory_analyzer.sh
/tmp/memory_analyzer.sh

# ----------------------------------------
# Task 3.3: Memory channel analyzer script
# ----------------------------------------

nano /tmp/memory_channel_analyzer.sh
chmod +x /tmp/memory_channel_analyzer.sh
/tmp/memory_channel_analyzer.sh

# ----------------------------------------
# Task 4.1: Motherboard / system / BIOS information
# ----------------------------------------

sudo dmidecode --type system
sudo dmidecode --type baseboard
sudo dmidecode --type bios

nano /tmp/system_analyzer.sh
chmod +x /tmp/system_analyzer.sh
/tmp/system_analyzer.sh

# ----------------------------------------
# Task 4.2: Expansion capability analysis
# ----------------------------------------

nano /tmp/expansion_analyzer.sh
chmod +x /tmp/expansion_analyzer.sh
/tmp/expansion_analyzer.sh

# ----------------------------------------
# Task 5.1: Comprehensive performance assessment
# ----------------------------------------

nano /tmp/performance_analyzer.sh
chmod +x /tmp/performance_analyzer.sh
/tmp/performance_analyzer.sh

# ----------------------------------------
# Task 5.2: Hardware inventory report generation
# ----------------------------------------

nano /tmp/hardware_inventory.sh
chmod +x /tmp/hardware_inventory.sh
/tmp/hardware_inventory.sh

# ----------------------------------------
# Task 5.3: Performance baseline documentation
# ----------------------------------------

nano /tmp/create_baseline.sh
chmod +x /tmp/create_baseline.sh
/tmp/create_baseline.sh

# ----------------------------------------
# Troubleshooting / verification commands used
# ----------------------------------------

sudo dmidecode --type processor | head -10
which dmidecode
sudo yum install dmidecode
sudo dmidecode | grep -i virtual | head -10
sudo dmidecode --type 1,4,17 | head -30

sudo dmidecode | head -10
lscpu | head -20
lsmem | head -20
lshw -short | head -20
