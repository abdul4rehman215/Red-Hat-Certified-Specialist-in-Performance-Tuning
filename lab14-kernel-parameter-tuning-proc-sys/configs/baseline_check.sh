#!/bin/bash
echo "=== System Baseline Parameters ==="
echo "Date: $(date)"
echo "Hostname: $(hostname)"
echo ""

echo "=== Memory Management Parameters ==="
echo "vm.swappiness: $(cat /proc/sys/vm/swappiness)"
echo "vm.dirty_ratio: $(cat /proc/sys/vm/dirty_ratio)"
echo "vm.dirty_background_ratio: $(cat /proc/sys/vm/dirty_background_ratio)"
echo "vm.vfs_cache_pressure: $(cat /proc/sys/vm/vfs_cache_pressure)"
echo ""

echo "=== Network Parameters ==="
echo "net.ipv4.tcp_rmem: $(cat /proc/sys/net/ipv4/tcp_rmem)"
echo "net.ipv4.tcp_wmem: $(cat /proc/sys/net/ipv4/tcp_wmem)"
echo "net.core.rmem_max: $(cat /proc/sys/net/core/rmem_max)"
echo "net.core.wmem_max: $(cat /proc/sys/net/core/wmem_max)"
echo ""

echo "=== File System Parameters ==="
echo "fs.file-max: $(cat /proc/sys/fs/file-max)"
echo "fs.inotify.max_user_watches: $(cat /proc/sys/fs/inotify/max_user_watches)"
