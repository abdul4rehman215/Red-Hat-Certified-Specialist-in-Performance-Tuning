# 🛠️ Troubleshooting Guide — Lab 04: Exploring `vmstat` for Memory and CPU Insights

> This troubleshooting guide records issues observed in the lab and common real-world causes/fixes when using `vmstat` on RHEL-based cloud systems.

---

## 1) `vmstat: command not found`

### ✅ Symptoms
```text
vmstat: command not found
````

### 🔍 Cause

`vmstat` is provided by the `procps-ng` (RHEL) / `procps` (Debian/Ubuntu) package family.
If missing, the system doesn’t have procps tools installed.

### ✅ Fix (RHEL/CentOS)

> Note: RHEL 9 uses `dnf` even if old notes mention `yum`.

```bash id="9zq9a7"
sudo dnf install -y procps-ng
```

### ✅ Fix (Ubuntu/Debian)

```bash id="hbrz4d"
sudo apt-get update
sudo apt-get install -y procps
```

---

## 2) Permission denied while monitoring system metrics

### ✅ Symptoms

* Some system stats or files are inaccessible
* `vmstat` outputs but other related commands fail in scripts

### 🔍 Cause

Certain monitoring actions may require elevated privileges.

### ✅ Fix

Run with sudo:

```bash id="l95gtj"
sudo vmstat 1 3
```

---

## 3) Swap “exists” but performance impact is confusing (zram swap)

### ✅ Symptoms

* `swapon --show` shows `/dev/zram0`
* swap usage appears but disk I/O isn't obviously high

### 🔍 Cause

The system uses **zram** swap (compressed RAM-based swap).
It can still cause CPU overhead and indicates memory pressure, but it is not disk swap.

### ✅ Fix / Best Practice

* Confirm swap device:

```bash id="xjrz2k"
swapon --show
```

* Treat increasing `swpd` + nonzero `si/so` as memory pressure regardless of zram/disk swap.

---

## 4) `swpd` is nonzero but `si`/`so` are zero — is that a problem?

### ✅ Symptoms

* `swpd` > 0
* `si` and `so` stay at 0 during sampling

### 🔍 Cause

This can be normal:

* swap was used earlier and pages remain in swap
* system is not currently swapping actively

### ✅ How to Interpret

* **Active swapping** is indicated by **nonzero `si/so`** repeatedly.
* `swpd` alone indicates swap usage exists, not necessarily current swapping.

---

## 5) `vmstat -p /dev/sda1` fails on cloud VM

### ✅ Symptoms

```text id="4q90ur"
vmstat: failed to get partition stat /dev/sda1
```

### 🔍 Cause

Cloud VMs often use NVMe or virtio disks (`/dev/nvme0n1p1`, `/dev/vda1`) instead of `sda1`.

### ✅ Fix (Used in this lab)

1. Find the correct partition:

```bash id="g5l72x"
lsblk
```

2. Use the correct device:

```bash id="0pvq0w"
vmstat -p /dev/nvme0n1p1 2 5
```

---

## 6) Memory load test uses temp files — may affect I/O and not purely memory

### ✅ Symptoms

* memory_test.sh uses `dd` to create large files in `/tmp`
* vmstat shows increased `bo` (write output)

### 🔍 Cause

Writing files creates disk I/O, not just memory usage. It still creates memory pressure through cache and filesystem buffers, but it’s not a pure heap allocation test.

### ✅ Fix / Best Practice (Optional Improvement Later)

If you want a pure memory test, use:

* `stress --vm ...`
* or a Python allocation script
  For this lab, we kept the script as provided.

---

## 7) Swap pressure script didn’t trigger swap (no `swpd` increase)

### ✅ Symptoms

* `so` stays 0
* `swpd` stays 0 even under load

### 🔍 Cause

Possible reasons:

* the system had enough available memory
* memory pressure was not high enough
* workload duration too short
* kernel swappiness settings and zram behavior can delay swap activation

### ✅ Fix

Increase the allocation target or run longer (carefully):

```bash id="chcpxc"
# Example: increase memory pressure percentage (if safe in your VM)
# Adjust inside swap_test.sh to allocate closer to total RAM.
```

Also confirm `stress` exists:

```bash id="jfb8t7"
command -v stress || sudo dnf install -y stress
```

---

## 8) `memory_trend.csv` has an extra value at end of CSV line

### ✅ Symptoms

Example line:

```text
14:33:01,1457,1342,25,992,32,2228
```

(Extra number at end)

### 🔍 Cause

The script combines values from multiple `free -m` fields in a way that adds an extra column.

### ✅ Fix (If you choose to refine later)

Use a single `awk` pass and explicitly print the correct columns.
For this lab, the script was kept as-is to match the workflow.

---

## 9) Dashboard/simulator leaves background processes running

### ✅ Symptoms

* CPU remains high after simulation
* unexpected temp files remain in `/tmp`

### 🔍 Cause

Simulators spawn background loops (`bc`, `dd`) and create temporary files. If interrupted forcefully, cleanup may not run.

### ✅ Fix

Use the built-in cleanup (trap), or manually cleanup:

```bash id="k4pz5m"
killall dd bc 2>/dev/null
rm -f /tmp/leak_* /tmp/iobottleneck_* /tmp/ioload_* /tmp/swaptest_* /tmp/memtest_* /tmp/iotest_*
```

---

## ✅ Best Practices Reinforced by This Lab

* Always interpret vmstat trends using multiple columns together:

  * CPU: `us/sy/id/wa` + run queue `r`
  * I/O: blocked tasks `b` + `wa` + `bi/bo`
  * memory: `free` + `swpd` + `si/so`
* Confirm disk device naming (`lsblk`) before using `vmstat -p`
* Capture baselines during normal operation for later comparisons
* Use scripts/dashboards to turn raw metrics into repeatable evidence

---
