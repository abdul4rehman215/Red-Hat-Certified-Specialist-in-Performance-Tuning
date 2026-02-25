# 🧪 Lab 14: Kernel Parameter Tuning with `/proc/sys`

> **Track:** Red Hat Certified Specialist in Performance Tuning (Exam)  
> **Lab Range in this repo:** Labs 11–15 (this folder = Lab 14)

---

## 🎯 Objectives

By the end of this lab, I was able to:

- Navigate and explore the `/proc/sys` filesystem to understand kernel parameters
- View current kernel parameter values and understand their impact on system performance
- Modify kernel parameters at runtime using the `/proc/sys` interface
- Tune performance parameters such as:
  - `vm.swappiness`
  - `net.ipv4.tcp_rmem` / `net.ipv4.tcp_wmem`
  - `net.core.rmem_max` / `net.core.wmem_max`
  - `vm.dirty_ratio` / `vm.dirty_background_ratio`
  - `vm.vfs_cache_pressure`
  - `fs.file-max`
- Validate changes using `sysctl` and custom validation scripts
- Perform before/after comparisons using simple performance test scripts
- Make changes persistent across reboots using `/etc/sysctl.d/*.conf`

---

## ✅ Prerequisites

- Basic Linux system administration knowledge
- Comfortable with CLI navigation and shell commands
- Understanding of memory, network, and I/O performance concepts
- Basic TCP/IP familiarity
- Experience with monitoring tools (e.g., `free`, `top`, `iostat`)

---

## 🧰 Lab Environment

This lab was performed in an online cloud lab environment.

| Component | Details |
|---|---|
| OS | RHEL/CentOS-like Linux (EL9 behavior observed) |
| Access | sudo/root |
| Interfaces | `/proc/sys` and `sysctl` |
| Persistence | `/etc/sysctl.d/99-performance-tuning.conf` |
| Testing Tools | `dd`, optional `fio`, optional `iostat` (`sysstat`) |
| Notes | Some tools were not installed initially (`stress`, `fio`, `sysstat`) and were installed during the lab workflow/troubleshooting. |

---

## 🗂️ Repository Structure (Lab 14)

```text
lab14-kernel-parameter-tuning-proc-sys/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
├── configs/
│   ├── 99-performance-tuning.conf
│   └── 99-custom-tuning.conf
├── scripts/
│   ├── baseline_check.sh
│   ├── memory_test.sh
│   ├── network_test.sh
│   ├── io_test.sh
│   ├── monitor_performance.sh
│   └── validate_tuning.sh
└── artifacts/
    ├── baseline_results.txt
    ├── optimized_results.txt
    ├── baseline_io_results.txt
    └── optimized_io_results.txt
````

> 📌 Notes:
>
> * The lab created files under `~/lab14`, `/tmp`, and `/etc/sysctl.d/`.
> * For GitHub organization:
>
>   * scripts go into `scripts/`
>   * sysctl config goes into `configs/`
>   * generated test outputs go into `artifacts/`

---

## 🧾 Lab Summary

This lab focused on kernel tuning via `/proc/sys` and `sysctl`:

1. Explored `/proc/sys` categories (`kernel/`, `vm/`, `net/`, `fs/`)
2. Captured baseline values for memory, network, and filesystem parameters
3. Tuned:

   * memory swap behavior (`vm.swappiness`)
   * TCP buffer memory (`tcp_rmem/tcp_wmem`, `rmem_max/wmem_max`)
   * writeback behavior (`dirty_ratio`, `dirty_background_ratio`)
   * inode/dentry caching behavior (`vfs_cache_pressure`)
   * file descriptor limits (`fs.file-max`)
4. Ran before/after tests using scripts and stored results
5. Persisted tuning using `/etc/sysctl.d/99-performance-tuning.conf`
6. Validated correct application using `validate_tuning.sh`

---

## ✅ Tasks Overview

### ✅ Task 1: Explore `/proc/sys` and View Kernel Parameters

* Listed `/proc/sys` categories: `abi`, `debug`, `dev`, `fs`, `kernel`, `net`, `user`, `vm`
* Reviewed subdirectories of:

  * `kernel/`
  * `vm/`
  * `net/`
  * `fs/`
* Checked key baseline parameter values:

  * `vm.swappiness`
  * `net.ipv4.tcp_rmem`, `net.ipv4.tcp_wmem`
  * `fs.file-max`
* Used `sysctl` to:

  * list parameters (`sysctl -a | head`)
  * query specific parameters (`sysctl vm.swappiness`)
  * browse grouped parameters (`sysctl vm.` / `sysctl net.ipv4.`)

### ✅ Task 2: Tune Performance Parameters

* Tuned swappiness at runtime:

  * direct write to `/proc/sys/vm/swappiness`
  * `sysctl vm.swappiness=...`
* Tuned TCP buffer memory:

  * updated `tcp_rmem`, `tcp_wmem`
  * increased `net.core.rmem_max` and `net.core.wmem_max`
* Tuned additional parameters:

  * `fs.file-max`
  * `vm.dirty_ratio`, `vm.dirty_background_ratio`
  * `vm.vfs_cache_pressure`
* Created baseline documentation script (`baseline_check.sh`)
* Created a memory pressure test script (`memory_test.sh`)

  * installed `stress` since it was missing

### ✅ Task 3: Testing and Before/After Comparison

* Built scripts for testing:

  * `network_test.sh` (iperf3 if available; fallback to netcat)
  * `io_test.sh` (dd + optional fio)
  * `monitor_performance.sh` (periodic system monitoring; iostat if available)
* Ran baseline test values and saved artifacts:

  * `baseline_results.txt`, `baseline_io_results.txt`
* Ran tuned test values and saved artifacts:

  * `optimized_results.txt`, `optimized_io_results.txt`
* Realistic fix included:

  * handled `Permission denied` on `io_test.sh` by applying executable bit again

### ✅ Task 4: Persistence and Validation

* Persisted tuning:

  * `/etc/sysctl.d/99-performance-tuning.conf`
  * applied using `sysctl -p <file>`
* Created validation script `validate_tuning.sh`

  * confirmed tuned values match expected values

---

## ✅ Verification & Validation

I confirmed:

* Runtime values changed correctly using `/proc/sys` and `sysctl`
* Persistent config loads correctly using:

  * `sysctl -p /etc/sysctl.d/99-performance-tuning.conf`
* Validation script confirms all expected tuned values are applied:

  * `All kernel parameters are correctly tuned!`

---

## 📌 Result

* `/proc/sys` kernel parameters successfully explored and tuned
* Tuned settings applied at runtime and persisted via `/etc/sysctl.d/`
* Before/after artifact files generated for documentation
* A reusable toolkit was created for baseline capture, stress testing, I/O/network testing, monitoring, and validation

---

## 🧠 What I Learned

* `/proc/sys` provides a live interface to kernel behavior control without recompiling the kernel
* Kernel tuning must be:

  * measured (baseline first)
  * tested (before/after)
  * validated (scripts + sysctl checks)
  * persisted carefully (sysctl.d configs)
* Practical tuning areas for performance include:

  * memory swap aggressiveness
  * TCP buffer sizing
  * dirty page writeback behavior
  * cache pressure behavior

---

## 💡 Why This Matters (Performance Tuning Context)

Kernel tuning bridges the gap between:

* hardware capacity
* workload behavior
* and system performance outcomes

Correct tuning can improve:

* responsiveness under memory pressure
* network throughput on high-latency/high-bandwidth paths
* filesystem writeback efficiency under heavy I/O workloads

---

## 🌍 Real-World Applications

* Tuning Linux systems for:

  * web servers
  * database servers
  * log-heavy systems
  * high-throughput network services
* Building repeatable tuning baselines per environment
* Producing documentation evidence for performance change control and audits

---

## 🏁 Conclusion

In this lab, I explored `/proc/sys`, tuned performance-related kernel parameters at runtime, validated results using scripts and sysctl queries, performed baseline vs tuned comparisons, and persisted configurations via `/etc/sysctl.d/`. This workflow mirrors real-world performance engineering: **measure → change → test → validate → persist**.

✅ **Lab 14 completed successfully on a Linux cloud environment.**

