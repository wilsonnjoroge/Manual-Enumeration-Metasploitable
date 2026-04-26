# Vulnerability Assessment Methodology - Complete

**Purpose:** Blue-team focused vulnerability identification and risk assessment  
**Scope:** No exploitation, pure assessment and documentation  
**Approach:** Systematic, repeatable, portfolio-ready

---

## Methodology Overview

```markdown
Phase 1: Pre-Engagement    → Setup and verify isolation
Phase 2: Reconnaissance    → Discover what's alive
Phase 3: Scanning          → Identify services and vulnerabilities
Phase 4: Enumeration       → Deep-dive into each service
Phase 5: Analysis          → Risk scoring and prioritization
Phase 6: Validation        → Verify findings, eliminate false positives
Phase 7: Reporting         → Document everything professionally
```

---

## Phase 1: Pre-Engagement 📋

**Goal:** Ensure safe, isolated testing environment

### Activities:
1. **VM Configuration Documentation**
   - Screenshot VM settings (network, resources)
   - Document target IP address
   - Record network configuration

2. **Network Isolation Verification**
   - Test internet connectivity (should FAIL)
   - Verify host-only network
   - Confirm attacker-to-target reachability

3. **Baseline Documentation**
   - Target system specifications
   - Expected services (if known)
   - Assessment scope and objectives

### Deliverables:
```markdown
01-pre-engagement/
├── evidence/
│   ├── vm-configuration.png
│   ├── ip-address.png
│   ├── isolation-test.png
│   └── reachability-test.png
└── [optional sub-folders for specific checks]
```

### Key Commands:
```markdown
# Get target IP
ifconfig

# Test isolation (should fail)
ping -c 4 8.8.8.8

# Test reachability (should succeed)
ping -c 4 $TARGET_IP
```

---

## Phase 2: Reconnaissance 🔍

**Goal:** Discover live hosts and gather initial information

### Activities:
1. **Host Discovery**
   - Confirm target is online
   - Identify MAC address/vendor
   - Basic OS fingerprinting

2. **Initial Enumeration**
   - Quick port scan (top 1000 ports)
   - Identify major services

### Deliverables:
```
02-reconnaissance/
├── host-discovery/
│   ├── host-discovery.nmap
│   ├── host-discovery.xml
│   └── host-discovery.gnmap
├── os-fingerprinting/ (if performed)
└── evidence/
    └── host-discovery-screenshot.png
```

### Key Commands:
```markdown
# Host discovery
nmap -sn $TARGET_IP

# Quick port scan
nmap -T4 $TARGET_IP

# Save results
nmap -sn $TARGET_IP -oA 02-reconnaissance/host-discovery/host-discovery
```

---

## Phase 3: Scanning 🎯

**Goal:** Comprehensive service and vulnerability identification

### Activities:

#### 3.1 Nmap Scanning (Progressive Depth)
```markdown
# Step 1: Initial port scan (SYN scan, fast)
nmap -sS -T4 $TARGET_IP -oA 03-scanning/nmap/results/$TARGET/01-initial-port-scan

# Step 2: Service version detection
nmap -sV -sC -T4 $TARGET_IP -oA 03-scanning/nmap/results/$TARGET/02-service-version-detection

# Step 3: Full port scan (all 65535 ports)
nmap -sS -sV -sC -O -p- -T4 $TARGET_IP -oA 03-scanning/nmap/results/$TARGET/03-full-scan

# Step 4: Aggressive scan (optional - adds traceroute, scripts)
nmap -A -T4 $TARGET_IP -oA 03-scanning/nmap/results/$TARGET/04-aggressive-scan
```

#### 3.2 Advanced Nmap Scans

##### UDP Scanning (Often Overlooked!)
```markdown
# Top 100 UDP ports
sudo nmap -sU --top-ports 100 $TARGET_IP -oA 03-scanning/nmap/results/$TARGET/05-udp-top100

# Common UDP services
sudo nmap -sU -p 53,69,161,162,123 $TARGET_IP -oA 03-scanning/nmap/results/$TARGET/06-udp-common

# Full UDP scan (very slow - optional)
sudo nmap -sU -p- $TARGET_IP -oA 03-scanning/nmap/results/$TARGET/07-udp-full
# Note: This can take hours - only do if time permits
```

##### NSE Script Categories
```markdown
# Vulnerability-specific scripts
nmap --script vuln -p- $TARGET_IP -oA 03-scanning/nmap/results/$TARGET/08-nse-vuln

# Safe scripts only
nmap --script safe -p- $TARGET_IP -oA 03-scanning/nmap/results/$TARGET/09-nse-safe

# Discovery scripts
nmap --script discovery -p- $TARGET_IP -oA 03-scanning/nmap/results/$TARGET/10-nse-discovery

# Authentication testing
nmap --script auth -p- $TARGET_IP -oA 03-scanning/nmap/results/$TARGET/11-nse-auth

# Brute force (use carefully)
nmap --script brute -p- $TARGET_IP -oA 03-scanning/nmap/results/$TARGET/12-nse-brute
```

##### OS Detection Deep Dive
```markdown
# Aggressive OS detection
sudo nmap -O --osscan-guess $TARGET_IP -oA 03-scanning/nmap/results/$TARGET/13-os-detection

# TTL analysis
ping -c 10 $TARGET_IP | grep ttl
# TTL ~64 = Linux
# TTL ~128 = Windows

# TCP/IP stack fingerprinting
sudo nmap -sV -O --script "banner,version,os-*" $TARGET_IP
```

#### 3.3 Vulnerability Scanning
```markdown
# OpenVAS/Greenbone (GUI-based)
# - Create target in web interface
# - Run "Full and fast" scan configuration
# - Export results (PDF + CSV)

# Alternative: Nmap NSE vulnerability scripts (covered above in 3.2)
```

#### 3.4 Web Vulnerability Scanning
```markdown
# Nikto Version
nikto -Version | tee  /03-scanning/nikto/configs/nikto-version.md

# Nikto for HTTP services (deafult 80)
nikto -h http://$TARGET_IP -o 03-scanning/nikto/results/[vm-name]/nikto-http-scan.txt

# or 
nikto -h $TARGET_IP 80 -o 03-scanning/nikto/results/[vm-name]/nikto-http-scan.txt

# Nikto for HTTP services (discovered by nmao sv scan)
nikto -h http://$TARGET_IP 80,8180,<PORTS> -o 03-scanning/nikto/results/[vm-name]/nikto-http-scan.txt

# If HTTPS
nikto -h https://$TARGET_IP -o 03-scanning/nikto/results/[vm-name]/nikto-ssl-scan.txt

# or
nikto -h https://$TARGET_IP | tee 03-scanning/nikto/results/[vm-name]/nikto-ssl-scan.txt

# If additional web ports (e.g., 8080, 8180)
nikto -h http://$TARGET_IP:8180 -o 03-scanning/nikto/results/nikto-8180-scan.txt
```

#### 3.1 Nessus Installation & Setup (Pre-scan)

```markdown
# Download latest Nessus Debian package (example)
wget "https://www.tenable.com/downloads/api/v1/public/pages/nessus/downloads/14799/download?i_agree_to_tenable_license_agreement=true" -O Nessus.deb

# Install Nessus
sudo dpkg -i Nessus.deb

# Fix missing dependencies if required
sudo apt --fix-broken install -y

# Start Nessus service
sudo systemctl start nessusd
sudo systemctl enable nessusd
sudo systemctl status nessusd

# Access Nessus via browser
# https://localhost:8834

3.2 Nessus Initial Configuration

Select Nessus Essentials

Register and obtain activation code

Paste activation code into Nessus

Create admin user

Wait for plugin download to complete (10–30 minutes)

3.3 Nessus Policy & Scan Configuration

Create a scan policy:

Scans → Policies → New Policy

Choose template:

Basic Network Scan (recommended)

sc (optional)

Web Application Tests (optional)

Policy settings (recommended):

Port scan range: default

Service discovery: enabled

Plugin families:

General

Linux

Web Servers

Databases

Backdoors

Credentials (optional):

SSH (Linux)

SMB (Windows)

SNMP (if applicable)

3.4 Scan Execution (Nessus)
3.4.1 Basic Network Scan (Unauthenticated)
- Target: 192.168.172.128 (Metasploitable2)
- Scan type: Basic Network Scan
- Policy: Default or custom
- Launch: Immediately

3.4.2 Credentialed Scan (Optional but Recommended)

Add credentials for deeper assessment:

SSH (Linux)

SMB (Windows)

SNMP (if applicable)

3.5 Scan Results Review

Export scan report:

PDF

CSV

Nessus (.nessus)

Store results in:

03-scanning/nessus/results/metasploitable2/

3.6 Validation & Cross-verification (OpenVAS vs Nessus)

Cross-check high severity results between OpenVAS and Nessus

Confirm duplicates and false positives

Validate critical vulnerabilities

Document discrepancies:

Vulnerabilities found only in Nessus

Vulnerabilities found only in OpenVAS

Confirmed findings


### Deliverables:

03-scanning/
├── nmap/
│   ├── results/$TARGET/
│   │   ├── 01-initial-port-scan.(nmap|xml|gnmap)
│   │   ├── 02-service-version-detection.*
│   │   ├── 03-full-scan.*
│   │   ├── 04-aggressive-scan.*
│   │   ├── 05-udp-top100.*
│   │   ├── 06-udp-common.*
│   │   ├── 07-udp-full.* (optional)
│   │   ├── 08-nse-vuln.*
│   │   ├── 09-nse-safe.*
│   │   ├── 10-nse-discovery.*
│   │   ├── 11-nse-auth.*
│   │   ├── 12-nse-brute.*
│   │   └── 13-os-detection.*
│   ├── screenshots/$TARGET/
│   │   └── [numbered screenshots]
│   └── detailed-reports/
│       └── $TARGET-nmap-report.md
├── openvas/
│   ├── results/$TARGET/
│   │   ├── scan-report.pdf
│   │   └── scan-report.csv
│   └── screenshots/
│       └── [configuration and results screenshots]
├── nikto/
│   ├── results/
│   │   ├── nikto-scan.txt
│   │   └── nikto-8180-scan.txt
│   └── screenshots/
└── nessus/ (if used)
    └── results/


    
```

---

## Phase 4: Enumeration 🔎

**Goal:** Manual deep-dive into discovered services

### Core Service Enumeration:

#### 4.1 FTP Enumeration
```markdown
# Directory: 04-enumeration/ftp/

# Banner grabbing
nc -vn $TARGET_IP 21

# Anonymous login test
ftp $TARGET_IP
# Try: anonymous / anonymous

# Version check
nmap -sV -p 21 $TARGET_IP

**Document:**
- FTP version
- Anonymous access (Yes/No)
- Writable directories
- Known vulnerabilities for version

**Deliverables:**
- ftp-enumeration.md
- ftp-banner.txt
- screenshots/

```


#### 4.2 SSH Enumeration
```markdown
# Directory: 04-enumeration/ssh/

# Version and algorithms
ssh -v $TARGET_IP 2>&1 | tee /vulnerability-assessment/<vm-name>/04-enumeration/ssh/results/01-ssh-version-and-algorithms.txt

# Supported authentication methods
ssh -v $TARGET_IP 2>&1 | tee /vulnerability-assessment/<vm-name>/04-enumeration/ssh/results/02-ssh-auth-methods.txt

# Service version verification
nmap -sV -p 22 -oA /vulnerability-assessment/<vm-name>/04-enumeration/ssh/results/03-ssh-version $TARGET_IP

# Test known credentials (if applicable)
ssh msfadmin@$MS_TARGET 2>&1 | tee /mnt/shared/vulnerability-assessment/metasploitable2/04-enumeration/ssh/results/04-ssh-credential-test-a.txt

ssh -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa msfadmin@$MS_TARGET 2>&1 | tee /mnt/shared/vulnerability-assessment/metasploitable2/04-enumeration/ssh/results/04-ssh-credential-test-b.txt


**Document:**
- SSH version
- Weak algorithms supported
- Authentication methods
- Weak/default credentials

**Deliverables:**
- ssh-enumeration.md
- ssh-algorithms.txt
- screenshots/

```

#### 4.3 Telnet Enumeration
```markdown
# Directory: 04-enumeration/telnet/

# Banner grabbing
nc -vn $TARGET_IP 23

or

nc -vn $MS_TARGET 23 2>&1 | tee /04-enumeration/telnet/results/01-telnet-banner-grab.txt

# Connection test
telnet $TARGET_IP

# Capture cleartext traffic (demonstrates vulnerability)
sudo tcpdump -i eth0 -A 'port 23' -w telnet-traffic.pcap


**Document:**
- Telnet version
- Cleartext credential exposure
- Authentication requirements
- Security risk assessment

**Deliverables:**
- telnet-enumeration.md
- telnet-banner.txt
- telnet-traffic.pcap
- screenshots/

```

#### 4.4 SMTP Enumeration
```markdown
# Directory: 04-enumeration/smtp/

# Version detection
nmap -sV -p 25 $TARGET_IP

# User enumeration
smtp-user-enum -M VRFY -U /usr/share/metasploit-framework/data/wordlists/unix_users.txt -t $TARGET_IP

# Manual VRFY commands
nc $TARGET_IP 25
HELO attacker
VRFY root
VRFY msfadmin
VRFY admin

# Open relay test
nmap --script smtp-open-relay -p 25 $TARGET_IP

**Document:**
- SMTP version
- Valid user enumeration results
- Open relay status
- User enumeration vulnerability

**Deliverables:**
- smtp-enumeration.md
- user-enumeration.txt
- relay-test-results.txt
- screenshots/

```

#### 4.5 DNS Enumeration
```markdown
# Directory: 04-enumeration/dns/

# Zone transfer attempt
dig @$TARGET_IP axfr
dig @$TARGET_IP axfr domain.local

# DNS version
nmap --script dns-nsid -p 53 $TARGET_IP

# DNS recursion test
nmap --script dns-recursion -p 53 $TARGET_IP

**Document:**
- DNS version
- Zone transfer results
- Recursion status
- DNS vulnerabilities

**Deliverables:**
- dns-enumeration.md
- zone-transfer-attempt.txt
- dns-version.txt
- screenshots/

```

#### 4.7 RPC/NFS Enumeration
```markdown
# Directory: 04-enumeration/rpc-nfs/

# List RPC services
rpcinfo -p $TARGET_IP

# NFS shares
showmount -e $TARGET_IP

# Mount NFS (if available)
mkdir /tmp/nfs-test
sudo mount -t nfs $TARGET_IP:/export /tmp/nfs-test
ls -la /tmp/nfs-test
sudo umount /tmp/nfs-test

# Nmap scripts
nmap --script nfs-ls,nfs-showmount,nfs-statfs -p 111,2049 $TARGET_IP

**Document:**
- RPC services running
- NFS shares available
- Share permissions
- Mount success/failure

**Deliverables:**
- rpc-nfs-enumeration.md
- rpcinfo-output.txt
- nfs-shares.txt
- nfs-mount-contents.txt (if successful)
- screenshots/

```

#### 4.8 Database Enumeration
```markdown
# Directory: 04-enumeration/database/

# MySQL
mysql -h $TARGET_IP -u root -p

or
mysql --ssl=0 --protocol=TCP -h $MS_TARGET -u root

# Try blank password or common defaults

# If connected:
SHOW DATABASES;
SELECT user, host FROM mysql.user;
SELECT User, Host, authentication_string FROM mysql.user;

# PostgreSQL
psql -h $TARGET_IP -U postgres
# Default password often: postgres


# If connected:
## For rescent postgres
\l  (list databases)
\du (list users)
\dp (list permissions)

## For legacy postgres
SELECT datname FROM pg_database;

**Document:**
- Database version
- Default credentials
- Accessible databases
- User privileges
- Security misconfigurations

**Deliverables:**
- database-enumeration.md
- mysql-databases.txt
- postgresql-databases.txt
- screenshots/

```

#### 4.11 Java RMI Enumeration
```markdown
# Directory: 04-enumeration/java-rmi/

# Service detection
nmap -sV -p 1099 $TARGET_IP

# RMI registry dump
nmap --script rmi-dumpregistry -p 1099 $TARGET_IP

**Document:**
- RMI version
- Registry contents
- Available objects
- Security implications

**Deliverables:**
- java-rmi-enumeration.md
- rmi-registry-dump.txt
- screenshots/

```

#### 4.13 X11 Enumeration
```markdown
# Directory: 04-enumeration/x11/

# Service detection
nmap -sV -p 6000 $TARGET_IP

# Access test
xdpyinfo -display $TARGET_IP:0

# Screenshot (if accessible)
xwd -root -display $TARGET_IP:0 -out x11-screenshot.xwd
convert x11-screenshot.xwd x11-screenshot.png

**Document:**
- X11 version
- Access control status
- Display information
- Screenshot evidence

**Deliverables:**
- x11-enumeration.md
- x11-access-test.txt
- x11-screenshot.png (if successful)
- screenshots/

```

#### 4.14 Web Enumeration
```markdown
# Directory: 04-enumeration/web/

# Directory enumeration
dirb http://$TARGET_IP /usr/share/wordlists/dirb/common.txt

# OR
gobuster dir -u http://$TARGET_IP -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt

# Technology fingerprinting
whatweb http://$TARGET_IP

# Manual browsing
firefox http://$TARGET_IP &

# Screenshot all discovered web apps

# Information disclosure hunting
curl http://$TARGET_IP/phpinfo.php
curl http://$TARGET_IP/server-status
curl -i http://$TARGET_IP/.git/
curl -i http://$TARGET_IP/.svn/

# Backup files
dirb http://$TARGET_IP /usr/share/wordlists/dirb/common.txt -X .bak,.old,.zip,.tar.gz

# Configuration files
gobuster dir -u http://$TARGET_IP -w /usr/share/wordlists/dirb/common.txt -x .conf,.config,.xml,.yml

**Document:**
- Web server version
- Application frameworks
- Discovered directories/files
- Login pages
- Sensitive information exposure
- Information disclosure findings

**Deliverables:**
- web-enumeration.md
- dirb-results.txt
- whatweb-output.txt
- info-disclosure-findings.txt
- screenshots/
  - dvwa-homepage.png
  - mutillidae-homepage.png
  - phpmyadmin-login.png

```

#### 4.15 Tomcat/Axis2 Enumeration
```markdown
# Directory: 04-enumeration/tomcat/

# Web enumeration
nikto -h http://$TARGET_IP:8180

# Directory bruteforce
dirb http://$TARGET_IP:8180 /usr/share/wordlists/dirb/common.txt

# Manager interface check
curl -I http://$TARGET_IP:8180/manager/html

# Default credentials test (document only, don't access)
# Common: tomcat/tomcat, admin/admin, manager/manager

# Axis2 specific
curl http://$TARGET_IP:8180/axis2/axis2-admin/

**Document:**
- Tomcat version
- Manager interface accessibility
- Axis2 presence
- Default credential vulnerability
- Known CVEs

**Deliverables:**
- tomcat-enumeration.md
- nikto-results.txt
- dirb-results.txt
- manager-interface-check.txt
- screenshots/

```

### Cross-Service Analysis:

#### 4.16 Credential Reuse Testing
```markdown
# Directory: 04-enumeration/credential-testing/

# Test discovered credentials across all services
# Example: msfadmin:msfadmin

# Services to test:
- SSH (port 22): ssh msfadmin@$TARGET_IP
- FTP (port 21): ftp msfadmin@$TARGET_IP
- Telnet (port 23): telnet $TARGET_IP (then login)
- MySQL (port 3306): mysql -h $TARGET_IP -u msfadmin -pmsfadmin
- PostgreSQL (port 5432): psql -h $TARGET_IP -U msfadmin
- SMB (port 445): smbclient -L //$TARGET_IP -U msfadmin%msfadmin
- VNC (port 5900): vncviewer $TARGET_IP:5900

**Document in matrix format:**

| Service | Port | Credentials | Success | Notes |
|---------|------|-------------|---------|-------|
| SSH | 22 | msfadmin:msfadmin | ✓ | Full shell access |
| FTP | 21 | msfadmin:msfadmin | ✓ | File upload possible |
| Telnet | 23 | msfadmin:msfadmin | ✓ | Cleartext transmission |
| MySQL | 3306 | msfadmin:msfadmin | ✓ | Database access |
| PostgreSQL | 5432 | msfadmin:msfadmin | ? | Test required |
| SMB | 445 | msfadmin:msfadmin | ✓ | Share access |

**Deliverables:**
- credential-reuse-matrix.md
- credential-testing-results.txt

```

#### 4.17 Banner Collection
```markdown
# Directory: 04-enumeration/banner-analysis/

# Create: collect-banners.sh

#!/bin/bash

TARGET=$1

if [ -z "$TARGET" ]; then
    echo "Usage: $0 <target_ip>"
    exit 1
fi

read -p "Enter output directory path: " OUTDIR

# Use current directory if blank
if [ -z "$OUTDIR" ]; then
    OUTDIR="."
fi

# Remove trailing slash if present
OUTDIR="${OUTDIR%/}"

# Create directory if it doesn't exist
mkdir -p "$OUTDIR"

OUTPUT="$OUTDIR/banners-$(date +%Y%m%d).txt"

echo "Collecting banners from $TARGET" > "$OUTPUT"
echo "=================================" >> "$OUTPUT"

PORTS=$(nmap -sS "$TARGET" | grep "open" | awk -F/ '{print $1}')

for port in $PORTS; do
    echo -e "\n=== Port $port ===" >> "$OUTPUT"
    timeout 5 nc -nv "$TARGET" "$port" < /dev/null >> "$OUTPUT" 2>&1
done

echo
echo "================================="
echo "Banner collection complete."
echo "Results saved to:"
echo "  $OUTPUT"
echo "================================="
echo


# Run the script
chmod +x collect-banners.sh
./collect-banners.sh $TARGET_IP


**Deliverables:**
- collect-banners.sh
- banners-[date].txt
- banner-analysis.md

```

### Complete Enumeration Structure:
```markdown
04-enumeration/
├── ftp/
├── ssh/
├── telnet/
├── smtp/
├── dns/
├── smb/
├── rpc-nfs/
├── database/
├── vnc/
├── irc/
├── java-rmi/
├── distcc/
├── x11/
├── web/
├── tomcat/
├── credential-testing/
└── banner-analysis/
```

---

## Phase 5: Analysis & Risk Scoring 📊

**Goal:** Organize findings and prioritize by risk

### Activities:

#### 5.1 Create Master Vulnerability List
```markdown
Consolidate ALL findings into one spreadsheet:

**Columns:**
- Vuln ID (V-001, V-002, etc.)
- CVE (if applicable)
- Service/Port
- Severity (Critical/High/Medium/Low)
- CVSS Score
- Description
- Affected Asset
- Exploitability (High/Medium/Low)
- Impact (Critical/High/Medium/Low)
- Remediation
- Status (Open/Validated/False Positive)

**Sources to merge:**
- Nmap scan results (all scans)
- OpenVAS/Nessus findings
- Nikto results
- Manual enumeration discoveries (all services)

```

#### 5.2 Risk Scoring Formula
```markdown
Risk Score = Severity × Exploitability × Business Impact

Severity:
- Critical = 4
- High = 3
- Medium = 2
- Low = 1

Exploitability:
- Public exploit exists = 3
- PoC available = 2
- Theory only = 1

Business Impact (for lab: data exposure/system access):
- Full system compromise = 3
- Partial access/data leak = 2
- Information disclosure = 1
```

#### 5.3 Prioritization
```markdown
Sort vulnerabilities by:
1. Risk Score (highest first)
2. Exploitability
3. Remediation effort

**Create priority groups:**
- **P0 (Immediate):** Critical + High exploitability
- **P1 (Urgent):** High + Public exploits
- **P2 (Scheduled):** Medium/High
- **P3 (Low Priority):** Low severity

```

#### 5.4 Attack Chain Analysis

```markdown
Document potential attack paths:

**Example chains:**
1. vsftpd backdoor (Port 21) → Remote shell → Root access
2. Weak SSH credentials → User shell → Privilege escalation → Root
3. SQL injection (Web) → Database access → Read sensitive data
4. SMB null session → User enumeration → Password spray → SSH access
5. UnrealIRCd backdoor (Port 6667) → Remote shell → Persistence

**Create detailed chain documentation:**
# Attack Chain 1: Public Service → Root Access

## Steps:
1. **Entry Point:** vsftpd 2.3.4 backdoor (CVE-2011-2523)
   - Port: 21/TCP
   - No authentication required
   - Public exploit available
   - Exploitability: HIGH

2. **Initial Access:** Remote shell as root
   - Direct root access via backdoor
   - Impact: CRITICAL

3. **Persistence:** Create backdoor user
   - Command: useradd -m -s /bin/bash backdoor
   - Add to sudoers
   - Full system control

**Overall Risk:** CRITICAL (Score: 36/36)
```

#### 5.5 Attack Surface Mapping

```markdown
05-reporting/analysis/attack-surface-map.md

# Attack Surface Analysis

## External Entry Points
| Service | Port | Protocol | Authentication | Encryption | Risk |
|---------|------|----------|----------------|------------|------|
| FTP | 21 | TCP | Weak (msfadmin:msfadmin) | None | Critical |
| SSH | 22 | TCP | Password | Yes | High |
| Telnet | 23 | TCP | Password | None | Critical |
| SMTP | 25 | TCP | None (relay) | None | Medium |
| DNS | 53 | UDP/TCP | None | None | Medium |
| HTTP | 80 | TCP | App-based | None | High |
| RPC | 111 | TCP/UDP | None | None | High |
| SMB | 445 | TCP | Null session | None | Critical |
| MySQL | 3306 | TCP | Weak (root/blank) | None | Critical |
| PostgreSQL | 5432 | TCP | Weak | None | High |
| VNC | 5900 | TCP | None/Weak | Weak | Critical |
| IRC | 6667 | TCP | None | None | Critical |
| Java RMI | 1099 | TCP | None | None | High |
| NFS | 2049 | TCP/UDP | Host-based | None | High |
| Distcc | 3632 | TCP | None | None | Critical |
| X11 | 6000 | TCP | None | None | Critical |
| Tomcat | 8180 | TCP | Weak defaults | None | High |

## Authentication Mechanisms
- **FTP:** Username/password (default: msfadmin/msfadmin)
- **SSH:** Username/password, public key (weak password)
- **Telnet:** Username/password (cleartext)
- **MySQL:** Username/password (root with blank password)
- **PostgreSQL:** Username/password (postgres/postgres)
- **Web Apps:** Form-based (DVWA, Mutillidae - multiple vulns)
- **SMB:** Username/password, null session allowed
- **VNC:** Password or none
- **Tomcat:** Username/password (tomcat/tomcat, admin/admin)

## Data Flow
- Database (MySQL/PostgreSQL) → Web Applications → External Users
- File Shares (NFS/SMB) → Network Access → Data Exfiltration
- Remote Services (VNC/X11/SSH/Telnet) → Direct System Access
- Web Services → Application Layer → Database Layer

## Network Segmentation
- [ ] No firewall between services
- [ ] All ports exposed to network
- [ ] No DMZ or service isolation
- [ ] No network-based IDS/IPS
- [ ] No access control lists
```

#### 5.6 Vulnerability Chaining Matrix
```markdown
**Create:** `05-reporting/analysis/vulnerability-chains.md`

# Vulnerability Exploitation Chains
## Chain 1: Public Service → Root Access
1. **Entry:** vsftpd 2.3.4 backdoor (CVE-2011-2523)
   - No authentication required
   - Public exploit available
   - Exploitability: HIGH

2. **Foothold:** Remote shell as root
   - Direct root access
   - Impact: CRITICAL

3. **Persistence:** Create backdoor user
   - useradd backdoor
   - Full system control

**Overall Risk:** CRITICAL

## Chain 2: Web → Database → System
1. **Entry:** SQL Injection in DVWA
   - Authentication bypass
   - Database enumeration
   - Exploitability: MEDIUM

2. **Lateral Movement:** MySQL root access
   - Load file privileges
   - Write webshell to /var/www
   - SELECT ... INTO OUTFILE

3. **Privilege Escalation:** Kernel exploit
   - Linux 2.6.x vulnerable
   - Local root exploit available

**Overall Risk:** HIGH

## Chain 3: Network Service → Credential Access
1. **Entry:** SMB null session
   - User enumeration via enum4linux
   - Share listing
   - No authentication required

2. **Credential Attack:** Password spray
   - Weak passwords identified
   - Multiple service access (SSH, FTP, Telnet)
   - Credential reuse across services

3. **System Access:** SSH login
   - msfadmin account has sudo privileges
   - Full control achieved

**Overall Risk:** HIGH

## Chain 4: IRC Backdoor → Root
1. **Entry:** UnrealIRCd 3.2.8.1 backdoor (CVE-2010-2075)
   - No authentication required
   - Public exploit available
   - Port 6667

2. **Foothold:** Remote shell
   - Direct command execution
   - User-level access initially

3. **Privilege Escalation:** Sudo misconfiguration
   - Check sudo -l
   - Potential privilege escalation vectors

**Overall Risk:** CRITICAL

## Chain 5: Distcc → System Compromise
1. **Entry:** Distcc daemon (CVE-2004-2687)
   - Remote code execution
   - No authentication
   - Port 3632

2. **Access:** Shell as daemon user
   - Limited privileges initially
   - File system access

3. **Escalation:** SUID binaries or kernel exploits
   - Local privilege escalation
   - Path to root

**Overall Risk:** HIGH
```

#### 5.7 Compliance/Framework Mapping
```markdown
**Create:** `05-reporting/analysis/compliance-mapping.md`

# Compliance & Framework Mapping

## OWASP Top 10 (Web Vulnerabilities)
- **A1: Injection** - SQL injection in DVWA, Mutillidae, command injection
- **A2: Broken Authentication** - Default credentials (multiple services), weak passwords
- **A3: Sensitive Data Exposure** - Unencrypted protocols (FTP, Telnet, HTTP), cleartext credentials
- **A5: Broken Access Control** - Directory traversal, file inclusion, null session access
- **A6: Security Misconfiguration** - Default configs, exposed services, unnecessary services running
- **A7: Cross-Site Scripting (XSS)** - Present in DVWA, Mutillidae
- **A9: Using Components with Known Vulnerabilities** - vsftpd 2.3.4, UnrealIRCd 3.2.8.1, outdated software

## CIS Critical Security Controls
- **Control 1 (Inventory):** ✓ Completed - All assets and services identified
- **Control 2 (Software Inventory):** ✓ Completed - All services catalogued
- **Control 3 (Continuous Vulnerability Management):** ✓ In Progress - Assessment ongoing
- **Control 4 (Controlled Use of Admin Privileges):** ❌ Failed - Root exposure, sudo misconfig
- **Control 6 (Maintenance, Monitoring, and Analysis of Audit Logs):** ❌ Not Assessed
- **Control 7 (Email and Web Browser Protections):** ❌ Failed - Multiple web vulns
- **Control 9 (Limitation of Network Ports):** ❌ Failed - 20+ unnecessary services exposed
- **Control 11 (Secure Network Ports/Protocols):** ❌ Failed - Cleartext protocols (Telnet, FTP, HTTP)
- **Control 12 (Boundary Defense):** ❌ Failed - No firewall, all services exposed
- **Control 14 (Controlled Access Based on Need to Know):** ❌ Failed - Open shares, null sessions
- **Control 16 (Account Monitoring):** ❌ Failed - Default accounts active

## MITRE ATT&CK Mapping
| Tactic | Technique | Finding |
|--------|-----------|---------|
| Initial Access | T1190 - Exploit Public-Facing Application | Web vulnerabilities, backdoors |
| Initial Access | T1133 - External Remote Services | SSH, Telnet, FTP with weak auth |
| Execution | T1059 - Command and Scripting Interpreter | Backdoors (vsftpd, UnrealIRCd), web shells |
| Persistence | T1136 - Create Account | Weak authentication allows account creation |
| Persistence | T1098 - Account Manipulation | Sudo privileges, user modification |
| Privilege Escalation | T1068 - Exploitation for Privilege Escalation | Kernel vulnerabilities |
| Privilege Escalation | T1078 - Valid Accounts | Default credentials, password reuse |
| Defense Evasion | T1070 - Indicator Removal | Log access via root shells |
| Credential Access | T1110 - Brute Force | Weak passwords susceptible |
| Credential Access | T1003 - OS Credential Dumping | Database credential access |
| Discovery | T1087 - Account Discovery | SMTP VRFY, SMB enumeration |
| Discovery | T1046 - Network Service Scanning | All services easily enumerable |
| Lateral Movement | T1021 - Remote Services | SSH, Telnet, FTP, SMB, VNC, RDP-like services |
| Collection | T1005 - Data from Local System | Database access, file shares |
| Exfiltration | T1048 - Exfiltration Over Alternative Protocol | FTP, HTTP, SMB for data theft |
| Impact | T1485 - Data Destruction | Root access allows complete destruction |
| Impact | T1486 - Data Encrypted for Impact | Potential ransomware scenario |

## NIST Cybersecurity Framework
- **Identify (ID):** ✓ Asset and vulnerability identification complete
- **Protect (PR):** ❌ Failed - No access controls, encryption, or secure configs
- **Detect (DE):** ❌ Not Assessed - No monitoring/logging reviewed
- **Respond (RS):** ❌ Not Assessed - No incident response capability tested
- **Recover (RC):** ❌ Not Assessed - No backup/recovery mechanisms tested
```

### Deliverables:
```markdown
05-reporting/
├── analysis/
│   ├── vulnerability-master-list.csv
│   ├── risk-scored-vulnerabilities.csv
│   ├── attack-chain-analysis.md
│   ├── attack-surface-map.md
│   ├── vulnerability-chains.md
│   ├── compliance-mapping.md
│   └── prioritization-matrix.md
├── validation/ (Phase 6)
- **High:** 100% (if public exploits exist), 50% sample otherwise
- **Medium:** 25% sample
- **Low:** 10% sample



## Phase 7: Reporting 📝

**Goal:** Professional, actionable documentation

### Report Structure:

```markdown
1. Executive Summary (1-2 pages)
   - High-level overview
   - Key statistics
   - Critical findings summary
   - Overall risk rating
   - Immediate recommendations

2. Methodology (1 page)
   - Scope and objectives
   - Tools and techniques used
   - Assessment timeline
   - Limitations and constraints

3. Findings Summary (2-3 pages)
   - Vulnerability statistics
   - Charts and graphs
   - Asset-level summary
   - Top 10 vulnerabilities
   - Severity distribution

4. Technical Findings (Main section)
   - Detailed vulnerability entries
   - One section per critical/high finding
   - Evidence screenshots
   - Risk analysis
   - Remediation steps

5. Risk Analysis (2-3 pages)
   - Attack path documentation
   - Exploitability assessment
   - Business impact (adapted for lab)
   - Attack surface analysis
   - Vulnerability chaining

6. Recommendations (2-3 pages)
   - Prioritized remediation roadmap
   - Quick wins (immediate actions)
   - Long-term improvements
   - Patch management strategy

7. Appendices
   - Appendix A: Tool Configurations
   - Appendix B: Limitations and Assumptions
   - Appendix C: Complete Vulnerability List
   - Appendix D: Raw Scan Outputs
   - Appendix E: References and Resources
```

### Executive Summary Template:

```markdown
# Executive Summary

## Assessment Overview
This vulnerability assessment was conducted between [start date] and [end date] against the Metasploitable2 virtual machine in a controlled laboratory environment. The assessment identified **[total]** security findings across **[number]** network services, with **[critical count]** rated as Critical severity.

**Assessment Date:** [Date Range]  
**Target System:** Metasploitable2 (192.168.x.x)  
**Assessment Type:** Comprehensive Vulnerability Assessment  
**Methodology:** NIST SP 800-115 / OWASP Testing Guide

## Risk Summary
**Overall Risk Rating: CRITICAL**

The target system exhibits an extremely high-risk profile with multiple pathways to complete system compromise. Of particular concern:

- **8 Critical** and **12 High** severity vulnerabilities identified
- **6 vulnerabilities** have publicly available exploits with Metasploit modules
- **4 services** allow unauthenticated remote code execution
- **10 services** expose sensitive information or use cleartext protocols
- **5 services** use default or no credentials

## Key Findings

### Critical Issues (Immediate Action Required)

1. **vsftpd 2.3.4 Backdoor (CVE-2011-2523)**
   - **Affected:** FTP service (Port 21)
   - **Risk:** Unauthenticated remote code execution as root
   - **Impact:** Complete system compromise
   - **Exploit:** Publicly available, Metasploit module exists
   - **Recommendation:** Immediate service disable or upgrade to vsftpd 3.0.5+

2. **UnrealIRCd 3.2.8.1 Backdoor (CVE-2010-2075)**
   - **Affected:** IRC service (Port 6667)
   - **Risk:** Remote code execution via backdoor
   - **Impact:** System compromise
   - **Exploit:** Publicly available
   - **Recommendation:** Remove service (unnecessary for lab environment)

3. **Samba 3.0.20 Username Map Script (CVE-2007-2447)**
   - **Affected:** SMB service (Port 445)
   - **Risk:** Remote code execution
   - **Impact:** System compromise
   - **Exploit:** Metasploit module available
   - **Recommendation:** Upgrade to Samba 3.0.25 or later

4. **Distcc Daemon RCE (CVE-2004-2687)**
   - **Affected:** Distcc service (Port 3632)
   - **Risk:** Unauthenticated remote code execution
   - **Impact:** System compromise
   - **Exploit:** Public exploit available
   - **Recommendation:** Disable service (unnecessary)

### High Priority Issues

- **Default Credentials:** MySQL root account with blank password
- **Cleartext Protocols:** Telnet (Port 23) transmits credentials in clear text
- **Null Session Access:** SMB allows anonymous user enumeration
- **VNC No Authentication:** Remote desktop accessible without password
- **X11 Open Access:** Display server accessible without authentication
- **Web Application Vulnerabilities:** SQL injection, XSS, command injection in DVWA/Mutillidae

## Attack Paths Identified

Multiple attack chains provide rapid paths to system compromise:

1. **Path 1 (Fastest):** FTP backdoor → Root shell (0 authentication, 1 step)
2. **Path 2:** Weak credentials → SSH access → Sudo privileges → Root
3. **Path 3:** Web SQL injection → Database → File write → Webshell → Privilege escalation
4. **Path 4:** SMB null session → User enum → Password spray → Multi-service access

## Summary Statistics

| Severity | Count | Percentage | With Public Exploits |
|----------|-------|------------|----------------------|
| Critical | 8     | 18%        | 6                    |
| High     | 12    | 27%        | 8                    |
| Medium   | 18    | 40%        | 3                    |
| Low      | 7     | 15%        | 0                    |
| **Total**| **45**| **100%**   | **17**               |

## Immediate Actions Required (0-24 hours)

1. **Disable critical services:**
   
   sudo service vsftpd stop
   sudo service unrealircd stop
   sudo service distcc stop
   

2. **Change default credentials:**
   - MySQL root password
   - PostgreSQL postgres password
   - All msfadmin passwords

3. **Restrict network access:**
   - Implement firewall rules
   - Disable unnecessary services
   - Enable network segmentation

## Compliance Impact

- **OWASP Top 10:** Fails A1 (Injection), A2 (Broken Auth), A3 (Sensitive Data Exposure), A6 (Misconfiguration)
- **CIS Controls:** Fails Controls 4, 9, 11, 12, 14, 16
- **NIST CSF:** PROTECT function completely absent

## Conclusion

The Metasploitable2 system is **intentionally vulnerable** and demonstrates a worst-case security posture. All identified vulnerabilities are remediated through available patches, configuration changes, or service removal. Implementation of recommendations will significantly improve security posture, though this system should **never be exposed** to untrusted networks.

**Assessor:** [Your Name]  
**Report Date:** [Date]  
**Classification:** LAB ENVIRONMENT / EDUCATIONAL USE ONLY
```

#############################################################################################
### Technical Finding Template:

```markdown
## [V-001] vsftpd 2.3.4 Backdoor - Remote Code Execution

### Vulnerability Details
- **CVE:** CVE-2011-2523
- **CVSS Score:** 10.0 (Critical)
- **CVSS Vector:** AV:N/AC:L/Au:N/C:C/I:C/A:C
- **Affected Asset:** 192.168.172.128 (Metasploitable2)
- **Service:** FTP (vsftpd 2.3.4)
- **Port:** 21/TCP
- **Discovery Method:** Nmap service scan, OpenVAS vulnerability scan
- **Validation Status:** TRUE POSITIVE (High confidence)

### Description
The vsftpd 2.3.4 version distributed via SourceForge between June 30 and July 1, 2011 contained a malicious backdoor that allows unauthenticated remote code execution. An attacker can trigger the backdoor by sending a specially crafted username containing a smiley face character sequence (":)") followed by any password. Upon successful trigger, a root shell is opened on TCP port 6200.

This backdoor was discovered when users reported strange behavior after downloading vsftpd 2.3.4 from the compromised SourceForge repository. The malicious code was embedded directly into the source tarball.

### Evidence
![FTP version banner showing vsftpd 2.3.4](../evidence/v-001-ftp-banner.png)

![Nmap scan detecting vsftpd backdoor](../evidence/v-001-nmap-detection.png)

### Technical Details
- **Attack Vector:** Network-based, remotely exploitable
- **Authentication:** None required
- **Trigger Mechanism:** Username ending with ":)" (smiley face)
- **Backdoor Port:** TCP 6200 (opened after trigger)
- **Shell Type:** /bin/sh as root user
- **Affected Versions:** Only vsftpd 2.3.4 from compromised source
- **Exploit Complexity:** Low (single FTP connection)

**Code Analysis:**
The backdoor code was inserted into `str_vsftpd_log_line()` function in `sysdeputil.c`:


if(str_contains_line(p_str, ":)"))
{
    vsf_sysutil_extra();  // Opens backdoor on port 6200
}


### Risk Assessment

- **Exploitability:** **HIGH**
  - Public exploit widely available
  - Metasploit module exists: `exploit/unix/ftp/vsftpd_234_backdoor`
  - No authentication required
  - Exploit is highly reliable

- **Impact:** **CRITICAL**
  - Remote code execution as root user
  - Complete system compromise
  - Full confidentiality, integrity, and availability loss
  - Attacker gains full control with highest privileges

- **Attack Complexity:** **LOW**
  - Single FTP connection required
  - No special conditions needed
  - Exploit succeeds consistently

- **Overall Risk Score:** **36/36** (P0 - Immediate action required)
  - Severity: Critical (4) × Exploitability: High (3) × Impact: Full Compromise (3) = 36


### Attack Scenario
1. Attacker connects to target:21 via FTP
2. Sends username ending with ":)" (e.g., "user:)")
3. Sends any password
4. Backdoor opens shell on port 6200
5. Attacker connects to port 6200
6. Root shell access achieved
7. Full system compromise in <10 seconds


### Proof of Concept
**Metasploit Module Available:**

msf6 > use exploit/unix/ftp/vsftpd_234_backdoor
msf6 exploit(unix/ftp/vsftpd_234_backdoor) > set RHOSTS 192.168.172.128
msf6 exploit(unix/ftp/vsftpd_234_backdoor) > exploit

[*] 192.168.172.128:21 - Banner: 220 (vsFTPd 2.3.4)
[*] 192.168.172.128:21 - USER: 331 Please specify the password.
[+] 192.168.172.128:21 - Backdoor service has been spawned, handling...
[+] 192.168.172.128:21 - UID: uid=0(root) gid=0(root)
[*] Command shell session 1 opened

id
uid=0(root) gid=0(root)


**Manual Exploitation Steps (NOT performed in assessment):**
1. `telnet 192.168.172.128 21`
2. Enter username: `user:)`
3. Enter any password
4. `telnet 192.168.172.128 6200`
5. Root shell obtained

### Business Impact (Lab Context)
While this is a lab environment, in a production context:
- Complete data breach potential
- Ransomware deployment possible
- Pivot point for lateral movement
- Regulatory compliance violations (PCI-DSS, HIPAA, SOX, GDPR)
- Reputational damage
- Legal liability

**Estimated Remediation Cost (Production):**
- Emergency patching: 2-4 hours
- Incident response: 8-16 hours
- Forensic analysis: 16-24 hours
- Potential breach notification: Regulatory requirements
- Total: ~40 hours + potential fines/legal costs

### Remediation
**Priority:** **P0 - IMMEDIATE** (0-24 hours)

#### Short-term (Immediate):
# Stop vsftpd service
sudo service vsftpd stop
sudo systemctl disable vsftpd

# Block port 21 via firewall
sudo iptables -A INPUT -p tcp --dport 21 -j DROP
sudo iptables -A INPUT -p tcp --dport 6200 -j DROP

# Save iptables rules
sudo iptables-save > /etc/iptables/rules.v4

#### Long-term (Permanent Fix):

# Remove compromised version
sudo apt-get remove vsftpd

# Download from official repository
sudo apt-get update
sudo apt-get install vsftpd

# Verify version (should be 3.0.5 or later)
vsftpd -v
# Expected: vsftpd: version 3.0.5

# Verify package signature
apt-cache policy vsftpd

#### Alternative Solutions:
1. **Replace with secure alternative:**
   - SFTP (SSH File Transfer Protocol) - encrypted, more secure
   - FTPS (FTP over TLS/SSL)

2. **If FTP required:**
   - Use updated vsftpd (3.0.5+)
   - Implement network segmentation
   - Use firewall rules to restrict access
   - Enable logging and monitoring
   - Disable anonymous access
   - Use strong authentication

#### Verification Steps:
```bash
# Confirm service is stopped
sudo systemctl status vsftpd
# Expected: inactive (dead)

# Verify port is closed
nmap -p 21 localhost
# Expected: closed or filtered

# Check for backdoor port
nmap -p 6200 localhost
# Expected: closed

# If upgraded, verify version
vsftpd -v
# Expected: 3.0.5 or higher

### References
- **CVE:** https://nvd.nist.gov/vuln/detail/CVE-2011-2523
- **Vendor Advisory:** https://security.appspot.com/vsftpd.html
- **Exploit-DB:** https://www.exploit-db.com/exploits/17491
- **Metasploit Module:** https://www.rapid7.com/db/modules/exploit/unix/ftp/vsftpd_234_backdoor/
- **SecurityFocus:** https://www.securityfocus.com/bid/48539
- **Analysis:** https://scarybeastsecurity.blogspot.com/2011/07/alert-vsftpd-download-backdoored.html

### Validation Evidence
- **Files:**
  - `05-reporting/validation/v-001-vsftpd-validation.md`
  - `05-reporting/validation/evidence/version-checks/ftp-banner.txt`
  - `05-reporting/validation/evidence/exploit-availability/searchsploit-vsftpd.txt`

- **Cross-Scanner Confirmation:**
  - Nmap NSE: Detected
  - OpenVAS: Confirmed (NVT: CVE-2011-2523)
  - Manual verification: Confirmed

---

**Assessment Performed By:** [Your Name]  
**Date:** [Date]  
**Review Status:** Validated  
**Next Review:** N/A (Lab environment)
```

### Additional Report Sections

#### Appendix A: Tool Configurations
```markdown
## Assessment Tools Used

### Nmap
- **Version:** 7.94SVN
- **Operating System:** Kali Linux 2024.3
- **Scan Types Performed:**
  - Host discovery (-sn)
  - TCP SYN scan (-sS)
  - Service version detection (-sV)
  - NSE script scanning (-sC)
  - OS detection (-O)
  - Full port scan (-p-)
  - UDP scan (-sU)
  - Aggressive scan (-A)

- **Key Flags Used:**
  - `-sS`: TCP SYN (stealth) scan
  - `-sV`: Service version detection
  - `-sC`: Default NSE scripts
  - `-O`: OS detection
  - `-p-`: Scan all 65535 ports
  - `-T4`: Aggressive timing template
  - `-oA`: Output in all formats

- **NSE Scripts:**
  - default, vuln, safe, discovery, auth, brute
  - Service-specific: ftp-anon, ssh-auth-methods, smb-enum-shares, http-enum

### OpenVAS/GVM
- **Version:** 23.1.0
- **Scan Configuration:** Full and fast
- **Feed Version:** 20250131
- **NVT Count:** 98,456
- **Credentials:** None (unauthenticated scan)
- **Scan Duration:** ~45 minutes
- **Results Format:** PDF, CSV

### Nikto
- **Version:** 2.5.0
- **Tuning:** All tests enabled
- **Plugins:** All active
- **Timeout:** 10 seconds per request
- **User-Agent:** Nikto/2.5.0
- **Tests Performed:** ~6,700 checks

### Manual Tools
- **nc (netcat):** Banner grabbing, port checking
- **telnet:** Service connectivity testing
- **curl:** HTTP header analysis
- **enum4linux:** SMB enumeration
- **smbclient:** SMB share access
- **mysql:** Database connectivity
- **psql:** PostgreSQL connectivity
- **searchsploit:** Exploit database searches
- **msfconsole:** Exploit verification (no exploitation performed)

## Scan Configurations

### Network Configuration
- **Assessment Source:** 192.168.172.1 (Kali Linux VM)
- **Target System:** 192.168.172.128 (Metasploitable2)
- **Network Type:** Host-only (VMnet1)
- **Internet Access:** Disabled (verified via ping test)
- **Network Bandwidth:** Unlimited (local VM network)

### Scan Parameters
- **Rate Limiting:** None (controlled environment)
- **Scan Intensity:** Aggressive (T4)
- **Scan Coverage:** 100% of in-scope target
- **Port Range:** All 65,535 TCP ports + top 100 UDP
- **Scan Duration:** ~3 hours total
- **Concurrent Scans:** Sequential (one scan at a time)

### Safety Measures
- **DoS Prevention:** N/A (intentionally vulnerable lab)
- **Traffic Capture:** tcpdump for validation
- **Snapshot Taken:** Before assessment start
- **Rollback Plan:** VM snapshot available
```

#### Appendix B: Limitations and Assumptions
```markdown
# Appendix B: Assessment Limitations and Assumptions

## Scope Limitations

### Out of Scope
- **Physical Security:** No physical access testing performed
- **Social Engineering:** No phishing or pretexting conducted
- **Wireless Networks:** No wireless assessment (lab uses wired network)
- **Denial of Service:** No DoS or stress testing performed
- **Password Cracking:** No offline password cracking (beyond default credentials)
- **Exploitation:** No vulnerabilities were actively exploited
- **Post-Exploitation:** No privilege escalation or persistence testing
- **Source Code Review:** Application code not analyzed
- **Mobile Applications:** N/A for this target
- **Cloud Infrastructure:** N/A (local VM environment)

### In Scope
- Network service enumeration
- Vulnerability identification
- Default credential testing
- Service version detection
- Vulnerability validation
- Risk assessment
- Compliance mapping

## Technical Limitations

### Scanner Limitations
- **False Positives:** Some scanner findings may not be exploitable
- **False Negatives:** Not all vulnerabilities may be detected by automated tools
- **Version Detection:** Banner-based detection may be inaccurate
- **UDP Scanning:** Incomplete due to protocol limitations
- **Authenticated Scans:** No credentials provided (unauthenticated assessment)
- **Deep Packet Inspection:** Not performed
- **Application Logic:** Web app business logic not fully tested
- **Zero-Day Vulnerabilities:** Unknown vulnerabilities not detected

### Assessment Constraints
- **Time-Based:** Assessment conducted over 3 days
- **Single Perspective:** Assessed from single network location
- **Tool Versions:** Results dependent on tool/signature versions
- **Assessment Date:** Findings valid as of [date]
- **No Exploitation:** Vulnerabilities identified but not exploited
- **No Remediation Verification:** Fixes not validated

## Assumptions

### Environmental Assumptions
- **Lab Environment:** System is intentionally vulnerable for training
- **Network Isolation:** Target confirmed isolated from production networks
- **No Production Data:** No sensitive/production data present
- **Acceptable Risk:** Full assessment approved, no services off-limits
- **Snapshot Available:** VM snapshot exists for rollback if needed

### Assessment Assumptions
- **Service Accuracy:** Banner information assumed accurate
- **Current State:** System state unchanged during assessment
- **Default Config:** System running default/unmodified Metasploitable2
- **No Active Defense:** No IDS/IPS/WAF active on target
- **Root Cause:** Vulnerabilities assumed to be configuration/version issues

### Validation Assumptions
- **Exploit Availability:** Public exploits assumed functional
- **Version Information:** Service versions assumed correctly identified
- **False Positive Rate:** Estimated based on cross-scanner validation
- **Remediation Impact:** Proposed fixes assumed feasible

## Known Constraints

### Excluded Testing
1. **Authenticated Web App Testing:**
   - DVWA tested at default security level only
   - Mutillidae tested without authentication
   - No complete OWASP Top 10 testing methodology

2. **Advanced Persistence:**
   - Rootkits not searched for
   - Kernel backdoors not investigated
   - Bootkit analysis not performed

3. **Data Exfiltration:**
   - No actual data extraction performed
   - Database contents not downloaded
   - File shares not accessed beyond enumeration

4. **Lateral Movement:**
   - No multi-host assessment (single target)
   - No domain enumeration
   - No Active Directory testing

## Impact on Findings

### Limitations Impact
- **Coverage:** ~90% coverage estimate (UDP incomplete)
- **Accuracy:** ~95% accuracy estimate (validated critical findings)
- **Completeness:** Some vulnerabilities may remain undetected
- **Exploitability:** Not all findings confirmed exploitable

### Recommendation
- Findings should be validated in context of actual deployment
- Remediation should be prioritized by risk score
- Regular reassessment recommended
- Consider professional penetration test for production systems


### Deliverables:

05-reporting/
├── analysis/
│   ├── vulnerability-master-list.csv
│   ├── risk-scored-vulnerabilities.csv
│   ├── attack-chain-analysis.md
│   ├── attack-surface-map.md
│   ├── vulnerability-chains.md
│   ├── compliance-mapping.md
│   └── prioritization-matrix.md
├── validation/
│   ├── validation-tracker.csv
│   ├── v-001-vsftpd-validation.md
│   ├── v-002-unrealircd-validation.md
│   ├── [additional validations]
│   ├── false-positive-tracker.csv
│   └── evidence/
├── drafts/
│   └── final-report.md (iterative versions)
├── final/
│   ├── metasploitable2-vulnerability-assessment-report.md
│   ├── metasploitable2-vulnerability-assessment-report.pdf
│   ├── executive-summary.pdf (1-pager)
│   ├── remediation-roadmap.xlsx
│   └── technical-findings-detailed.pdf
└── evidence/ (organized screenshots)
    ├── scanning/
    ├── enumeration/
    ├── validation/
    └── charts/
```

---

## Quick Reference Card

### Phase Checklist:
```markdown
✅ Phase 1: Pre-Engagement
   └─ VM config, isolation, reachability verified

✅ Phase 2: Reconnaissance  
   └─ Host discovery, OS fingerprinting completed

✅ Phase 3: Scanning
   └─ Nmap (13 scan types), UDP, NSE scripts, OpenVAS, Nikto

⚪ Phase 4: Enumeration
   └─ 15 services + cross-service analysis

⚪ Phase 5: Analysis
   └─ Master list, risk scoring, attack chains, compliance mapping

⚪ Phase 6: Validation
   └─ Version checks, cross-scanner, exploit verification, PoC testing

⚪ Phase 7: Reporting
   └─ Executive summary → Technical findings → Appendices → PDF
```

### Complete Enumeration Checklist:
```markdown
Core Network Services:
□ FTP (21) - vsftpd backdoor
□ SSH (22) - weak credentials
□ Telnet (23) - cleartext
□ SMTP (25) - user enum
□ DNS (53) - zone transfer
□ HTTP/HTTPS (80/443) - web apps
□ RPC (111) - service list
□ SMB (445) - null session
□ MySQL (3306) - no password
□ PostgreSQL (5432) - default creds
□ NFS (2049) - share access
□ VNC (5900) - no auth
□ IRC (6667) - backdoor
□ Java RMI (1099) - registry
□ Distcc (3632) - RCE
□ X11 (6000) - display
□ Tomcat (8180) - defaults

Web Applications:
□ DVWA
□ Mutillidae
□ phpMyAdmin
□ TWiki
□ Tomcat Manager
□ Apache Axis2

Cross-Service Analysis:
□ Credential reuse matrix
□ Banner collection
□ Information disclosure
□ Attack surface mapping
□ Vulnerability chaining

Advanced Scanning:
□ UDP port scan (top 100)
□ NSE script categories (vuln, safe, discovery, auth, brute)
□ OS fingerprinting
□ Version deep-dive

Analysis & Reporting:
□ Master vulnerability list
□ Risk scoring
□ Attack chain analysis
□ Compliance mapping (OWASP, CIS, MITRE, NIST)
□ Validation tracker
□ Executive summary
□ Technical findings
□ Appendices
```

### Essential Commands:
```markdown
# Variables (set once)
export MS_TARGET=192.168.172.128

# Pre-Engagement
ping -c 4 8.8.8.8                    # Should FAIL (isolation)
ping -c 4 $MS_TARGET                 # Should SUCCEED

# Reconnaissance
nmap -sn $MS_TARGET
nmap -T4 $MS_TARGET

# Scanning - Progressive Depth
nmap -sS -T4 $MS_TARGET -oA results/01-initial
nmap -sV -sC -T4 $MS_TARGET -oA results/02-service
nmap -sS -sV -sC -O -p- -T4 $MS_TARGET -oA results/03-full
nmap -A -T4 $MS_TARGET -oA results/04-aggressive

# Scanning - Advanced
sudo nmap -sU --top-ports 100 $MS_TARGET -oA results/05-udp
nmap --script vuln -p- $MS_TARGET -oA results/06-vuln
nmap --script safe -p- $MS_TARGET -oA results/07-safe

# Web Scanning
nikto -h http://$MS_TARGET -o nikto-results.txt

# Enumeration - Core Services
nc -vn $MS_TARGET 21                 # FTP banner
ssh -v $MS_TARGET                    # SSH version
nc -vn $MS_TARGET 23                 # Telnet
enum4linux -a $MS_TARGET             # SMB full enum
smbclient -L //$MS_TARGET -N         # SMB shares
mysql -h $MS_TARGET -u root          # MySQL (blank password)
showmount -e $MS_TARGET              # NFS shares
dirb http://$MS_TARGET               # Web directories

# Validation
searchsploit <service> <version>     # Exploit search
nc -vn $MS_TARGET $PORT              # Banner grab
curl -I http://$MS_TARGET            # HTTP headers

# Banner Collection
for port in 21 22 23 25 80 3306 5432; do
  echo "=== Port $port ===" >> banners.txt
  nc -vn $MS_TARGET $port < /dev/null >> banners.txt 2>&1
done
```

---

## Methodology Principles
```markdown
1. **Systematic:** Follow phases in order, don't skip steps
2. **Documented:** Screenshot and save everything, maintain evidence chain
3. **Reproducible:** Commands should be repeatable, document all steps
4. **Professional:** Portfolio-quality outputs, proper formatting
5. **Safe:** No exploitation, assessment only (blue team focus)
6. **Comprehensive:** Cover all services, don't skip validation
7. **Clear:** Reports should be understandable to technical and non-technical audiences
8. **Validated:** Cross-check findings, eliminate false positives
9. **Prioritized:** Risk-based approach, focus on critical issues first
10. **Actionable:** Provide specific remediation steps, not just findings
```
---

## Success Metrics
```markdown
### Assessment Quality Indicators:
- ✅ All critical services enumerated
- ✅ 100% of critical findings validated
- ✅ Multiple attack chains documented
- ✅ Cross-scanner validation performed
- ✅ Evidence properly organized and referenced
- ✅ Professional report with executive summary
- ✅ Compliance frameworks mapped
- ✅ Remediation steps specific and actionable
- ✅ Tool configurations documented
- ✅ Limitations clearly stated

### Portfolio Readiness:
- ✅ Demonstrates systematic methodology
- ✅ Shows technical depth (15+ services enumerated)
- ✅ Exhibits risk assessment skills
- ✅ Proves validation capabilities
- ✅ Documents professional reporting
- ✅ Includes compliance knowledge
- ✅ Shows attention to detail
- ✅ Demonstrates communication skills

---
```
**End of Complete Methodology**

<div align="center">
        <p><strong>Methodology generated for educational purposes in an isolated lab environment.</strong></p>
  <p><strong>⭐ If you find my work valuable, please consider starring the projects</strong></p>
    <p><strong>Prepared By: Wilson Njoroge Wanderi</strong></p>
  <p><em>Last Updated: 20th February 2026</em></p>
</div>
