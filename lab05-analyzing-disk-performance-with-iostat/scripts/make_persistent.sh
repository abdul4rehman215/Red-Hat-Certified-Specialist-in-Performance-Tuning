#!/bin/bash
# Make I/O Scheduler Changes Persistent
UDEV_RULE_FILE="/etc/udev/rules.d/60-io-schedulers.rules"
echo "Creating persistent I/O scheduler configuration..."
# Backup existing rules if they exist
if [ -f "$UDEV_RULE_FILE" ]; then
 cp "$UDEV_RULE_FILE" "${UDEV_RULE_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
fi
# Create new udev rules
cat > "$UDEV_RULE_FILE" << 'UDEV_EOF'
# I/O Scheduler optimization rules
# Generated automatically - modify with care
# SSD devices - use kyber scheduler
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="kyber"
ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="kyber"
# HDD devices - use mq-deadline scheduler
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="mqdeadline"
# Additional optimizations for SSDs
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/nr_requests}="64"
ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/nr_requests}="64"
UDEV_EOF
echo "Udev rules created at: $UDEV_RULE_FILE"
echo "Rules will take effect after reboot or udev reload."
# Reload udev rules
udevadm control --reload-rules
udevadm trigger
echo "Udev rules reloaded successfully."
