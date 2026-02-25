#!/bin/bash
# Generate per-host PCP summaries into /tmp/pcp_reports

HOSTS=("localhost" "target-1" "target-2")
REPORT_DIR="/tmp/pcp_reports"
TS=$(date +%Y%m%d_%H%M%S)

mkdir -p "$REPORT_DIR"

echo "Generating performance dashboard for $(date)"
echo "============================================="

for host in "${HOSTS[@]}"; do
 echo "Processing $host..."
 OUTFILE="${REPORT_DIR}/${host}_summary_${TS}.txt"

 {
  echo "PCP PERFORMANCE SUMMARY"
  echo "Host: $host"
  echo "Generated: $(date)"
  echo "---------------------------------------------"
  echo ""

  echo "Load Average (kernel.all.load):"
  pmval -h "$host" -s 3 -t 1 kernel.all.load 2>/dev/null | tail -5
  echo ""

  echo "CPU (user/sys/idle):"
  pmval -h "$host" -s 5 -t 1 kernel.all.cpu.user kernel.all.cpu.sys kernel.all.cpu.idle 2>/dev/null | tail -12
  echo ""

  echo "Memory (used/free):"
  pmval -h "$host" -s 3 -t 1 mem.util.used mem.util.free 2>/dev/null | tail -6
  echo ""

 } > "$OUTFILE"

 echo "Report generated: $OUTFILE"
done

echo "Dashboard generation complete!"
echo "Reports available in: $REPORT_DIR"
