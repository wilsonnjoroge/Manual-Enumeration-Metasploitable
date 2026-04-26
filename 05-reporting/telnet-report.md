# Telnet Enumeration Report – Metasploitable2

> This document provides a detailed technical write‑up of Telnet enumeration performed during Phase 4 (Enumeration).  
> See the consolidated high-level report here: [Full Technical Report](../technical-report/metasploitable2-full-technical-report.md)

---

## 1. Setup & Configuration

    Tooling: telnet client, tcpdump, nmap

    Target: $MS_TARGET (192.168.172.128)

    Service: Telnet (Port 23)

    Environment: Isolated host‑only network (Kali → Metasploitable2)

---

## 2. Enumeration Performed

### 2.1. Service Discovery

```
Command:
	nmap -p 23 $MS_TARGET

Result:
	23/tcp open  telnet
```

The Telnet service was identified as accessible on port 23, confirming that remote terminal access is exposed over the network.

---

### 2.2. Interactive Telnet Access

```
Command:
	telnet $MS_TARGET

Result:
	Connected to 192.168.172.128.
	Escape character is '^]'.
```

The Telnet service accepted inbound connections and presented an authentication prompt, confirming the service is active and reachable.

---

### 2.3. Cleartext Credential Transmission

```
Command:
	tcpdump -i eth0 tcp port 23 -w results/03-telnet-traffic.pcap
```

Network traffic was captured during an active Telnet session.  
Analysis of the packet capture confirmed that authentication credentials were transmitted in cleartext.

This demonstrates that Telnet provides no encryption or transport‑layer security.

---

## 3. Results Location

```
Enumeration outputs:

   - results/03-telnet-traffic.pcap
```

---

## 4. Key Observations

```
Telnet service is exposed on port 23

Remote terminal access is available

Authentication credentials are transmitted in cleartext

Network traffic can be intercepted by a passive attacker
```

---

## 5. Security Assessment

```
The Telnet service represents a critical security risk.
All authentication data is transmitted without encryption, allowing credentials to be intercepted via network monitoring.
The presence of Telnet significantly weakens host security and facilitates credential compromise.
```

---

[Back to Enumeration](../)

---

<div align="center">
	<p><strong>Report generated for educational purposes in an isolated lab environment.</strong></p>
  <p><strong>⭐ If you find my work valuable, please consider starring the projects</strong></p>
    <p><strong>Prepared By: Wilson Njoroge Wanderi</strong></p>
  <p><em>Last Updated: 19th February 2026</em></p>
</div>
