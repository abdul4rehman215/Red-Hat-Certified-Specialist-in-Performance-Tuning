#!/bin/bash
BACKUP_FILE="/tmp/sysctl_backup_$(date +%Y%m%d_%H%M%S).conf"

echo "Creating sysctl backup..."
echo "# sysctl backup created on $(date)" > $BACKUP_FILE
echo "# Original system values before performance tuning" >> $BACKUP_FILE
echo >> $BACKUP_FILE

PARAMS=(
  "vm.swappiness"
  "vm.dirty_ratio"
  "vm.dirty_background_ratio"
  "vm.dirty_expire_centisecs"
  "vm.dirty_writeback_centisecs"
  "vm.vfs_cache_pressure"
  "net.ipv4.tcp_window_scaling"
  "net.ipv4.tcp_timestamps"
  "net.ipv4.tcp_sack"
  "net.ipv4.tcp_keepalive_time"
  "net.ipv4.tcp_keepalive_probes"
  "net.ipv4.tcp_keepalive_intvl"
  "net.core.rmem_default"
  "net.core.rmem_max"
  "net.core.wmem_default"
  "net.core.wmem_max"
  "net.core.somaxconn"
  "net.ipv4.tcp_max_syn_backlog"
  "net.ipv4.tcp_syncookies"
  "net.ipv4.tcp_syn_retries"
  "net.ipv4.tcp_synack_retries"
  "net.ipv4.tcp_tw_reuse"
  "net.ipv4.tcp_fin_timeout"
)

for param in "${PARAMS[@]}"; do
  value=$(sysctl -n "$param" 2>/dev/null)
  if [ $? -eq 0 ]; then
    echo "$param = $value" >> $BACKUP_FILE
  fi
done

echo "Backup created: $BACKUP_FILE"
