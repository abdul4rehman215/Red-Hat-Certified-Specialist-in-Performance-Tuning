#!/bin/bash
echo "=========================================="
echo " COMPREHENSIVE HARDWARE PERFORMANCE ANALYSIS"
echo "=========================================="
echo "Generated on: $(date)"
echo "System: $(hostname)"
echo "=========================================="

# Function to print section headers
print_section() {
  echo -e "\n"
  echo "==========================================="
  echo " $1"
  echo "==========================================="
}

# CPU Performance Analysis
print_section "CPU PERFORMANCE ANALYSIS"
CPU_MODEL=$(sudo dmidecode --type 4 | grep "Version" | head -1 | cut -d: -f2 | xargs)
CPU_CORES=$(sudo dmidecode --type 4 | grep "Core Count" | head -1 | awk '{print $3}')
CPU_THREADS=$(sudo dmidecode --type 4 | grep "Thread Count" | head -1 | awk '{print $3}')
CPU_CURRENT_SPEED=$(sudo dmidecode --type 4 | grep "Current Speed" | head -1 | awk '{print $3}')
CPU_MAX_SPEED=$(sudo dmidecode --type 4 | grep "Max Speed" | head -1 | awk '{print $3}')
echo "CPU Model: $CPU_MODEL"
echo "Cores: $CPU_CORES | Threads: $CPU_THREADS"
echo "Current Speed: $CPU_CURRENT_SPEED MHz | Max Speed: $CPU_MAX_SPEED MHz"

# CPU Performance Recommendations
echo -e "\n--- CPU Performance Recommendations ---"
if [ "$CPU_CURRENT_SPEED" != "$CPU_MAX_SPEED" ]; then
  echo " CPU not running at maximum speed"
  echo " Recommendation: Check power management settings (cpufreq-utils)"
  echo " Command: sudo cpupower frequency-info"
fi

if [ "$CPU_THREADS" -gt "$CPU_CORES" ]; then
  echo " Hyperthreading enabled - good for multithreaded workloads"
else
  echo " Hyperthreading not detected or disabled"
fi

# Memory Performance Analysis
print_section "MEMORY PERFORMANCE ANALYSIS"
TOTAL_MEMORY_MB=$(sudo dmidecode --type 17 | grep "Size:" | grep -v "No Module Installed" | \
  awk '{sum += $2} END {print sum}')
TOTAL_MEMORY_GB=$((TOTAL_MEMORY_MB / 1024))
MEMORY_MODULES=$(sudo dmidecode --type 17 | grep "Size:" | grep -v "No Module Installed" | wc -l)
MEMORY_SPEED=$(sudo dmidecode --type 17 | grep "Speed:" | grep -v "Unknown" | head -1 | awk '{print $2}')
echo "Total Memory: ${TOTAL_MEMORY_GB} GB (${TOTAL_MEMORY_MB} MB)"
echo "Memory Modules: $MEMORY_MODULES"
echo "Memory Speed: $MEMORY_SPEED MHz"

# Memory Performance Recommendations
echo -e "\n--- Memory Performance Recommendations ---"
# Check memory speed consistency
UNIQUE_SPEEDS=$(sudo dmidecode --type 17 | grep "Speed:" | grep -v "Unknown" | awk '{print $2}' | sort -u | wc -l)
if [ "$UNIQUE_SPEEDS" -gt 1 ]; then
  echo " Mixed memory speeds detected"
  echo " Recommendation: Use identical speed modules for optimal performance"
else
  echo " Consistent memory speed across modules"
fi

# Check for dual channel configuration
if [ $((MEMORY_MODULES % 2)) -eq 0 ]; then
  echo " Even number of memory modules - dual channel capable"
else
  echo " Odd number of memory modules - may not utilize dual channel"
fi

# Memory capacity recommendations
if [ "$TOTAL_MEMORY_GB" -lt 8 ]; then
  echo " Low memory capacity detected (${TOTAL_MEMORY_GB}GB)"
  echo " Recommendation: Upgrade to at least 8GB for modern workloads"
elif [ "$TOTAL_MEMORY_GB" -lt 16 ]; then
  echo " Moderate memory capacity (${TOTAL_MEMORY_GB}GB)"
  echo " Consider upgrading to 16GB+ for performance-intensive tasks"
else
  echo " Good memory capacity (${TOTAL_MEMORY_GB}GB)"
fi

# Storage and System Analysis
print_section "SYSTEM CONFIGURATION ANALYSIS"
# BIOS Analysis
BIOS_DATE=$(sudo dmidecode --type 0 | grep "Release Date" | awk '{print $3}')
BIOS_VERSION=$(sudo dmidecode --type 0 | grep "Version" | cut -d: -f2 | xargs)
echo "BIOS Version: $BIOS_VERSION"
echo "BIOS Date: $BIOS_DATE"

# System recommendations
echo -e "\n--- System Recommendations ---"
# Check BIOS age
CURRENT_YEAR=$(date +%Y)
BIOS_YEAR=$(echo $BIOS_DATE | cut -d'/' -f3)
BIOS_AGE=$((CURRENT_YEAR - BIOS_YEAR))
if [ "$BIOS_AGE" -gt 3 ]; then
  echo " BIOS is $BIOS_AGE years old"
  echo " Recommendation: Check for BIOS updates for security and performance"
else
  echo " BIOS is relatively recent ($BIOS_AGE years old)"
fi

# Performance Tuning Summary
print_section "PERFORMANCE TUNING SUMMARY"
echo "Priority Actions for Performance Improvement:"
echo ""

# Generate priority recommendations
PRIORITY=1
if [ "$CPU_CURRENT_SPEED" != "$CPU_MAX_SPEED" ]; then
  echo "$PRIORITY. Fix CPU frequency scaling"
  echo " - Check power management settings"
  echo " - Ensure performance governor is active"
  PRIORITY=$((PRIORITY + 1))
fi

if [ "$TOTAL_MEMORY_GB" -lt 8 ]; then
  echo "$PRIORITY. Upgrade system memory"
  echo " - Current: ${TOTAL_MEMORY_GB}GB, Recommended: 16GB+"
  PRIORITY=$((PRIORITY + 1))
fi

if [ "$UNIQUE_SPEEDS" -gt 1 ]; then
  echo "$PRIORITY. Standardize memory modules"
  echo " - Replace mixed-speed modules with identical specifications"
  PRIORITY=$((PRIORITY + 1))
fi

if [ "$BIOS_AGE" -gt 3 ]; then
  echo "$PRIORITY. Update system BIOS"
  echo " - Check manufacturer website for latest version"
  PRIORITY=$((PRIORITY + 1))
fi

if [ "$PRIORITY" -eq 1 ]; then
  echo " No critical performance issues detected"
  echo " System appears well-configured for current hardware"
fi

# Additional monitoring recommendations
echo -e "\n--- Ongoing Performance Monitoring ---"
echo "Recommended tools for continuous monitoring:"
echo "• htop - Real-time process monitoring"
echo "• iotop - I/O monitoring"
echo "• sar - System activity reporting"
echo "• perf - Performance analysis tools"

echo -e "\n=========================================="
echo " ANALYSIS COMPLETE"
echo "=========================================="
