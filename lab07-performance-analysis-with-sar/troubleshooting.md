# 🛠️ Troubleshooting Guide - Lab 07 (sar + sysstat + Historical Performance Reporting)

> This document lists common issues encountered while configuring `sar`/`sysstat` on Ubuntu, adjusting collection intervals, locating SAR log files, and generating reports.

---

## ✅ Issue 1: `rpm: command not found`

### **Symptoms**
Running:
```bash
rpm -qa | grep sysstat
````

returns:

* `-bash: rpm: command not found`

### **Cause**

Ubuntu/Debian systems do not use RPM package tooling by default. They use `apt`.

### **Fix**

Use `apt`:

```bash
sudo apt update
sudo apt install -y sysstat
```

---

## ✅ Issue 2: SAR logs not found in `/var/log/sa`

### **Symptoms**

```bash
ls -la /var/log/sa/
```

returns:

* `No such file or directory`

or:

```bash
sar -u -f /var/log/sa/sa25
```

returns:

* `Cannot open /var/log/sa/sa25: No such file or directory`

### **Cause**

On Ubuntu, SAR logs commonly live under:

* `/var/log/sysstat/`

### **Fix**

Use the Ubuntu path:

```bash
ls -la /var/log/sysstat/
sar -u -f /var/log/sysstat/sa$(date +%d)
```

---

## ✅ Issue 3: Data collection not happening (no `saDD` files)

### **Symptoms**

* No `saDD` or `sarDD` files appear in `/var/log/sysstat/`
* `sar` shows missing file errors or empty history

### **Cause**

* sysstat service not enabled/started
* collection schedule not running (cron entries missing/disabled)

### **Fix**

Enable and start sysstat:

```bash
sudo systemctl enable sysstat
sudo systemctl start sysstat
sudo systemctl status sysstat
```

### **Validation**

```bash
ls -la /var/log/sysstat/
```

---

## ✅ Issue 4: Attempting to force collection using `/usr/lib64/sa/sa1` fails

### **Symptoms**

```bash
sudo /usr/lib64/sa/sa1 1 1
```

returns:

* `command not found`

### **Cause**

That path is typical in some RHEL-like environments, but on Ubuntu the collector is in `/usr/lib/sysstat/`.

### **Fix**

Use the Ubuntu path:

```bash
sudo /usr/lib/sysstat/sa1 1 1
```

### **Validation**

```bash
sar -u 1 1
```

---

## ✅ Issue 5: Cron collection interval change breaks the sysstat collector

### **Symptoms**

After editing `/etc/cron.d/sysstat`, data collection stops or errors occur.

### **Cause**

Using incorrect collector commands/paths in cron (e.g., `/usr/lib64/sa/sa1` on Ubuntu).

### **Fix**

Use Ubuntu’s debian helpers:

```text
*/2 * * * * root command -v debian-sa1 > /dev/null && debian-sa1 1 1
53 23 * * * root command -v debian-sa2 > /dev/null && debian-sa2 -A
```

### **Validation**

Wait a few minutes and confirm:

```bash
ls -la /var/log/sysstat/
```

---

## ✅ Issue 6: `sar` command works, but time range queries return nothing

### **Symptoms**

Using start time `-s` shows little or no output:

```bash
sar -u -s 10:00:00 -f /var/log/sysstat/sa25
```

### **Cause**

* Data collection may not have existed during the requested period
* Collection interval may be too sparse

### **Fix**

* Ensure collection is enabled and running
* Increase collection frequency (e.g., every 2 minutes)
* Validate data exists for the requested time window:

```bash
sar -u -f /var/log/sysstat/sa$(date +%d) | head
sar -u -f /var/log/sysstat/sa$(date +%d) | tail
```

---

## ✅ Issue 7: HTML report generated but text report is missing/unreadable

### **Symptoms**

* HTML report exists
* Text conversion fails or creates an empty file

### **Cause**

Text conversion tools not installed (`lynx` or `w3m`).

### **Fix**

Install `lynx` (as done in this lab):

```bash
sudo apt install -y lynx
```

### **Validation**

Re-run:

```bash
./master_performance_analysis.sh
ls -la /tmp/performance_reports/
```

---

## ✅ Issue 8: Analysis scripts show incorrect totals / wrong columns

### **Symptoms**

* CPU totals look wrong
* Memory thresholds don’t match actual output
* Disk throughput fields show zero unexpectedly

### **Cause**

`sar` output columns can differ between distros and modes. Scripts written for one distro may use incorrect field indexes on another.

### **Fix**

Confirm the column layout by running a single command and inspecting headers:

```bash
sar -u 1 1
sar -r 1 1
sar -d 1 1
```

Update scripts to match Ubuntu columns:

* CPU total = `%user + %system`
* Memory `%memused` is in the expected `%memused` column
* Disk uses `rkB/s` and `wkB/s`

---

## ✅ Issue 9: Background stress tests leave runaway processes (`yes`, `dd`)

### **Symptoms**

* CPU stays high after test finishes
* Many `yes` or `dd` processes remain running

### **Cause**

Stress scripts may not terminate properly if interrupted.

### **Fix**

Stop the generators:

```bash
sudo killall yes 2>/dev/null
sudo killall dd 2>/dev/null
```

Validate:

```bash
ps aux | egrep "yes|dd" | grep -v grep
```

---

## ✅ Issue 10: Cron jobs created but not running

### **Symptoms**

* `/etc/cron.d/sar-automation` exists
* snapshots/reports not being generated

### **Cause**

* cron service not running
* permissions / owner issues
* wrong user specified in cron file

### **Fix**

Check cron service:

```bash
sudo systemctl status cron
sudo systemctl start cron
```

Confirm cron file correctness:

```bash
sudo cat /etc/cron.d/sar-automation
```

Check if scripts are executable:

```bash
ls -la ~/sar_automation/
```

---

## ✅ Issue 11: Permission denied writing into `/var/log/sysstat`

### **Symptoms**

* scripts fail to write logs under `/var/log/sysstat`
* permission errors occur

### **Cause**

`/var/log/sysstat` is owned by root.

### **Fix Options**

1. Run script with sudo:

```bash
sudo /usr/local/bin/enhanced_sar_collection.sh
```

2. Or log to a user-writable directory for non-root use:

```bash
LOG_DIR="$HOME/sar_logs"
mkdir -p "$LOG_DIR"
```

---

## ✅ Issue 12: SAR data exists but looks “too low” or “too clean”

### **Symptoms**

* CPU/memory/disk averages show near-idle values

### **Cause**

System may be mostly idle during collection. SAR is not a synthetic benchmark tool; it reports what actually happened.

### **Fix**

Generate controlled workload during collection (as done in this lab):

* CPU load script (`cpu_stress_test.sh`)
* Memory pressure script (`memory_stress_test.sh`)
* Disk I/O script (`disk_stress_test.sh`)

---
