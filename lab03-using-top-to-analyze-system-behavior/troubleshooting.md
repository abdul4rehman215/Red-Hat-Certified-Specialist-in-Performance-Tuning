# 🛠️ Troubleshooting Guide — Lab 03: Using `top` to Analyze System Behavior

> This troubleshooting guide documents issues seen in the lab and the most common real-world causes/fixes when using `top`, `stress`, and priority controls (`nice`/`renice`) on RHEL-based systems.

---

## 1) `stress: command not found`

### ✅ Symptoms
```text
-bash: stress: command not found
````

### 🔍 Cause

The `stress` package was not installed.

### ✅ Fix (Used in this lab)

On RHEL 9 use `dnf`:

```bash
sudo dnf install -y stress
stress --version
```

---

## 2) `yum` not available on RHEL 9 (suggests using dnf)

### ✅ Symptoms

```text
No such command: yum. Please use dnf instead.
```

### 🔍 Cause

On RHEL 9, `dnf` is the supported package manager. `yum` may not exist or is redirected depending on system configuration.

### ✅ Fix

```bash
sudo dnf install -y <package>
```

---

## 3) Load average is high but CPU usage looks low (confusing metrics)

### ✅ Symptoms

* load average is high
* `%Cpu(s)` shows high `id` (idle) or low `us`

### 🔍 Cause (common)

High load does not always mean CPU saturation. It can occur when tasks are stuck in uninterruptible sleep (`D` state) waiting on disk/network I/O.

### ✅ Fix / Verification Steps

1. Check I/O wait in `top`:

* look for `wa` > 0
* check if many tasks are in `D` state

2. Verify with `iostat`:

```bash
iostat -x 1 5
```

3. Check disk space and pressure:

```bash
df -h
```

---

## 4) Process appears stuck in `D` state

### ✅ Symptoms

In `top`, a process shows state `D` (example: `dd`).

### 🔍 Cause

The process is waiting on I/O (disk read/write), filesystem latency, or storage throttling.

### ✅ Fix / Best Practices

* confirm I/O pressure with:

```bash
iostat -x 1 5
```

* reduce disk-heavy jobs during peak hours:

  * run them at lower priority
  * schedule off-peak
* avoid killing important storage tasks unless required (could risk data consistency)

---

## 5) `top` feels unresponsive or “hangs”

### ✅ Symptoms

* `top` not responding smoothly
* input keys lagging

### 🔍 Cause

This can happen during heavy CPU load when interactive refresh becomes slow.

### ✅ Fix (Used in lab)

Kill stuck top sessions and switch to `htop` if available:

```bash
pkill top
htop
```

---

## 6) Cannot change process priority (renice fails)

### ✅ Symptoms

* `renice` returns permission errors
* negative nice values fail

### 🔍 Cause

Increasing priority (negative nice) requires root privileges.
Some processes may also be protected by policy/cgroups.

### ✅ Fix

Use sudo for negative nice values:

```bash
sudo renice -10 <PID>
```

Verify the process exists:

```bash
ps -p <PID>
```

---

## 7) `renice` seems to work but CPU usage doesn’t change much

### ✅ Symptoms

* nice value changed successfully
* CPU share seems similar

### 🔍 Cause

Nice has the biggest effect when there is CPU contention. If system is not CPU-saturated, priority changes may not be obvious.

### ✅ Fix / Verification

Generate contention (carefully in lab environments) and compare:

```bash
ps -o pid,ni,%cpu,comm -p <pid1>,<pid2>,<pid3>
```

---

## 8) Memory usage “looks wrong” in top

### ✅ Symptoms

* high memory usage shown
* “free memory” looks low, causing confusion

### 🔍 Cause

Linux uses free memory for filesystem cache. Low “free” memory is not automatically a problem.
The better indicator is **available memory**, plus swap activity.

### ✅ Fix / Verification

```bash
free -h
cat /proc/meminfo | head -20
```

If swap usage increases rapidly, memory pressure is real.

---

## 9) `netstat` not found inside system_monitor.sh

### ✅ Symptoms

* script fails at the netstat section

### 🔍 Cause

On newer RHEL systems, `netstat` may not be installed by default (it comes from `net-tools`).

### ✅ Fix

```bash
sudo dnf install -y net-tools
```

Alternative modern tool (if you choose later):

```bash
ss -tuln
```

---

## 10) Cleanup doesn’t stop all test processes

### ✅ Symptoms

* resource generators still running
* CPU stays high after cleanup

### 🔍 Cause

Background jobs can spawn child processes (e.g., multiple `stress` or shell loops). Sometimes the match pattern misses a process.

### ✅ Fix

Use targeted pkill patterns and verify:

```bash
pkill -f resource_test.sh
pkill stress
ps aux | egrep "resource_test|stress|python3|dd" | head
```

If needed, kill by PID:

```bash
kill -9 <PID>
```

---

## ✅ Best Practices Reinforced by This Lab

* Always confirm the package manager (`dnf` on RHEL 9)
* Interpret load average together with `%iowait` and process states
* Use sorting (`P`, `M`) and locate (`L`) to quickly identify hogs
* Prefer `nice/renice` to reduce impact of background work instead of killing processes
* Log evidence (`top -b`) for reports and RCA
* Clean up workloads and verify the system returns to baseline

---
