#!/bin/bash
PROFILE_DIR="/etc/sysctl.d"

create_web_server_profile() {
  echo "Creating web server performance profile..."

  sudo tee ${PROFILE_DIR}/90-webserver-profile.conf << 'WEBEOF'
# Web Server Performance Profile

# Memory optimizations for web servers
vm.swappiness = 1
vm.dirty_ratio = 10
vm.dirty_background_ratio = 3
vm.vfs_cache_pressure = 50

# Network optimizations for high connection loads
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_keepalive_time = 300

# Buffer optimizations
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216

# File handle limits
fs.file-max = 1000000
WEBEOF
}

create_database_profile() {
  echo "Creating database server performance profile..."

  sudo tee ${PROFILE_DIR}/90-database-profile.conf << 'DBEOF'
# Database Server Performance Profile

# Memory optimizations for databases
vm.swappiness = 1
vm.dirty_ratio = 5
vm.dirty_background_ratio = 2
vm.dirty_expire_centisecs = 1500
vm.dirty_writeback_centisecs = 250
vm.vfs_cache_pressure = 200

# Shared memory optimizations
kernel.shmmax = 68719476736
kernel.shmall = 4294967296

# Network optimizations
net.core.rmem_default = 262144
net.core.rmem_max = 16777216
net.core.wmem_default = 262144
net.core.wmem_max = 16777216

# File system optimizations
fs.file-max = 2097152
fs.aio-max-nr = 1048576
DBEOF
}

create_default_profile() {
  echo "Creating balanced default profile..."

  sudo tee ${PROFILE_DIR}/90-default-profile.conf << 'DEFEOF'
# Balanced Default Performance Profile

# Balanced memory settings
vm.swappiness = 10
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
vm.vfs_cache_pressure = 100

# Standard network settings
net.core.somaxconn = 1024
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 30

# Standard buffer sizes
net.core.rmem_default = 212992
net.core.wmem_default = 212992
DEFEOF
}

show_help() {
  echo "Available profiles:"
  echo " - webserver"
  echo " - database"
  echo " - default"
  echo "Usage:"
  echo " $0 <profile>"
  echo "Example:"
  echo " $0 webserver"
}

case "$1" in
  "webserver")
    create_web_server_profile
    echo "Applying sysctl profiles..."
    sudo sysctl --system >/dev/null
    echo "Done."
    ;;
  "database")
    create_database_profile
    echo "Applying sysctl profiles..."
    sudo sysctl --system >/dev/null
    echo "Done."
    ;;
  "default")
    create_default_profile
    echo "Applying sysctl profiles..."
    sudo sysctl --system >/dev/null
    echo "Done."
    ;;
  "list")
    show_help
    ;;
  *)
    show_help
    exit 1
    ;;
esac
