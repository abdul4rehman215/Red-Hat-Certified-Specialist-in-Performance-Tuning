# 🛠️ Troubleshooting Guide — Lab 19: Using eBPF for System Performance Analysis

> This troubleshooting guide is based strictly on the lab workflow and common issues when running **BCC eBPF tools** (`syscount.py`, `gethostlatency.py`, etc.) on **CentOS Stream 9**.

---

## ✅ Issue 1: eBPF Tools Don’t Work Because Kernel/Filesystem Requirements Aren’t Met

### 🔍 Symptom
- Tools fail immediately, or show errors referencing tracing/debugfs/bpf filesystem.
- `/sys/kernel/debug/tracing/` not accessible.

### ✅ Checks Used in Lab
```bash
uname -r
ls /sys/kernel/debug/tracing/ | head -15
mount | grep bpf
````

Expected:

* Kernel modern enough (`5.14.x` in lab)
* `bpffs` mounted on `/sys/fs/bpf`

### ✅ Fix Used in Lab (debugfs mount)

```bash
sudo mount -t debugfs debugfs /sys/kernel/debug
mount | grep debugfs
sudo ls -la /sys/kernel/debug/tracing/ | head -12
```

---

## ✅ Issue 2: `syscount.py` Not Found

### 🔍 Symptom

* `which syscount.py` returns nothing
* Running `/usr/share/bcc/tools/syscount.py` fails because file doesn’t exist

### ✅ Fix Used in Lab (Install/Verify BCC)

```bash
sudo dnf install -y epel-release
sudo dnf install -y bcc-tools kernel-devel-$(uname -r)
sudo dnf install -y python3-bcc
```

Verify:

```bash id="x7d4oq"
which syscount.py
ls /usr/share/bcc/tools/ | head -20
```

---

## ✅ Issue 3: Permission Errors (Need Root for Tracing)

### 🔍 Symptom

* BCC tools fail with permission denied or cannot attach probes

### ✅ Fix (Lab Behavior)

Run tools with sudo:

```bash id="v8n6gg"
sudo /usr/share/bcc/tools/syscount.py -d 10
sudo /usr/share/bcc/tools/gethostlatency.py
```

Also verified access to tracing events:

```bash id="c2om71"
sudo ls /sys/kernel/debug/tracing/events/ | head -10
```

---

## ✅ Issue 4: `syscount` Output Looks “Too Small” or Empty

### 🔍 Symptom

* Syscall counts are very low
* It appears nothing is being traced

### ✅ Explanation

If the system is idle, fewer syscalls happen. In this lab, we generated activity to make tracing meaningful.

### ✅ Workload Used in Lab

```bash id="7m8tua"
./test_workload.sh
```

And for process-specific tracing:

```bash id="5l6c7f"
sleep 20 &
TARGET_PID=$!
sudo /usr/share/bcc/tools/syscount.py -p $TARGET_PID -d 5
```

---

## ✅ Issue 5: `gethostlatency.py` Shows No Lines

### 🔍 Symptom

* Tool runs but prints only header
* No DNS activity appears

### ✅ Explanation

`gethostlatency.py` reports only when a process triggers DNS resolution via `getaddrinfo/gethostbyname`. If nothing performs DNS lookups, it will stay empty.

### ✅ Fix Used in Lab (Generate DNS Activity)

```bash id="m9l4ck"
./dns_test.sh
```

Also ensured DNS tools exist:

```bash id="9s4c3j"
which nslookup || sudo dnf install -y bind-utils
```

---

## ✅ Issue 6: Stopping `gethostlatency.py` After Logging

### 🔍 Symptom

* Tool is running in background writing to a log
* Need to stop it cleanly

### ✅ Fix Used in Lab

```bash id="f6n4o6"
sudo pkill -f gethostlatency.py
```

---

## ✅ Issue 7: PID-Filtered gethostlatency Shows Nothing

### 🔍 Symptom

You run:

```bash
sudo /usr/share/bcc/tools/gethostlatency.py -p $(pgrep -n bash) -t
```

but see no DNS entries.

### ✅ Explanation (Observed in Lab)

`bash` itself usually does not resolve DNS. The lookup happens inside tools like `nslookup/host/dig`, so filtering to the wrong PID produces empty output.

---

## ✅ Issue 8: Monitoring Bundle Script Produces Folder but Missing Optional Files

### 🔍 Symptom

* `ebpf_monitoring_.../` is created
* but `file_opens.txt` or `process_execs.txt` not present

### ✅ Explanation

The script only starts those tools if they exist:

* `/usr/share/bcc/tools/opensnoop.py`
* `/usr/share/bcc/tools/execsnoop.py`

### ✅ Fix

Confirm tools exist:

```bash id="d3qf2s"
ls /usr/share/bcc/tools/opensnoop.py
ls /usr/share/bcc/tools/execsnoop.py
```

If missing, reinstall/verify BCC tool package:

```bash id="o2vk8b"
sudo dnf install -y bcc-tools
```

---

## ✅ Issue 9: `wait` Confusion When Monitoring in Background

### 🔍 Symptom

* You start syscount with redirect in background and `wait` appears to “hang”

### ✅ Explanation

`wait` waits for background jobs to complete. In the lab:

* `syscount.py -d 30` completes after 30 seconds
  So `wait` is expected to block until completion.

Lab pattern:

```bash id="x9q3no"
sudo /usr/share/bcc/tools/syscount.py -d 30 > syscount_output.txt &
sleep 2
./test_workload.sh
wait
```

---

## ✅ Issue 10: Analyzer Scripts Parse “Too Much” or Percentages > 100%

### 🔍 Symptom

Analyzer prints:

* I/O percentage slightly above 100% (example seen in lab: 100.14%)

### ✅ Explanation (Lab-Accurate)

This happens because the I/O list can overlap or not perfectly match syscall names in output (e.g., using both `open` and `openat` or including syscalls not present). It’s not a tool failure; it just means the classification list should be refined.

### ✅ Fix Approach

Refine syscall classification lists to match only syscalls that appear in your captured output (e.g., prefer `openat` on newer systems).

---

## ✅ Best Practices (Lab-Relevant)

* Always verify `bpffs` and `debugfs` before tracing
* Run BCC tools with `sudo`
* Generate controlled workload to make results meaningful
* Capture output to logs for repeatable analysis
* Use scripts (`comprehensive_monitor.sh`) to bundle evidence during troubleshooting
* Convert raw output into structured reporting (`generate_performance_report.py`) for professional documentation

---
