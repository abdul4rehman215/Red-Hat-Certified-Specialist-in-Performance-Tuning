# 🧪 Lab 15: Modifying Kernel Parameters with `sysctl`

> **Track:** Red Hat Certified Specialist in Performance Tuning (Exam)  
> **Scope:** Runtime + persistent kernel parameter tuning using `sysctl` and `/etc/sysctl.d/*`

---

## 🎯 Objectives

By the end of this lab, I was able to:

- Understand the purpose and functionality of the `sysctl` command
- View and modify kernel parameters dynamically (without rebooting)
- Tune virtual memory parameters for better system responsiveness
- Adjust network parameters for improved network performance
- Make tuning persistent across reboots using `/etc/sysctl.d/*.conf`
- Monitor system performance impact using repeatable scripts and baseline comparisons
- Apply best practices: validation + backup/restore + role-based profiles

---

## ✅ Prerequisites

- Basic Linux system administration skills
- Comfort with CLI and file editing
- Understanding of basic networking concepts
- Root/sudo access
- Familiarity with basic monitoring tools (`free`, `uptime`, `ss`, `iostat`, etc.)

---

## 🧰 Lab Environment

This lab was performed in an online cloud lab environment.

| Component | Details |
|---|---|
| OS | CentOS/RHEL-like (EL9 behavior) |
| Access | sudo/root |
| Tools | `sysctl`, `/proc`, `iostat` (via `sysstat`), `stress-ng` (installed during lab) |
| Persistence | `/etc/sysctl.d/*.conf` |
| Notes | Performance tuning values reflect lab environment and should always be tested before production deployment. |

---

## 🗂️ Repository Structure (Lab 15)

```text
lab15-modifying-kernel-parameters-sysctl/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
├── configs/
│   ├── 97-filesystem-tuning.conf
│   ├── 98-security-tuning.conf
│   └── 99-performance-tuning.conf
├── scripts/
│   ├── explore_sysctl.sh
│   ├── monitor_memory.sh
│   ├── monitor_cache.sh
│   ├── monitor_network.sh
│   ├── performance_monitor.sh
│   ├── load_test.sh
│   ├── compare_performance.sh
│   ├── validate_config.sh
│   ├── backup_sysctl.sh
│   ├── restore_sysctl.sh
│   └── sysctl_profiles.sh
└── artifacts/
    ├── performance_log_20260226_123910.txt
    ├── performance_log_20260226_124105.txt
    └── sysctl_validation.log
````

---

## 🧾 Lab Summary

This lab focused on controlling kernel behavior through `sysctl`:

* Explored sysctl output and categories (VM, NET, KERNEL, FS)
* Tuned memory parameters:

  * `vm.swappiness`, dirty page ratios, cache pressure
* Tuned network parameters:

  * TCP keepalive, connection handling, buffer defaults/max, congestion control selection (BBR if available else CUBIC)
* Measured performance before and after changes:

  * baseline monitoring + load test + post-change monitoring
* Created persistent tuning configurations:

  * `/etc/sysctl.d/99-performance-tuning.conf`
  * `/etc/sysctl.d/98-security-tuning.conf`
  * `/etc/sysctl.d/97-filesystem-tuning.conf`
* Implemented production-style safety controls:

  * validation script (fixed to support multi-value sysctl params)
  * backup and restore scripts
  * role-based profiles (webserver/database/default)

---

## ✅ Tasks Overview

### ✅ Task 1: Understanding and Exploring `sysctl`

* listed kernel parameters and counted them
* reviewed sysctl help/options
* inspected VM and network parameter sets
* created `explore_sysctl.sh` to show categorized key values

### ✅ Task 2: Modifying Virtual Memory Parameters

* reviewed memory state (`free -h`, `/proc/meminfo`)
* monitored memory behavior using `monitor_memory.sh`
* tuned:

  * `vm.swappiness`
  * dirty memory policy (`dirty_ratio`, `dirty_background_ratio`, `dirty_expire_centisecs`, `dirty_writeback_centisecs`)
  * caching policy (`vm.vfs_cache_pressure`)
* built cache monitoring script `monitor_cache.sh`

### ✅ Task 3: Configuring Network Parameters

* monitored network sysctl state via `monitor_network.sh`
* tuned TCP behavior:

  * keepalive time/probes/interval
  * enabled window scaling/timestamps/SACK
  * congestion control selection (BBR if available else CUBIC)
* tuned buffers:

  * default/max send/receive buffers
  * tcp_rmem/tcp_wmem
* tuned connection limits:

  * somaxconn, backlog, syncookies, fin timeout, TIME_WAIT reuse

### ✅ Task 4: Monitoring Performance Impact

* created `performance_monitor.sh` and logged snapshots to `/tmp/performance_log_*.txt`
* installed `stress-ng` when missing
* executed `load_test.sh` to generate controlled CPU/memory/I/O activity
* compared metrics using `compare_performance.sh`

### ✅ Task 5: Persistence + Validation

* reviewed sysctl persistence locations (`/etc/sysctl.conf`, `/etc/sysctl.d/`)
* created persistent tuning config:

  * `/etc/sysctl.d/99-performance-tuning.conf`
* applied changes:

  * `sysctl -p <file>`
  * `sysctl --system`
* created `validate_config.sh`

  * **realistic bug discovered** (spaces removed in multi-value params)
  * fixed script normalization so `tcp_rmem/tcp_wmem` validate correctly
* created backup/restore tools:

  * `backup_sysctl.sh`
  * `restore_sysctl.sh`

### ✅ Task 6: Advanced Tuning (Security + Filesystem + Profiles)

* created security tuning file (`98-security-tuning.conf`)
* created filesystem tuning file (`97-filesystem-tuning.conf`)
* created profile tool `sysctl_profiles.sh`:

  * `webserver` profile
  * `database` profile
  * `default` profile
  * verified applied values

---

## ✅ Verification

Verified settings were applied via:

* `sysctl -p /etc/sysctl.d/99-performance-tuning.conf`
* `sysctl --system`
* `validate_config.sh`
* direct checks:

  * `sysctl vm.swappiness`
  * `sysctl net.core.somaxconn`
  * `sysctl net.ipv4.tcp_fin_timeout`
  * etc.

---

## 🧠 What I Learned

* `sysctl` provides controlled runtime tuning and standard persistence mechanisms
* Multi-value parameters (like `tcp_rmem`) require careful validation handling (whitespace matters)
* Professional tuning workflow includes:

  * monitoring + baseline evidence
  * safe change rollout
  * validation
  * rollback plan
  * role-based profiles

---

## 🌍 Real-World Relevance

* Web servers: high connection load, backlog, TIME_WAIT tuning
* Databases: low swappiness, dirty writeback behavior tuning, file handle limits
* Security baselines: rp_filter, disable redirects/source routing, enable ASLR
* Operations: consistent tuning via `/etc/sysctl.d/*.conf` + automated validation

---

## 🏁 Conclusion

In this lab, I used `sysctl` to inspect, tune, validate, and persist kernel parameters affecting memory, network, filesystem, and security behavior. I also built reusable scripts for monitoring, baseline comparison, validation (including multi-value fixes), backup/restore, and workload-specific profiles—mirroring real-world production tuning practices.

✅ **Lab 15 completed successfully on a Linux cloud environment.**
