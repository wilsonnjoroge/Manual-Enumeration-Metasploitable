# Full Technical Vulnerability Assessment Report
## Metasploitable2

**Assessor:** Wilson Njoroge Wanderi  
**Assessment Date:** February 2026  
**Target:** Metasploitable2 — 192.168.172.128  
**OS:** Ubuntu 8.04 LTS (EOL since 2013-05-09)  
**Environment:** Isolated VMware lab — host-only network, no internet connectivity  
**Tools:** Nmap (NSE), OpenVAS/GVM, Nessus, Nikto, manual enumeration  
**Classification:** LAB ENVIRONMENT / EDUCATIONAL USE ONLY  

---

## 1. Assessment Scope and Methodology

This assessment covered all TCP and UDP services exposed by the target. No exploitation was performed — vulnerabilities were identified through version analysis, authenticated scanner confirmation, and cross-tool validation. Manual enumeration was conducted per-service to validate automated findings and discover issues scanners missed.

**Scanning coverage:**
- TCP: Full port range (65,535 ports)
- UDP: Top 100 ports
- Web: HTTP port 80 and Tomcat port 8180
- Manual enumeration: 13 services enumerated individually

**Validation approach:** Findings from OpenVAS, Nessus, and Nmap NSE were cross-referenced. Where multiple scanners confirmed the same finding, confidence is rated High. Scanner-only findings without manual confirmation are rated Medium confidence. OpenVAS active checks (marked QoD 95-99) that returned confirmed responses are treated as validated.

---

## 2. Vulnerability Statistics

| Severity | Count | With Public Exploits | Scanner Confirmed | Manually Confirmed |
|----------|-------|----------------------|-------------------|--------------------|
| Critical | 14 | 10 | 14 | 8 |
| High | 7 | 5 | 7 | 4 |
| Medium | 22 | 3 | 22 | 6 |
| Low | 4 | 0 | 4 | 1 |
| **Total** | **47** | **18** | **47** | **19** |

**Note on vsftpd (CVE-2011-2523):** This vulnerability appears on both port 21 (service) and port 6200 (backdoor shell port). Both are counted as separate findings because they represent distinct exposure points — the trigger mechanism on 21 and the resulting shell on 6200.

**Note on duplicate SSL/TLS findings:** Several SSL/TLS configuration weaknesses (deprecated protocols, weak ciphers, expired certificates) appear across both port 25 (SMTP) and port 5432 (PostgreSQL) because both services share the same misconfigured TLS stack. These are counted per affected service, consistent with how a VM programme would track and assign remediation per asset/service.

---

## 3. Attack Surface Overview

| Port | Protocol | Service | Version | Auth | Encryption | Risk |
|------|----------|---------|---------|------|------------|------|
| 21 | TCP | FTP (vsftpd) | 2.3.4 | Weak/Anonymous | None | Critical |
| 22 | TCP | SSH (OpenSSH) | 4.7p1 | Weak password | Yes (weak algos) | High |
| 23 | TCP | Telnet | - | Weak password | None | Critical |
| 25 | TCP | SMTP (Postfix) | 2.5.5 | None | SSLv2/v3 (deprecated) | Medium |
| 80 | TCP | HTTP (Apache) | 2.2.8 | App-based | None | High |
| 111 | TCP/UDP | RPC | - | None | None | Medium |
| 445 | TCP | SMB (Samba) | 3.0.20 | Null session | None | High |
| 512 | TCP | rexec | - | None | None | Critical |
| 513 | TCP | rlogin | - | None (root) | None | Critical |
| 514 | TCP | rsh | - | None | None | High |
| 1099 | TCP | Java RMI | - | None | None | High |
| 1524 | TCP | Ingreslock backdoor | - | None | None | Critical |
| 2049 | TCP/UDP | NFS | - | Host-based | None | High |
| 2121 | TCP | FTP (ProFTPD) | 1.3.1 | Weak | None | High |
| 3306 | TCP | MySQL | 5.0.51a | root/blank | None | Critical |
| 3632 | TCP | DistCC | 2.x | None | None | Critical |
| 5432 | TCP | PostgreSQL | 8.3.1 | postgres/postgres | SSLv3 (weak) | Critical |
| 5900 | TCP | VNC | - | password/weak | None | Critical |
| 6200 | TCP | vsftpd backdoor shell | - | None | None | Critical |
| 6667/6697 | TCP | UnrealIRCd | 3.2.8.1 | None | None | High |
| 8009 | TCP | Tomcat AJP | 5.5 | None | None | Critical |
| 8180 | TCP | Tomcat HTTP | 5.5 | Default | None | High |
| 8787 | TCP | dRuby/DRb | Ruby 1.8 | None | None | Critical |

---

## 4. Critical Findings

### F-001 — vsftpd 2.3.4 Backdoor

**CVE:** CVE-2011-2523 | **CVSS:** 9.8 | **Ports:** 21/TCP, 6200/TCP
**Scanner confirmation:** OpenVAS (QoD 99) | **Manual confirmation:** Banner confirmed

vsftpd 2.3.4, distributed via a compromised SourceForge repository between June 30 and July 3, 2011, contains a compiled-in backdoor. Sending a username ending with `:)` during FTP authentication triggers the backdoor, which opens a root shell on TCP port 6200. The OpenVAS scan confirmed the presence of vsftpd 2.3.4 and detected the active backdoor port. Manual enumeration confirmed the version banner.

The backdoor requires zero authentication and provides immediate root access. A Metasploit module (`exploit/unix/ftp/vsftpd_234_backdoor`) exists and requires no configuration beyond the target IP.

**Evidence:** `04-enumeration/ftp/results/01-ftp-banner.txt`, `04-enumeration/ftp/results/03-ftp-version.nmap`

**Remediation (P0):** Disable vsftpd immediately. Remove or replace with SFTP. Block ports 21 and 6200 at the firewall.

---

### F-002 — Ingreslock Backdoor (Port 1524)

**CVE:** None assigned | **CVSS:** 10.0 | **Port:** 1524/TCP
**Scanner confirmation:** OpenVAS active check — confirmed `uid=0(root) gid=0(root)` response

A backdoor service is listening on port 1524 and responding to shell commands with root privileges. OpenVAS confirmed this by sending an `id;` command and receiving `uid=0(root) gid=0(root)` in response. This is a pre-installed backdoor included in Metasploitable2 by design, representing a second completely independent unauthenticated root access path.

**Evidence:** OpenVAS scan result — OID 1.3.6.1.4.1.25623.1.0.103549, confirmed response in scan data

**Remediation (P0):** Identify and terminate the process listening on port 1524. Investigate how the backdoor was installed. Perform a full system integrity check. Block port 1524 at the firewall.

---

### F-003 — dRuby/DRb Remote Code Execution (Port 8787)

**CVE:** None | **CVSS:** 10.0 | **Port:** 8787/TCP
**Scanner confirmation:** OpenVAS active check confirmed syscall execution

The Distributed Ruby (dRuby) service running on port 8787 allows unauthenticated remote code execution. OpenVAS confirmed this by triggering an invalid syscall and receiving a Ruby stack trace showing execution context. The service is running without access controls or safe mode restrictions sufficient to prevent command execution.

By default, dRuby does not restrict which hosts can submit commands. If the dRuby process runs with elevated privileges, arbitrary system commands can be executed.

**Evidence:** OpenVAS result OID 1.3.6.1.4.1.25623.1.0.108010 — stack trace confirmed in scan data

**Remediation (P0):** Disable the dRuby service if not required. If required, implement ACL restrictions (`drb/acl.rb`), set `$SAFE >= 2`, and restrict to trusted hosts only.

---

### F-004 — rlogin Passwordless Root Access (Port 513)

**CVE:** None | **CVSS:** 10.0 | **Port:** 513/TCP
**Scanner confirmation:** OpenVAS confirmed root access without password

The rlogin service on port 513 allows connection as root without any password. OpenVAS confirmed this finding with a direct authentication test. rlogin also transmits all session data — including any credentials used — in cleartext, compounding the risk.

**Evidence:** OpenVAS result OID 1.3.6.1.4.1.25623.1.0.113766

**Remediation (P0):** Disable rlogin immediately. Replace with SSH. Block port 513 at the firewall.

---

### F-005 — rexec Service Exposed (Port 512)

**CVE:** CVE-1999-0618 | **CVSS:** 10.0 | **Port:** 512/TCP
**Scanner confirmation:** OpenVAS detected active service

rexec (remote execution) on port 512 allows execution of shell commands on the target. Unlike rsh, rexec reads username and password from the socket — but does so unencrypted. Combined with the weak/default credentials confirmed across this system, this represents a direct remote code execution path.

**Evidence:** OpenVAS result OID 1.3.6.1.4.1.25623.1.0.100111

**Remediation (P0):** Disable rexec. Replace with SSH. Block port 512 at the firewall.

---

### F-006 — MySQL Root Account with Blank Password (Port 3306)

**CVE:** CVE-2001-0645 et al. | **CVSS:** 9.8 | **Port:** 3306/TCP
**Scanner confirmation:** OpenVAS confirmed login as root with empty password (QoD 95)
**Manual confirmation:** Full MySQL session established, databases enumerated

The MySQL root account has no password set. OpenVAS confirmed unauthenticated login. Manual enumeration established a full interactive session and enumerated all databases. Root-level MySQL access enables reading and writing arbitrary files via `SELECT INTO OUTFILE` and `LOAD DATA INFILE`, which can be used to write webshells to the web root or read sensitive system files.

**Evidence:** `04-enumeration/database/results/01-mysql-full-session.log`

**Remediation (P1):** Set a strong root password immediately. Restrict MySQL to localhost unless remote access is required. Revoke the FILE privilege from all accounts. Run MySQL under a dedicated low-privilege service account.

---

### F-007 — DistCC Remote Code Execution (Port 3632)

**CVE:** CVE-2004-2687 | **CVSS:** 9.3 | **Port:** 3632/TCP
**Scanner confirmation:** OpenVAS active check confirmed `uid=1(daemon) gid=1(daemon)` (QoD 99)

The DistCC distributed compiler daemon on port 3632 allows unauthenticated remote code execution. DistCC trusts clients completely by default. OpenVAS confirmed exploitation by executing the `id` command and receiving a valid response. The resulting access is as the daemon user, which while not root, provides filesystem access and a foothold for further privilege escalation.

**Evidence:** OpenVAS result OID 1.3.6.1.4.1.25623.1.0.103553

**Remediation (P0):** Disable DistCC if not actively required. If required, restrict access to trusted hosts via firewall rules or DistCC's `--allow` option.

---

### F-008 — Apache Tomcat AJP Ghostcat (Port 8009)

**CVE:** CVE-2020-1938 | **CVSS:** 9.8 | **Port:** 8009/TCP
**Scanner confirmation:** OpenVAS confirmed file read — retrieved `/WEB-INF/web.xml` (QoD 99)

The AJP connector on Tomcat 5.5 is vulnerable to Ghostcat. OpenVAS confirmed the vulnerability by reading the contents of `/WEB-INF/web.xml` through the AJP connector without authentication. Beyond file read, this vulnerability can be escalated to remote code execution if file upload functionality exists anywhere on the Tomcat instance.

**Evidence:** OpenVAS result OID 1.3.6.1.4.1.25623.1.0.143545 — web.xml contents confirmed in scan data. `04-enumeration/tomcat/results/01-tomcat-service-enumeration.nmap`

**Remediation (P0):** Disable the AJP connector in `server.xml` if not required. If required, restrict to trusted IP addresses only. Upgrade Tomcat to 7.0.100+, 8.5.51+, or 9.0.31+.

---

### F-009 — PHP CGI Remote Code Execution (Port 80)

**CVE:** CVE-2012-1823, CVE-2012-2311, CVE-2012-2336 | **CVSS:** 9.8 | **Port:** 80/TCP
**Scanner confirmation:** OpenVAS confirmed PHP code execution — phpinfo() returned (QoD 95)

The PHP installation is configured in CGI mode and is vulnerable to argument injection. OpenVAS confirmed exploitation by sending a crafted HTTP POST request that executed `<?php phpinfo();?>` and received the full phpinfo output in response. This allows remote attackers to execute arbitrary PHP code on the server.

**Evidence:** OpenVAS result OID 1.3.6.1.4.1.25623.1.0.103482 — phpinfo output confirmed

**Remediation (P0):** Update PHP to 5.3.13 or 5.4.3+. Disable PHP CGI mode. If CGI is required, apply the patch that prevents argument injection.

---

### F-010 — VNC Weak Password (Port 5900)

**CVE:** None | **CVSS:** 9.0 | **Port:** 5900/TCP
**Scanner confirmation:** OpenVAS brute force confirmed password: `password` (QoD 95)

The VNC server accepts the password `password` — a trivially guessable credential. OpenVAS confirmed login. VNC also transmits session data without encryption (finding F-020), meaning both the authentication and the full desktop session are visible to any network observer. Successful VNC authentication provides full graphical desktop access to the system.

**Evidence:** OpenVAS result OID 1.3.6.1.4.1.25623.1.0.106056

**Remediation (P1):** Set a strong VNC password. Restrict VNC access by IP via firewall. Tunnel VNC over SSH. Consider replacing with a more secure remote access solution.

---

### F-011 — PostgreSQL Default Credentials (Port 5432)

**CVE:** None | **CVSS:** 9.0 | **Port:** 5432/TCP
**Scanner confirmation:** OpenVAS confirmed login as postgres with password `postgres` (QoD 99)
**Manual confirmation:** Full PostgreSQL session established

The PostgreSQL superuser account uses default credentials (`postgres:postgres`). OpenVAS and manual enumeration both confirmed successful login. PostgreSQL superuser access provides complete database control including the ability to read/write files via `COPY TO/FROM` if configured.

**Evidence:** `04-enumeration/database/results/02-postgres-full-session.log`

**Remediation (P1):** Change the postgres superuser password immediately. Restrict PostgreSQL to localhost unless remote access is explicitly required. Review pg_hba.conf authentication configuration.

---

### F-012 — TWiki Command Execution (Port 80)

**CVE:** CVE-2008-5304, CVE-2008-5305 | **CVSS:** 10.0 | **Port:** 80/TCP
**Scanner confirmation:** OpenVAS version detection confirmed TWiki 01.Feb.2003 (far below fixed version 4.2.4)

The TWiki installation is an extremely outdated version (2003 release) vulnerable to both cross-site scripting and Perl eval injection via the `%SEARCH{}` variable. The eval injection allows arbitrary Perl code execution through the web application layer.

**Evidence:** OpenVAS result OID 1.3.6.1.4.1.25623.1.0.800320. `04-enumeration/web-enumeration/results/01-dirb-web-enumeration.txt`

**Remediation (P1):** Upgrade TWiki to 4.2.4 or later, or remove the application entirely if not required.

---

### F-013 — OS End of Life: Ubuntu 8.04 LTS

**CVE:** None | **CVSS:** 10.0 | **Port:** N/A (host-level)
**Scanner confirmation:** OpenVAS confirmed Ubuntu 8.04 LTS, EOL 2013-05-09

The operating system has been end-of-life for over 12 years. No security patches have been issued since May 2013. Every vulnerability discovered after that date — including all kernel exploits, library vulnerabilities, and application-level CVEs found in this assessment — has no vendor patch available for this OS version. This compounds every other finding in this report.

**Evidence:** OpenVAS result OID 1.3.6.1.4.1.25623.1.0.103674

**Remediation (P0):** In a production context, the OS must be replaced. In this lab context, this finding explains why so many services are running vulnerable versions — the entire package ecosystem is frozen at 2012-era versions.

---

### F-014 — Java RMI Insecure Default Configuration (Port 1099)

**CVE:** CVE-2011-3556 | **CVSS:** 7.5 | **Port:** 1099/TCP
**Scanner confirmation:** OpenVAS active check confirmed callback to scanner host (QoD 95)

The Java RMI registry on port 1099 has an insecure default configuration that allows unauthenticated remote code execution. OpenVAS confirmed the vulnerability by sending a crafted JRMI request and observing the target connect back to the scanner host on a dynamically assigned port — the classic indicator of successful SSRF/callback exploitation.

**Evidence:** `04-enumeration/java-rmi/results/02-rmi-registry-dump.nmap`

**Remediation (P1):** Disable class-loading in the RMI configuration. Implement firewall rules restricting port 1099 to authorised hosts only. If the service is not required, disable it.

---

## 5. High Findings

### F-015 — UnrealIRCd 3.2.8.1 Backdoor (Port 6697)

**CVE:** CVE-2010-2075 | **CVSS:** 7.5 | **Port:** 6697/TCP
**Scanner confirmation:** OpenVAS version detection confirmed 3.2.8.1

UnrealIRCd 3.2.8.1 (Linux package distributed from November 2009) contains a compiled-in backdoor allowing remote command execution. The backdoor is triggered by sending `AB` followed by a system command. This is a separate CVE from the authentication spoofing vulnerability also present in this version.

**Remediation (P1):** Remove or replace UnrealIRCd. The backdoored version should be considered fully compromised.

---

### F-016 — Samba MS-RPC Remote Shell Command Execution (Port 445)

**CVE:** CVE-2007-2447 | **CVSS:** 6.0 | **Port:** 445/TCP
**Scanner confirmation:** OpenVAS active check confirmed — ping callback received from target (QoD 99)

Samba 3.0.20 is vulnerable to command injection via the MS-RPC `SamrChangePassword` function. OpenVAS confirmed the vulnerability by executing a ping command on the target and observing the ICMP response arrive at the scanner host. This provides remote command execution as the Samba process user.

**Evidence:** OpenVAS result OID 1.3.6.1.4.1.25623.1.0.108011 — ICMP callback confirmed

**Remediation (P1):** Upgrade Samba to 3.0.25 or later. If SMB is not required, disable the service.

---

### F-017 — Default FTP Credentials Across Multiple Accounts (Ports 21, 2121)

**CVE:** CVE-1999-0501 et al. | **CVSS:** 7.5 | **Ports:** 21/TCP, 2121/TCP
**Scanner confirmation:** OpenVAS confirmed login with: `msfadmin:msfadmin`, `postgres:postgres`, `service:service`, `user:user`
**Manual confirmation:** Credential testing confirmed

Multiple accounts use default or trivially guessable credentials on both FTP services. The same credentials work across SSH, Telnet, MySQL, and PostgreSQL — confirming a systemic credential hygiene failure rather than isolated misconfiguration.

**Evidence:** `04-enumeration/credential-testing/results/02-ftp-credential-test.txt`

**Remediation (P0):** Change all account passwords. Enforce a password policy. Disable FTP; replace with SFTP.

---

### F-018 — rsh Cleartext Service (Port 514)

**CVE:** CVE-1999-0651 | **CVSS:** 7.5 | **Port:** 514/TCP
**Scanner confirmation:** OpenVAS detected active service

rsh (remote shell) transmits all data including credentials in cleartext and relies on `.rhosts` files for authentication — a mechanism known to be easily abused. Combined with the credential exposure from Telnet (F-019), rsh represents an additional unauthenticated entry vector.

**Remediation (P0):** Disable rsh. Replace with SSH.

---

### F-019 — HTTP PUT/DELETE Methods Enabled (Port 80)

**CVE:** None | **CVSS:** 7.5 | **Port:** 80/TCP
**Scanner confirmation:** OpenVAS confirmed file upload and deletion via PUT/DELETE (QoD 99)

The web server accepts HTTP PUT and DELETE methods on the `/dav/` path. OpenVAS confirmed this by successfully uploading and deleting a test file. An attacker who can PUT files can upload a webshell to the web root and achieve remote code execution through the web layer.

**Evidence:** OpenVAS result OID 1.3.6.1.4.1.25623.1.0.10498

**Remediation (P1):** Disable WebDAV if not required. If required, restrict PUT/DELETE to authenticated, authorised users only. Apply IP-based access controls.

---

### F-020 — Telnet Cleartext Credential Exposure (Port 23)

**CVE:** None | **CVSS:** 4.8 (scanner) — assessed High due to confirmed credential capture
**Scanner confirmation:** OpenVAS detected service
**Manual confirmation:** Traffic captured in pcap; credentials visible in plaintext

Telnet transmits the complete session including username, password, and all commands in cleartext. A traffic capture collected during manual enumeration confirmed credentials are visible in plaintext to any network observer. Given the credential reuse confirmed across this system, capturing one Telnet session yields access to six services.

**Evidence:** `04-enumeration/telnet/results/03-telnet-traffic.pcap`, `04-enumeration/telnet/results/01-telnet-banner-grab.txt`

**Remediation (P0):** Disable Telnet. Replace with SSH for all remote administration.

---

### F-021 — SSH Weak Algorithms (Port 22)

**CVE:** None | **CVSS:** 5.3–4.3 | **Port:** 22/TCP
**Scanner confirmation:** OpenVAS confirmed weak host key (DSA), weak KEX (DH-SHA1, 1024-bit), weak ciphers (CBC mode, RC4, 3DES), weak MACs (MD5-based)
**Manual confirmation:** SSH algorithm enumeration performed

While SSH itself provides encryption, this implementation supports a collection of deprecated and cryptographically weak algorithms across key exchange, ciphers, and MACs. A nation-state level attacker could break 1024-bit DH key exchange. CBC mode ciphers are vulnerable to plaintext recovery attacks.

**Evidence:** `04-enumeration/ssh/results/01-ssh-version-and-algorithms.txt`, `04-enumeration/ssh/results/02-ssh-auth-methods.txt`

**Remediation (P2):** Disable DSA host keys. Remove SHA-1 and 1024-bit DH KEX algorithms. Remove CBC mode ciphers and MD5-based MACs. Enforce modern algorithm suites only.

---

## 6. Selected Medium Findings

The following medium-severity findings are documented in summary. Full scanner output is available in `03-scanning/openvas/results/metasploitable2/`.

| ID | Finding | CVE | CVSS | Port |
|----|---------|-----|------|------|
| F-022 | SMTP STARTTLS command injection | CVE-2011-0411 et al. | 6.8 | 25/TCP |
| F-023 | phpinfo() exposed at multiple URLs | CVE-2008-0149 | 5.3 | 80/TCP |
| F-024 | phpMyAdmin XSS (error.php) | CVE-2010-4480 | 4.3 | 80/TCP |
| F-025 | TWiki CSRF vulnerabilities | CVE-2009-1339, CVE-2009-4898 | 6.8, 6.0 | 80/TCP |
| F-026 | jQuery XSS (Mutillidae) | CVE-2012-6708, CVE-2011-4969 | 6.1, 4.3 | 80/TCP |
| F-027 | HTTP TRACE method enabled | CVE-2003-1567 et al. | 5.8 | 80/TCP |
| F-028 | Directory traversal (Mutillidae) | CVE-2005-0283 | 5.0 | 80/TCP |
| F-029 | Local file inclusion (Mutillidae) | None | 5.0 | 80/TCP |
| F-030 | Anonymous FTP access | CVE-1999-0497 | 6.4 | 21/TCP |
| F-031 | SMTP VRFY/EXPN enabled | None | 5.0 | 25/TCP |
| F-032 | /doc directory browsable | CVE-1999-0678 | 5.0 | 80/TCP |
| F-033 | Cleartext password forms (HTTP) | None | 4.8 | 80/TCP |
| F-034 | FTP cleartext login (ports 21, 2121) | None | 4.8 | 21, 2121/TCP |
| F-035 | VNC unencrypted session | None | 4.8 | 5900/TCP |
| F-036 | SSL/TLS: SSLv2/v3 deprecated protocol | CVE-2014-3566, CVE-2016-0800 | 5.9 | 25, 5432/TCP |
| F-037 | SSL/TLS: Weak cipher suites (RC4) | CVE-2013-2566, CVE-2015-2808 | 5.9 | 5432/TCP |
| F-038 | SSL/TLS: TLSv1.0/1.1 deprecated | CVE-2011-3389 et al. | 4.3 | 25, 5432/TCP |
| F-039 | SSL/TLS: Certificate expired (2010) | None | 5.0 | 25, 5432/TCP |
| F-040 | SSL/TLS: RSA key < 2048 bits | None | 5.3 | 25, 5432/TCP |
| F-041 | SSL/TLS: FREAK (RSA_EXPORT) | CVE-2015-0204 | 4.3 | 25/TCP |
| F-042 | SSL/TLS: Logjam (DHE_EXPORT) | CVE-2015-4000 | 3.7 | 25/TCP |
| F-043 | OpenSSL CCS injection (MITM) | CVE-2014-0224 | 7.4 | 5432/TCP |

---

## 7. Low Findings

| ID | Finding | CVE | CVSS | Port |
|----|---------|-----|------|------|
| F-044 | SSL/TLS POODLE (SSLv3 CBC) | CVE-2014-3566 | 3.4 | 25, 5432/TCP |
| F-045 | SSL/TLS renegotiation DoS | CVE-2011-1473 | 5.0 | 25, 5432/TCP |
| F-046 | TCP timestamps information disclosure | None | 2.6 | Host |
| F-047 | ICMP timestamp reply | CVE-1999-0524 | 2.1 | Host |

---

## 8. Cross-Scanner Validation Summary

| Finding | Nmap NSE | OpenVAS | Nessus | Nikto | Confidence |
|---------|----------|---------|--------|-------|------------|
| vsftpd 2.3.4 backdoor | Detected | Confirmed (QoD 99) | Confirmed | - | High |
| MySQL root/blank | - | Confirmed (QoD 95) | Confirmed | - | High |
| PostgreSQL default creds | - | Confirmed (QoD 99) | Confirmed | - | High |
| Telnet cleartext | Detected | Detected | Detected | - | High |
| FTP default creds | - | Confirmed (QoD 95) | Confirmed | - | High |
| phpinfo exposed | - | Confirmed (QoD 80) | - | Confirmed | High |
| HTTP TRACE enabled | - | Confirmed (QoD 99) | - | Confirmed | High |
| Tomcat AJP Ghostcat | Detected | Confirmed (QoD 99) | Confirmed | - | High |
| DistCC RCE | Detected | Confirmed (QoD 99) | - | - | High |
| Samba RCE | Detected | Confirmed (QoD 99) | Confirmed | - | High |
| SSH weak algorithms | Detected | Confirmed | Confirmed | - | High |
| SSL/TLS weaknesses | - | Confirmed | Confirmed | - | High |
| Ingreslock backdoor | - | Confirmed (QoD 99) | - | - | Medium-High |
| dRuby RCE | - | Confirmed (QoD 99) | - | - | Medium-High |
| rlogin passwordless | - | Confirmed (QoD 80) | - | - | Medium |

**False positive assessment:** No findings in this report are assessed as false positives. All critical and high findings are supported by either active confirmation (QoD 95+) or manual enumeration. Medium findings based solely on version detection (QoD 70-80) carry a small false positive risk but are consistent with the known-vulnerable service versions running on this system.

---

## 9. Prioritised Remediation Roadmap

### P0 — Immediate (0-24 hours in production)

These findings represent active, unauthenticated paths to full system compromise.

| ID | Action | Affected Finding(s) |
|----|--------|---------------------|
| R-01 | Disable vsftpd; block ports 21 and 6200 | F-001 |
| R-02 | Investigate and remove Ingreslock backdoor; block port 1524 | F-002 |
| R-03 | Disable dRuby service; block port 8787 | F-003 |
| R-04 | Disable rlogin, rexec, rsh; block ports 512, 513, 514 | F-004, F-005, F-018 |
| R-05 | Change all default credentials system-wide | F-006, F-011, F-017 |
| R-06 | Disable Telnet; block port 23 | F-020 |
| R-07 | Disable Tomcat AJP connector or restrict by IP | F-008 |
| R-08 | Update PHP or disable CGI mode | F-009 |
| R-09 | Disable DistCC or restrict to trusted hosts | F-007 |

### P1 — Urgent (1-7 days in production)

| ID | Action | Affected Finding(s) |
|----|--------|---------------------|
| R-10 | Upgrade or remove Samba | F-016 |
| R-11 | Remove or upgrade UnrealIRCd | F-015 |
| R-12 | Set strong VNC password; tunnel over SSH | F-010 |
| R-13 | Disable WebDAV PUT/DELETE or restrict access | F-019 |
| R-14 | Disable Java RMI class-loading; restrict port 1099 | F-014 |
| R-15 | Upgrade or remove TWiki | F-012 |
| R-16 | Remove phpinfo.php files from web root | F-023 |

### P2 — Scheduled (7-30 days in production)

| ID | Action | Affected Finding(s) |
|----|--------|---------------------|
| R-17 | Harden SSH algorithm configuration | F-021 |
| R-18 | Replace TLS certificates; disable SSLv2/v3/TLS1.0/1.1 | F-036, F-038, F-039, F-040 |
| R-19 | Disable weak SSL cipher suites; fix FREAK/Logjam | F-037, F-041, F-042 |
| R-20 | Disable SMTP VRFY/EXPN; harden STARTTLS | F-031, F-022 |
| R-21 | Disable HTTP TRACE | F-027 |
| R-22 | Restrict /doc directory; remove phpMyAdmin default config | F-032 |
| R-23 | Patch or remove vulnerable jQuery versions in Mutillidae | F-026 |
| R-24 | Patch phpMyAdmin XSS; upgrade or remove application | F-024 |

### P3 — Low Priority (30+ days in production)

| ID | Action | Affected Finding(s) |
|----|--------|---------------------|
| R-25 | Disable TCP timestamps | F-046 |
| R-26 | Block ICMP timestamp replies at firewall | F-047 |

---

## 10. Evidence Index

All evidence is organised by phase and service in the repository:

| Phase | Location | Contents |
|-------|----------|----------|
| Pre-engagement | `01-pre-engagement/evidence/` | VM config, isolation, reachability screenshots |
| Reconnaissance | `02-reconnaissance/evidence/metasploitable2/` | Host discovery scan |
| Nmap scanning | `03-scanning/nmap/screenshots/metasploitable2/` | All nmap scan screenshots |
| OpenVAS | `03-scanning/openvas/results/metasploitable2/` | Full scan PDF and CSV |
| Nessus | `03-scanning/nessus/screenshots/metasploitable2/` | Scan configuration and results |
| Nikto | `03-scanning/nikto/results/metasploitable2/` | HTTP and HTTPS scan outputs |
| FTP enumeration | `04-enumeration/ftp/` | Banner, anon login, version |
| SSH enumeration | `04-enumeration/ssh/` | Algorithms, auth methods, credential test |
| Telnet enumeration | `04-enumeration/telnet/` | Banner, connection, pcap capture |
| SMTP enumeration | `04-enumeration/smtp/` | Version, VRFY, user enumeration |
| Database enumeration | `04-enumeration/database/` | MySQL and PostgreSQL full sessions |
| Web enumeration | `04-enumeration/web-enumeration/` | dirb, gobuster, whatweb, curl outputs |
| Tomcat enumeration | `04-enumeration/tomcat/` | Service scan, manager check, Axis2 |
| Credential testing | `04-enumeration/credential-testing/` | Cross-service credential matrix |
| Banner collection | `04-enumeration/banner-analysis/` | Automated banner collection script and output |
| Attack chain analysis | `05-reporting/analysis/attack-chain-analysis.md` | Six confirmed attack paths |

---

## 11. Conclusion

This assessment identified 47 vulnerabilities across 23 exposed services, including 14 critical-severity findings. Of the 14 critical findings, 10 have publicly available exploits and 8 were confirmed through active scanner checks or manual enumeration.

The most significant observation from this assessment is not any individual vulnerability, but the systemic nature of the exposure. The end-of-life operating system, combined with default credentials reused across services and multiple pre-installed backdoors, means there is no single fix that meaningfully changes the risk posture. Remediation requires addressing the entire stack — OS, credentials, service configuration, and network controls — in parallel rather than sequentially.

For a production environment, the P0 remediation actions would be required within 24 hours of this report being delivered. In this lab context, these findings serve as a reference for understanding how vulnerability accumulation, credential hygiene failure, and unpatched software combine to create environments that offer no meaningful resistance to even low-skill attackers.

--- 

<div align="center">
	<p><strong>Report generated for educational purposes in an isolated lab environment.</strong></p>
  <p><strong>⭐ If you find my work valuable, please consider starring the projects</strong></p>
    <p><strong>Prepared By: Wilson Njoroge Wanderi</strong></p>
  <p><em>Last Updated: 19th February 2026</em></p>
</div>
