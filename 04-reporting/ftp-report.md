# FTP Enumeration Report – Metasploitable2

> This document provides a detailed technical write‑up of FTP enumeration performed during Phase 4 (Enumeration).  
> See the consolidated high-level report here: [Full Technical Report](./04-reporting/technical-report/metasploitable2-full-technical-report.md)

---

## 1. Setup & Configuration

    Tooling: nc, ftp client, nmap

    Target: $MS_TARGET (192.168.172.128)

    Service: FTP (Port 21)

    Environment: Isolated host‑only network (Kali → Metasploitable2)


---

## 2. Enumeration Performed

### 2.1. Banner Grabbing

```
Command:
	nc -vn $MS_TARGET 21 < /dev/null

Result:
	220 (vsFTPd 2.3.4)

The FTP service responded with a clear banner disclosing the software and version.  
This confirms that port 21 is open and running **vsFTPd 2.3.4**.

```
---

### 2.2. Anonymous Login Testing
```
Command:
	ftp $MS_TARGET

Result:
	Username: anonymous
	Password: <blank>
	Login successful
	Remote directory: /


Anonymous authentication was accepted without credentials, granting access to the FTP service.  
This confirms that **unauthenticated users can log in** and interact with the server.
```
---

### 2.3. Service Version Verification (Nmap)
```
Command:
	nmap -sV -p 21 -oA results/03-ftp-version $MS_TARGET

Result:
	21/tcp open ftp vsftpd 2.3.4


Nmap service detection independently confirmed the FTP version identified during banner grabbing.
```
---

## 3. Results Location
```
    Enumeration outputs:

       - results/02-ftp-banner.txt

       - results/02-ftp-anon-login.txt

       - results/03-ftp-version.nmap

       - results/03-ftp-version.gnmap

       - results/03-ftp-version.xml

```
---

## 4. Key Observations
```
    FTP service is exposed on port 21

    Software version is explicitly disclosed via banner

    Anonymous login is enabled

    Communication occurs in cleartext

```
---

## 5. Security Assessment
```
The FTP service is misconfigured and insecure.
vsFTPd 2.3.4 is a known vulnerable version and anonymous access significantly increases attack surface.
The combination of version disclosure, anonymous authentication, and cleartext transmission represents a critical security risk.

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
