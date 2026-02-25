# 🎤 Interview Q&A — Lab 01: Introduction to Performance Tuning Concepts

This Q&A set is based on the exact workflow used in this lab: establishing a baseline, detecting bottlenecks, applying safe tuning changes, and validating via metrics.

---

## 1) What is performance tuning in Linux?
Performance tuning is a systematic, measurement-driven process to optimize system resources (CPU, memory, disk, network) to improve throughput, reduce response time, increase efficiency, and maintain stability under load.

---

## 2) Why is creating a baseline important before tuning?
Because you need a reference point. Without baseline metrics, you can’t prove whether a tuning change improved performance or made things worse. Baselines help compare before/after behavior and support data-driven decisions.

---

## 3) What does “load average” represent and how do you interpret it?
Load average represents the average number of tasks that are runnable or waiting for CPU (and sometimes I/O) over 1, 5, and 15 minutes.  
A common interpretation: if the 1-minute load average is consistently higher than the number of CPU cores, the system may be CPU saturated (or stuck in I/O wait depending on context).

---

## 4) What tools did you use to monitor CPU usage in this lab?
- `htop` for real-time interactive monitoring  
- `sar -u` (sysstat) for CPU utilization breakdown (`%user`, `%system`, `%idle`, `%iowait`)  
- `ps aux --sort=-%cpu` for top CPU consuming processes  
- `stress-ng` to generate controlled CPU load

---

## 5) What is `%iowait` and why is it important?
`%iowait` is the percentage of time the CPU is idle while waiting for disk I/O to complete.  
High `%iowait` can indicate storage performance issues, slow disks, or overloaded I/O paths. It helps distinguish CPU bottlenecks from disk bottlenecks.

---

## 6) What is the difference between “free memory” and “available memory”?
- **Free memory** is unused RAM currently not allocated.  
- **Available memory** is a better metric because it includes reclaimable cache/buffers that the system can free when needed.  
Linux aggressively caches, so low “free” memory is not always a problem.

---

## 7) What indicators suggest a memory bottleneck?
- Very high memory usage (e.g., >90% used with low available memory)  
- Swap usage increasing significantly  
- Frequent page faults (not measured in this lab, but typically checked with `vmstat`)  
- OOM killer events (`dmesg | grep -i killed process`)

---

## 8) What tools did you use for disk I/O monitoring?
- `iotop` for process-level real-time I/O activity  
- `iostat -x` for extended disk metrics (`%util`, `await`, throughput, IOPS)  
- `df -h` and `df -i` to check space and inode usage  
- `lsof` to identify heavy file usage patterns at a basic level

---

## 9) Why did reading CPU governor files from `/sys/.../cpufreq/` fail on this system?
Many cloud VMs don’t expose CPU frequency scaling in the same way as physical servers. The sysfs cpufreq paths may not exist depending on virtualization and the CPU driver setup.  
In this lab, the workaround was to use `cpupower frequency-info` via `kernel-tools`.

---

## 10) What is a CPU governor and what did you set it to in this lab?
A CPU governor controls how CPU frequency scales with load.  
In this lab, I set it to **`performance`** using:
- `cpupower frequency-set -g performance`

---

## 11) What is `nice` / `renice` and how does it help performance tuning?
`nice` and `renice` adjust a process’s scheduling priority.  
Higher nice value (e.g., +10) = lower priority.  
Lower nice value (e.g., -5) = higher priority.  
This helps ensure critical services get CPU time before background workloads.

---

## 12) What is CPU affinity and why would you use `taskset`?
CPU affinity binds a process to specific CPU cores.  
This can reduce cache misses, improve predictability, and isolate noisy workloads. It’s useful for latency-sensitive apps or when dedicating cores to specific services.

---

## 13) What does `vm.swappiness` control?
`vm.swappiness` controls how aggressively the kernel swaps memory pages out to swap space.  
Lower value (e.g., 10) reduces swapping tendency, which can help performance if swap activity is hurting latency.  
However, overly low swappiness can increase memory pressure and risk OOM if RAM is tight.

---

## 14) Why is `echo 3 > /proc/sys/vm/drop_caches` inside a script tricky with sudo?
Because shell redirection (`>`) happens before `sudo` executes.  
So `sudo echo 3 > ...` still tries to write as the non-privileged shell and fails.  
The correct pattern is:
- `echo 3 | sudo tee /proc/sys/vm/drop_caches`

---

## 15) What was the purpose of the comprehensive performance test suite?
To run controlled CPU, memory, and disk stress tests, capture monitoring logs, and produce a consolidated summary report.  
This supports repeatable benchmarking and helps validate tuning decisions with measurable results.

---
