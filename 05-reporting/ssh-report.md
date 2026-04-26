# SSH Enumeration Report – Metasploitable2

> This document provides a detailed technical write-up of SSH enumeration performed during Phase 4 (Enumeration).  
> See the consolidated high-level report here: [Full Technical Report](../technical-report/metasploitable2-full-technical-report.md)

---

## 1. Setup & Configuration
```
Tooling: ssh client, nmap  
Target: $MS_TARGET (192.168.172.128)  
Service: SSH (Port 22)  
Environment: Isolated host-only network (Kali → Metasploitable2)

```
---

## 2. Enumeration Performed

### 2.1. SSH Version & Algorithm Enumeration
```
Command:

	ssh -v $MS_TARGET 2>&1 | tee /metasploitable2/04-enumeration/ssh/results/01-ssh-version-and-algorithms.txt

Result:

	Remote protocol version 2.0
	Remote software version OpenSSH_4.7p1 Debian-8ubuntu1
	Offered host key algorithms: ssh-rsa, ssh-dss
	Connection failed due to unsupported host key algorithms


The SSH service disclosed its software version and cryptographic parameters during the initial handshake process.  
The remote system is running OpenSSH 4.7p1 (Debian-8ubuntu1).

During key negotiation, the server offered only legacy host key algorithms (ssh-rsa and ssh-dss).  
The modern SSH client refused to complete the handshake due to the absence of supported, secure host key types.

```
---

### 2.2. Authentication Method Enumeration
```
Command:

	ssh -v $MS_TARGET 2>&1 | tee /metasploitable2/04-enumeration/ssh/results/02-ssh-auth-methods.txt


Result:

	Authentication methods not disclosed


Authentication method enumeration could not be completed.  
The SSH handshake failed during key negotiation due to unsupported host key algorithms, preventing the server from  
reaching the authentication phase and advertising supported authentication methods.

```
---

### 2.3. Service Version Verification (Nmap)
```
Command:

	map -sV -p 22 -oA $MS_TARGET  /metasploitable2/04-enumeration/ssh/results/03-ssh-version


Result:

	22/tcp open ssh OpenSSH 4.7p1 Debian 8ubuntu1 (protocol 2.0)


Nmap service detection independently confirmed the SSH version identified during manual enumeration.

```
---

### 2.4 Test known credentials
```
- Default client posture:

Command:

	ssh msfadmin@$MS_TARGET 2>&1 | tee results/04-ssh-credential-test-a.txt

Result:

	Connection failed due to unsupported host key algorithms.

- Legacy host key algorithms enabled:

Command:
	ssh -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa \
	msfadmin@$MS_TARGET 2>&1 | tee results/04-ssh-credential-test-b.txt

Result:
	Authentication succeeded (password)
	Interactive shell obtained as user 'msfadmin'

Default credentials msfadmin:msfadmin were accepted after enabling legacy host key algorithms on the client.
This confirms that password-based authentication is enabled and that weak default credentials are in use on the SSH service.

```
---

## 3. Results Location
```
Enumeration outputs:

results/
├── 01-ssh-version-and-algorithms.txt
├── 02-ssh-auth-methods.txt
├── 03-ssh-version.nmap
├── 03-ssh-version.gnmap
└── 03-ssh-version.xml

```
---

## 4. Key Observations
```
SSH service is exposed on port 22
Service is running an obsolete OpenSSH version
Only deprecated host key algorithms are supported
Modern clients cannot negotiate a secure connection

```
---

## 5. Security Assessment
```
The SSH service is outdated and cryptographically weak.
Support for deprecated host key algorithms indicates poor security hardening and increases the risk of  
downgrade or interception attacks.

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
