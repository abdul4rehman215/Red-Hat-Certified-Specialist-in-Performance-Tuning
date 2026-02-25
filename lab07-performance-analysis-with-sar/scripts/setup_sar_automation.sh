#!/bin/bash
echo "=== Automated SAR Monitoring Setup ==="

BASE_DIR="$HOME/sar_automation"
REPORT_DIR="/tmp/performance_reports"
mkdir -p "$BASE_DIR"
mkdir -p "$REPORT_DIR"

echo "Creating directory: $BASE_DIR"

# Snapshot script (quick and lightweight)
cat > "$BASE_DIR/sar_snapshot.sh" << 'EOF'
#!/bin/bash
LOGDIR="$HOME/sar_automation/snapshots"
mkdir -p "$LOGDIR"
TS=$(date +%Y%m%d_%H%M%S)

# Save quick snapshots (CPU, memory, disk) using sar (1 sample)
{
 echo "=== Snapshot: $(date) ==="
 echo ""
 echo "--- CPU ---"
 sar -u 1 1 | tail -3
 echo ""
 echo "--- Memory ---"
 sar -r 1 1 | tail -3
 echo ""
 echo "--- Disk ---"
 sar -d 1 1 | tail -3
 echo ""
} > "$LOGDIR/sar_snapshot_${TS}.txt"
EOF
chmod +x "$BASE_DIR/sar_snapshot.sh"
echo "Creating snapshot script: $BASE_DIR/sar_snapshot.sh"

# Daily report runner
cat > "$BASE_DIR/run_daily_report.sh" << 'EOF'
#!/bin/bash
# Runs the master performance report generator and keeps output in /tmp/performance_reports
SCRIPT="$HOME/master_performance_analysis.sh"

if [ ! -x "$SCRIPT" ]; then
 echo "Master report script not found or not executable: $SCRIPT"
 exit 1
fi

"$SCRIPT" >/dev/null 2>&1
EOF
chmod +x "$BASE_DIR/run_daily_report.sh"
echo "Creating daily report runner: $BASE_DIR/run_daily_report.sh"

# Cleanup script (keep 7 days)
cat > "$BASE_DIR/cleanup_reports.sh" << 'EOF'
#!/bin/bash
REPORT_DIR="/tmp/performance_reports"
# remove reports older than 7 days
find "$REPORT_DIR" -type f -name "master_performance_report_*" -mtime +7 -delete 2>/dev/null
# remove snapshots older than 7 days
find "$HOME/sar_automation/snapshots" -type f -name "sar_snapshot_*" -mtime +7 -delete 2>/dev/null
EOF
chmod +x "$BASE_DIR/cleanup_reports.sh"
echo "Creating cleanup script: $BASE_DIR/cleanup_reports.sh"

# Cron file (simple approach)
CRON_FILE="/etc/cron.d/sar-automation"
echo "Adding cron jobs in $CRON_FILE (daily report + cleanup)..."

sudo bash -c "cat > $CRON_FILE" << EOF
# Automated SAR monitoring - created by setup_sar_automation.sh

# Collect a simple SAR snapshot every 10 minutes
*/10 * * * * $USER $BASE_DIR/sar_snapshot.sh >/dev/null 2>&1

# Generate the master performance report daily at 01:00
0 1 * * * $USER $BASE_DIR/run_daily_report.sh >/dev/null 2>&1

# Cleanup reports older than 7 days daily at 01:10
10 1 * * * $USER $BASE_DIR/cleanup_reports.sh >/dev/null 2>&1
EOF

echo "Cron file created successfully."
echo ""
echo "Verification:"
ls -la "$BASE_DIR" | grep -E "(sar_snapshot|run_daily_report|cleanup_reports)"
echo ""
echo "Done ✅"
echo "- Snapshots: every 10 minutes"
echo "- Daily report: 01:00 AM"
echo "- Cleanup: 01:10 AM (keeps 7 days)"
