# 🎤 Lab 10 — Interview Q&A (PCP: pmcd / PMDA / pmlogger / pmie)

> Interview-style questions and answers based on **Lab 10: Advanced Performance Analysis with PCP**.

---

## 1) What is PCP (Performance Co-Pilot)?
**Answer:**  
PCP is an enterprise-grade performance monitoring framework for Linux/UNIX systems. It collects, stores, and analyzes system and application metrics in real time and historically, and it supports distributed monitoring across multiple hosts.

---

## 2) What are the main PCP components used in this lab?
**Answer:**  
- **pmcd**: Performance Metrics Collector Daemon (serves metrics to clients)
- **PMDAs**: Performance Metrics Domain Agents (provide specific metric sets, e.g., linux/proc/network)
- **pmlogger**: collects/stores historical metrics into archives
- **pmie**: Performance Metrics Inference Engine (rule-based alerting/inference)
- (optional) **pmchart**: visualization tool (GUI-based)

---

## 3) What port does `pmcd` commonly listen on and why is it important?
**Answer:**  
`pmcd` typically listens on **TCP 44321**. This is important for remote monitoring; if the port is blocked by firewall or network policies, remote `pminfo`/`pmval` queries will fail.

---

## 4) What is a PMDA and why do we install/verify them?
**Answer:**  
A PMDA provides a domain of metrics (CPU, disk, network, memory, services, etc.). Without the right PMDAs, the metrics you want may not exist or will return incomplete results. In this lab we verified PMDAs like **linux**, **proc**, **disk**, **network**, and **memory**.

---

## 5) How did you confirm PMDAs were enabled and healthy?
**Answer:**  
We checked agent status metrics:
```bash
pminfo -f pmcd.agent.status
````

Then verified that core metrics could be queried:

```bash
pminfo kernel.all.load
pmval -s 5 kernel.all.load
```

---

## 6) What is the difference between `pminfo` and `pmval`?

**Answer:**

* `pminfo` is used to **discover** metrics and inspect metadata/instances.
* `pmval` is used to **sample** metrics over time and print values (real-time or from archives).

---

## 7) How do you query PCP metrics from a remote host?

**Answer:**
Use the `-h` option:

```bash
pminfo -h target-1 kernel.all.load
pmval  -h target-2 -s 10 -t 2 kernel.all.cpu.user
```

This requires pmcd running on the targets and network access to port 44321.

---

## 8) What role does `pmlogger` play in monitoring?

**Answer:**
`pmlogger` records metrics into PCP archive files under paths like:

```text
/var/log/pcp/pmlogger/localhost/
/var/log/pcp/pmlogger/target-1/
/var/log/pcp/pmlogger/target-2/
```

These archives enable historical analysis, trending, and reporting.

---

## 9) How did you add remote hosts to historical logging?

**Answer:**
We appended entries to:

```bash
sudo nano /etc/pcp/pmlogger/control
```

Then added:

```text
target-1 n PCP_LOG_DIR/target-1 -r -T24h10m -c config.default
target-2 n PCP_LOG_DIR/target-2 -r -T24h10m -c config.default
```

And restarted:

```bash
sudo systemctl restart pmlogger
```

---

## 10) What are PCP “archives” and how do you query them?

**Answer:**
Archives are recorded metric logs created by `pmlogger`. Query using `-a` (archive mode):

```bash
pmval -a /var/log/pcp/pmlogger/localhost/20260225 -s 20 kernel.all.load
```

And for formatted, time-stepped dumps:

```bash
pmdumptext -a /var/log/pcp/pmlogger/localhost/20260225 -t 60 kernel.all.cpu.user
```

---

## 11) What is `pmie` used for?

**Answer:**
`pmie` evaluates rule-based conditions against live metrics to produce alerts and events. It’s used for proactive detection (high CPU, high memory, low disk, high load average).

---

## 12) What types of alert rules were created in this lab?

**Answer:**
Rules included:

* CPU user+sys > 80%
* Memory usage > 90%
* Load average (1m) > 4
* Disk space below threshold on `/dev/sda1`

These were written into a config and logged to:

```text
/var/log/pcp/pmie/localhost/pmie.log
```

---

## 13) How did you validate that pmie alerting worked?

**Answer:**
We started pmie and then generated load using `stress-ng` + disk writes:

```bash
sudo pmie -v /etc/pcp/pmie/config.local &
./generate_load.sh
sudo tail -n 10 /var/log/pcp/pmie/localhost/pmie.log
```

The log showed alert messages like “High CPU utilization” and “High load average”.

---

## 14) Why did you generate load during the lab?

**Answer:**
Monitoring and alerting are hard to validate on idle systems. Controlled load creates measurable changes in CPU, memory, disk, and load average so we can confirm:

* PCP metrics are updating,
* archives record meaningful samples,
* alert rules trigger as expected.

---

## 15) What’s the benefit of monitoring multiple systems with PCP?

**Answer:**
It enables centralized monitoring, comparisons across hosts, and detection of bottlenecks caused by differences in configuration, workload, or resource constraints—similar to real operations environments with fleets of servers.

---

## 16) How did you automate monitoring in this lab?

**Answer:**
We created `automated_monitoring.sh`, installed it into:

```text
/usr/local/bin/automated_monitoring.sh
```

Then scheduled it in `/etc/crontab` every 5 minutes:

```text
*/5 * * * * root /usr/local/bin/automated_monitoring.sh
```

It logged results into:

```text
/var/log/pcp_monitoring.log
```

---

## 17) What would you check first if remote PCP queries fail?

**Answer:**

1. `pmcd` running on target:

```bash
sudo systemctl status pmcd
```

2. pmcd listening on port 44321:

```bash
sudo ss -tlnp | grep :44321
```

3. Firewall rules allowing 44321/tcp (firewalld):

```bash
sudo firewall-cmd --add-port=44321/tcp --permanent
sudo firewall-cmd --reload
```

4. DNS/hostname resolution (or use IP).

---

## 18) What real-world scenarios match this lab?

**Answer:**

* Fleet monitoring across many Linux servers
* Performance troubleshooting spanning multiple machines
* Capacity planning using historical trends
* Proactive alerting on CPU/memory/disk pressure
* Preparing reports for incident analysis and optimization efforts

---
