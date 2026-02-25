# 🛠️ Troubleshooting Guide — Lab 20: Comprehensive Performance Tuning Review

> This troubleshooting guide is based strictly on the tasks performed in **Lab 20** and the kinds of issues that can occur while collecting metrics, applying tuning, and validating changes in a **CentOS/RHEL 9 cloud VM**.

---

## ✅ Issue 1: “Permission denied” when creating `/opt/performance-review` or writing to it

### 🔍 Symptom
Commands like `mkdir` or writing logs fail under `/opt/`.

### ✅ Cause
`/opt` is root-owned by default.

### ✅ Fix (lab-consistent)
```bash
sudo mkdir -p /opt/performance-review
sudo mkdir -p /opt/performance-review/{cpu-data,memory-data,disk-data,network-data,reports}
sudo chown -R centos:centos /opt/performance-review
````

---

## ✅ Issue 2: `sar` shows no historical data or `/var/log/sa/` is missing

### 🔍 Symptom

* `sar -u` shows no data
* `/var/log/sa/sa*` does not exist

### ✅ Cause

`sysstat` may not be installed or the `sysstat` service is not enabled.

### ✅ Fix

```bash
sudo dnf install -y sysstat
sudo systemctl enable --now sysstat
ls -la /var/log/sa/
```

---

## ✅ Issue 3: `stress-ng` not found

### 🔍 Symptom

Running `stress-ng` fails: command not found.

### ✅ Fix (used pattern in lab)

```bash
which stress-ng || sudo dnf install -y stress-ng
```

---

## ✅ Issue 4: `perf` not found or fails to run

### 🔍 Symptom

* `perf: command not found`
* `perf record` fails due to permissions or restrictions

### ✅ Fix (lab-consistent)

```bash
which perf || sudo dnf install -y perf
sudo perf record -g -a sleep 60
```

> **Note:** In some cloud environments, kernel settings may limit perf events. If so, fall back to `sar/top/iostat` as primary evidence and document that perf is restricted.

---

## ✅ Issue 5: CPU governor file missing (`cpufreq not available`)

### 🔍 Symptom

`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor` returns nothing.

### ✅ Cause (observed in lab)

Many cloud VMs do not expose CPU frequency scaling.

### ✅ Fix / Handling (lab style)

* Treat it as **expected behavior**, not an error.
* Keep the optimization script tolerant:

```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "N/A"
```

---

## ✅ Issue 6: Writing to `/proc/sys/...` fails in memory tuning

### 🔍 Symptom

Errors while changing:

* `/proc/sys/vm/drop_caches`
* `/proc/sys/vm/swappiness`
* `/proc/sys/vm/overcommit_memory`

### ✅ Cause

Requires root privileges.

### ✅ Fix

Run the script with sudo:

```bash
sudo ./optimize-memory.sh
```

---

## ✅ Issue 7: `bc` not found (analysis scripts fail)

### 🔍 Symptom

Scripts fail when calculating memory percent or comparing load vs cores.

### ✅ Fix (lab-consistent)

```bash
which bc || sudo dnf install -y bc
```

---

## ✅ Issue 8: Disk scheduler tuning not applied because device name differs (`vda` vs `sda`)

### 🔍 Symptom

Script targets `/sys/block/sd*/...` but VM disk is `vda`.

### ✅ Cause

Virtio disks appear as `vda` commonly in cloud VMs.

### ✅ Fix

Check current schedulers first:

```bash
for disk in /sys/block/*/queue/scheduler; do echo "$disk: $(cat $disk)"; done
```

If you want to tune `vda` explicitly:

```bash
echo mq-deadline | sudo tee /sys/block/vda/queue/scheduler
```

---

## ✅ Issue 9: `sar -u 1 3 | grep Average` gives empty output

### 🔍 Symptom

The I/O wait line in `analyze-disk.sh` is empty.

### ✅ Cause

Some `sar` builds output “Average:” or “Average” differently depending on locale/version.

### ✅ Fix (robust approach)

```bash
sar -u 1 3 | tail -1
```

Or adjust grep:

```bash
sar -u 1 3 | grep -i average
```

---

## ✅ Issue 10: `wait` in scripts “hangs” longer than expected

### 🔍 Symptom

Scripts appear stuck after starting background commands.

### ✅ Cause

`wait` blocks until all background tasks finish.

* In this lab, tests are intentionally timed (e.g., 300s stress).

### ✅ Fix

* Confirm expected runtime.
* If the system becomes unresponsive, stop workloads:

```bash
sudo killall stress-ng
sudo pkill -f stress-ng
```

---

## ✅ Issue 11: Low disk space during testing/logging

### 🔍 Symptom

* `dd` fails or logs cannot be written
* `df -h` shows high usage

### ✅ Fix (lab-consistent approach)

* Remove `/tmp/testfile`:

```bash
sudo rm -f /tmp/testfile
```

* Clear old temp:

```bash
sudo find /tmp -type f -atime +7 -delete 2>/dev/null
sudo find /var/tmp -type f -atime +7 -delete 2>/dev/null
```

* Identify large files:

```bash
sudo find / -type f -size +100M 2>/dev/null | head -10
```

---

## ✅ Issue 12: Cron jobs not appearing after setup

### 🔍 Symptom

`crontab -l` shows nothing.

### ✅ Cause

Script may not have run as the correct user or cron service issues.

### ✅ Fix

1. Verify user context:

```bash
crontab -l
sudo crontab -l
```

2. Reapply entries (same pattern used in lab):

```bash
(crontab -l 2>/dev/null; echo "0 6 * * * /opt/performance-monitoring/daily-monitor.sh") | crontab -
(crontab -l 2>/dev/null; echo "0 7 * * 1 /opt/performance-monitoring/weekly-monitor.sh") | crontab -
```

---

## ✅ Best Practices Used in This Lab

* Always separate **data collection**, **analysis**, and **optimization** steps
* Store evidence artifacts in structured folders (`cpu-data/`, `reports/`, etc.)
* Prefer persistent configs in `/etc/sysctl.d/` over editing random files
* Make scripts **VM-safe** (handle missing cpufreq gracefully)
* Use repeatable tests (`performance-test.sh`) and save raw results
* Document the system state and tuning changes in a final report

---
