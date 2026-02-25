# 🛠️ Troubleshooting Guide — Lab 05: Analyzing Disk Performance with `iostat`

> This guide documents issues encountered in the lab and the most common real-world fixes when monitoring and tuning disk I/O using `iostat` and Linux I/O schedulers.

---

## 1) `iostat: command not found`

### ✅ Symptoms
```text
bash: iostat: command not found
````

### 🔍 Cause

`iostat` is part of the **sysstat** package.

### ✅ Fix (RHEL/CentOS)

```bash
sudo dnf install -y sysstat
```

### ✅ Fix (Ubuntu/Debian)

```bash
sudo apt-get update
sudo apt-get install -y sysstat
```

### ✅ Verify

```bash
iostat -V
rpm -q sysstat   # on RHEL
```

---

## 2) `iostat: cannot find device "/dev/sda"` (or `/dev/sdb`)

### ✅ Symptoms

```text
iostat: cannot find device "/dev/sda"
iostat: cannot find device "/dev/sdb"
```

### 🔍 Cause

Cloud VMs often use **NVMe** naming (`nvme0n1`) or **virtio** naming (`vda`) instead of `sda/sdb`.

### ✅ Fix (Used in this lab)

```bash
lsblk
iostat -x 2 nvme0n1 nvme1n1
```

---

## 3) Confusing iostat output: “first report looks wrong”

### ✅ Symptoms

* First output line doesn't match expected “current” behavior.

### 🔍 Cause

The first report often includes averages since boot (or since iostat started) and may differ from interval-based sampling.

### ✅ Best Practice

Use interval mode and focus on later samples:

```bash
iostat -x 2
```

---

## 4) High system load but `%util` not high

### ✅ Symptoms

* Load average rises, but `%util` stays low.

### 🔍 Cause

Load can increase due to:

* CPU contention
* memory pressure
* blocked processes not purely disk saturation
* other subsystems (network, kernel, filesystem locks)

### ✅ Fix / Next Checks

Correlate with other tools:

```bash
vmstat 1 5
sar -u 1 5
sar -d 1 5
```

---

## 5) Permission denied when changing schedulers

### ✅ Symptoms

```text
Permission denied
```

or
scheduler changes do not apply.

### 🔍 Cause

Writing to `/sys/block/.../queue/scheduler` requires root.

### ✅ Correct Fix (IMPORTANT)

This fails (redirection happens before sudo):

```bash
sudo echo kyber > /sys/block/nvme0n1/queue/scheduler
```

Use `tee` instead:

```bash
echo kyber | sudo tee /sys/block/nvme0n1/queue/scheduler
```

---

## 6) Requested scheduler not available

### ✅ Symptoms

* You attempt to set `bfq` or `kyber` but it doesn’t exist in the scheduler list.

### 🔍 Cause

Schedulers depend on kernel support and configuration.

### ✅ Fix

Check what is actually available:

```bash
cat /sys/block/nvme0n1/queue/scheduler
```

Optional (if supported by your kernel):

```bash
sudo modprobe bfq
sudo modprobe kyber-iosched
```

---

## 7) System becomes slow/unresponsive during workload generation

### ✅ Symptoms

* CLI sluggish
* high iowait
* long command response times

### 🔍 Cause

The workload generator uses multiple concurrent `dd` operations and random reads, which can overwhelm small VMs.

### ✅ Fix Options

**Option A: Reduce intensity**

* reduce file sizes/counts in `io_workload_generator.sh`
* reduce concurrent loops

**Option B: Lower I/O priority**

```bash
ionice -c 3 ./io_workload_generator.sh mixed
```

**Option C: Stop test**

```bash
pkill -f io_workload_generator.sh
pkill dd
rm -rf /tmp/iostest
```

---

## 8) Inconsistent benchmark results between runs

### ✅ Symptoms

* “kyber better once, worse another time”
* metrics vary significantly

### 🔍 Cause

Common causes:

* cache effects
* background services/logging
* VM noisy neighbors
* different system state per run

### ✅ Fix / Best Practice

* run multiple iterations and average
* ensure system is quiet during tests
* optionally clear caches *carefully* before repeated tests

Safe cache drop (sudo + tee):

```bash
sudo sync
echo 3 | sudo tee /proc/sys/vm/drop_caches
```

---

## 9) Udev rule caveat: `mqdeadline` vs `mq-deadline`

### ✅ Symptoms

* rule applies but scheduler doesn’t change as expected after reboot
* or rule errors in logs

### 🔍 Cause

Some kernels expect the scheduler name as `mq-deadline` (with hyphen).
The lab’s udev file contains `mqdeadline` (no hyphen) in one rule:

```text
ATTR{queue/scheduler}="mqdeadline"
```

### ✅ Fix (If needed in your environment)

Update the rule to match what your system exposes:

```bash
cat /sys/block/<device>/queue/scheduler
```

Use the exact string it shows (e.g., `mq-deadline`).

> In this repo, the rule is kept exactly as used during the lab for authenticity.

---

## 10) Validation script generates “weird output” in report template

### ✅ Symptoms

* template variables don’t expand
* report shows raw `$(...)` lines

### 🔍 Cause

Script relies on `eval` to expand template content. If executed from the wrong directory or if filenames differ, expansions can break.

### ✅ Fix

Run it from the directory containing the scripts and ensure files exist:

```bash
ls -la
./validate_optimization.sh
```

Also verify the generated folder has expected logs:

```bash
ls -la validation_*
```

---

## ✅ Best Practices Reinforced by Lab 05

* Always confirm device naming via `lsblk` (NVMe vs SATA)
* Use `iostat -x` for real bottleneck analysis (await/queue/%util)
* Baseline → change → validate (avoid tuning blind)
* Persist changes with udev rules, but confirm scheduler strings match kernel output
* Use `ionice` for safe testing on small systems

---

