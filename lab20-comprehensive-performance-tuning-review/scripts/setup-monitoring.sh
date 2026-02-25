#!/bin/bash
echo "=== Setting up Ongoing Performance Monitoring ==="

mkdir -p /opt/performance-monitoring
cd /opt/performance-monitoring || exit 1

cat > daily-monitor.sh << 'DAILY_EOF'
#!/bin/bash
DATE=$(date +%Y%m%d)
LOGDIR="/opt/performance-monitoring/logs"
mkdir -p $LOGDIR
{
 echo "=== Daily Performance Report - $(date) ==="
 echo ""
 echo "System Load:"
 uptime
 echo ""
 echo "Memory Usage:"
 free -h
 echo ""
 echo "Disk Usage:"
 df -h
 echo ""
 echo "Top CPU Processes:"
 ps aux --sort=-%cpu | head -10
 echo ""
 echo "Top Memory Processes:"
 ps aux --sort=-%mem | head -10
 echo ""
} > ${LOGDIR}/daily-report-${DATE}.txt
sar -A > ${LOGDIR}/sar-all-${DATE}.txt
DAILY_EOF
chmod +x daily-monitor.sh

cat > weekly-monitor.sh << 'WEEKLY_EOF'
#!/bin/bash
WEEK=$(date +%Y%U)
REPORTDIR="/opt/performance-monitoring/reports"
mkdir -p $REPORTDIR
{
 echo "=== Weekly Performance Summary - Week $WEEK ==="
 echo ""
 echo "Average System Load (last 7 days):"
 sar -q -f /var/log/sa/sa* | grep Average
 echo ""
 echo "Average Memory Usage (last 7 days):"
 sar -r -f /var/log/sa/sa* | grep Average
 echo ""
 echo "Average Disk I/O (last 7 days):"
 sar -d -f /var/log/sa/sa* | grep Average
 echo ""
} > ${REPORTDIR}/weekly-summary-${WEEK}.txt
WEEKLY_EOF
chmod +x weekly-monitor.sh

echo "Setting up cron jobs for automated monitoring..."
(crontab -l 2>/dev/null; echo "0 6 * * * /opt/performance-monitoring/daily-monitor.sh") | crontab -
(crontab -l 2>/dev/null; echo "0 7 * * 1 /opt/performance-monitoring/weekly-monitor.sh") | crontab -

echo "Automated monitoring setup completed."
echo "Daily reports will be generated at 6:00 AM"
echo "Weekly summaries will be generated at 7:00 AM on Mondays"
