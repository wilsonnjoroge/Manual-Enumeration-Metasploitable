Web Enumeration Report – Metasploitable2

> This document provides a detailed technical write‑up of Web Enumeration performed during Phase 4 (Enumeration).
> See the consolidated high-level report here: [Full Technical Report](./metasploitable2-full-technical-report.md)

---

## 1. Setup & Configuration
Tooling: dirb, gobuster, whatweb, curl, firefox   
Target: $MS_TARGET (192.168.172.128)   
Service: HTTP (Port 80)   
Environment: Isolated host-only network (Kali → Metasploitable2)

---

## 2. Enumeration Performed
### 2.1 Technology Fingerprinting

```
Command:
	whatweb http://$MS_TARGET


Result:

Apache/2.2.8 (Ubuntu) DAV/2
PHP/5.2.4-2ubuntu5.10


Findings:

Apache 2.2.8 (outdated)

PHP 5.2.4 (end-of-life)

WebDAV enabled

```

---

### 2.2 Directory Enumeration

```
Commands: 
	dirb http://$MS_TARGET /usr/share/wordlists/dirb/common.txt
	gobuster dir -u http://$MS_TARGET -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt


Discovered applications:

	/dvwa/

	/mutillidae/

	/phpMyAdmin/

	/twiki/

```

---

### 2.3 Information Disclosure – phpinfo()

```
Command: 
	curl http://$MS_TARGET/phpinfo.php


Findings:

- display_errors = On
- allow_url_fopen = On
- disable_functions = none
- open_basedir = not set
- file_uploads = On

Full PHP configuration publicly exposed.

```

---

### 2.4 Server Status Endpoint

```
Command:
	curl http://$MS_TARGET/server-status


Result:
403 Forbidden

Endpoint exists but is restricted.

```

---

### 2.5 Version Control Artifact Checks

```
Commands:
	curl -I http://$MS_TARGET/.git/
	curl -i http://$MS_TARGET/.svn/

Result:
404 Not Found
No exposed version control directories identified.

```

---

### 2.6 Backup & Configuration File Checks

```
Performed using:

-X .bak,.old,.zip,.tar.gz
-x .conf,.config,.xml,.yml

No publicly accessible backup/config files identified.

```

---

## 3. Results Location
```
results/
 ├── 01-dirb-web-enumeration.txt
 ├── 02-gobuster-web-enumeration.txt
 ├── 03-web-technology-fingerprinting.txt
 ├── 05-curl-phpinfo.txt
 ├── 06-curl-server-status.txt
 ├── 07-curl-git-url.txt
 ├── 08-curl-svn-url.txt
 ├── 09-check-for-backups.txt
 └── 10-check-for-configuration-files.txt

```

---

## 4. Key Observations
```
• Outdated Apache and PHP versions
• phpinfo() publicly accessible
• WebDAV enabled
• Multiple intentionally vulnerable web applications exposed
• No version control artifacts found

```

---

## 5. Security Assessment
```
The web service presents a high attack surface:

- Legacy software versions
- Extensive configuration disclosure
- WebDAV enabled
- Vulnerable web applications exposed

Risk Level: HIGH

```
---

<div align="center">
	<p><strong>Report generated for educational purposes in an isolated lab environment.</strong></p>
  <p><strong>⭐ If you find my work valuable, please consider starring the projects</strong></p>
    <p><strong>Prepared By: Wilson Njoroge Wanderi</strong></p>
  <p><em>Last Updated: 19th February 2026</em></p>
</div>
