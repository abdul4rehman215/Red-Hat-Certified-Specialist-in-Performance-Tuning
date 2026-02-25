# 🎤 Interview Q&A - Lab 08 (gnome-system-monitor + Real-time Monitoring)

> This file contains interview-style questions and answers based on the work performed in **Lab 08: Real-time Performance Monitoring with gnome-system-monitor**.

---

## 1) What is `gnome-system-monitor` and what is it used for?
**Answer:**  
`gnome-system-monitor` is a graphical system monitoring tool that provides real-time visibility into:
- running processes and their CPU/memory usage,
- resource graphs (CPU, memory, network),
- file system utilization.

It’s commonly used for quick performance troubleshooting and identifying resource-heavy processes interactively.

---

## 2) What are the key tabs in `gnome-system-monitor`?
**Answer:**  
The main tabs are:
- **Processes**: running processes and per-process resource usage
- **Resources**: live graphs for CPU, memory, swap, network
- **File Systems**: mounted disks and usage
- **Hardware**: hardware/system info (varies by version)

---

## 3) Why did `gnome-system-monitor` fail with “cannot open display”?
**Answer:**  
Because the cloud lab environment was terminal-only and did not have an attached GUI display (`$DISPLAY` not set), so GTK could not open a graphical window.

---

## 4) How did you run the GUI tool in a headless cloud environment?
**Answer:**  
I installed `xvfb` (a headless X server) and launched it using:
```bash
xvfb-run -a gnome-system-monitor &
````

This allows GUI apps to run even without a physical display.

---

## 5) How did you validate process/resource behavior without relying only on GUI?

**Answer:**
I cross-checked with CLI tools:

* `top -bn1` for CPU/memory summary
* `ps aux --sort=-%cpu` and `ps aux --sort=-%mem` for top processes
* `free -h` / `free -m` for memory breakdown
* `df -h` for disk usage

---

## 6) How did you establish a baseline performance snapshot?

**Answer:**
I captured a baseline using:

* `top -bn1 | head -8`
  This shows load average, CPU breakdown (%user, %system, %idle), memory totals, and swap.

---

## 7) How did you generate CPU load for testing and what did you observe?

**Answer:**
I used:

```bash
stress-ng --cpu 0 --timeout 120s --metrics-brief
```

This dispatches CPU workers across all cores. CPU usage climbed near 100% and `ps` showed stress-ng workers consuming ~98–99% CPU.

---

## 8) How did you generate memory pressure and what metrics mattered most?

**Answer:**
I used:

```bash
stress-ng --vm 1 --vm-bytes 1G --timeout 120s --metrics-brief
```

Key metrics:

* increasing “used” memory,
* decreasing “available” memory,
* whether swap becomes active,
* responsiveness during allocation.

---

## 9) How did you simulate a memory leak and confirm it was happening?

**Answer:**
I ran a Python script that continuously allocated memory and appended it to a list.
I confirmed growth using:

```bash
ps -p $PID -o pid,%cpu,%mem,rss,cmd
```

RSS increased over time, indicating increasing memory consumption like a leak.

---

## 10) What is the difference between “used memory” and “cached memory” on Linux?

**Answer:**
Linux uses free memory aggressively for filesystem caching. “Cached” memory is often reclaimable.
So high “used” is not always bad; the key is **available memory** and whether the system begins swapping or paging heavily.

---

## 11) What is a process tree and why is it useful?

**Answer:**
A process tree shows parent-child relationships. It helps identify:

* which parent process spawned a runaway child,
* service hierarchies,
* process dependencies and containment.
  I demonstrated this with a script and verified it using `pstree`.

---

## 12) Why would you change a process priority (`nice`/`renice`)?

**Answer:**
To reduce the CPU scheduling priority of non-critical workloads so critical services remain responsive.
Example:

```bash
renice +10 -p <PID>
```

This lowers priority and helps stabilize system responsiveness under load.

---

## 13) What signals did you use to terminate processes, and why?

**Answer:**

* `SIGTERM` (`kill -TERM`) for graceful shutdown
* `SIGKILL` (`kill -KILL`) for forced termination when a process refuses to exit
  This is a standard escalation approach.

---

## 14) What did your automated performance report include?

**Answer:**
The report captured:

* OS/kernel/architecture
* CPU info + current CPU usage
* memory state (free/used/cache)
* top processes by CPU and memory
* disk usage (`df -h`)
* network listener counts (`netstat -tuln | wc -l`)
* load average snapshot

---

## 15) What’s the value of trend analysis even in “real-time monitoring” labs?

**Answer:**
Real-time monitoring is great for immediate visibility, but trend logs prove patterns:

* average/min/max CPU or memory usage,
* whether there were threshold breaches,
* whether alerts happened,
* whether optimizations improved the baseline.

In this lab, trend analysis produced a `trend_summary.txt` from monitoring logs.
