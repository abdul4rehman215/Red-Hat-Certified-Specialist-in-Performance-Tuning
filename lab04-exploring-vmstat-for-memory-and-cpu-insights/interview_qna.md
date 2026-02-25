# 🎤 Interview Q&A — Lab 04: Exploring `vmstat` for Memory and CPU Insights

> This Q&A is based on the workflow performed in the lab: using `vmstat` in snapshot/continuous modes, simulating memory + swap pressure, generating CPU and I/O workloads, analyzing disk/partition stats, and creating baselines + dashboards.

---

## 1) What is `vmstat` used for?
`vmstat` reports virtual memory and overall system performance statistics in a compact format. It helps quickly identify whether a system is CPU-bound, memory-bound, or I/O-bound.

---

## 2) What does the first line of `vmstat` represent when running `vmstat <delay>`?
The first line after the header often represents averages since boot or since vmstat started sampling (depending on implementation).  
The subsequent lines represent activity during each sampling interval and are typically the most useful for real-time analysis.

---

## 3) What do the `r` and `b` columns mean in vmstat?
- `r`: number of runnable processes waiting for CPU time (run queue)
- `b`: number of processes blocked (usually waiting on I/O)

If `r` consistently exceeds CPU core count, that suggests CPU contention. If `b` is consistently > 0 with high `wa`, it suggests I/O contention.

---

## 4) How do you detect memory pressure using vmstat?
Key indicators include:
- `free` consistently low (trend)
- `swpd` increasing (swap in use)
- frequent `si` / `so` activity (swap in/out)
- overall performance impact (higher context switches, blocked tasks)

---

## 5) What is the difference between `swpd` and `si/so`?
- `swpd`: total amount of swap used (KB)
- `si`: swap-in rate (KB/s) — pages being read from swap into RAM
- `so`: swap-out rate (KB/s) — pages being written from RAM to swap

High `si/so` indicates **active swapping**, which usually hurts performance.

---

## 6) Why is swap activity harmful to performance?
Swap uses a much slower medium than RAM (even zram has overhead). Active swapping increases latency and can make systems feel slow or unresponsive. It’s a common symptom of memory pressure or leaks.

---

## 7) What do the CPU columns `us`, `sy`, `id`, and `wa` mean?
- `us`: CPU time running user-space code
- `sy`: CPU time running kernel-space code
- `id`: idle time
- `wa`: time waiting for I/O (disk/network)

High `us` suggests CPU-bound workload; high `wa` suggests I/O bottlenecks.

---

## 8) How do you differentiate CPU bottleneck vs I/O bottleneck using vmstat?
- **CPU bottleneck**: high `us+sy`, low `id`, run queue (`r`) grows
- **I/O bottleneck**: `wa` increases, blocked processes (`b`) rises, I/O activity (`bi/bo`) increases

---

## 9) What are `bi` and `bo` used for?
- `bi`: blocks received from block device (read activity)
- `bo`: blocks sent to block device (write activity)

They help correlate I/O workload with high `wa` or increasing `b`.

---

## 10) What is the benefit of `vmstat -d` and `vmstat -p`?
- `vmstat -d`: disk statistics (reads/writes, sectors, time)
- `vmstat -p <partition>`: partition-level read/write counters

They help pinpoint which disks/partitions are busy and validate that bottlenecks align with storage activity.

---

## 11) Why did `vmstat -p /dev/sda1` fail in the lab?
Because the VM used **NVMe storage** (e.g., `/dev/nvme0n1p1`) instead of `sda1`.  
In cloud environments, device naming often differs, so `lsblk` should be used to confirm the correct partition.

---

## 12) What does `vmstat -s` provide that regular vmstat output does not?
`vmstat -s` provides cumulative counters and totals such as:
- total/used/free memory
- swap totals and usage
- CPU ticks (user, system, idle, iowait)
These are useful for baseline snapshots and deeper analysis.

---

## 13) Why do you create a system performance baseline file?
A baseline captures “normal” behavior (CPU/memory/disk/network + vmstat samples).  
It makes it easier to detect regressions and identify what changed during incidents (before vs during vs after comparisons).

---

## 14) How did the lab simulate real performance issues?
Using scripts:
- memory allocation (memory_test.sh)
- swap pressure (swap_test.sh using stress)
- CPU load (cpu_test.sh)
- I/O load (io_test.sh)
- combined menu simulator (performance_simulator.sh)

Then observed expected signatures in vmstat (changes in `free`, `swpd`, `us/sy/id/wa`, `bi/bo`, `r/b`).

---

## 15) What is the value of a real-time vmstat dashboard script?
A dashboard automates:
- consistent sampling
- interpretation rules (normal/warning/critical)
- rapid triage visibility without manual parsing  
It’s especially useful during incidents when you need quick classification and evidence.

---
