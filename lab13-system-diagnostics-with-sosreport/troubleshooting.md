# 🛠️ Troubleshooting Guide — Lab 13: System Diagnostics with `sosreport`

> This document lists common issues when generating and analyzing `sosreport` archives, along with practical fixes and operational best practices.

---

## 1) `sosreport: command not found`

### ✅ Symptoms
Running:
```bash
sosreport --version
````

returns:

* `command not found`

### 🔍 Likely Cause

The `sos` package is not installed (possible on minimal images).

### ✅ Fix (RHEL/CentOS)

```bash
sudo dnf install -y sos
```

Validate:

```bash id="3fpv5h"
which sosreport
sosreport --version
```

---

## 2) Permission denied / incomplete collection

### ✅ Symptoms

* sosreport fails early
* output indicates access denied or missing files

### 🔍 Likely Cause

`sosreport` needs root privileges to read system logs, configs, and runtime kernel info.

### ✅ Fix

Run with sudo:

```bash id="y7a2w6"
sudo sosreport --batch
```

---

## 3) Report not created where expected

### ✅ Symptoms

You run `sosreport` but don’t see the `.tar.xz` in your directory.

### 🔍 Likely Cause

* You are not in the intended directory
* You did not specify `--tmp-dir`
* You do not have write permission in that location

### ✅ Fix

Use a known writable directory and explicitly set the destination:

```bash id="e54a2v"
sudo mkdir -p /var/tmp/sosreports
sudo sosreport --batch --tmp-dir=/var/tmp/sosreports
ls -la /var/tmp/sosreports
```

---

## 4) `--tmpdir` option errors

### ✅ Symptoms

`sosreport` returns an error for unknown option:

* `--tmpdir`

### 🔍 Likely Cause

Correct flag is:

* `--tmp-dir`
  (not `--tmpdir`)

### ✅ Fix

Use:

```bash id="p7u8zk"
sudo sosreport --batch --tmp-dir=/var/tmp/sosreports
```

---

## 5) Report generation takes too long or creates huge archives

### ✅ Symptoms

* report is very large (tens/hundreds of MB)
* collection takes long time
* upload/transfer becomes hard

### 🔍 Likely Cause

Full reports include many plugins, sometimes heavy logs or rpm package data.

### ✅ Fix A: Targeted collection

Example: network + firewall only:

```bash id="y2v7t5"
sudo sosreport --batch --only-plugins=networking,network,firewalld,iptables --tmp-dir=/var/tmp/sosreports
```

Example: performance triage only:

```bash id="3r4bvs"
sudo sosreport --batch --only-plugins=performance,kernel,memory,processor,block --tmp-dir=/var/tmp/sosreports
```

### ✅ Fix B: Skip heavy plugins

```bash id="xwq7b8"
sudo sosreport --batch --skip-plugins=logs,rpm
```

---

## 6) `tree: command not found` when exploring extracted report

### ✅ Symptoms

Trying:

```bash
tree -L 2 .
```

returns:

* `tree: command not found`

### 🔍 Likely Cause

`tree` isn’t installed on the system.

### ✅ Fix A: Use `find` (no install required)

```bash id="d9o2n7"
find . -maxdepth 2 -type d
```

### ✅ Fix B: Install tree (optional)

```bash id="nq6x2z"
sudo dnf install -y tree
```

---

## 7) You extracted the archive but can’t find expected files

### ✅ Symptoms

You expect `hostname`, `uname`, `proc/*`, `etc/*`, but can’t locate them.

### 🔍 Likely Cause

* You are not inside the extracted directory
* You extracted into a different path
* You are looking for a path that differs per plugin set

### ✅ Fix

Confirm where you are and list the extracted folder:

```bash id="p9q9n0"
pwd
ls -la
find . -maxdepth 2 -type f | head -30
```

---

## 8) Analysis script prints “calculation unavailable”

### ✅ Symptoms

Load-per-CPU calculation prints:

* `calculation unavailable`

### 🔍 Likely Cause

`bc` was not installed (needed for floating-point division).

### ✅ Fix

Install bc:

```bash id="m3q3ac"
sudo dnf install -y bc
```

---

## 9) Network stats show drops/errors — how to interpret?

### ✅ Symptoms

In `proc/net/dev`, you see:

* drops > 0
* errs > 0

### 🔍 Likely Cause

Could be:

* transient network congestion
* NIC driver behavior in virtual environments
* MTU mismatch / offload behavior
* bursts or packet queue pressure

### ✅ Next Steps

1. Correlate with time-window logs:

   * `var/log/messages` or `journald` data inside the report
2. Compare to current live system:

```bash id="qp4dr8"
ip -s link
ss -s
```

3. Check MTU and interface configuration:

```bash id="0owf8k"
ip link show
ip route
```

---

## 10) Best Practices for using sosreport (operational)

### ✅ Recommendations

1. Use **full reports** when the issue is unclear or for escalation.
2. Use **targeted plugins** for faster, smaller, focused triage.
3. Always store reports in a dedicated folder (`/var/tmp/sosreports` or `/var/log/sosreports`).
4. Extract and analyze with a repeatable workflow:

   * generate → extract → quick summary → deep dive
5. Build small automation helpers:

   * `sosreport-analyzer`
   * `monthly-sosreport`
   * `sosreport-workflow`

---

## ✅ Quick Checklist (from this lab)

* [ ] `which sosreport` returns `/usr/sbin/sosreport`
* [ ] `sosreport --version` prints `sos-4.7.2`
* [ ] Reports saved under `/var/tmp/sosreports/`
* [ ] Extracted directory contains: `etc/`, `proc/`, `var/log/`, `sos_commands/`
* [ ] Analyzer script runs and prints summary successfully
* [ ] Install `bc` if scripts require calculations

---

