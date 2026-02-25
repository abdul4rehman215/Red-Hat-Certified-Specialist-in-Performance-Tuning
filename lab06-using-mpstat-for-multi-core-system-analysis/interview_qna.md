# 🎤 Lab 06 — Interview Q&A (mpstat + Multi-Core CPU Analysis)

> This file contains interview-style questions and answers based on the work performed in **Lab 06: Using mpstat for Multi-Core System Analysis**.

---

## 1) What is `mpstat` and why is it useful?
**Answer:**  
`mpstat` (Multiprocessor Statistics) is a tool from the `sysstat` package that reports CPU utilization metrics for **all CPUs** or **specific CPUs**. It is useful for analyzing performance on multi-core systems, identifying CPU bottlenecks, checking load distribution, and spotting virtualization-related delays like `%steal`.

---

## 2) What’s the difference between physical cores and logical CPUs?
**Answer:**  
- **Physical cores** are actual CPU cores on the processor.
- **Logical CPUs** include hyperthreaded threads (if enabled).  
In this lab, the system showed:
- `Core(s) per socket: 2`
- `Thread(s) per core: 2`
So the machine provided **4 logical CPUs** total.

---

## 3) How did you verify the system CPU configuration?
**Answer:**  
I used:
- `lscpu` for summary architecture and topology
- `/proc/cpuinfo` for detailed processor entries and core/sibling values
- `nproc` for total logical CPU count
- `uptime` for load average baseline

---

## 4) What does `%usr` represent in `mpstat` output?
**Answer:**  
`%usr` is the percentage of CPU time spent running **user space** processes (normal applications), excluding time spent on kernel/system tasks.

---

## 5) What does `%sys` represent in `mpstat` output?
**Answer:**  
`%sys` is the percentage of CPU time spent in **kernel space**, performing system calls, running drivers, and handling OS-level work.

---

## 6) What does `%iowait` tell you?
**Answer:**  
`%iowait` indicates the CPU is idle while waiting for I/O operations (disk/network I/O). High `%iowait` often points to storage bottlenecks or slow I/O paths.

---

## 7) What does `%steal` mean and when is it important?
**Answer:**  
`%steal` is the percentage of time a virtual CPU was **waiting for the hypervisor** to schedule it on a physical CPU. It’s critical in virtualized environments (like cloud VMs). Persistent high `%steal` suggests host contention and can cause unexplained slowness.

---

## 8) How do you monitor all CPU cores in real-time with mpstat?
**Answer:**  
A common command is:
- `mpstat -P ALL 2 5`  
This monitors all cores every 2 seconds for 5 samples. For continuous monitoring you can omit the count:
- `mpstat -P ALL 2`

---

## 9) How did you generate controlled CPU load in this lab?
**Answer:**  
I used the `stress` tool:
- `stress --cpu $(nproc) --timeout 60s &`  
This created CPU load across all logical CPUs, allowing me to observe per-core utilization changes in `mpstat`.

---

## 10) What is CPU affinity and how did you test it?
**Answer:**  
CPU affinity pins a process to a specific CPU core to control scheduling behavior.  
In this lab, I used:
- `taskset -c <cpu_id> stress --cpu 1 --timeout 10s`  
Then I monitored the pinned CPU with `mpstat -P <cpu_id>`.

---

## 11) What did you observe when running multiple processes on only one CPU core?
**Answer:**  
The CPU pinned core reached near 100% utilization while other cores remained mostly idle. This demonstrated poor distribution and showed how pinning everything to one core can create bottlenecks even when other cores are free.

---

## 12) How did you validate “balanced load distribution” vs “unbalanced”?
**Answer:**  
I captured `mpstat -P ALL` logs in two scenarios:
- **Unbalanced:** all processes pinned to CPU0  
- **Balanced:** processes distributed across all CPUs  
The per-core averages showed whether utilization was evenly spread or concentrated.

---

## 13) Why did you install and enable `sysstat` service?
**Answer:**  
`sysstat` enables **historical performance data collection** (via `sar`). Without enabling it, `sar` might have no data to analyze. I verified `ENABLED="true"` in `/etc/default/sysstat`.

---

## 14) What is `sar` and how is it related to `mpstat`?
**Answer:**  
`sar` (System Activity Reporter) provides historical performance reporting. Both `sar` and `mpstat` come from `sysstat`. In this lab, I used `sar -u` and `sar -P ALL` to analyze CPU usage trends from sysstat log files.

---

## 15) How would you approach performance tuning if CPU usage is consistently high?
**Answer:**  
I would:
1. Identify top CPU consumers (`ps aux --sort=-%cpu`)
2. Determine if load is evenly distributed (`mpstat -P ALL`)
3. Check for I/O wait or steal time (`%iowait`, `%steal`)
4. Consider CPU affinity for critical workloads (`taskset`)
5. Tune process priority (`nice/renice`) if required
6. Evaluate scaling options if sustained >70–80% utilization

---
