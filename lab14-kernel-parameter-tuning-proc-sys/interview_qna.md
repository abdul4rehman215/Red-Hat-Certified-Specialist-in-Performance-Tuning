# 💬 Interview Q&A — Lab 14: Kernel Parameter Tuning with `/proc/sys`

> This Q&A is based on the work performed in **Lab 14**, focusing on runtime kernel tuning via `/proc/sys` and persistent configuration using `sysctl`.

---

## 1) What is `/proc/sys` and why is it important?

`/proc/sys` is a runtime interface into kernel parameters (sysctl).  
It allows administrators to **view and modify kernel behavior live** without recompiling or rebooting.

---

## 2) What are the main categories under `/proc/sys` you explored?

From this lab:
- `kernel/` (host/kernel behavior)
- `vm/` (virtual memory behavior)
- `net/` (network stack parameters)
- `fs/` (filesystem and file descriptor parameters)

---

## 3) What is `vm.swappiness`?

`vm.swappiness` controls how aggressively the kernel swaps memory pages to disk.  
Range: **0 to 100**
- Lower values: prefer RAM, reduce swapping
- Higher values: swap earlier/more aggressively

In this lab, we tuned it from `60` down to `10` (and also tested `20` via sysctl).

---

## 4) How can you change `vm.swappiness` at runtime?

Two methods shown in the lab:

**Method A: Write directly to `/proc/sys`**
```bash
echo 10 > /proc/sys/vm/swappiness
````

**Method B: Use sysctl**

```bash
sysctl vm.swappiness=20
```

---

## 5) Why can `sudo echo 10 > /proc/sys/...` fail?

Because `>` redirection happens in the **current shell**, not inside sudo.
So `echo` may run as root, but the redirection is still done as the non-root user.

Correct approaches:

* `sudo su -` then write
* or use `sudo tee`:

```bash id="21f8ez"
echo 10 | sudo tee /proc/sys/vm/swappiness
```

---

## 6) What do `net.ipv4.tcp_rmem` and `tcp_wmem` control?

They control TCP socket buffer sizes (receive and send).
Each has three values:

* **min**
* **default**
* **max**

This affects throughput and performance, especially on high-latency networks.

---

## 7) Why did you also tune `net.core.rmem_max` and `net.core.wmem_max`?

Because `tcp_rmem/tcp_wmem` maximums are constrained by system-wide socket limits:

* `net.core.rmem_max`
* `net.core.wmem_max`

We increased them to match tuned TCP max values to allow larger buffers.

---

## 8) What are `vm.dirty_ratio` and `vm.dirty_background_ratio`?

They control how much dirty (modified) memory can accumulate before:

* background writeback kicks in (`dirty_background_ratio`)
* processes are forced to flush (`dirty_ratio`)

Lowering them can reduce latency spikes under write-heavy workloads (but can increase writeback frequency).

---

## 9) What is `vm.vfs_cache_pressure`?

It controls how aggressively the kernel reclaims filesystem caches (inode/dentry caches).
Lower value (e.g., 50) means:

* keep caches longer
* potentially faster file metadata operations
  But uses more memory for cache retention.

---

## 10) What does `fs.file-max` represent?

It defines the **maximum number of file handles** the kernel can allocate system-wide.
This matters for servers with high concurrency (many open sockets/files).

In this lab, it was set to `1048576` for testing purposes.

---

## 11) How did you make sysctl changes persistent across reboots?

By using a file under:

* `/etc/sysctl.d/`

Example used:

* `/etc/sysctl.d/99-performance-tuning.conf`

Then apply immediately:

```bash id="7wy8az"
sysctl -p /etc/sysctl.d/99-performance-tuning.conf
```

---

## 12) How did you validate that the tuned values were correctly applied?

Two ways:

1. Read directly from `/proc/sys/...`
2. Use `sysctl` queries
3. Run a validation script (`validate_tuning.sh`) that checks expected values and prints pass/fail.

---

## 13) What testing did you use to compare before vs after?

We created scripts to capture:

* baseline kernel parameter snapshot (`baseline_check.sh`)
* I/O test via `dd` + optional `fio` (`io_test.sh`)
* network test via `iperf3` if available, otherwise `nc` fallback (`network_test.sh`)
* monitoring loop (`monitor_performance.sh`)

Outputs were redirected into artifact files:

* `baseline_results.txt`, `optimized_results.txt`
* `baseline_io_results.txt`, `optimized_io_results.txt`

---

## 14) Why did `io_test.sh` initially show “Permission denied”?

The lab produced a realistic issue where the script existed but wasn’t executable at runtime (or had been saved in a way that removed exec permissions).
The fix was:

```bash
chmod +x io_test.sh
```

---

## 15) What’s the key safety principle in kernel tuning?

Always follow:
**baseline → change → test → validate → persist**

Kernel tuning can improve performance, but wrong values can hurt stability or throughput.
You should:

* document changes
* test in non-production first
* apply incrementally
* validate after every change
