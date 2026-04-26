# Tomcat Enumeration Report – Metasploitable2

> This document provides a detailed technical write‑up of Tomcat enumeration performed during Phase 4 (Enumeration).  
> See the consolidated high-level report here: [Full Technical Report](../technical-report/metasploitable2-full-technical-report.md)

---

## 1. Setup & Configuration

Tooling: nmap, nikto, dirb, curl

Target: $MS_TARGET (192.168.172.128)

Service: Apache Tomcat (Port 8180)

Environment: Isolated host‑only network (Kali → Metasploitable2)


---

## 2. Enumeration Performed

### 2.1. Service Detection (Nmap)

Command:
nmap -sV -p 8180 -oA results/01-tomcat-service-enumeration $MS_TARGET

Result:
8180/tcp open http Apache Tomcat/Coyote JSP engine 1.1


---

### 2.2. Web Enumeration (Nikto)

Command:
nikto -h http://$MS_TARGET:8180

Result Highlights:

Server: Apache-Coyote/1.1
Default Apache Tomcat installation detected
Allowed HTTP Methods: GET, HEAD, POST, PUT, DELETE, TRACE, OPTIONS
WebDAV enabled (/webdav)
/manager/html identified
Default credentials detected (tomcat:tomcat)
Missing X-Frame-Options header
Missing X-Content-Type-Options header
JSESSIONID cookie without HttpOnly flag


---

### 2.3. Directory Bruteforce (DIRB)

Command:
dirb http://$MS_TARGET:8180 /usr/share/wordlists/dirb/common.txt

Result:

/admin/
/host-manager/
/jsp-examples/
/manager/
/servlets-examples/
/tomcat-docs/
/webdav
/WEB-INF/


---

### 2.4. Manager Interface Check

Command:
curl -I http://$MS_TARGET:8180/manager/html

Result:
HTTP/1.1 401 Unauthorized


---

### 2.5. Default Credential Check (Documented Only)

Common default credentials:
tomcat / tomcat
admin / admin
manager / manager


Nikto reported a default account for Tomcat Manager (`tomcat:tomcat`).  
Credentials were documented but not used during enumeration.

---

### 2.6. Axis2 Specific Check

Command:
curl http://$MS_TARGET:8180/axis2/axis2-admin/

Result:
HTTP Status 404 - /axis2/axis2-admin/
Apache Tomcat/5.5


Axis2 is not installed. Tomcat version is confirmed as 5.5.

---

## 3. Results Location

Enumeration outputs:

results/01-tomcat-service-enumeration.nmap
results/01-tomcat-service-enumeration.gnmap
results/01-tomcat-service-enumeration.xml
results/02-web-enumeration.txt
results/03-directory-bruteforce.txt
results/04-manager-interface-check.txt
results/06-axis2-specific-check.txt


Screenshots:

screenshots/01-tomcat-service-enumeration.png
screenshots/02-web-enumeration.png
screenshots/03-directory-bruteforce.png
screenshots/04-manager-interface-check.png
screenshots/05-tomcat-admin-interface-check.png
screenshots/06-axis2-specific-check.png


---

## 4. Key Observations

Apache Tomcat is exposed on port 8180
Version disclosure confirms Apache Tomcat/5.5
Default installation artifacts are present
Manager and Host-Manager interfaces are accessible
WebDAV is enabled
Dangerous HTTP methods (PUT, DELETE, TRACE) are allowed
Default credentials identified by Nikto
Axis2 is not installed


---

## 5. Security Assessment

The Tomcat service is misconfigured and insecure.
Apache Tomcat/5.5 is outdated and end-of-life.
The presence of exposed administrative interfaces, enabled WebDAV,
dangerous HTTP methods, and identified default credentials
significantly increase the attack surface.
This configuration presents a high risk of remote code execution
through the Tomcat Manager application or file upload mechanisms.


---

[Back to Enumeration](../)

---

<div align="center">
	<p><strong>Report generated for educational purposes in an isolated lab environment.</strong></p>
  <p><strong>⭐ If you find my work valuable, please consider starring the projects</strong></p>
    <p><strong>Prepared By: Wilson Njoroge Wanderi</strong></p>
  <p><em>Last Updated: 19th February 2026</em></p>
</div>
