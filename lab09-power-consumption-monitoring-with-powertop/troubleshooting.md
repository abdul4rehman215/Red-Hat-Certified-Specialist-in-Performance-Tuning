# 🛠️ Troubleshooting Guide - Lab 09 (powertop + Power Management on CentOS/RHEL)

> This document lists common issues and fixes encountered while installing/using `powertop`, generating reports, applying tunables, and making power settings persistent with `systemd` and `TLP`.

---

## ✅ Issue 1: `powertop: command not found`

### **Symptoms**
Running:
```bash
powertop --version
````

returns:

* `powertop: command not found`

### **Cause**

`powertop` is not installed (or EPEL repo not enabled in some environments).

### **Fix**

Install powertop (and tools commonly needed):

```bash
sudo dnf install -y powertop kernel-tools
```

If repo is missing powertop, enable EPEL (depends on environment policy):

```bash
sudo dnf install -y epel-release
sudo dnf install -y powertop
```

---

## ✅ Issue 2: Permission errors / missing hardware counters

### **Symptoms**

* powertop shows errors accessing counters
* missing or incomplete metrics
* warnings about MSR / RAPL access

### **Cause**

Hardware counters and MSR access require root and correct kernel modules.

### **Fix**

Run with sudo and load msr:

```bash
sudo modprobe msr
sudo powertop
```

---

## ✅ Issue 3: `powertop --calibrate` takes too long

### **Symptoms**

Calibration runs for a long time or feels “stuck”.

### **Cause**

Calibration is intentionally slow (collects multiple samples). If system is busy, calibration can take longer and results may be less stable.

### **Fix**

* Keep system idle during calibration
* If you need a bounded run:

```bash
sudo timeout 300 powertop --calibrate
```

* Or skip calibration and use automatic tuning:

```bash
sudo powertop --auto-tune
```

---

## ✅ Issue 4: No battery device found (`BAT*` missing)

### **Symptoms**

```bash
cat /sys/class/power_supply/BAT*/status
```

returns nothing and prints:

* `AC Power detected`

### **Cause**

Cloud VMs usually do not expose a physical battery.

### **Fix**

This is expected. Use AC status to confirm:

```bash
ls /sys/class/power_supply/
cat /sys/class/power_supply/ACAD/online
```

You can still use powertop to estimate usage (RAPL) and apply tunables.

---

## ✅ Issue 5: Reports not generated / files missing

### **Symptoms**

`powertop --html=...` or `--csv=...` finishes but output file not found.

### **Cause**

* Running directory confusion
* Permissions (report created as root in root-owned path)

### **Fix**

Run in intended directory and list results:

```bash
pwd
ls -la
sudo powertop --html=power_report.html --time=60
sudo powertop --csv=power_data.csv --time=30
ls -la power_report.html power_data.csv
```

---

## ✅ Issue 6: `iostat: command not found` in analysis script

### **Symptoms**

Running `./analyze_power.sh` fails at:

* `iostat: command not found`

### **Cause**

`iostat` is part of `sysstat`, which may not be installed by default.

### **Fix**

```bash
sudo dnf install -y sysstat
```

---

## ✅ Issue 7: CPU governor path missing (`scaling_governor` not found)

### **Symptoms**

Script errors when writing:

* `/sys/devices/system/cpu/cpu*/cpufreq/scaling_governor`

### **Cause**

* CPU frequency scaling not exposed in the VM
* missing cpufreq drivers
* power management features limited by hypervisor

### **Fix**

Check available governors:

```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
```

If cpufreq is unavailable, rely on:

* powertop tunables
* TLP policies (if supported)
* hypervisor-level power settings

---

## ✅ Issue 8: Disk tuning does nothing (NVMe vs sdX)

### **Symptoms**

Disk scheduler loop doesn’t change anything:

```bash
for disk in /sys/block/sd*; do ...
```

### **Cause**

Cloud VM uses NVMe devices (`/sys/block/nvme*`), not `/sys/block/sd*`.

### **Fix (optional improvement)**

Extend the loop to include NVMe:

```bash
for disk in /sys/block/sd* /sys/block/nvme*; do
  ...
done
```

*(In this lab, the script was kept as-provided and still applied CPU + USB + network tunables successfully.)*

---

## ✅ Issue 9: Power tuning not persistent after reboot

### **Symptoms**

After reboot:

* governor resets
* laptop mode resets
* USB/network power controls revert

### **Cause**

Most sysfs and kernel tuning resets on boot.

### **Fix**

Use a `systemd` unit:

1. Place script in `/usr/local/bin/`
2. Create a service file
3. Enable it:

```bash
sudo systemctl daemon-reload
sudo systemctl enable power-optimize.service
sudo systemctl start power-optimize.service
sudo systemctl status power-optimize.service
```

---

## ✅ Issue 10: `TLP` running but no effect

### **Symptoms**

* `tlp-stat -s` shows enabled
* but system settings don’t appear to change

### **Cause**

VM may not expose laptop-style AC/BAT interfaces or power features. Some settings are hardware-dependent.

### **Fix**

Validate mode and power source:

```bash
sudo tlp-stat -s
```

Confirm whether you’re on AC or battery. Review supported settings and logs.

---

## ✅ Issue 11: Automated power management service loops forever / logs grow

### **Symptoms**

* `auto-power-mgmt.service` runs continuously
* log file grows

### **Cause**

Script is designed as a monitoring loop (checks every 60s).

### **Fix**

* Ensure log rotation is used in real systems
* For lab environments, keep log minimal or redirect output
* Stop service if needed:

```bash
sudo systemctl stop auto-power-mgmt.service
```

---

## ✅ Issue 12: `power_profiles.sh list` returns nothing

### **Symptoms**

* `list` shows empty

### **Cause**

Profile directory or conf files were not created (permissions or early failure).

### **Fix**

Run script once (it creates profiles automatically):

```bash
sudo /usr/local/bin/power_profiles.sh list
```

Verify:

```bash
ls -la /etc/power-profiles/
```

---
