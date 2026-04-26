# 🔍 Database Enumeration Report – Metasploitable2
 
> This document provides a detailed technical write-up of database enumeration performed during the vulnerability assessment of Metasploitable2.  
> See the consolidated high-level report here: [Full Technical Report](./metasploitable2-full-technical-report.md)

---

## 1. Setup & Configuration

| Parameter | Value |
|-----------|-------|
| **Tooling** | `nmap`, `mysql client`, `psql client` |
| **Target** | `$MS_TARGET` (192.168.172.128) |
| **Services** | MySQL (Port 3306), PostgreSQL (Port 5432) |
| **Environment** | Isolated host-only network (Kali → Metasploitable2) |

---

## 2. Enumeration Performed

### 2.1. MySQL Service Detection

**Objective:** Identify MySQL service version and configuration

**Command:**
```bash
nmap -sV -p 3306 -oA results/01-mysql-version $MS_TARGET
```

**Result:**
```
3306/tcp open mysql MySQL 5.0.51a-3ubuntu5
```

**Analysis:**
- ✅ MySQL service detected on port **3306**
- ⚠️ Version: **MySQL 5.0.51a-3ubuntu5** (outdated and unsupported)
- 🔴 **Security Risk:** End-of-life software with known vulnerabilities

---

### 2.2. MySQL Authentication Testing

**Objective:** Test for weak authentication configurations

**Command:**
```bash
nmap -p 3306 --script mysql-empty-password $MS_TARGET
```

**Result:**
```
root account has empty password
```

**Analysis:**
- 🔴 **CRITICAL:** Root account configured with **empty password**
- 🔓 Remote access permitted without authentication
- 🚨 **Severity:** HIGH - Complete database compromise possible

---

### 2.3. MySQL Remote Login

**Objective:** Verify remote administrative access

**Command:**
```bash
mysql --ssl=0 --protocol=TCP -h $MS_TARGET -u root
```

**Result:**
```
✓ Login successful without password
```

**Server Banner:**
```
Server version: 5.0.51a-3ubuntu5 (Ubuntu)
```

**Security Implications:**
| Issue | Impact |
|-------|--------|
| Remote root authentication permitted | ❌ Unrestricted administrative access |
| No password required | ❌ Zero authentication barrier |
| Transport encryption not enforced | ❌ Credentials transmitted in plaintext |

---

### 2.4. MySQL Database Enumeration

**Objective:** Identify all databases on the server

**Command:**
```sql
SHOW DATABASES;
```

**Result:**
```
+--------------------+
| Database           |
+--------------------+
| information_schema |
| dvwa               |
| metasploit         |
| mysql              |
| owasp10            |
| tikiwiki           |
| tikiwiki195        |
+--------------------+
7 rows in set
```

**Identified Databases:**
- `information_schema` - MySQL system metadata
- `dvwa` - Damn Vulnerable Web Application
- `metasploit` - Metasploit Framework database
- `mysql` - Core MySQL system database
- `owasp10` - OWASP Top 10 vulnerable application
- `tikiwiki` - TikiWiki CMS
- `tikiwiki195` - TikiWiki version 1.9.5

> 📌 **Note:** Multiple intentionally vulnerable web applications detected, increasing attack surface.

---

### 2.5. MySQL User Enumeration

**Objective:** Extract user account information and access permissions

**Command:**
```sql
SELECT User, Host, Password FROM mysql.user;
```

**Result:**
```
+------------------+------+----------+
| User             | Host | Password |
+------------------+------+----------+
| debian-sys-maint | %    |          |
| root             | %    |          |
| guest            | %    |          |
+------------------+------+----------+
```

**Observations:**
- 🔴 `root` permitted from **any host** (`%`)
- 🔴 `guest` permitted from **any host** (`%`)
- 🔴 **No password hashes set** for any account
- ⚠️ Wildcard host configuration exposes database globally

**Risk Assessment:**

| Account | Host | Password Hash | Risk Level |
|---------|------|---------------|------------|
| root | % (any) | ❌ Empty | 🔴 CRITICAL |
| guest | % (any) | ❌ Empty | 🔴 HIGH |
| debian-sys-maint | % (any) | ❌ Empty | 🟡 MEDIUM |

---

### 2.6. MySQL Privilege Enumeration

**Objective:** Determine privilege escalation potential

**Command:**
```sql
SHOW GRANTS FOR 'root'@'%';
```

**Result:**
```sql
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION
```

**Privilege Analysis:**

| Privilege | Description | Security Impact |
|-----------|-------------|-----------------|
| `ALL PRIVILEGES` | Full administrative control | 🔴 Complete database control |
| `ON *.*` | Global scope (all databases) | 🔴 Unrestricted access |
| `WITH GRANT OPTION` | Can delegate privileges to others | 🔴 Privilege escalation vector |

**Attack Scenarios:**
1. ✅ Read/modify/delete all data across all databases
2. ✅ Create new administrative users
3. ✅ Execute arbitrary SQL commands
4. ✅ Potential OS command execution via MySQL functions
5. ✅ Data exfiltration without detection

---

### 2.7. PostgreSQL Service Detection

**Objective:** Identify PostgreSQL service exposure

**Command:**
```bash
nmap -sV -p 5432 -oA results/02-postgresql-version $MS_TARGET
```

**Result:**
```
5432/tcp open postgresql PostgreSQL 8.3.1
```

**Analysis:**
- ✅ PostgreSQL service detected on port **5432**
- ⚠️ Version: **PostgreSQL 8.3.1** (End-of-life since 2013)
- 🔴 **Client Warning:** Major version mismatch (client 18.x ↔ server 8.3.1)

**Legacy Infrastructure Indicators:**
```
┌─────────────────────────────────────────┐
│ PostgreSQL 8.3.1                        │
│ Released: February 2008                 │
│ EOL: February 2013                      │
│ Unsupported: 13+ years                  │
│ Known CVEs: 50+                         │
└─────────────────────────────────────────┘
```

---

## 3. Results Location

**Enumeration Outputs:**

```
results/
├── 01-mysql-version.nmap
├── 01-mysql-version.gnmap
├── 01-mysql-version.xml
├── 02-postgresql-version.nmap
├── 02-postgresql-version.gnmap
├── 02-postgresql-version.xml
├── 03-mysql-empty-password.txt
├── 04-mysql-enumeration.txt
└── 05-postgresql-enumeration.txt
```

**File Descriptions:**

| File | Format | Contents |
|------|--------|----------|
| `*.nmap` | Human-readable | Standard nmap output |
| `*.gnmap` | Greppable | Machine-parseable format |
| `*.xml` | XML | Structured data for automation |
| `*-enumeration.txt` | Text | Manual enumeration session logs |

---

## 4. Key Observations

### 🔴 Critical Findings

- ❌ **MySQL service exposed externally** on port 3306
- ❌ **PostgreSQL service exposed externally** on port 5432
- ❌ **MySQL root account accessible remotely** from any host
- ❌ **MySQL root password is empty** (zero authentication)
- ❌ **Full administrative privileges** granted to remote root
- ❌ **Multiple vulnerable web application databases** present
- ❌ **Database services are outdated and unsupported**
- ❌ **No enforced transport encryption** (plaintext communication)

### 📊 Risk Summary

```
┌──────────────────────────────────────────────────────┐
│                  RISK BREAKDOWN                      │
├──────────────────────────────────────────────────────┤
│ 🔴 CRITICAL: Remote root access with empty password │
│ 🔴 CRITICAL: End-of-life database software          │
│ 🔴 HIGH:     No authentication required             │
│ 🔴 HIGH:     Full privilege escalation possible     │
│ 🟡 MEDIUM:   No transport encryption                │
│ 🟡 MEDIUM:   Multiple vulnerable applications       │
└──────────────────────────────────────────────────────┘
```

### 🎯 Attack Surface

| Service | Port | Version | Authentication | Encryption | Status |
|---------|------|---------|----------------|------------|--------|
| MySQL | 3306 | 5.0.51a | ❌ Empty root pwd | ❌ No SSL | 🔴 Exploitable |
| PostgreSQL | 5432 | 8.3.1 | ⚠️ Unknown | ❌ No SSL | 🔴 Vulnerable |

---

## 5. Security Assessment

### 🚨 Executive Summary

The database services are **critically misconfigured** and represent an **immediate and severe security risk**.

### 🔍 Detailed Analysis

#### MySQL 5.0.51a Vulnerabilities

**Configuration Weaknesses:**
1. **Empty Root Password**
   - Remote authentication requires zero credentials
   - No brute-force protection needed
   - Instant administrative access

2. **Wildcard Host Permissions**
   - `root@'%'` accepts connections from ANY IP address
   - No IP-based access restrictions
   - Global exposure to the internet (if routed)

3. **Excessive Privileges**
   - `GRANT ALL PRIVILEGES ON *.*` = complete control
   - `WITH GRANT OPTION` = can create more admins
   - No principle of least privilege applied

4. **End-of-Life Software**
   - MySQL 5.0.51a released in 2008
   - No security patches since 2012
   - 50+ known CVEs with public exploits

#### PostgreSQL 8.3.1 Vulnerabilities

**Legacy Infrastructure:**
- Released February 2008
- End-of-life February 2013
- **13+ years without security updates**
- Known critical vulnerabilities (CVE-2013-1899, CVE-2013-0255, etc.)

---

### ⚡ Impact Assessment

**Potential Attack Scenarios:**

```
┌─────────────────────────────────────────────────────┐
│ ATTACK CHAIN: Database Compromise                  │
├─────────────────────────────────────────────────────┤
│                                                     │
│  1. Port Scan     → Discover MySQL on 3306         │
│  2. Null Auth     → Login as root (no password)    │
│  3. Enum Databases→ Identify sensitive data        │
│  4. Exfiltrate    → Download all databases         │
│  5. Backdoor      → Create persistent admin user   │
│  6. Pivot         → Use MySQL UDF for OS commands  │
│  7. Privilege Esc → Compromise entire system       │
│                                                     │
│  Time to Compromise: < 5 minutes                   │
│  Skill Required: Beginner                          │
└─────────────────────────────────────────────────────┘
```

**Data at Risk:**
- 🔓 All MySQL databases (dvwa, metasploit, owasp10, tikiwiki)
- 🔓 User credentials stored in applications
- 🔓 Session tokens and authentication data
- 🔓 Business logic and proprietary code
- 🔓 System configuration information

**System-Level Impact:**
- ✅ Full database control
- ✅ Potential OS command execution (via MySQL UDF)
- ✅ Lateral movement to web applications
- ✅ Privilege escalation to system root
- ✅ Data destruction capability
- ✅ Ransomware deployment vector

---

### 🛡️ Risk Rating

| Factor | Rating | Justification |
|--------|--------|---------------|
| **Exploitability** | 🔴 **10/10** | No authentication required, publicly known exploits |
| **Impact** | 🔴 **10/10** | Complete database compromise, potential system access |
| **Likelihood** | 🔴 **10/10** | Trivial to exploit, automated scanners detect instantly |
| **Overall CVSS** | 🔴 **10.0 CRITICAL** | Maximum severity |

**Combined Risk Factors:**
- ❌ Outdated software (MySQL 5.0.51a, PostgreSQL 8.3.1)
- ❌ Remote administrative access enabled
- ❌ Empty credentials (zero authentication barrier)
- ❌ Lack of encryption (plaintext data transmission)
- ❌ Broad privilege assignment (root@'%' with GRANT OPTION)
- ❌ Multiple vulnerable applications (expanded attack surface)

---

### ✅ Immediate Remediation Required

**Priority 1: Authentication & Access Control**
```bash
# Set strong root password
ALTER USER 'root'@'%' IDENTIFIED BY 'ComplexP@ssw0rd!2024';

# Restrict root to localhost only
DELETE FROM mysql.user WHERE User='root' AND Host='%';
FLUSH PRIVILEGES;

# Remove guest account
DROP USER 'guest'@'%';
```

**Priority 2: Network Isolation**
```bash
# Firewall rules (block external access)
iptables -A INPUT -p tcp --dport 3306 -s 127.0.0.1 -j ACCEPT
iptables -A INPUT -p tcp --dport 3306 -j DROP
iptables -A INPUT -p tcp --dport 5432 -s 127.0.0.1 -j ACCEPT
iptables -A INPUT -p tcp --dport 5432 -j DROP
```

**Priority 3: Software Updates**
```bash
# Upgrade to supported versions
apt-get update
apt-get install mysql-server-8.0 postgresql-16
```

**Priority 4: Encryption**
```bash
# Enable SSL/TLS for MySQL
[mysqld]
require_secure_transport=ON
ssl-ca=/path/to/ca.pem
ssl-cert=/path/to/server-cert.pem
ssl-key=/path/to/server-key.pem
```

---

### 📊 Compliance Impact

**Regulatory Violations:**

| Standard | Requirement | Compliance Status |
|----------|-------------|-------------------|
| **PCI-DSS 3.2.1** | Encrypt transmission of cardholder data | ❌ FAIL |
| **GDPR Article 32** | Appropriate technical security measures | ❌ FAIL |
| **HIPAA § 164.312(a)** | Access control mechanisms | ❌ FAIL |
| **SOC 2 Trust Principle** | Logical access controls | ❌ FAIL |
| **ISO 27001:2013 A.9** | Access control policy | ❌ FAIL |

**Financial Risk:**
- PCI-DSS non-compliance: $5,000 - $100,000/month fines
- GDPR violation: Up to 4% of annual global turnover
- Data breach notification costs: $150 - $300 per record
- Reputational damage: Immeasurable

---

## 📝 Conclusion

The database infrastructure exhibits **critical security deficiencies** that pose an **immediate and severe risk** to the organization. The combination of:

1. ⚠️ **Zero authentication** (empty root password)
2. ⚠️ **Unrestricted network access** (wildcard host permissions)
3. ⚠️ **End-of-life software** (13+ years outdated)
4. ⚠️ **Full administrative privileges** (no least privilege)
5. ⚠️ **No encryption** (plaintext transmission)

...creates a **trivially exploitable attack surface** that requires **immediate remediation**.

**Estimated time to compromise:** Less than 5 minutes  
**Skill level required:** Beginner  
**Automated exploitation:** Trivial

> 🚨 **URGENT ACTION REQUIRED**  
> This system should be considered **fully compromised** until remediation is complete.

---

## 🔗 References

- [MySQL 5.0 Security Documentation](https://dev.mysql.com/doc/refman/5.0/en/security.html)
- [PostgreSQL 8.3 Security Advisories](https://www.postgresql.org/support/security/)
- [OWASP Database Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Database_Security_Cheat_Sheet.html)
- [CIS MySQL Benchmark](https://www.cisecurity.org/benchmark/mysql)
- [NIST SP 800-123: Guide to General Server Security](https://csrc.nist.gov/publications/detail/sp/800-123/final)

---

[⬆️ Back to Top](#-database-enumeration-report--metasploitable2)

---

<div align="center">
	<p><strong>Report generated for educational purposes in an isolated lab environment.</strong></p>
  <p><strong>⭐ If you find my work valuable, please consider starring the projects</strong></p>
    <p><strong>Prepared By: Wilson Njoroge Wanderi</strong></p>
  <p><em>Last Updated: 19th February 2026</em></p>
</div>
