# 🛠️ Troubleshooting Guide — Lab 17: Analyzing Application Performance with `ps`

> This troubleshooting guide is based strictly on the lab actions and common issues encountered when using `ps`, signals, and process monitoring scripts in a CentOS/RHEL environment.

---

## ✅ Issue 1: Process Information Not Updating

### 🔍 Symptom
- `ps` output appears “stale” or doesn’t reflect expected memory/cpu changes quickly.
- You expect changes after stopping/starting workloads but view doesn’t seem refreshed.

### ✅ Fix / Commands Used
```bash
sync
sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
````

### 📝 Notes

* `sync` flushes filesystem buffers.
* Dropping caches can help when investigating memory behavior; use cautiously (especially on production systems).

---

## ✅ Issue 2: Cannot Kill a Process (TERM Doesn’t Work)

### 🔍 Symptom

* Process ignores `TERM` or doesn’t exit after graceful stop attempts.

### ✅ Fix / Signal Escalation Strategy

Try escalating signals in order:

```bash
kill -TERM $PID
sleep 5
kill -INT $PID
sleep 5
kill -KILL $PID
```

### 📝 Notes

* `TERM` (15): default, graceful exit request.
* `INT` (2): similar to Ctrl+C, often handled by interactive programs.
* `KILL` (9): force kill, no cleanup—use last.

---

## ✅ Issue 3: High CPU Usage but No Obvious User Process

### 🔍 Symptom

* System feels slow/high CPU, but `ps aux --sort=-%cpu` doesn’t clearly show the culprit.
* Often happens when kernel threads or internal tasks consume CPU.

### ✅ Fix / Commands Used

List kernel threads (bracketed names):

```bash
ps aux | grep -E '\[.*\]'
```

Example output observed:

```text
root           2  0.0  0.0      0     0 ?        S    12:14   0:00 [kthreadd]
root           8  0.0  0.0      0     0 ?        I<   12:14   0:00 [rcu_sched]
root         109  0.5  0.0      0     0 ?        S    12:14   0:12 [ksoftirqd/0]
```

Then check if I/O is involved:

```bash
iostat 1 5
```

---

## ✅ Issue 4: Memory Usage “Doesn’t Add Up”

### 🔍 Symptom

* Sum of per-process memory doesn’t match `free` or system totals.
* RSS/VSZ values seem confusing compared to total used RAM.

### ✅ Fix / Commands Used

Inspect kernel-reported memory breakdown:

```bash
cat /proc/meminfo | head -15
```

Inspect a process memory map:

```bash
pmap -x $PID | head -15
```

Example output observed:

```text
2124:   python3 -c import time; [time.sleep(0.1) for _ in range(1000)]
Address           Kbytes     RSS   Dirty Mode  Mapping
0000562a3c000000    1320     560       0 r-x-- python3.6
0000562a3c14a000    1024     320       0 r---- python3.6
0000562a3c24a000     512     256     256 rw--- python3.6
...
```

### 📝 Notes

* Linux uses page cache and buffers heavily; “used” memory includes caches.
* RSS is per-process physical memory usage, while system totals include shared memory and caches.

---

## ✅ Issue 5: `bc` Not Found for CPU Stress Script

### 🔍 Symptom

* Running the CPU workload script fails because `bc` is missing.

### ✅ Fix / Command Used

```bash
which bc || sudo yum install -y bc
```

---

## ✅ Issue 6: Monitoring Scripts Show Empty Results

### 🔍 Symptom

* You run:

  ```bash
  ./process_manager.sh --search "python"
  ```

  and get no output.

### ✅ Why This Happened in the Lab

The memory-intensive Python workload had already been terminated, so there were no matching processes. That is normal.

### ✅ Validation

Use plain search with `ps` to confirm:

```bash
ps aux | grep -i python | grep -v grep
```

---

## ✅ Notes / Best Practices

* Use `watch` for quick real-time monitoring, but exit it cleanly with **Ctrl+C**.
* Always capture baseline before doing optimization (the lab created a baseline file).
* Avoid `kill -9` unless necessary.
* For automation scripts, always:

  * validate PID exists
  * print process details before action
  * confirm success after action

---
