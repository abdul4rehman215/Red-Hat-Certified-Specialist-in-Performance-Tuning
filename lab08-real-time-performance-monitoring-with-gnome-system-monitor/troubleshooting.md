# 🛠️ Troubleshooting Guide - Lab 08 (gnome-system-monitor + Cloud GUI Limitations)

> This document lists common issues and fixes encountered while installing and using `gnome-system-monitor` in a cloud-based Ubuntu environment, including headless execution, workload testing, and report tooling.

---

## ✅ Issue 1: `gnome-system-monitor` fails with `cannot open display`

### **Symptoms**
Launching:
```bash
gnome-system-monitor &
````

returns:

* `Gtk-WARNING **: cannot open display:`

### **Cause**

Cloud lab instance is terminal-only with no GUI display attached (`$DISPLAY` not set).

### **Fix**

Install and run using headless X server:

```bash
sudo apt install -y xvfb
xvfb-run -a gnome-system-monitor &
```

### **Validation**

```bash id="sv19wj"
ps aux | grep gnome-system-monitor | grep -v grep
```

---

## ✅ Issue 2: `xvfb-run` command not found

### **Symptoms**

* `xvfb-run: command not found`

### **Cause**

`xvfb` package not installed.

### **Fix**

```bash id="ad0q8u"
sudo apt install -y xvfb
```

---

## ✅ Issue 3: CPU usage logging script reports weird values / parsing breaks

### **Symptoms**

`cpu_monitor.sh` logs wrong CPU values (empty/garbage), especially if top output format differs.

### **Cause**

`top` output varies across locales/configs. Parsing depends on the `Cpu(s)` line format.

### **Fix**

Confirm format:

```bash id="qj8jws"
top -bn1 | grep "Cpu(s)"
```

If needed, switch parsing to a more stable source like `/proc/stat` or `mpstat`:

```bash
sudo apt install -y sysstat
mpstat 1 1
```

---

## ✅ Issue 4: `stress-ng` not installed

### **Symptoms**

* `stress-ng: command not found`

### **Fix**

```bash id="fu1fjz"
sudo apt install -y stress-ng
```

---

## ✅ Issue 5: `bc` not installed (CPU-intensive loop fails)

### **Symptoms**

`cpu_intensive.sh` prints:

* `bc: command not found`

### **Cause**

Script uses `bc -l`.

### **Fix**

```bash id="42h4n6"
sudo apt install -y bc
```

---

## ✅ Issue 6: `netstat` not found during report generation

### **Symptoms**

`performance_report.sh` errors:

* `netstat: command not found`

### **Cause**

Ubuntu no longer installs `net-tools` by default.

### **Fix**

```bash id="he1hcl"
sudo apt install -y net-tools
```

### **Alternative (modern)**

Use `ss`:

```bash
ss -tuln | wc -l
```

---

## ✅ Issue 7: Memory leak simulation keeps running after exit / system gets slow

### **Symptoms**

* Python leak process continues allocating memory
* system becomes sluggish

### **Cause**

Leak simulation is intentional and runs until stopped.

### **Fix**

Stop process by PID:

```bash id="e6rtzv"
kill <PID>
```

If it ignores termination:

```bash id="e98j2c"
kill -KILL <PID>
```

### **Validation**

```bash id="eyqxa7"
ps -p <PID>
```

---

## ✅ Issue 8: Stress test leaves processes running in background

### **Symptoms**

CPU or memory remains high after running stress scenarios.

### **Cause**

Background stress processes still active.

### **Fix**

Stop stress-ng quickly:

```bash id="zob0qy"
pkill -f stress-ng
```

Validate:

```bash id="6v8vm1"
pgrep -af stress-ng
```

---

## ✅ Issue 9: `process_manager.sh` shows open files count as 0 or errors

### **Symptoms**

Open file count missing or errors appear.

### **Cause**

`lsof` may not be installed or permission restrictions exist.

### **Fix**

Install `lsof`:

```bash id="yxdgr9"
sudo apt install -y lsof
```

If still restricted, run with sudo:

```bash id="tn28yp"
sudo ./process_manager.sh <PID>
```

---

## ✅ Issue 10: `system_optimizer.sh` cache drop fails

### **Symptoms**

Script prints:

* `Cache cleanup requires root privileges`

### **Cause**

Writing to `/proc/sys/vm/drop_caches` requires root.

### **Fix**

Run with sudo:

```bash id="rm9eph"
sudo ./system_optimizer.sh
```

---

## ✅ Issue 11: Dashboard scripts don’t render correctly in non-interactive mode

### **Symptoms**

* Dashboard doesn’t “refresh”
* Output looks messy or doesn’t clear screen

### **Cause**

`clear` and continuous refresh require an interactive terminal.

### **Fix**

Run directly in terminal:

```bash id="8fksim"
./performance_dashboard.sh
```

For proof/testing in automation, use `timeout`:

```bash
timeout 6s ./performance_dashboard.sh
```

---

## ✅ Issue 12: Trend analyzer finds no logs

### **Symptoms**

`trend_analyzer.sh` prints:

* `No CPU log found in monitoring_logs`

### **Cause**

`advanced_monitor.sh` was not run (or logs were removed).

### **Fix**

Run the monitor first:

```bash id="fjz0un"
./advanced_monitor.sh
ls -la monitoring_logs/
```

Then analyze:

```bash id="elx10j"
./trend_analyzer.sh
cat monitoring_logs/trend_summary.txt
```
