# Banner Collection Report – Metasploitable2

> This document provides a technical write-up of automated banner collection performed during Phase 4 (Enumeration).  
> See the consolidated high-level report here: [Full Technical Report](./04-reporting/metasploitable2-full-technical-report.md)

---

## 1. Setup & Configuration

    Tooling: bash script, nmap, netcat (nc)

    Script: collect-banners.sh

    Target: $MS_TARGET (192.168.172.128)

    Environment: Isolated host-only network (Kali → Metasploitable2)

---

## 2. Enumeration Performed

### 2.1. Automated Banner Collection

```
Command:
    ./collect-banners.sh $MS_TARGET

Output file:
    banners-20260217.txt


The script performed:

    - SYN scan using nmap to identify open ports
    - Banner grabbing using netcat (nc)
    - Output logging into timestamped file
```
---

### 2.2. Collected Service Banners

```
Port 21 (FTP)
    220 (vsFTPd 2.3.4)

Port 22 (SSH)
    SSH-2.0-OpenSSH_4.7p1 Debian-8ubuntu1

Port 23 (Telnet)
    Binary / unreadable banner response

Port 25 (SMTP)
    220 metasploitable.localdomain ESMTP Postfix (Ubuntu)

Port 80 (HTTP)
    Open (no immediate banner via nc)

Port 3306 (MySQL)
    5.0.51a-3ubuntu5

Port 5432 (PostgreSQL)
    Open (no clear banner returned)

Port 6667 (IRC)
    :irc.Metasploitable.LAN NOTICE AUTH :*** Looking up your hostname...
    :irc.Metasploitable.LAN NOTICE AUTH :*** Couldn't resolve your hostname; using your IP address instead

Port 8180 (HTTP - Tomcat)
    Open (no banner via nc)
```

---

### 2.3. Nmap Port Verification

```
Command:
    nmap -sS $MS_TARGET

Open ports confirmed:

    21, 22, 23, 25, 53, 80, 111, 139, 445,
    512, 513, 514, 1099, 1524, 2121,
    3306, 5432, 5900, 6000, 6667,
    8009, 8180
```

---

## 3. Results Location

```
Enumeration outputs:

    banners-20260217.txt
```

---

## 4. Key Observations

```
    Multiple services disclose exact version information

    vsFTPd 2.3.4 identified

    OpenSSH 4.7p1 identified

    MySQL 5.0.51a identified

    Postfix SMTP identified

    IRC service publicly accessible

    Multiple legacy services exposed (Telnet, r-services, VNC, X11)

    Significant attack surface present
```

---

## 5. Security Assessment

```
The target host exposes numerous legacy and potentially vulnerable services.

Several services disclose full version information via banner grabbing,
which significantly aids fingerprinting and vulnerability mapping.

The combination of:

    - Cleartext protocols (FTP, Telnet)
    - Legacy software versions
    - High number of exposed ports

Indicates a deliberately vulnerable configuration suitable for exploitation testing.
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
