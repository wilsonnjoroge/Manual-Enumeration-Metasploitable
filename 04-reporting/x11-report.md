# X11 Enumeration Report – Metasploitable2

> This document provides a detailed technical write‑up of X11 enumeration performed during Phase 4 (Enumeration).
> See the consolidated high-level report here: [Full Technical Report](./metasploitable2-full-technical-report.md)

---

## 1. Setup & Configuration
```
Tooling: nmap, xdpyinfo

Target: $MS_TARGET (192.168.172.128)

Service: X11 (Port 6000)

Environment: Isolated host-only network (Kali → Metasploitable2)

```

## 2. Enumeration Performed
### 2.1 Service Detection

```
Command:
	nmap -sV -p 6000 -oA results/01-x11-service-detection $MS_TARGET


Result:

6000/tcp open  X11


The X Window System service is exposed over TCP port 6000.

```


### 2.2 Remote Access Test
```
Command:
	xdpyinfo -display $MS_TARGET:0


Result:

Client is not authorized to connect to Server


The X11 server responded but denied access due to authorization controls.

```

### 3. Results Location
```
results/
 ├── 01-x11-service-detection.*
 └── 02-access-test.txt

screenshots/
 ├── 01-x11-service-detection.png
 └── 02-access-test.png

```

### 4. Key Observations
```
• X11 service exposed on TCP 6000
• Service responds to remote requests
• Access control mechanism in place (authorization required)

```

### 5. Security Assessment
```
Although remote access was denied, exposing X11 over TCP significantly increases attack surface.

X11 services should not be publicly accessible.
Even with access control enabled, historical vulnerabilities and misconfigurations may allow bypass.

Best practice: Disable TCP listening or restrict via firewall.

```
---

<div align="center">
	<p><strong>Report generated for educational purposes in an isolated lab environment.</strong></p>
  <p><strong>⭐ If you find my work valuable, please consider starring the projects</strong></p>
    <p><strong>Prepared By: Wilson Njoroge Wanderi</strong></p>
  <p><em>Last Updated: 19th February 2026</em></p>
</div>
