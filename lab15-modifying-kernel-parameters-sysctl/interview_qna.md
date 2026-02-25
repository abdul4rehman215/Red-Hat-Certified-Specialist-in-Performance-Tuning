# 💬 Interview Q&A — Lab 15: Modifying Kernel Parameters with `sysctl`

> This Q&A is based on **Lab 15**, where I used `sysctl` to inspect, tune, validate, and persist Linux kernel parameters for **memory**, **networking**, **filesystem**, and **security**.

---

## 1) What is `sysctl` and what is it used for?

`sysctl` is a Linux utility used to **view and modify kernel parameters at runtime**.  
It controls kernel behavior across categories like:
- virtual memory (`vm.*`)
- networking (`net.*`)
- filesystem (`fs.*`)
- kernel/security (`kernel.*`)

It allows tuning **without rebooting**.

---

## 2) How do you list all sysctl parameters?

```bash
sudo sysctl -a
````

To count how many parameters exist:

```bash
sudo sysctl -a | wc -l
```

In this lab it returned **1098**.

---

## 3) What is the difference between `sysctl -a` and reading `/proc/sys/...` directly?

They are two views into the same sysctl interface:

* `/proc/sys/...` is the filesystem representation
* `sysctl` is a safer and more standardized interface

Example:

```bash
sysctl vm.swappiness
cat /proc/sys/vm/swappiness
```

---

## 4) What does `vm.swappiness` control?

It controls how aggressively the kernel swaps memory to disk. Range **0–100**:

* lower: swap less (prefer RAM)
* higher: swap more aggressively

In this lab, `vm.swappiness` was tuned to **10** for lower swap tendency.

---

## 5) What are “dirty” memory parameters and why tune them?

Dirty pages are memory pages that were modified but not yet written to disk.

Key parameters tuned:

* `vm.dirty_ratio`
* `vm.dirty_background_ratio`
* `vm.dirty_expire_centisecs`
* `vm.dirty_writeback_centisecs`

They impact **writeback behavior**, latency, and I/O bursts. Tuning helps smooth out writeback and reduce spikes.

---

## 6) What does `vm.vfs_cache_pressure` do?

It controls how aggressively the kernel reclaims filesystem metadata cache (inode/dentry caches):

* lower value keeps cache longer (faster filesystem metadata operations)
* higher value reclaims cache faster (frees memory sooner)

In this lab it was set to **50** to retain cache longer.

---

## 7) Why tune TCP keepalive parameters?

TCP keepalive tuning helps detect dead connections faster and reduce stale sessions.

We tuned:

* `net.ipv4.tcp_keepalive_time = 600`
* `net.ipv4.tcp_keepalive_probes = 3`
* `net.ipv4.tcp_keepalive_intvl = 60`

This is useful for environments with NAT gateways, firewalls, and long-lived connections.

---

## 8) What does `net.core.somaxconn` affect?

`net.core.somaxconn` controls the **maximum connection backlog** for listening sockets (e.g., web servers).
We tuned it to **65535** for high-connection workloads.

---

## 9) Why tune socket buffer sizes (`rmem/wmem`)?

Buffer sizes affect throughput and performance for high-bandwidth or high-latency networks.

Adjusted parameters:

* `net.core.rmem_default`, `net.core.wmem_default`
* `net.core.rmem_max`, `net.core.wmem_max`
* `net.ipv4.tcp_rmem`, `net.ipv4.tcp_wmem`

This helps reduce packet loss due to buffer constraints and improves transfer rates under load.

---

## 10) How did you choose TCP congestion control?

We checked available algorithms:

```bash
sysctl net.ipv4.tcp_available_congestion_control
```

The environment supported **reno** and **cubic**, so we used:

* `net.ipv4.tcp_congestion_control = cubic`

If BBR was available, we would prefer it for some WAN/high-latency cases.

---

## 11) How do you make sysctl changes persistent?

Runtime changes disappear after reboot. Persistence is done via:

* `/etc/sysctl.conf`
* `/etc/sysctl.d/*.conf` (recommended)

We created:

* `/etc/sysctl.d/99-performance-tuning.conf`
* `/etc/sysctl.d/98-security-tuning.conf`
* `/etc/sysctl.d/97-filesystem-tuning.conf`

Apply:

```bash
sudo sysctl -p /etc/sysctl.d/99-performance-tuning.conf
sudo sysctl --system
```

---

## 12) What validation approach did you use?

A validation script (`validate_config.sh`) checks:

* each key=value in the config file
* compares expected vs actual sysctl output
* logs results into `/tmp/sysctl_validation.log`

Important note: multi-value parameters like `tcp_rmem` require whitespace-aware comparisons.

---

## 13) What production best practice did you implement for safety?

Two key safeguards:

1. **Backup** current sysctl state:

   * `backup_sysctl.sh` creates `/tmp/sysctl_backup_<timestamp>.conf`
2. **Restore** from backup:

   * `restore_sysctl.sh <backup_file>`

This creates an easy rollback path.

---

## 14) Why create role-based tuning profiles?

Different workloads need different tuning:

* Web servers: high connections, low timeouts, high backlog
* Databases: lower swappiness, tuned dirty writeback, filesystem limits
* Default: balanced profile

`sysctl_profiles.sh` supports:

* `webserver`
* `database`
* `default`
* `list`

---

## 15) What monitoring did you do to observe impact?

I used:

* `performance_monitor.sh` (uptime, memory, iostat, socket stats, current sysctl snapshot)
* `load_test.sh` (stress-ng + dd I/O workload)
* `compare_performance.sh` (prints tuned vs typical defaults + current system status)

This creates repeatable **baseline → change → test → compare** evidence.
