# 🛠️ Troubleshooting Guide — Lab 14: Kernel Parameter Tuning with `/proc/sys`

> This document captures realistic issues encountered when tuning kernel parameters at runtime and persisting changes using `sysctl`.

---

## 1) Permission denied when writing to `/proc/sys/*`

### ✅ Symptoms
You run:
```bash
echo 10 > /proc/sys/vm/swappiness
````

and see:

* `Permission denied`

### 🔍 Likely Cause

You are not root (or the shell performing redirection isn’t root).

### ✅ Fix A (recommended): use `sudo tee`

```bash id="xav0ef"
echo 10 | sudo tee /proc/sys/vm/swappiness
```

### ✅ Fix B: switch to root shell

```bash id="qz0iqx"
sudo su -
echo 10 > /proc/sys/vm/swappiness
```

---

## 2) `sudo echo 10 > /proc/sys/...` does not work (common pitfall)

### ✅ Symptoms

You try:

```bash
sudo echo 10 > /proc/sys/vm/swappiness
```

and it still fails or silently does nothing.

### 🔍 Why it happens

`sudo` only applies to `echo`.
The `>` redirection is handled by your non-root shell, so it cannot write to `/proc/sys/...`.

### ✅ Fix

Use `sudo tee` instead:

```bash id="h9j5u4"
echo 10 | sudo tee /proc/sys/vm/swappiness
```

---

## 3) Changes are lost after reboot

### ✅ Symptoms

You tune values in `/proc/sys/...` and they revert after reboot.

### 🔍 Likely Cause

Runtime `/proc/sys` changes are **not persistent**.

### ✅ Fix: Add sysctl config

Create a file like:

* `/etc/sysctl.d/99-performance-tuning.conf`

Example:

```conf
vm.swappiness = 10
```

Apply immediately:

```bash id="e0hkjp"
sudo sysctl -p /etc/sysctl.d/99-performance-tuning.conf
```

Verify:

```bash id="l8y24p"
sysctl vm.swappiness
cat /proc/sys/vm/swappiness
```

---

## 4) Invalid parameter values / system rejects the value

### ✅ Symptoms

Writing a value fails or sysctl returns an error.

### 🔍 Likely Cause

* Value is outside allowed range
* Parameter does not exist on this kernel version
* Typo in parameter name

### ✅ Fix

1. Confirm the parameter exists:

```bash id="r8nqgr"
sysctl -a | grep -E "^vm\.swappiness|^net\.ipv4\.tcp_rmem|^net\.core\.rmem_max"
```

2. Check documentation/manpages:

```bash id="7kbyig"
man 5 proc
man 8 sysctl
```

3. Restore safe defaults if needed:

```bash id="j9g0zn"
echo 60 | sudo tee /proc/sys/vm/swappiness
```

---

## 5) Testing tools not available (`stress`, `fio`, `iostat`, `iperf3`)

### ✅ Symptoms

* `stress: command not found`
* `fio: command not found`
* `iostat: command not found`
* `iperf3: command not found`

### ✅ Fix A: install what’s available

`stress` (commonly via EPEL on EL systems):

```bash id="t9o4q4"
sudo dnf install -y stress
```

`fio` + `sysstat` (for `iostat`):

```bash id="8h5v5k"
sudo dnf install -y fio sysstat
```

### ✅ Fix B: iperf3 not found

In many environments `iperf3` requires EPEL or repo enablement, so this can happen:

```bash
No match for argument: iperf3
```

Fallback used in the lab:

* `nc` (netcat) simple local connectivity test inside `network_test.sh`

---

## 6) `io_test.sh: Permission denied`

### ✅ Symptoms

Running:

```bash
./io_test.sh
```

returns:

* `Permission denied`

### 🔍 Likely Cause

Executable bit missing (or script saved in a way that removed it).

### ✅ Fix

```bash id="f3u0g4"
chmod +x io_test.sh
./io_test.sh
```

Optional check:

```bash id="m0d9p8"
ls -la io_test.sh
file io_test.sh
```

---

## 7) `iostat not available` inside monitoring script

### ✅ Symptoms

`monitor_performance.sh` logs:

* `iostat not available`

### 🔍 Likely Cause

`iostat` comes from `sysstat`, not installed by default.

### ✅ Fix

```bash id="6w3vbf"
sudo dnf install -y sysstat
```

Re-run:

```bash id="6vqb10"
./monitor_performance.sh 30 5
```

---

## 8) Networking tuning doesn’t show improvement in a local-only test

### ✅ Symptoms

TCP buffer tuning doesn’t show major gains when testing localhost.

### 🔍 Likely Cause

Localhost tests often aren’t limited by TCP buffers; real impact is seen with:

* latency
* WAN links
* high throughput flows
* many concurrent connections

### ✅ Recommendation

Test on realistic conditions:

* use real remote endpoints (when permitted)
* use workload-representative traffic patterns
* compare baseline and tuned performance under similar load

---

## ✅ Best Practices (what this lab reinforced)

1. **Document baseline** before tuning.
2. Change **one thing at a time** and validate.
3. Prefer `sysctl` or `sudo tee` for safe writes.
4. Persist using `/etc/sysctl.d/*.conf`.
5. Always keep a rollback plan (restore defaults quickly).
6. Measure results with testing + monitoring scripts and store artifacts.

---
