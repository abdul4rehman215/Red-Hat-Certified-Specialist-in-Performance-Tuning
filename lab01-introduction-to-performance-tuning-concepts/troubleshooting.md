# 🛠️ Troubleshooting — Lab 01: Introduction to Performance Tuning Concepts

> This troubleshooting guide documents real issues encountered in this lab and the fixes applied.

---

## 1) `cat: /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor: No such file or directory`

### ✅ Symptoms
```text
cat: /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor: No such file or directory
cat: /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors: No such file or directory
````

### 🔍 Cause

On many **cloud/virtualized** systems, CPU frequency scaling interfaces are not exposed via the classic `cpufreq` sysfs path. The CPU driver (e.g., `intel_pstate`) may be managed differently.

### ✅ Fix (Used in this lab)

Install `kernel-tools` and use `cpupower`:

```bash
sudo dnf install -y kernel-tools
cpupower frequency-info
sudo cpupower frequency-set -g performance
```

---

## 2) `stress-ng` command uses more CPU workers than available cores

### ✅ Symptoms

Running:

```bash
stress-ng --cpu 4 --timeout 60s --metrics-brief
```

on a system with **2 CPU cores** still works but may show >100% CPU usage in metrics.

### 🔍 Cause

The lab intentionally created a CPU-heavy workload. Worker count is not required to match core count.

### ✅ Fix / Best Practice

On small VMs, use:

```bash
stress-ng --cpu "$(nproc)" --timeout 60s --metrics-brief
```

This scales automatically to the host.

---

## 3) `sysstat` appears "active (exited)" and looks confusing

### ✅ Symptoms

```text
Active: active (exited)
```

### 🔍 Cause

`sysstat.service` is a **oneshot** service that initializes logging (`sa1 --boot`).
The real periodic collection is controlled through sysstat timers/cron-style mechanisms depending on distro config.

### ✅ Fix / Verification

Confirm sysstat is enabled and sar works:

```bash
systemctl is-enabled sysstat
sar -u 1 3
```

---

## 4) `iotop` doesn’t show useful output or shows zero I/O

### ✅ Symptoms

* `iotop` shows minimal disk reads/writes
* no obvious I/O-heavy processes

### 🔍 Cause

System is idle, or storage workload is too light. Also, some disk activity might be cached.

### ✅ Fix

Generate controlled disk I/O load for testing:

```bash
dd if=/dev/zero of=/tmp/io_test bs=1M count=512 oflag=direct
rm -f /tmp/io_test
```

Or run disk stress testing via `stress-ng`:

```bash
stress-ng --hdd 2 --hdd-bytes 1G --timeout 30s --metrics-brief
```

---

## 5) `iostat` command not found

### ✅ Symptoms

```text
bash: iostat: command not found
```

### 🔍 Cause

`iostat` is provided by the `sysstat` package.

### ✅ Fix

```bash
sudo dnf install -y sysstat
```

---

## 6) `sar` shows no data / "Cannot open ..."

### ✅ Symptoms

* `sar` fails
* sar reports missing activity data files

### 🔍 Cause

sysstat is installed but not enabled or has not collected enough samples yet.

### ✅ Fix

Enable and start sysstat, then wait for data:

```bash
sudo systemctl enable sysstat
sudo systemctl start sysstat
sar -u 1 3
```

---

## 7) Script writing to `/var/log/*.log` fails with permission denied

### ✅ Symptoms

```text
Permission denied: /var/log/cpu_performance.log
```

### 🔍 Cause

Writing to `/var/log` requires root privileges.

### ✅ Fix (Used in this lab)

Use `sudo tee` for privileged writes:

```bash
echo "header" | sudo tee /var/log/cpu_performance.log >/dev/null
echo "line" | sudo tee -a /var/log/cpu_performance.log >/dev/null
```

---

## 8) Cache drop command fails inside scripts due to sudo redirection

### ✅ Symptoms

A common failure pattern (not always shown directly):

```bash
sudo echo 3 > /proc/sys/vm/drop_caches
# fails silently or permission denied
```

### 🔍 Cause

Shell redirection (`>`) happens before sudo runs, so the write occurs as the current user.

### ✅ Fix (Applied in this lab)

Use `tee`:

```bash
echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null
```

---

## 9) `cpupower frequency-set -g performance` fails

### ✅ Symptoms

* cpupower errors
* governor not available

### 🔍 Cause

Some VMs restrict governor changes, or the driver only supports limited governor modes.

### ✅ Fix / Workarounds

1. Verify what governors are available:

```bash
cpupower frequency-info
```

2. Use the supported governor (`powersave` or `performance`) only.

3. If governor changes are blocked by policy, document it and continue with monitoring-based tuning:

* priority tuning (nice/renice)
* affinity tuning (taskset)
* workload optimization

---

## 10) Disk scheduler write fails (permission or unsupported scheduler)

### ✅ Symptoms

* writing to `/sys/block/<dev>/queue/scheduler` fails
* scheduler name is not accepted

### 🔍 Cause

Scheduler availability depends on device type (NVMe vs SATA vs virtio) and kernel configuration.

### ✅ Fix

1. Check available schedulers:

```bash
cat /sys/block/<dev>/queue/scheduler
```

2. Choose one that appears in the list (for NVMe typically `none` or `mq-deadline`):

```bash
echo none | sudo tee /sys/block/nvme0n1/queue/scheduler
```

---

## ✅ General Best Practices (Used Throughout This Lab)

* Always create a **baseline** before tuning
* Change one thing at a time and validate with metrics
* Prefer safe, reversible tuning:

  * sysctl files under `/etc/sysctl.d/`
  * scripts for repeatability
* Record outputs and results for documentation and comparison

---
