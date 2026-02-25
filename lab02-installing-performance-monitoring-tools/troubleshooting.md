# 🛠️ Troubleshooting Guide — Lab 02: Installing Performance Monitoring Tools

> This troubleshooting guide captures issues observed in the lab and common real-world fixes when setting up performance monitoring on RHEL 8/9.

---

## 1) `which iostat/mpstat/sar` returns “no … in PATH”

### ✅ Symptoms
```text
/usr/bin/which: no iostat in (...)
/usr/bin/which: no mpstat in (...)
/usr/bin/which: no sar in (...)
````

### 🔍 Cause

These tools are provided by **sysstat**, which was not installed initially.

### ✅ Fix

```bash
sudo dnf install -y sysstat
which iostat
which mpstat
which sar
```

---

## 2) `nethogs` not found during installation

### ✅ Symptoms

```text
No match for argument: nethogs
Error: Unable to find a match: nethogs
```

### 🔍 Cause

`nethogs` is commonly provided via **EPEL**, not the default RHEL repos.

### ✅ Fix (Used in this lab)

```bash
sudo dnf install -y epel-release
sudo dnf install -y nethogs
```

---

## 3) `sysstat.service` shows “active (exited)” and looks like it isn’t running

### ✅ Symptoms

```text
Active: active (exited)
```

### 🔍 Cause

This is normal. `sysstat.service` typically performs an initialization action (`sa1 --boot`) and exits.
Actual periodic collection is controlled through cron/timers depending on distro configuration.

### ✅ Fix / Verification

```bash
sudo systemctl status sysstat --no-pager -l
cat /etc/cron.d/sysstat
sar -u 1 3
```

---

## 4) `sar` shows very little historical data or “No such file” for yesterday’s sa file

### ✅ Symptoms

* `sar -u` shows only a few entries
* `sar -u -f /var/log/sa/saXX` fails because file does not exist

### 🔍 Cause

* sysstat wasn’t collecting long enough yet
* yesterday’s file may not exist if the VM was created today
* collection interval may not have produced enough samples yet

### ✅ Fix / Workarounds

1. Ensure sysstat is enabled and started:

```bash
sudo systemctl enable sysstat
sudo systemctl start sysstat
```

2. Trigger a collection manually:

```bash
sudo /usr/libexec/sysstat/sa1
```

3. Confirm files exist:

```bash
ls -la /var/log/sa/
```

4. If yesterday’s file does not exist, document it (normal in short-lived lab VMs).

---

## 5) `sar -A > /tmp/system_report.txt` produces a large file (concern about storage)

### ✅ Symptoms

* report is large (e.g., 118K or more)
* repeated reports can build up over time

### 🔍 Cause

`sar -A` outputs all available SAR metrics. This is expected.

### ✅ Fix / Best Practice

* generate reports only when needed
* rotate or delete old reports
* use logrotate for recurring files

```bash
ls -lh /tmp/system_report.txt
rm -f /tmp/system_report.txt
```

---

## 6) `top` output differs between interactive and batch mode

### ✅ Symptoms

* interactive `top` looks different than `top -b`
* some columns may appear/format differently

### 🔍 Cause

Interactive mode depends on terminal capabilities and display size.
Batch mode prints a fixed formatted output for scripting.

### ✅ Fix / Best Practice

Use batch mode for documentation and scripts:

```bash
top -n 1 -b > /tmp/top_output.txt
head -25 /tmp/top_output.txt
```

---

## 7) `iostat -x sda` returns “Device not found”

### ✅ Symptoms

```text
iostat: Device not found: sda
```

### 🔍 Cause

Many cloud VMs use NVMe or virtio disks (e.g., `nvme0n1`, `vda`) instead of `sda`.

### ✅ Fix (Used in this lab)

1. Identify the real disk:

```bash
lsblk
iostat
```

2. Run iostat on the correct device:

```bash
iostat -x nvme0n1 2 5
```

---

## 8) Scripts writing logs into `/tmp` work, but cron execution produces no visible output

### ✅ Symptoms

* cron job runs but you don’t see output in terminal
* no messages displayed

### 🔍 Cause

Cron runs in a non-interactive environment and output is redirected to `/dev/null` as configured.

### ✅ Fix / Verification

1. Temporarily log cron output to a file:

```cron
*/15 * * * * /tmp/system_monitor.sh >> /tmp/system_monitor_cron.log 2>&1
```

2. Check the log:

```bash
tail -50 /tmp/system_monitor_cron.log
```

3. Ensure script is executable:

```bash
chmod +x /tmp/system_monitor.sh
```

---

## 9) Logrotate config doesn’t seem to run immediately

### ✅ Symptoms

* logs are not rotated right away after creating `/etc/logrotate.d/system-monitor`

### 🔍 Cause

Logrotate typically runs daily via cron/systemd timer. It won’t rotate instantly unless forced.

### ✅ Fix / Verification

Force a logrotate run (safe test):

```bash
sudo logrotate -f /etc/logrotate.d/system-monitor
```

---

## 10) Permission issues when viewing kernel/service data

### ✅ Symptoms

* permission denied when accessing certain /proc entries or running monitoring tools

### 🔍 Cause

Some metrics require root privileges.

### ✅ Fix

Run with sudo when needed:

```bash
sudo sar -u
sudo iostat -x
sudo journalctl -u sysstat --no-pager | tail -15
```

---

## ✅ Best Practices Applied in This Lab

* Install **sysstat** early (`sar`, `iostat`, `mpstat`)
* Enable continuous collection and confirm scheduled collection exists
* Automate monitoring with scripts and cron
* Prevent log growth using logrotate
* Always verify disk device names (`nvme0n1`, `vda`, etc.) before targeting tools

---
