# 🛠️ Troubleshooting Guide - Lab 06: mpstat + Multi-Core CPU Analysis

> This document captures common issues encountered while installing/using `mpstat`, enabling sysstat historical logging, and running multi-core CPU analysis automation.

---

## ✅ Issue 1: `mpstat: command not found`

### **Symptoms**
Running `mpstat` returns:
- `mpstat: command not found`

### **Cause**
`mpstat` is part of the **sysstat** package and may not be installed by default.

### **Fix**
**Ubuntu/Debian**
```bash
sudo apt update
sudo apt install -y sysstat
````

**RHEL/CentOS**

```bash
sudo yum install -y sysstat
# or
sudo dnf install -y sysstat
```

### **Validation**

```bash
mpstat -V
```

---

## ✅ Issue 2: `sar` shows no data / historical logs missing

### **Symptoms**

* `sar -u` shows empty results
* `sar: Cannot open /var/log/sysstat/saXX: No such file or directory`

### **Cause**

`sysstat` service may not be enabled or data collection may be disabled in config.

### **Fix**

Enable and start sysstat:

```bash
sudo systemctl enable sysstat
sudo systemctl start sysstat
```

Ensure sysstat is enabled in config:

```bash
cat /etc/default/sysstat
```

Look for:

```text
ENABLED="true"
```

If it’s `"false"`, update it:

```bash
sudo nano /etc/default/sysstat
# set ENABLED="true"
sudo systemctl restart sysstat
```

### **Validation**

Wait a few minutes, then try:

```bash
sar -u
sar -P ALL
```

---

## ✅ Issue 3: `systemctl status sysstat` shows `active (exited)` and looks suspicious

### **Symptoms**

* `sysstat.service` shows:

  * `Active: active (exited)`

### **Cause**

This is normal behavior on many systems. The sysstat service often triggers scripts and timers that handle periodic data collection.

### **Fix**

No fix required.

### **Validation**

Check sysstat timers (optional):

```bash
systemctl list-timers | grep sysstat
```

---

## ✅ Issue 4: CPU load test not working / stress not installed

### **Symptoms**

Running `stress` returns:

* `stress: command not found`

### **Cause**

The `stress` package is not installed.

### **Fix**

**Ubuntu/Debian**

```bash
sudo apt install -y stress
```

**RHEL/CentOS**

```bash
sudo yum install -y stress
# or
sudo dnf install -y stress
```

### **Validation**

```bash
stress --version
```

---

## ✅ Issue 5: `taskset: command not found` or CPU affinity tests fail

### **Symptoms**

* `taskset` missing
* CPU affinity test script fails to run pinned workloads

### **Cause**

`taskset` is provided by the `util-linux` package, which is usually installed, but may be missing in minimal containers/images.

### **Fix**

**Ubuntu/Debian**

```bash
sudo apt install -y util-linux
```

**RHEL/CentOS**

```bash
sudo yum install -y util-linux
```

### **Validation**

```bash
taskset --help | head
```

---

## ✅ Issue 6: Script comparisons fail with `bc: command not found`

### **Symptoms**

While running report scripts:

* `bc: command not found`
* numeric threshold comparisons fail

### **Cause**

Some scripts compare floating values using `bc`.

### **Fix**

**Ubuntu/Debian**

```bash
sudo apt install -y bc
```

**RHEL/CentOS**

```bash
sudo yum install -y bc
# or
sudo dnf install -y bc
```

### **Validation**

```bash
bc --version | head -1
```

---

## ✅ Issue 7: Monitoring scripts generate high CPU usage themselves

### **Symptoms**

* Monitoring increases CPU load noticeably
* `mpstat` sampling too frequently causes overhead

### **Cause**

Aggressive intervals like `mpstat -P ALL 1` repeated continuously can add overhead on low-resource systems.

### **Fix**

Use longer intervals:

```bash
mpstat -P ALL 10 6
```

Run monitoring at lower priority:

```bash
nice -n 10 mpstat -P ALL 5
```

For long-running scripts:

* increase sleep window (e.g., from 60s to 300s)
* reduce count or frequency

---

## ✅ Issue 8: Historical log file path differs (`/var/log/sa` vs `/var/log/sysstat`)

### **Symptoms**

Scripts fail to locate SAR files in expected directory.

### **Cause**

Different distributions store sysstat logs in different directories.

### **Fix**

Check both:

```bash
ls -la /var/log/sysstat 2>/dev/null
ls -la /var/log/sa 2>/dev/null
```

Update scripts to dynamically select the correct folder (already done in this lab's `historical_analysis.sh`).

---

## ✅ Issue 9: `cpu_dashboard.sh` prints “requires interactive terminal”

### **Symptoms**

Script prints:

* `This script requires interactive terminal. Run directly: ./cpu_dashboard.sh`

### **Cause**

The script checks interactive mode:

```bash
if [ -t 0 ]; then ...
```

### **Fix**

Run directly in a terminal:

```bash
./cpu_dashboard.sh
```

Avoid running it through a non-interactive pipe, cron, or redirect.

---

## ✅ Issue 10: `cpu_stats.log` missing for bottleneck scripts

### **Symptoms**

`detect_bottlenecks.sh` can’t find `cpu_stats.log`

### **Cause**

`cpu_analysis.sh` wasn’t run before running bottleneck detection.

### **Fix**

Generate logs first:

```bash
./cpu_analysis.sh 60 2
./detect_bottlenecks.sh
```

### **Validation**

```bash
ls -la cpu_stats.log
```
