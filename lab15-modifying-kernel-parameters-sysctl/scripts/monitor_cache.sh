#!/bin/bash
echo "Cache Usage Monitoring"
echo "====================="
echo "VFS Cache Pressure: $(sysctl -n vm.vfs_cache_pressure)"
echo
echo "Cache Statistics:"
cat /proc/meminfo | grep -E "(Cached|Buffers|SReclaimable|SUnreclaim)"
echo
echo "Slab Information:"
cat /proc/slabinfo | head -5
