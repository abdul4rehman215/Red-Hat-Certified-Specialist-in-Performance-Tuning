#!/bin/bash
# Create a simple HTML report (single-host archive snapshot)

TS=$(date +%Y%m%d_%H%M%S)
OUT="/tmp/pcp_comprehensive_report_${TS}.html"
ARCHIVE="/var/log/pcp/pmlogger/localhost/$(date +%Y%m%d)"

cat > "$OUT" << EOF
<!DOCTYPE html>
<html>
<head>
  <title>PCP Comprehensive Performance Report</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 20px; }
    pre { background: #f5f5f5; padding: 10px; overflow-x: auto; }
    .section { margin-bottom: 20px; }
    h2 { border-bottom: 1px solid #ddd; padding-bottom: 6px; }
  </style>
</head>
<body>
  <h1>PCP Comprehensive Performance Report</h1>
  <p><b>Generated:</b> $(date)</p>
  <p><b>Archive:</b> $ARCHIVE</p>

  <div class="section">
    <h2>Load Average</h2>
    <pre>$(pmval -a "$ARCHIVE" -s 10 kernel.all.load 2>/dev/null)</pre>
  </div>

  <div class="section">
    <h2>CPU User/System</h2>
    <pre>$(pmdumptext -a "$ARCHIVE" -t 60 kernel.all.cpu.user kernel.all.cpu.sys 2>/dev/null)</pre>
  </div>

  <div class="section">
    <h2>Memory Used</h2>
    <pre>$(pmdumptext -a "$ARCHIVE" -t 60 mem.util.used mem.util.free 2>/dev/null)</pre>
  </div>

</body>
</html>
EOF

echo "Comprehensive report generated: $OUT"
echo "Open this file in a web browser to view the formatted report."
