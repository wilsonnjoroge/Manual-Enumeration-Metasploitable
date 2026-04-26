# RPC / NFS Enumeration Report – Metasploitable2

> This document provides a detailed technical write‑up of RPC (Remote Procedure Call) and NFS (Network File System) enumeration performed during Phase 4 (Enumeration).  
> See the consolidated high-level report here: [Full Technical Report](./04-reporting/technical-report/metasploitable2-full-technical-report.md)

---

## 1. Setup & Configuration

Tooling: nmap, rpcinfo, showmount

Target: $MS_TARGET (192.168.172.128)

Services: RPC (Port 111), NFS (Port 2049)

Environment: Isolated host‑only network (Kali → Metasploitable2)

---

## 2. Enumeration Performed

### 2.1. Targeted Port Scan (RPC/NFS)

Command:

nmap -sV -sC -p 111,2049 -oA results/01-rpc-nfs-port-scan $MS_TARGET


Result:

111/tcp open rpcbind 2 (RPC #100000)
2049/tcp closed nfs


The scan confirmed that port 111 is open and running **rpcbind (Remote Procedure Call bind service)**.  
Port 2049 (Network File System) was identified as **closed**.

---

### 2.2. RPC Service Enumeration

Command:

rpcinfo -p $MS_TARGET

Result:

program 100000 → portmapper (rpcbind)


RPC enumeration revealed that only the portmapper (rpcbind) service is registered.  
No additional Remote Procedure Call services such as Network File System (program 100003) were identified.

---

### 2.3. NFS Share Enumeration

Command:

showmount -e $MS_TARGET

Result:

clnt_create: RPC: Program not registered

The Network File System mount daemon is not registered with rpcbind.  
No exported shares were identified.

---

### 2.4. NFS Script Verification (Nmap)

Command:

nmap --script nfs-showmount -p 111,2049 -oA results/03-nfs-script-verification $MS_TARGET

Result:

No NFS script output returned

Nmap scripting confirmed that Network File System services are not accessible on the target.

---

## 3. Results Location

Enumeration outputs:

- results/01-rpc-nfs-port-scan.nmap
- results/01-rpc-nfs-port-scan.gnmap
- results/01-rpc-nfs-port-scan.xml
- results/02-rpcinfo-output.txt
- results/03-nfs-shares.txt
- results/03-nfs-script-verification.nmap
- results/03-nfs-script-verification.gnmap
- results/03-nfs-script-verification.xml

---

## 4. Key Observations

- RPC bind service is exposed on port 111
- No Network File System service is running
- No RPC programs are registered beyond portmapper
- No file shares are exported
- Remote mounting is not possible

---

## 5. Security Assessment

The rpcbind service is exposed on port 111; however, no additional Remote Procedure Call services are registered.  
Network File System is not running, and no shares are available for remote mounting.

While rpcbind exposure slightly increases reconnaissance surface, no exploitable NFS misconfiguration was identified during enumeration.  
Overall risk level: **Low**.

---

[Back to Enumeration](../)

---

<div align="center">
	<p><strong>Report generated for educational purposes in an isolated lab environment.</strong></p>
  <p><strong>⭐ If you find my work valuable, please consider starring the projects</strong></p>
    <p><strong>Prepared By: Wilson Njoroge Wanderi</strong></p>
  <p><em>Last Updated: 19th February 2026</em></p>
</div>
