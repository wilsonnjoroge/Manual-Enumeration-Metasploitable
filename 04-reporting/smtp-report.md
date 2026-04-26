# SMTP Enumeration Report – Metasploitable2

> This document provides a detailed technical write‑up of SMTP enumeration performed during Phase 4 (Enumeration).  
> See the consolidated high-level report here: [Full Technical Report](./metasploitable2-full-technical-report.md)

---

## 1. Setup & Configuration

    Tooling: nmap, smtp-user-enum, nc

    Target: $MS_TARGET (192.168.172.128)

    Service: SMTP (Port 25)

    Environment: Isolated host‑only network (Kali → Metasploitable2)

---

## 2. Enumeration Performed

### 2.1. Banner Grabbing

```
Command:
	nc $MS_TARGET 25

Result:
	220 metasploitable.localdomain ESMTP Postfix (Ubuntu)
```

The SMTP service disclosed a banner upon connection, revealing the mail server software and operating system information.

---

### 2.2. Service Verification (Nmap)

```
Command:
	nmap -sV -p 25 -oN results/smtp-version.txt $MS_TARGET

Result:
	25/tcp open smtp
```

Nmap confirmed that the SMTP service is exposed and accessible on port 25.

---

### 2.3. Automated User Enumeration (VRFY)

```
Command:
	smtp-user-enum -M VRFY \
	-U /usr/share/metasploit-framework/data/wordlists/unix_users.txt \
	-t $MS_TARGET
```

```
Result:
	bin exists
	news exists
	sys exists
	user exists
	www-data exists
```

The SMTP service responded positively to VRFY requests, allowing unauthenticated enumeration of valid local users.

---

### 2.4. Manual User Enumeration (VRFY)

```
Command:
	nc $MS_TARGET 25 | tee results/manual-vrfy.txt
```

```
Result:
	252 2.0.0 root
	252 2.0.0 msfadmin
	550 5.1.1 <admin>: Recipient address rejected
```

Manual SMTP interaction confirmed that valid and invalid users produce distinct responses, conclusively demonstrating user enumeration without authentication.

---

### 2.5. Open Relay Testing

```
Command:
	nmap --script smtp-open-relay -p 25 -oN results/relay-test-results.txt $MS_TARGET

Result:
	Server doesn't seem to be an open relay
```

The SMTP service does not permit unauthenticated mail relaying.

---

## 3. Results Location

```
Enumeration outputs:

   - results/smtp-version.txt
   - results/user-enumeration.txt
   - results/manual-vrfy.txt
   - results/relay-test-results.txt
```

---

## 4. Key Observations

```
SMTP service is exposed on port 25

Mail server software and OS information are disclosed

SMTP VRFY command is enabled

Valid system users can be enumerated without authentication

SMTP service is not configured as an open relay
```

---

## 5. Security Assessment

```
The SMTP service permits unauthenticated user enumeration via the VRFY command.
This information disclosure enables attackers to identify valid system accounts, facilitating targeted authentication attacks and credential reuse.
Although the service is not an open relay, user enumeration significantly increases attack surface.
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
