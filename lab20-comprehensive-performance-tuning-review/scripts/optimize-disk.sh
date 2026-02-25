#!/bin/bash
echo "=== Disk I/O Performance Optimization ==="

echo "Current I/O schedulers:"
for disk in /sys/block/*/queue/scheduler; do
 echo "$disk: $(cat $disk)"
done

echo "Setting optimal I/O scheduler..."
for disk in /sys/block/sd*/queue/scheduler; do
 echo mq-deadline > $disk 2>/dev/null && echo "Set mq-deadline for $disk"
done

echo "Checking current mount options..."
mount | grep -E "(ext4|xfs)" | head -5

echo "Cleaning up temporary files..."
find /tmp -type f -atime +7 -delete 2>/dev/null
find /var/tmp -type f -atime +7 -delete 2>/dev/null

echo "Configuring log rotation..."
cat > /etc/logrotate.d/performance-optimization << 'LOGROTATE_EOF'
/var/log/*.log {
 daily
 rotate 7
 compress
 delaycompress
 missingok
 notifempty
 create 644 root root
}
LOGROTATE_EOF

echo "Finding large files (>100MB)..."
find / -type f -size +100M 2>/dev/null | head -10

echo "Disk I/O optimization completed."
