# 🛠️ Troubleshooting Guide — Lab 18: SystemTap for Kernel Performance Analysis

> This troubleshooting guide is based strictly on the lab workflow and realistic issues when running SystemTap scripts on CentOS/RHEL 8/9.

---

## ✅ Issue 1: SystemTap Not Installed or Missing Components

### 🔍 Symptom
- `stap: command not found`
- `rpm -qa | grep systemtap` returns nothing

### ✅ Fix / Commands Used in Lab (Install / Verify)
```bash
sudo dnf install -y systemtap systemtap-runtime
sudo dnf install -y kernel-devel gcc
````

Confirm installation:

```bash
rpm -qa | grep systemtap
stap --version
```

---

## ✅ Issue 2: Kernel Debuginfo / Symbols Missing (Kernel Probes Fail)

### 🔍 Symptom

* Stap compilation fails when probing kernel functions
* Errors often mention missing symbols or debuginfo

### ✅ Validation Step Used

```bash
ls /usr/lib/debug/lib/modules/$(uname -r)/
```

Expected to see:

* `kernel/`
* `vmlinux`

### ✅ Fix / Commands Used in Lab

```bash
sudo dnf install -y kernel-debuginfo kernel-debuginfo-common-$(uname -m)
```

---

## ✅ Issue 3: SystemTap Doesn’t Run Any Probe Output

### 🔍 Symptom

* Script starts but prints nothing
* Log file exists but remains empty for a while

### ✅ Why This Happens

Many scripts in this lab print output on timers (every 5s / 10s / 15s / 20s / 30s).
So the log file can be empty until the first interval tick occurs.

### ✅ What We Observed in the Lab

`/tmp/dashboard.log` was size 0 initially and then updated after the first 5-second tick.

### ✅ Fix / Validation

Wait for one interval, then check:

```bash
ls -l /tmp/dashboard.log
tail -f /tmp/dashboard.log
```

---

## ✅ Issue 4: `curl -I http://localhost` Fails

### 🔍 Symptom

```text
curl: (7) Failed to connect to localhost port 80: Connection refused
```

### ✅ Explanation (Observed in Lab)

No web server is running on port 80 in this VM, so the failure is normal.

### ✅ Verification Used

Check listening services:

```bash
netstat -tuln
```

---

## ✅ Issue 5: SystemTap Script Produces Very Little Output

### 🔍 Symptom

* I/O or syscall scripts show low counts

### ✅ Explanation

If the system is idle, there may not be enough activity to generate events.
In the lab, we intentionally generated I/O and syscalls to trigger probes.

### ✅ Workload Commands Used (Lab-Accurate)

```bash
dd if=/dev/zero of=/tmp/testfile bs=1M count=100
cp /tmp/testfile /tmp/testfile_copy
find /usr -name "*.conf" -type f | head -20 | xargs cat > /tmp/config_dump
rm /tmp/testfile /tmp/testfile_copy /tmp/config_dump
```

---

## ✅ Issue 6: Stopping a Background SystemTap Script

### 🔍 Symptom

* `stap` is running in background and you want to stop it safely

### ✅ Fix / Commands Used in Lab

Capture the PID:

```bash
sudo stap script.stp &
PID=$!
```

Stop it:

```bash
sudo kill $PID
```

In the lab this method was used for:

* `io_bottleneck_detector.stp`
* `performance_monitor.stp`
* `realtime_dashboard.stp`

---

## ✅ Issue 7: High Context Switch Warning in Monitor Output

### 🔍 Symptom

Monitor prints:

```text
WARNING: High context switch rate detected!
```

### ✅ Meaning (Observed in Lab)

During mixed load generation (`yes` + Python allocation + I/O), context switches rose above threshold in the 10-second interval. This is expected when multiple busy processes compete for CPU time.

### ✅ What We Did

This was treated as a useful signal rather than an error. After testing, we stopped the load and stopped the monitor:

```bash
sudo kill $PERF_PID
```

---

## ✅ Issue 8: Dashboard Output Doesn’t Change Much

### 🔍 Symptom

Dashboard prints similar syscall counts or low I/O numbers

### ✅ Explanation

If no workload is running, syscall volume and I/O bytes can be low.

### ✅ Fix / Generate Quick Activity (Lab-Accurate)

```bash
dd if=/dev/zero of=/tmp/dash_test bs=1M count=30 2>/dev/null
rm -f /tmp/dash_test
```

---

## ✅ Notes / Best Practices (Lab-Relevant)

* Always confirm debuginfo is present before kernel.function probes
* Use short controlled load generators for repeatable tests
* Prefer timer-based interval reporting for “dashboard” views
* Stop background stap scripts cleanly using PID-based kill
* Use `tail -f` for live visibility when logging stap output to a file

---
