# Credential Reuse Testing Report – Metasploitable2

> See the consolidated high-level report here: [Full Technical Report](./04-reporting/metasploitable2-full-technical-report.md)

---

## 1. Objective

To test whether discovered system credentials (`msfadmin:msfadmin`) can be reused across multiple exposed services on the target host.

Target:
    $MS_TARGET (192.168.172.128)

Credentials Tested:
    Username: msfadmin
    Password: msfadmin

Environment:
    Kali Linux → Metasploitable2 (Host-only network)

---

## 2. Services Tested

The following services were tested for credential reuse:

    SSH (22)
    FTP (21)
    Telnet (23)
    MySQL (3306)
    PostgreSQL (5432)

---

## 3. Testing Details

### 3.1 SSH Credential Test (Port 22)

Command:
    ssh msfadmin@$MS_TARGET

Result:
    Authentication successful
    Interactive shell obtained

Evidence:
    results/01-ssh-credential-test-a.txt
    results/01-ssh-credential-test-b.txt

Screenshot:
    screenshots/01-ssh-credential-test-a.png
    screenshots/01-ssh-credential-test-b.png

---

### 3.2 FTP Credential Test (Port 21)

Command:
    ftp $MS_TARGET
    Username: msfadmin
    Password: msfadmin

Result:
    Login successful
    Authenticated file access granted

Evidence:
    results/02-ftp-credential-test.txt

Screenshot:
    screenshots/02-ftp-credential-test.png

---

### 3.3 Telnet Credential Test (Port 23)

Command:
    telnet $MS_TARGET

Result:
    Login successful using msfadmin/msfadmin
    Shell access granted

Note:
    Credentials transmitted in cleartext.

Evidence:
    results/03-telnet-credential-test.txt

Screenshot:
    screenshots/03-telnet-credential-test.png

---

### 3.4 MySQL Credential Test (Port 3306)

Command:
    mysql -h $MS_TARGET -u msfadmin -pmsfadmin

Result:
    Access denied for user 'msfadmin'@'%'

Conclusion:
    System credentials were NOT reused for MySQL authentication.

Evidence:
    results/04-mysql-credential-test.txt

Screenshot:
    screenshots/04-mysql-credential-test.png

---

### 3.5 PostgreSQL Credential Test (Port 5432)

Command:
    psql -h $MS_TARGET -U msfadmin

Result:
    Authentication failed

Conclusion:
    System credentials were NOT valid for PostgreSQL.

Evidence:
    results/04-postgres-credential-test.txt

Screenshot:
    screenshots/04-postgres-credential-test.png

---

## 4. Credential Reuse Matrix

| Service     | Port | Credentials Tested     | Result  | Access Level |
|-------------|------|------------------------|---------|--------------|
| SSH         | 22   | msfadmin:msfadmin      | Success | Full shell   |
| FTP         | 21   | msfadmin:msfadmin      | Success | File access  |
| Telnet      | 23   | msfadmin:msfadmin      | Success | Full shell   |
| MySQL       | 3306 | msfadmin:msfadmin      | Failed  | None         |
| PostgreSQL  | 5432 | msfadmin:msfadmin      | Failed  | None         |

---

## 5. Key Findings

- Credentials were successfully reused across multiple remote access services.
- SSH and Telnet both provided full interactive shell access.
- FTP allowed authenticated file access.
- MySQL and PostgreSQL required separate credentials.
- Telnet transmits credentials in cleartext, increasing risk exposure.

---

## 6. Security Impact

The reuse of identical credentials across multiple exposed services significantly increases compromise impact.

If a single service is breached, attackers can pivot laterally to:

    - Remote shell access (SSH, Telnet)
    - File transfer access (FTP)
    - Potential privilege escalation paths

Credential reuse combined with cleartext protocols (Telnet) represents a high-risk authentication weakness.

---

[Back to Enumeration](../)

---

<div align="center">
	<p><strong>Report generated for educational purposes in an isolated lab environment.</strong></p>
  <p><strong>⭐ If you find my work valuable, please consider starring the projects</strong></p>
    <p><strong>Prepared By: Wilson Njoroge Wanderi</strong></p>
  <p><em>Last Updated: 19th February 2026</em></p>
</div>


