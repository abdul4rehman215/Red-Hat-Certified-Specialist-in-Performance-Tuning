# 🛠️ Lab 10 — Troubleshooting Guide (PCP Multi-Host Monitoring)

> This guide covers common issues encountered while setting up **PCP (Performance Co-Pilot)** across multiple systems (`pcp-monitor`, `target-1`, `target-2`), including PMDA availability, remote access, logging with `pmlogger`, and alerting with `pmie`.

---

## ✅ Issue 1: `pmcd` / `pmlogger` services not running

### **Symptoms**
- `pminfo` returns connection errors
- `pmval` times out
- No archives are created under `/var/log/pcp/pmlogger/`

### **Fix**
Check status:
```bash
sudo systemctl status pmcd pmlogger
````

Start and enable:

```bash
sudo systemctl start pmcd
sudo systemctl enable pmcd
sudo systemctl start pmlogger
sudo systemctl enable pmlogger
```

Check logs:

```bash
sudo journalctl -u pmcd -n 50 --no-pager
sudo journalctl -u pmlogger -n 50 --no-pager
```

---

## ✅ Issue 2: Remote host query fails (`pminfo -h target-1 ...`)

### **Symptoms**

* `pminfo: Cannot connect to host`
* `Connection refused`
* `Timeout waiting for response`

### **Fix Checklist**

1. Verify network reachability:

```bash
ping -c 2 target-1
ping -c 2 target-2
```

2. Confirm `pmcd` is listening on port **44321** on target:

```bash
sudo ss -tlnp | grep :44321
```

Expected pattern:

```text
LISTEN ... *:44321 ... users:(("pmcd",pid=...,fd=...))
```

3. If firewall is enabled (firewalld), allow PCP:

```bash
sudo firewall-cmd --list-all
sudo firewall-cmd --add-port=44321/tcp --permanent
sudo firewall-cmd --reload
```

4. If hostname resolution fails, use IP:

```bash
pminfo -h 192.168.1.101 kernel.all.load
pminfo -h 192.168.1.102 kernel.all.load
```

---

## ✅ Issue 3: `pmcd` access control blocks remote requests

### **Symptoms**

* Remote host reachable, but `pminfo -h ...` still denied
* Logs indicate access restrictions

### **Fix**

PCP access rules must allow your subnet/host. In the lab flow, rules were appended to:

```text
/etc/pcp/pmcd/pmcd.options
```

Example appended rules:

```text
allow 192.168.1.0/24 : all;
allow localhost : all;
```

After changes:

```bash
sudo systemctl restart pmcd
```

✅ Validate by retrying:

```bash
pminfo -h target-1 kernel.all.load
```

---

## ✅ Issue 4: Missing metrics (PMDA not available)

### **Symptoms**

* `pminfo metric.name` returns nothing or errors
* Metrics like `kernel.all.cpu.*`, `mem.util.*` missing

### Fix

1. List installed PMDAs:

```bash
ls /var/lib/pcp/pmdas/
```

2. Check which agents are up:

```bash
pminfo -f pmcd.agent.status
```

3. Reinstall the relevant PMDA (example: linux):

```bash
cd /var/lib/pcp/pmdas/linux
sudo ./Remove
sudo ./Install
sudo systemctl restart pmcd
```

---

## ✅ Issue 5: `pmlogger` archives not being created (or remote archives missing)

### **Symptoms**

* `/var/log/pcp/pmlogger/localhost/` exists but no new archive
* `target-1/` or `target-2/` directories missing
* Archive queries fail: `pmval -a ...`

### Fix

1. Ensure `pmlogger` is running:

```bash
sudo systemctl status pmlogger
```

2. Confirm `pmlogger/control` includes remote entries:

```bash
sudo tail -n 20 /etc/pcp/pmlogger/control
```

Example entries:

```text
target-1 n PCP_LOG_DIR/target-1 -r -T24h10m -c config.default
target-2 n PCP_LOG_DIR/target-2 -r -T24h10m -c config.default
```

3. Restart the logger:

```bash
sudo systemctl restart pmlogger
```

4. Verify directories:

```bash
ls -la /var/log/pcp/pmlogger/
```

---

## ✅ Issue 6: Archive query path incorrect

### **Symptoms**

* `pmval -a ...` returns “archive not found”
* You accidentally used wrong date format or directory

### Fix

Confirm actual archive names:

```bash
ls -la /var/log/pcp/pmlogger/localhost/
```

Then use exact archive filename:

```bash
pmval -a /var/log/pcp/pmlogger/localhost/20260225 -s 20 kernel.all.load
```

---

## ✅ Issue 7: `pmie` not triggering alerts

### **Symptoms**

* `pmie` runs but no alerts appear
* `/var/log/pcp/pmie/localhost/pmie.log` stays quiet

### Fix

1. Ensure pmie is running:

```bash
sudo systemctl status pmie
```

2. Run pmie in verbose mode:

```bash
sudo pmie -v /etc/pcp/pmie/config.local &
```

3. Generate load strong enough to cross thresholds:

```bash
./generate_load.sh
```

4. Review log:

```bash
sudo tail -n 50 /var/log/pcp/pmie/localhost/pmie.log
```

5. Validate rules syntax

* If a rule references a device that doesn't exist (example `/dev/sda1`), that rule will never trigger.
  Confirm filesystem metrics available in PCP for the actual device.

---

## ✅ Issue 8: Disk rule in pmie does not match real disk name

### **Symptoms**

* Disk warning never triggers even when disk usage is high

### Cause

Cloud systems often use `/dev/nvme0n1p1` or `/dev/root`, not `/dev/sda1`.

### Fix

Identify mounted root filesystem:

```bash
df -h /
```

Then update pmie rule accordingly (example):

```cpp
filesys.free #'/dev/root' < 10%_of_filesys.capacity #'/dev/root' ->
 print "Low disk space on /: %v%% free" " [%i]";
```

Restart pmie:

```bash
sudo systemctl restart pmie
```

---

## ✅ Issue 9: Cron automation not running

### **Symptoms**

* `/var/log/pcp_monitoring.log` does not update
* script runs manually but not via cron

### Fix

1. Confirm cron entry exists:

```bash
sudo tail -n 5 /etc/crontab
```

Expected:

```text
*/5 * * * * root /usr/local/bin/automated_monitoring.sh
```

2. Ensure script is executable:

```bash
sudo ls -la /usr/local/bin/automated_monitoring.sh
```

3. Ensure cron service is running:

```bash
sudo systemctl status crond
```

4. Log file permission check:

```bash
sudo touch /var/log/pcp_monitoring.log
sudo chmod 644 /var/log/pcp_monitoring.log
```

---

## ✅ Issue 10: `netstat` not found when checking ports

### **Symptoms**

* `netstat: command not found`

### Fix

Install net-tools:

```bash
sudo dnf install -y net-tools
```

Better modern replacement:

```bash
sudo ss -tlnp | grep :44321
```

---

## ✅ Quick Verification Checklist (End-to-End)

Run these on `pcp-monitor`:

```bash
# local metrics
pminfo kernel.all.load
pmval -s 3 kernel.all.load

# remote metrics
pminfo -h target-1 kernel.all.load
pminfo -h target-2 kernel.all.load

# services
sudo systemctl status pmcd pmlogger pmie

# port open
sudo ss -tlnp | grep :44321

# archives present
ls -la /var/log/pcp/pmlogger/
```

If all pass ✅ — your PCP monitoring lab setup is working.

---
