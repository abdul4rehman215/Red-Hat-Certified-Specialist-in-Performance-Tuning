#!/bin/bash
BASELINE_DIR="/tmp/hardware_baseline_$(date +%Y%m%d)"
mkdir -p "$BASELINE_DIR"

echo "Creating hardware performance baseline..."
echo "Baseline directory: $BASELINE_DIR"

# System identification
echo "$(date): Creating hardware baseline for $(hostname)" > "$BASELINE_DIR/baseline_info.txt"

# CPU baseline
sudo dmidecode --type 4 > "$BASELINE_DIR/cpu_baseline.txt"

# Memory baseline
sudo dmidecode --type 16,17 > "$BASELINE_DIR/memory_baseline.txt"

# System baseline
sudo dmidecode --type 0,1,2,3 > "$BASELINE_DIR/system_baseline.txt"

# Performance metrics baseline
cat > "$BASELINE_DIR/performance_metrics.txt" << 'METRICS_EOF'
=== Hardware Performance Baseline Metrics ===
CPU Information:
METRICS_EOF

CPU_MODEL=$(sudo dmidecode --type 4 | grep "Version" | head -1 | cut -d: -f2 | xargs)
CPU_CORES=$(sudo dmidecode --type 4 | grep "Core Count" | head -1 | awk '{print $3}')
CPU_SPEED=$(sudo dmidecode --type 4 | grep "Max Speed" | head -1 | awk '{print $3}')
echo "Model: $CPU_MODEL" >> "$BASELINE_DIR/performance_metrics.txt"
echo "Cores: $CPU_CORES" >> "$BASELINE_DIR/performance_metrics.txt"
echo "Max Speed: $CPU_SPEED MHz" >> "$BASELINE_DIR/performance_metrics.txt"
echo "" >> "$BASELINE_DIR/performance_metrics.txt"

echo "Memory Information:" >> "$BASELINE_DIR/performance_metrics.txt"
TOTAL_MEMORY=$(sudo dmidecode --type 17 | grep "Size:" | grep -v "No Module Installed" | \
  awk '{sum += $2} END {print sum}')
MEMORY_SPEED=$(sudo dmidecode --type 17 | grep "Speed:" | grep -v "Unknown" | head -1 | awk '{print $2}')
echo "Total Memory: $TOTAL_MEMORY MB" >> "$BASELINE_DIR/performance_metrics.txt"
echo "Memory Speed: $MEMORY_SPEED MHz" >> "$BASELINE_DIR/performance_metrics.txt"

# Create comparison script for future use
cat > "$BASELINE_DIR/compare_baseline.sh" << 'COMPARE_EOF'
#!/bin/bash
echo "=== Hardware Configuration Comparison ==="
echo "Baseline created: $(cat baseline_info.txt)"
echo "Current date: $(date)"
echo ""
echo "Comparing current configuration with baseline..."

# Compare CPU
echo "--- CPU Comparison ---"
BASELINE_CPU=$(grep "Version" cpu_baseline.txt | head -1 | cut -d: -f2 | xargs)
CURRENT_CPU=$(sudo dmidecode --type 4 | grep "Version" | head -1 | cut -d: -f2 | xargs)
if [ "$BASELINE_CPU" = "$CURRENT_CPU" ]; then
  echo " CPU unchanged: $CURRENT_CPU"
else
  echo " CPU changed!"
  echo " Baseline: $BASELINE_CPU"
  echo " Current: $CURRENT_CPU"
fi

# Compare Memory
echo "--- Memory Comparison ---"
BASELINE_MEMORY=$(grep "Size:" memory_baseline.txt | grep -v "No Module Installed" | \
  awk '{sum += $2} END {print sum}')
CURRENT_MEMORY=$(sudo dmidecode --type 17 | grep "Size:" | grep -v "No Module Installed" | \
  awk '{sum += $2} END {print sum}')
if [ "$BASELINE_MEMORY" = "$CURRENT_MEMORY" ]; then
  echo " Memory unchanged: $CURRENT_MEMORY MB"
else
  echo " Memory changed!"
  echo " Baseline: $BASELINE_MEMORY MB"
  echo " Current: $CURRENT_MEMORY MB"
fi
COMPARE_EOF

chmod +x "$BASELINE_DIR/compare_baseline.sh"

echo "Baseline created successfully!"
echo ""
echo "Files created:"
ls -la "$BASELINE_DIR"
echo ""
echo "To compare current system with baseline in the future:"
echo "cd $BASELINE_DIR && ./compare_baseline.sh"
