# 🛠️ Troubleshooting Guide — Lab 15: Modifying Kernel Parameters with `sysctl`

> This file documents realistic issues that can occur while tuning kernel parameters using `sysctl`, applying persistent configs under `/etc/sysctl.d/`, and validating changes.

---

## 1) `sysctl: permission denied` when setting a value

### ✅ Symptom
```bash
sysctl vm.swappiness=10
````

Returns a permission error.

### 🔍 Cause

Kernel parameter writes require root privileges.

### ✅ Fix

```bash
sudo sysctl vm.swappiness=10
```

---

## 2) Changes work now but revert after reboot

### ✅ Symptom

You set values using `sysctl -w` or `sysctl key=value`, but after reboot values reset.

### 🔍 Cause

Runtime sysctl changes are not persistent.

### ✅ Fix (recommended)

Create a config file under `/etc/sysctl.d/`:

* `/etc/sysctl.d/99-performance-tuning.conf`

Apply immediately:

```bash
sudo sysctl -p /etc/sysctl.d/99-performance-tuning.conf
```

Apply all system configs:

```bash
sudo sysctl --system
```

Verify:

```bash
sysctl vm.swappiness
sysctl net.core.somaxconn
```

---

## 3) `sysctl -p` shows errors like “unknown key” or “cannot stat”

### ✅ Symptom

```bash
sudo sysctl -p /etc/sysctl.d/99-performance-tuning.conf
```

returns errors.

### 🔍 Causes

* Typo in parameter name
* Parameter not supported by your kernel
* Wrong file path / file not created

### ✅ Fix

1. Verify file exists:

```bash
ls -la /etc/sysctl.d/99-performance-tuning.conf
```

2. Check parameter exists:

```bash
sysctl -a | grep -E "^vm\.swappiness|^net\.core\.somaxconn"
```

3. Apply with ignore unknown keys (optional):

```bash
sudo sysctl -e -p /etc/sysctl.d/99-performance-tuning.conf
```

---

## 4) `stress-ng not found` during load testing

### ✅ Symptom

```bash
stress-ng
```

returns: `command not found`

### 🔍 Cause

Tool is not installed by default.

### ✅ Fix

```bash
sudo dnf install -y stress-ng
```

---

## 5) `iostat: command not found` in performance monitoring

### ✅ Symptom

`performance_monitor.sh` fails at `iostat -x 1 1`

### 🔍 Cause

`iostat` is provided by the `sysstat` package.

### ✅ Fix

```bash
sudo dnf install -y sysstat
```

---

## 6) TCP congestion control “BBR not available”

### ✅ Symptom

You try to enable BBR but it’s not listed:

```bash
sysctl net.ipv4.tcp_available_congestion_control
```

shows only `reno cubic`.

### 🔍 Cause

Kernel/module support may not include BBR.

### ✅ Fix

Keep `cubic` (safe default on most distros):

```bash
sudo sysctl net.ipv4.tcp_congestion_control=cubic
```

---

## 7) Validation script fails for multi-value sysctl keys (`tcp_rmem`, `tcp_wmem`)

### ✅ Symptom

Validation prints something like:

* Expected: `40966553616777216`
* Actual: `4096 65536 16777216`

### 🔍 Cause

The script removed spaces from expected values while parsing config:

* It compared normalized strings incorrectly for multi-value parameters.

### ✅ Fix

Normalize whitespace without removing internal separators, e.g.:

```bash
expected="$(echo "$expected_raw" | awk '{$1=$1;print}')"
current="$(sysctl -n "$param" | awk '{$1=$1;print}')"
```

✅ The corrected version is included in:

* `scripts/validate_config.sh`

---

## 8) Sysctl tuning causes unexpected behavior or connectivity issues

### ✅ Symptom

After tuning, apps behave differently (timeouts, connection issues, performance regressions).

### 🔍 Cause

Kernel tuning must match workload; aggressive values can reduce stability.

### ✅ Fix (safe rollback strategy)

1. Restore from a saved backup:

```bash
./restore_sysctl.sh /tmp/sysctl_backup_<timestamp>.conf
```

2. Remove or rename custom sysctl configs:

```bash
sudo mv /etc/sysctl.d/99-performance-tuning.conf /etc/sysctl.d/99-performance-tuning.conf.disabled
sudo sysctl --system
```

---

## 9) `net.ipv4.tcp_tw_reuse` value mismatch across systems

### ✅ Symptom

Some systems accept values `0/1`, others show `2`.

### 🔍 Cause

Kernel version differences or distro defaults.

### ✅ Fix

Always verify allowed values on your kernel:

```bash
sysctl net.ipv4.tcp_tw_reuse
```

Use conservative defaults if unsure:

```bash
sudo sysctl net.ipv4.tcp_tw_reuse=1
```

---

## ✅ Best Practices Checklist (production mindset)

* ✅ Take a **baseline** before changes (`performance_monitor.sh`)
* ✅ Tune **one category at a time** (VM → NET → FS)
* ✅ Validate every change (`sysctl key`, validation script)
* ✅ Persist configs in `/etc/sysctl.d/` (avoid editing vendor files)
* ✅ Use **backup/restore** scripts before risky tuning
* ✅ Compare results using repeatable load tests and monitoring logs
