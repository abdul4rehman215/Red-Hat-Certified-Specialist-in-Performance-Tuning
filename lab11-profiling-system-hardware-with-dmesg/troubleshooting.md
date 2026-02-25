
# 🛠️ Troubleshooting Guide — Lab 11: Profiling System Hardware with `dmesg`

> This document lists common issues encountered when using `dmesg` for hardware profiling, along with likely causes and practical fixes.

---

## 1) `dmesg: command not found`

### ✅ Symptoms
Running:
```bash
dmesg
````

returns:

* `bash: dmesg: command not found`

### 🔍 Likely Cause

* `dmesg` is typically provided by `util-linux`
* Minimal images or custom environments may not include it

### ✅ Fix

Install `util-linux`:

```bash
sudo yum install -y util-linux
```

or on newer systems using `dnf`:

```bash
sudo dnf install -y util-linux
```

---

## 2) `dmesg: read kernel buffer failed: Operation not permitted`

### ✅ Symptoms

Running `dmesg` as a non-root user shows permission errors.

### 🔍 Likely Cause

* Kernel restricts access to ring buffer messages
* `kernel.dmesg_restrict=1` may be enabled
* Or the user lacks required permissions

### ✅ Fix A (Use sudo)

```bash
sudo dmesg
```

### ✅ Fix B (Check the restriction setting)

```bash
sysctl kernel.dmesg_restrict
```

### ✅ Fix C (Temporary disable restriction — only for lab/testing)

```bash
sudo sysctl -w kernel.dmesg_restrict=0
```

> ⚠️ In production, keep restrictions enabled unless there is a strong operational reason to disable them.

---

## 3) Too many messages / hard to analyze scrolling output

### ✅ Symptoms

`dmesg` output is huge and scrolls quickly.

### 🔍 Likely Cause

Kernel ring buffer includes:

* boot logs
* runtime device messages
* audit/kernel warnings
  It can be noisy on cloud VMs.

### ✅ Fix A (Use paging)

```bash
dmesg | less
```

### ✅ Fix B (View only the boot-start portion)

```bash
dmesg | head -200
```

### ✅ Fix C (Targeted search)

```bash
dmesg | grep -i "nvme\|scsi\|ata"
```

---

## 4) Human-readable timestamps (`dmesg -T`) look incorrect

### ✅ Symptoms

The timestamps don’t match expected real time or show weird values.

### 🔍 Likely Cause

* System clock may not be synced yet early in boot
* Cloud lab images may have clock adjustments
* `dmesg -T` depends on correct system time

### ✅ Fix

Verify system time:

```bash
date
timedatectl status
```

If NTP is available:

```bash
sudo timedatectl set-ntp true
```

---

## 5) No output when filtering by error levels

### ✅ Symptoms

Commands like:

```bash
dmesg -l err
```

return nothing.

### 🔍 Likely Cause

* System may simply have no kernel-level errors recorded
* Many warnings may exist only at `warn` level
* Some issues are logged via `journalctl` instead of kernel ring buffer

### ✅ Fix A (Include warnings)

```bash
dmesg -l err,warn
```

### ✅ Fix B (Look in system journal too)

```bash
journalctl -k --priority=warning
```

---

## 6) Seeing AVC denials or audit warnings in `dmesg`

### ✅ Symptoms

Output includes entries like:

* `audit: avc: denied ... permissive=1`
* journald unclean shutdown messages
* occasional RCU stall info messages

### 🔍 Likely Cause

This is common in lab/cloud VM images where:

* SELinux is permissive or configured differently
* VM was previously snapshot/restored
* services were restarted abruptly
* CPU scheduling stalls happen briefly in shared virtualization environments

### ✅ Fix / Handling

* Treat as **contextual** and validate severity
* Check whether SELinux is enforcing or permissive:

```bash
getenforce
```

If the system is permissive in the lab:

* Document it as a lab environment artifact
* Avoid unnecessary tuning changes unless required

---

## 7) Real-time monitoring consumes too much output or feels “heavy”

### ✅ Symptoms

`dmesg -w` prints continuously and is difficult to follow.

### 🔍 Likely Cause

* Many kernel messages are generated regularly (audit, network)
* Real-time monitoring without filtering can be noisy

### ✅ Fix A (Monitor only critical levels)

```bash
dmesg -w -l err,crit,alert
```

### ✅ Fix B (Use keyword filtering)

```bash
dmesg -w | grep -i "error\|fail\|timeout\|thermal"
```

### ✅ Fix C (Use script-based alerting)

Use `scripts/realtime_monitor.sh` which prints only lines matching:

* `error|fail|warn|timeout|hardware|thermal|i/o`

---

## 8) Time-based filtering with `--since` returns unexpected results

### ✅ Symptoms

Commands like:

```bash
dmesg --since="1 hour ago"
```

return very few lines or none.

### 🔍 Likely Cause

* Few kernel messages happened in that time range
* System has been idle
* Time expressions rely on correct system time parsing

### ✅ Fix A (Widen time window)

```bash
dmesg --since="24 hours ago"
```

### ✅ Fix B (Verify time parsing works)

```bash
date
```

### ✅ Fix C (Use `journalctl -k` for stronger time filtering in some environments)

```bash
journalctl -k --since "1 hour ago"
```

---

## 9) Script output looks empty (no issues found)

### ✅ Symptoms

Scripts such as:

* `diagnose_storage.sh`
* `diagnose_memory.sh`
  produce mostly blank sections.

### 🔍 Likely Cause

This usually means:

* no matching error patterns exist in kernel buffer (good sign)
* system is healthy in that area
* lab workload didn’t trigger those events

### ✅ Fix / Validation

Confirm the script is working:

```bash
bash -n scripts/diagnose_storage.sh
chmod +x scripts/diagnose_storage.sh
./scripts/diagnose_storage.sh
```

Also verify manually by searching:

```bash
dmesg | grep -i "error\|fail\|timeout" | head
```

---

## ✅ Best Practices (from this lab)

1. **Filter first, then deep dive**

   * `-l err,warn`, `--since`, and keyword filtering reduce noise.
2. **Correlate time windows**

   * use `--since`, `--until`, and readable timestamps (`-T`).
3. **Create reusable scripts**

   * consistent diagnostics improve speed and reporting quality.
4. **Cross-check with journal**

   * kernel + system services may log in different places.
5. **Document lab-specific noise**

   * cloud images can generate benign warnings; record context clearly.

---

