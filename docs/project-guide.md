# LinuxSysAdminLab — Project Guide

**Owner:** Sampath Kumar Peddagolla  
**Started:** October 25, 2026  
**Status:** Core lab exercises complete; source files and dashboard export verified, documentation and repository package prepared. GitHub publication has not been performed.

**Last updated:** October 28, 2026. This guide records 40 milestones, including artifact verification. Early pending labels describe the state at that historical step; the final progress and limitations sections give the current outcome.

## Project overview and results

This project combines a Linux web server, access controls, recoverable backups, system monitoring and a separate Ansible management VM. The files were collected from the actual lab and checked against the supplied results. The lab is a learning environment on one Windows laptop, not an independently hosted production service.

| Area | Demonstrated result |
|---|---|
| Administration | Ubuntu installation/updates, SSH keys, UFW, users/groups and tested directory access |
| Web service | Custom Nginx page, request logs, manual recovery and Ansible correction of a stopped service |
| Data recovery | Local archive, extracted-file verification, deleted-file restoration, matching hashes and preserved usable access |
| Backup scheduling | Daily 02:00 Chicago timer enabled; manual service success logged; actual daily calendar-run success unobserved |
| Monitoring | Node Exporter -> Prometheus -> Grafana; RAM/CPU/root-disk panels and exporter outage/recovery |
| Automation | MGMT01 controls LNX01; inventory/ping/root elevation; first playbook changed=1, repeat changed=0 |
| Deliverables | Full Markdown/PDF, actual scripts/configurations, original dashboard export, portable derivative and GitHub-ready ZIP |

### Current topology

| Node | Role | Current address / endpoint |
|---|---|---|
| Windows host | VirtualBox, SSH client and browsers | Loopback SSH 2222, HTTP 8080; SSH browser tunnels 9090/3000 |
| MGMT01 | Ansible control node | 10.20.20.4/24, DHCP |
| LNX01 (hostname lnx01) | Web server, local backup and monitoring | 10.20.20.3/24, DHCP |
| LinuxLab | Shared VirtualBox NAT Network | 10.20.20.0/24, gateway 10.20.20.1, DHCP enabled |

MGMT01 reaches LNX01 directly on SSH port 22. Windows reaches the guest through VirtualBox forwarding or SSH tunnels. All observed addresses are DHCP leases; no static reservation was configured. Monitoring runs on LNX01 itself, so it does not provide independent monitoring of a total LNX01 failure.

### How to use this guide

Each milestone records where commands ran, their meaning, purpose and observed result. Screenshot evidence, operator confirmations and proposed-but-unverified actions are distinguished. Read historical sections in order to understand how the final state was reached. The repository operations notes are the shorter reference for reconnecting and running existing components.

Long commands may wrap in the PDF. Use the original scripts or the Markdown version for copying; a visual line break in the PDF is not necessarily a shell newline. No commands in the PDF were executed against the user's VMs during artifact preparation.

### Scope at completion

No complete unattended deployment, TLS, alert notifications, automatic external backup copy or retention was implemented. The existing backup scope predates the monitoring/automation additions. The later LNX01 login banner reported 19 available updates; the final checklist does not claim those were applied. Windows backup storage and VM snapshots remain on the same physical laptop. Future hardening is documented without presenting it as completed work.

## Project goal

Build and administer a Linux web server, control access, inspect logs, monitor system metrics, schedule backups, demonstrate file recovery, and automate repeatable configuration with Ansible.

The completed Windows lab is documented separately at:
https://github.com/Sampath-2004/SysAdminLab

## Documentation rules

Record meaningful configuration changes, commands, their execution context, the meaning of their arguments, their purpose, and actual results. Distinguish confirmed results from planned settings. Keep passwords, private keys, and other credentials out of this guide and the future public repository.

## Milestone 1 — Prepare the first Linux virtual machine

**Evidence:** The user confirmed completion of the VM creation instructions. No configuration screenshot has been supplied yet. At this milestone, Ubuntu installation was still pending.

### Installation image

The user already has `ubuntu-24.04.2-desktop-amd64.iso`. This image was accepted for the lab. The initially selected operating system was Ubuntu 24.04 LTS Desktop; the earlier proposal to download Ubuntu Server 26.04 LTS was replaced by this choice.

Ubuntu Desktop provides a graphical interface. Administration will also use terminal commands and SSH. Package updates will be installed after the operating system is installed.

### Configuration supplied for creation

| Setting | Supplied value |
|---|---|
| VM name | LNX01 |
| VM folder location | C:\LinuxSysAdminLab |
| Suggested ISO folder | C:\LinuxSysAdminLab\ISO |
| Image | ubuntu-24.04.2-desktop-amd64.iso |
| Guest OS | Linux / Ubuntu, 64-bit |
| Memory | 4096 MB |
| Virtual CPUs | 2 |
| System disk | 40 GB, dynamically allocated |
| Installation method | Manual; unattended installation disabled |

These are the instructed values covered by the completion report; they have not been independently inspected.

### Purpose

The VM provides a separate Linux operating system for the exercises. A dynamically allocated virtual disk grows as data is written, up to its configured capacity. The desktop interface helps with initial navigation while the lab develops terminal administration skills.

## Milestone 2 — Create and attach the Linux lab network

**Evidence:** The user confirmed completion of the network creation and Adapter 1 instructions. At this stage the Network Manager settings had not been inspected directly; guest addressing and routing were subsequently verified in milestone 4. A later Network Manager screenshot confirms the LinuxLab prefix and DHCP setting, as recorded in milestone 8.

| Network setting | Configured value, by user report |
|---|---|
| Network type | VirtualBox NAT Network |
| Name | LinuxLab |
| IPv4 network prefix | 10.20.20.0/24 |
| Network enabled | Yes |
| Built-in DHCP | Enabled for initial installation |
| IPv6 support | Disabled for this lab network |

LNX01 Adapter 1 is reported enabled and attached to NAT Network `LinuxLab`, with Cable Connected enabled.

### Purpose

A shared NAT Network provides outbound access and permits communication between attached lab VMs. It will also support a later management VM. The built-in VirtualBox DHCP service will provide the initial guest network settings, without depending on the Windows lab's DC01.

This is a new network. No deletion or modification of the existing Windows lab network is required. No fixed guest address has been assigned or verified yet.

### GUI procedure followed

1. Keep LNX01 powered off.
2. In VirtualBox, open File > Tools > Network Manager.
3. Select NAT Networks and create a network.
4. Open its properties and apply the planned values above.
5. Open LNX01 > Settings > Network > Adapter 1.
6. Select NAT Network, choose LinuxLab, and enable Cable Connected.
7. Save the settings. Keep the VM powered off until the installation preparation is complete.

## Milestone 3 — Install Ubuntu Desktop

**Evidence:** The user supplied a screenshot of the Ubuntu Disk setup screen and subsequently replied "done" after the remaining installation instructions. Installation completion is recorded as a user report. The subsequent login and terminal checks are documented in milestone 4.

The screenshot showed Erase disk and install Ubuntu selected, with Advanced features set to None selected. The screen did not display the target disk model or capacity. The user was instructed to check the final review for the new VirtualBox disk, approximately 40 GB (about 43 GB when displayed in decimal units), before clicking Install.

### Account and location instructions

| Field | Instructed value |
|---|---|
| Your name | Sampath Kumar Peddagolla |
| Computer name / hostname | lnx01 |
| Username | sampath |
| Password | Chosen privately by the user; not recorded |
| Password required at login | Enabled |
| Time zone / location | Chicago, America/Chicago |

The terminal prompt subsequently confirms username sampath and hostname lnx01. The full name, time zone, and login-password requirement have not been independently inspected. The VM name in VirtualBox is LNX01; the Linux hostname is lowercase lnx01.

### Display preparation

Before starting the installer, the supplied display settings were VMSVGA, 128 MB video memory, and 3D acceleration disabled. No display-settings screenshot has been provided. The installer screenshot confirms that the live Ubuntu environment booted.

## Milestone 4 — First login and network verification

**Evidence:** The user reported a successful login and supplied a terminal screenshot on October 27, 2026. The screenshot visibly shows the results of cat /etc/os-release, ip -br address, and ip route.

| Item | Verified result |
|---|---|
| Terminal account and hostname | sampath@lnx01 |
| Operating system | Ubuntu 24.04.2 LTS, Noble Numbat |
| VERSION_ID | 24.04 |
| Ethernet interface | enp0s3, UP |
| Current IPv4 address | 10.20.20.3/24 |
| Local subnet | 10.20.20.0/24 |
| Default gateway | 10.20.20.1 via enp0s3 |
| Default route details | proto dhcp, source 10.20.20.3, metric 100 |

The address is a current DHCP address, not a configured static address. The screenshot also shows the loopback interface and an IPv6 link-local address on enp0s3. Disabling IPv6 support on the VirtualBox NAT Network did not disable IPv6 link-local addressing inside Ubuntu.

The standalone hostname command output is not visible in the screenshot; the shell prompt identifies the hostname as lnx01. The IP and route output confirms local network configuration. At this stage Internet access and DNS resolution had not been independently tested. Later package installations show repository access was usable, but no dedicated DNS or Internet diagnostic test was recorded.

The user earlier reported difficulty entering the login password and later confirmed a successful login. The exact cause and corrective action were not confirmed; no password reset or reinstallation was reported.

## Historical update instructions

The following command register was first written before package updates. Its original pending labels are historical: milestone 5 records completion by user report. Current progress is summarized at the end of this guide.

## Command register

### Initial identity and network checks

**Run on:** LNX01, inside Ubuntu Terminal, signed in as sampath.  
**Privileges:** Normal user; no sudo required.  
**Purpose:** Confirm the installed system identity and inspect the LinuxLab network before installing updates or server services.  
**Effect:** Display information; no configuration changes.

~~~bash
hostname
cat /etc/os-release
ip -br address
ip route
~~~

| Command | Meaning and purpose | Actual evidence |
|---|---|---|
| hostname | With no arguments, displays the system hostname. | Standalone output not shown; the prompt sampath@lnx01 confirms the session hostname. |
| cat /etc/os-release | cat prints the specified file's contents. The file contains operating-system identification data. | Screenshot: Ubuntu 24.04.2 LTS; VERSION_ID=24.04; Noble Numbat. |
| ip -br address | ip is the Linux networking utility; -br means brief; address lists interface addresses. | Screenshot: enp0s3 is UP with 10.20.20.3/24. lo is the loopback interface; an IPv6 link-local address is also visible. |
| ip route | Displays the routing table through the route object's default display operation. | Screenshot: default via 10.20.20.1 dev enp0s3 proto dhcp src 10.20.20.3 metric 100; connected route for 10.20.20.0/24. |

### Refresh package metadata — supplied; results pending

**Run on:** LNX01, Ubuntu Terminal as sampath.  
**Privileges:** sudo runs the command with administrator/root privileges.

~~~bash
sudo apt update
~~~

- apt is Ubuntu's command-line package management tool.
- update downloads current package-list metadata from configured repositories.
- This writes local package metadata; it does not install package upgrades.
- Purpose: obtain current available versions and identify repository connectivity or DNS errors before upgrading.
- Enter the current Ubuntu user's password when sudo requests it. Terminal password entry displays no characters or dots; press Enter after typing.
- Expected: repository metadata refresh without fetch or resolution errors.
- Actual result: pending.

### Upgrade installed packages — supplied; results pending

**Prerequisite:** The preceding package-index refresh completed successfully.  
**Run on:** LNX01, Ubuntu Terminal as sampath, using sudo.

~~~bash
sudo apt upgrade
~~~

- upgrade downloads and installs available upgrades to installed packages, resolving supported dependencies.
- Purpose: apply available security and bug-fix updates to the fresh installation.
- This changes installed software. Review the proposed changes, then enter Y and press Enter when asked.
- Wait for completion and return of the shell prompt before rebooting.
- Actual result, upgraded-package count, and any held-back packages: pending.

### Reboot after the upgrade — supplied; results pending

**Prerequisite:** The upgrade command has completed successfully.  
**Run on:** LNX01, Ubuntu Terminal as sampath, using sudo.

~~~bash
sudo reboot
~~~

- reboot requests a normal restart of the Ubuntu guest.
- Purpose: boot into an updated kernel, if installed, and restart system components with their updated versions.
- Effect: the VM restarts and the current session ends.
- Expected: return to Ubuntu's login screen and successful login.
- Actual result: pending.

## Abbreviations

| Term | Meaning and purpose |
|---|---|
| VM | Virtual Machine — a guest computer running inside VirtualBox |
| OS | Operating System — Ubuntu in this project |
| ISO | A disk-image file used as installation media |
| AMD64 | The x86-64 architecture used by compatible 64-bit Intel and AMD processors |
| LTS | Long-Term Support — an Ubuntu release series with an extended maintenance period |
| GUI | Graphical User Interface — windows, menus, and desktop controls |
| RAM | Random Access Memory — memory assigned to a running VM |
| CPU / vCPU | Central Processing Unit / virtual CPU — processing resources presented to the guest |
| NAT | Network Address Translation — enables outbound connections from a private VM network |
| DHCP | Dynamic Host Configuration Protocol — automatically supplies IP network settings |
| IP / IPv4 | Internet Protocol / version 4 — addressing and routing on the lab network |
| SSH | Secure Shell — encrypted remote terminal access |
| VDI | Virtual Disk Image — VirtualBox's virtual disk file format |
| APT | Advanced Packaging Tool — Ubuntu's package management system, accessed here with apt |
| sudo | Runs a command with another user's privileges; by default the administrator/root user |
| Root | The Linux administrator account with system-wide privileges |
| DNS | Domain Name System — resolves repository and other hostnames into IP addresses |

## Official references

- Ubuntu support lifecycle: https://ubuntu.com/about/release-cycle
- Ubuntu Desktop installation: https://ubuntu.com/tutorials/install-ubuntu-desktop
- VirtualBox VM creation: https://docs.oracle.com/en/virtualization/virtualbox/7.2/user/create-vm.html
- VirtualBox networking: https://docs.oracle.com/en/virtualization/virtualbox/7.2/user/networkingdetails.html
- Ansible introduction: https://docs.ansible.com/projects/ansible/latest/getting_started/index.html
- Prometheus Node Exporter: https://prometheus.io/docs/guides/node-exporter/
- Grafana and Prometheus: https://grafana.com/docs/grafana/latest/fundamentals/getting-started/first-dashboards/get-started-grafana-prometheus/

- Operating-system identification file: https://www.freedesktop.org/software/systemd/man/latest/os-release.html
- ip command and brief output: https://manpages.debian.org/bookworm/iproute2/ip.8.en.html

- Ubuntu package management: https://documentation.ubuntu.com/server/how-to/software/package-management/


## Milestone 5 — Package updates, restart, and baseline snapshot

**Evidence:** The user reported completion of package updates and subsequent reboot/login. The exact package counts and full APT output were not provided.

The update and reboot commands in the initial register below are now complete by user report, superseding their original “results pending” labels. A later release upgrade is recorded separately in milestone 7; ordinary `apt upgrade` alone did not explain that release change.

The user reported creating the powered-off snapshot **LNX01-Updated-Baseline**. The supplied description was “Ubuntu installed, initial network verified, and system updates completed.” Its exact creation time and stored OS state were not independently inspected. It preceded the later confirmed 26.04.1 installation.

| Command / action | Where applied | Meaning, purpose, and result |
|---|---|---|
| `sudo apt update` | LNX01 Ubuntu Terminal | Refresh package metadata; completion reported without supplied full output. |
| `sudo apt upgrade` | LNX01 Ubuntu Terminal | Apply available installed-package updates; completion reported. |
| `apt list --upgradable` | LNX01 Ubuntu Terminal | List remaining available upgrades; instructed during follow-up, exact output not supplied. |
| `sudo reboot` | LNX01 Ubuntu Terminal | Restart guest and load updated components; subsequent login reported. |
| `sudo poweroff` | LNX01 Ubuntu Terminal | Shut down safely before the baseline snapshot; snapshot completion reported. |
| Take snapshot in VirtualBox | Windows VirtualBox Manager, LNX01 Snapshots | Recovery point depends on the underlying VM disks; it is not a separate off-host backup. |

## Milestone 6 — Install OpenSSH and verify local authentication

**Evidence:** Installation and service-status screenshot; local connection prompt screenshot; successful login initially reported and later screenshot-confirmed after the release upgrade.

**Run on:** LNX01 Ubuntu Terminal as sampath, using sudo only where shown.

~~~bash
sudo apt install openssh-server
systemctl status ssh --no-pager
systemctl status ssh.socket --no-pager
ssh sampath@localhost
exit
~~~

| Command | Meaning and purpose | Observed result |
|---|---|---|
| `sudo apt install openssh-server` | Install the SSH server with administrator privileges. | Installation completed; host configuration created. |
| `systemctl status ssh --no-pager` | Inspect the SSH service without an interactive pager. | Initially inactive (dead), with ssh.socket shown as its active trigger. This was not treated as an installation failure. |
| `systemctl status ssh.socket --no-pager` | Check the socket that listens and starts SSH on demand. | User confirmed the expected active/listening result. |
| `ssh sampath@localhost` | Connect as sampath to the same VM; localhost resolved to 127.0.0.1 in the prompt. | First host key accepted; password login reported successful. |
| `exit` | End the current SSH shell. | Returns to its parent terminal; context matters because exit can also end a switched-user shell. |

Ubuntu's socket activation allows the SSH daemon to start when a connection arrives. The first-time host identity prompt was expected. The user accepted the key after connecting to the known local VM. No private key or password is stored here.

## Milestone 7 — Upgrade the Ubuntu release and recheck SSH

**Evidence:** Screenshot of the release upgrader titled “Upgrading Ubuntu to version 26.04 LTS,” followed by a post-restart operating-system screenshot and an SSH login screenshot.

This was a full release upgrade from the initially installed 24.04.2 LTS, beyond the planned routine package updates. The command or UI action that initiated it was not supplied. The upgrader offered to remove 170 obsolete packages; removal and restart were instructed. The final system successfully booted, but the exact removed-package list was not captured.

~~~bash
cat /etc/os-release
ssh sampath@localhost
exit
ip -br address
~~~

**Where:** LNX01 Ubuntu Terminal.

- `cat /etc/os-release`: confirmed **Ubuntu 26.04.1 LTS (Resolute Raccoon)**, VERSION_ID=26.04 and codename resolute.
- `ssh sampath@localhost`: screenshot confirms successful password authentication after the upgrade.
- The SSH welcome banner shows **GNU/Linux 7.0.0-38-generic x86_64**.
- `exit`: close the local SSH test session.
- `ip -br address`: subsequent screenshot confirms **enp0s3 UP, 10.20.20.3/24**.
- The displayed welcome banner reported zero immediately available updates at the time captured; this is a point-in-time observation.

The original 24.04.2 installation remains part of the project's history; **26.04.1 is the current screenshot-verified release**.

## Milestone 8 — Access Ubuntu from Windows through NAT port forwarding

**Evidence:** Network Manager screenshot confirms LinuxLab prefix 10.20.20.0/24 and enabled DHCP. Windows PowerShell screenshot confirms reaching the SSH host-key prompt; successful remote login was reported. Later commands and a new-login test confirm ongoing access.

In VirtualBox Network Manager, select **LinuxLab**, not the separate Windows **SysAdminLab** network. The following SSH forwarding rule was supplied and is supported by the successful connection. Its configuration row was not independently screenshot-inspected.

| Rule | Protocol | Host IP | Host port | Guest IP | Guest port |
|---|---|---|---|---|---|
| LNX01-SSH | TCP | 127.0.0.1 | 2222 | 10.20.20.3 | 22 |

**Run on Windows PowerShell, before connecting:**

~~~powershell
ssh -p 2222 sampath@127.0.0.1
~~~

- `ssh` initiates an encrypted remote terminal session.
- `-p 2222` selects Windows's forwarded port.
- `sampath` is the guest login account.
- `127.0.0.1` is Windows loopback in this execution context.
- VirtualBox forwards that connection to the guest's SSH port 22.
- Host loopback binding limits this forwarding endpoint to the Windows computer.
- The host key fingerprint displayed in Windows matched the earlier local Ubuntu SSH prompt.
- After authentication, the prompt `sampath@lnx01:~$` identifies a Linux shell: commands entered there run on LNX01, even though the window is PowerShell/Windows Terminal.

**Troubleshooting:** The user first ran this forwarded-port command inside Ubuntu, where 127.0.0.1 means Ubuntu itself. It returned connection refused on port 2222. Repeating it from Windows reached SSH successfully. This was an execution-context error, not evidence that SSH was broken.

**Addressing limit:** 10.20.20.3 is still DHCP-assigned. The rule targets that exact address and may require adjustment if the guest lease changes. A static address or reservation has not been configured.

## Milestone 9 — Configure UFW and verify a fresh SSH connection

**Evidence:** Before/after firewall screenshots and user confirmation of successful login from a second Windows PowerShell window.

**Run on:** LNX01 through the connected sampath SSH session.

~~~bash
sudo ufw status verbose
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp
sudo ufw enable
sudo ufw status verbose
~~~

| Command | Meaning and purpose |
|---|---|
| `sudo ufw status verbose` | Inspect Uncomplicated Firewall status, default policies, and allowed traffic. |
| `sudo ufw default deny incoming` | Deny incoming traffic unless an explicit allow rule matches. |
| `sudo ufw default allow outgoing` | Permit outbound connections, such as package downloads. |
| `sudo ufw allow 22/tcp` | Permit TCP connections to SSH's guest port before enabling the firewall. The guest rule uses 22, not Windows port 2222. |
| `sudo ufw enable` | Activate the firewall and enable it at boot; the user answered y to the SSH-disruption warning after the allow rule existed. |

Screenshot-verified result: **active**, logging on (low), deny incoming, allow outgoing, routed traffic disabled, port 22/tcp allowed for IPv4 and IPv6. The IPv6 rule does not prove IPv6 connectivity through the NAT network.

The first session was kept open while the user opened a **second Windows PowerShell window** and repeated `ssh -p 2222 sampath@127.0.0.1`. The user confirmed a new successful login, demonstrating that the active firewall permits fresh SSH connections.

## Milestone 10 — Create a standard account and a supplementary group

**Evidence:** Screenshots confirm account creation, IDs, switched-user login, home directory, and added group.

**Run on:** LNX01 as sampath through SSH; enter the labuser password only at the interactive prompts.

~~~bash
sudo adduser labuser
id labuser
su - labuser
whoami
pwd
exit
sudo groupadd labteam
sudo usermod -aG labteam labuser
id labuser
~~~

| Command | Meaning, purpose, and result |
|---|---|
| `sudo adduser labuser` | Create account and home directory; user chose password privately and skipped optional contact fields. |
| `id labuser` | Display UID, primary GID and memberships. Initial result: uid=1001, gid=1001(labuser), groups labuser and users(100). |
| `su - labuser` | Switch identity and load the target login environment; a fresh login also picks up changed group memberships. |
| `whoami` | Display effective username; screenshot: labuser. |
| `pwd` | Print working directory; screenshot: /home/labuser. |
| `exit` | Leave the labuser shell and return to sampath. |
| `sudo groupadd labteam` | Create a supplementary access-control group. |
| `sudo usermod -aG labteam labuser` | Append (-a) the supplementary group (-G) while preserving existing group memberships. |
| `id labuser` | Confirm added group; screenshot includes 1002(labteam). |

The labuser account was not added to sudo. Group listing confirms its memberships; an actual sudo-denial test has not been performed.

## Milestone 11 — Configure and test group-controlled directory access

**Evidence:** Directory-permission screenshot, member file creation/read screenshot, and nonmember denial screenshot.

**Run as sampath on LNX01 through SSH:**

~~~bash
sudo mkdir -p /srv/labshare
sudo chown root:labteam /srv/labshare
sudo chmod 2770 /srv/labshare
ls -ld /srv/labshare
~~~

- `mkdir -p`: create the directory and any missing parents.
- `chown root:labteam`: set root as owner and labteam as owning group.
- `chmod 2770`: set the setgid bit (2), full directory access for owner (7) and group (7), and no access for others (0).
- Directory read means list names, write permits changes to directory entries, and execute permits traversal/access.
- Setgid causes new entries to inherit the directory group; it does **not** alone guarantee group-write permissions on every new file.
- `ls -ld`: long listing of the directory itself.
- Verified result: **drwxrws--- root labteam /srv/labshare**.

**Member test, after a fresh switched-user login:**

~~~bash
su - labuser
echo "Created by labuser for the Linux administration lab." > /srv/labshare/member-test.txt
cat /srv/labshare/member-test.txt
ls -l /srv/labshare/member-test.txt
exit
~~~

- `echo` outputs the test text; `>` writes it to the named file (and overwrites it if it already exists).
- `cat` reads the file; `ls -l` displays file ownership and permissions.
- Screenshot confirms successful create/read and **labuser:labteam** ownership.
- Actual file permissions were **-rw-rw-r--**, showing group-write access in this observed creation context. Although the file's “other” read bit exists, the parent directory denies nonmembers traversal.
- `exit` returns to sampath.

**Nonmember test as sampath, deliberately without sudo:**

~~~bash
id
cat /srv/labshare/member-test.txt
touch /srv/labshare/nonmember-test.txt
~~~

- `id` displays current session identity/groups; screenshot confirms labteam absent.
- `cat` attempts to read; **Permission denied**.
- `touch` attempts file creation/timestamp update; **Permission denied**.
- Ordinary commands use sampath's normal privileges even though it can elevate using sudo.
- Both allowed-member and denied-nonmember behavior have been demonstrated. This is a local Linux directory; no SMB/NFS network file-sharing service has been configured.

## Milestone 12 — Install Nginx and serve a custom webpage to Windows

**Evidence:** Nginx service-status screenshot; HTTP header output screenshot; default-page and custom-page screenshots. Browser address bars are cropped, so the configured URL is the instructed address supported by the reported workflow rather than independently visible in those screenshots.

**Run on LNX01 as sampath through SSH:**

~~~bash
sudo apt install nginx
systemctl status nginx --no-pager
curl -I http://localhost
~~~

| Command | Meaning, purpose, and result |
|---|---|
| `sudo apt install nginx` | Install the web server; subsequent status confirms success. |
| `systemctl status nginx --no-pager` | Check service state; screenshot shows active (running) and enabled for boot. |
| `curl -I http://localhost` | Make an HTTP HEAD request to the local web server, displaying headers; screenshot: HTTP/1.1 200 OK, nginx/1.28.3 (Ubuntu), Content-Type text/html. |
| `sudo apt install curl` | Supplied if curl was absent. The later screenshot shows package processing and successful curl execution; its full installation command/output was not captured. |
| `sudo ufw allow 80/tcp` | Supplied to allow guest HTTP connections; later browser access supports functioning HTTP access, though a post-rule UFW listing was not supplied. |

The HTTP NAT rule was supplied for **LinuxLab → Port Forwarding → IPv4**:

| Rule | Protocol | Host IP | Host port | Guest IP | Guest port |
|---|---|---|---|---|---|
| LNX01-HTTP | TCP | 127.0.0.1 | 8080 | 10.20.20.3 | 80 |

The user followed the instructions to browse **http://127.0.0.1:8080 on Windows**, then supplied the default “Welcome to nginx!” page. SSH rule remains required separately.

### Create the homepage and recover from an unsaved editor session

The initial edit was attempted with:

~~~bash
sudo nano /var/www/html/index.html
~~~

Nano opens the target file; Ctrl+O then Enter was supplied for save and Ctrl+X for exit. The user reported the shortcuts did not work and closed the terminal. On reconnecting from Windows, this check returned “No such file or directory”:

~~~bash
cat /var/www/html/index.html
~~~

The custom file had not been saved. SSH was re-established using the existing Windows command. The following alternative was supplied **inside the authenticated Linux SSH shell**, not at an unconnected Windows prompt:

~~~bash
sudo tee /var/www/html/index.html <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Sampath's Linux Lab</title>
</head>
<body>
  <h1>Linux Administration Lab</h1>
  <p>Administrator: Sampath</p>
  <p>Server: LNX01 | Ubuntu | Nginx</p>
  <p>This website is hosted on my Linux virtual machine.</p>
</body>
</html>
EOF
~~~

- `sudo tee` writes the file as administrator and echoes its input to the terminal.
- `<<'EOF'` is a quoted here-document: input continues until EOF alone on its own line, without shell expansion of the content.
- The command replaces index.html contents if a file already exists.
- /var/www/html is this installed site's document root.
- index.html is served as the homepage by the current default configuration.
- HTML structures the webpage; this static file change does not require an Nginx restart.

The subsequent screenshot confirms the custom **Linux Administration Lab** page with Sampath, LNX01, Ubuntu and Nginx text.

## Milestone 13 — Inspect actual web requests in the access log

**Evidence:** Screenshot of the final access-log entries.

**Run on:** LNX01 as sampath through SSH.

~~~bash
sudo tail -n 10 /var/log/nginx/access.log
~~~

- `tail` displays the end of a file; `-n 10` selects the latest ten lines.
- The access log records requests Nginx receives, useful for confirming traffic and diagnosing responses.
- Actual entries include **HEAD / → 200** from the curl check and **GET / → 200** from the Windows browser.
- **304** responses allow the browser to reuse cached content; they are not failures.
- **GET /favicon.ico → 404** indicates no tab icon at that path, which does not prevent the homepage working.
- Windows browser requests appear with source **10.20.20.1**, the NAT gateway, in these observed log entries.
- A successful response and access log demonstrate delivery; they do not prove TLS, public internet hosting, or monitoring has been configured.

## Milestone 14 — Controlled web outage and service recovery

**Where:** LNX01, sampath's authenticated SSH session from Windows.

**Evidence:** A screenshot shows curl error 7 (“Failed to connect to localhost port 80”). A subsequent screenshot shows `sudo systemctl start nginx` followed by HTTP/1.1 200 OK, and a separate browser screenshot shows the custom lab page restored.

~~~bash
sudo systemctl stop nginx
curl -I --max-time 5 http://localhost
systemctl status nginx --no-pager
sudo journalctl -u nginx -n 15 --no-pager
sudo systemctl start nginx
curl -I --max-time 5 http://localhost
~~~

| Command | Meaning, purpose, and evidence |
|---|---|
| `sudo systemctl stop nginx` | Supplied to deliberately stop the web service; its execution line is not captured. The subsequent request failure is directly verified. |
| `curl -I --max-time 5 http://localhost` | Request headers with a five-second total limit. Before recovery: curl error 7, could not connect on port 80. |
| `systemctl status nginx --no-pager` | Supplied to inspect the unit state. Expected inactive after a successful stop, but no output was provided for this diagnostic step. |
| `sudo journalctl -u nginx -n 15 --no-pager` | Supplied to inspect the latest 15 journal entries for the nginx unit without a pager. Execution and output were not captured; no claim is made that stopped-service messages were inspected. |
| `sudo systemctl start nginx` | Screenshot confirms the recovery command completed without a displayed error. |
| Repeated curl check | Screenshot confirms HTTP/1.1 200 OK, Server nginx/1.28.3 (Ubuntu), Content-Type text/html and Content-Length 302 after restart. |
| Refresh Windows browser | Screenshot confirms “Linux Administration Lab” and the custom text display again. |

**Outcome:** Controlled service interruption and restoration demonstrated by failed request → start service → successful local HTTP response and displayed webpage. This was a planned service-stop exercise, not a crash or configuration-failure investigation. No measured recovery duration was recorded. The diagnostic status/journal commands remain supplied-but-unverified.

## Milestone 15 — Create and inspect the first backup archive

**Where:** LNX01, authenticated sampath SSH session; sudo elevates the specified commands to root.

**Evidence:** Screenshot confirms the backup directory exists with root ownership. Later screenshot shows exit code 0 and the archive listing, including the custom homepage, Nginx configuration and shared test file. The archive-creation and chmod command lines were supplied but are not visible in that output crop.

~~~bash
sudo mkdir -p /var/backups/linuxsysadminlab
sudo ls -ld /var/backups/linuxsysadminlab
sudo chmod 700 /var/backups/linuxsysadminlab
sudo tar -czpf /var/backups/linuxsysadminlab/baseline.tar.gz -C / var/www/html etc/nginx srv/labshare
echo $?
sudo tar -tzf /var/backups/linuxsysadminlab/baseline.tar.gz
~~~

| Command / option | Meaning and purpose |
|---|---|
| mkdir -p | Create the backup directory, including any missing parents; safe to repeat for an existing directory. |
| ls -ld | Inspect directory ownership and permissions; initial screenshot shows root:root, mode drwxr-xr-x. |
| chmod 700 | Supplied to limit directory access to root. No later directory-permission listing has independently verified this change. |
| tar -c | Create an archive of the three specified source trees. |
| -z | Use gzip compression. |
| -p | Preserve permissions when extracting; tar records file mode metadata during creation regardless. |
| -f PATH | Name the archive file. Repeating this creation command with the same path overwrites the baseline archive. |
| -C / | Change tar's working directory to the filesystem root; source entries are relative, without leading slashes. |
| echo $? | Display the immediately preceding command's exit code; screenshot shows 0. This must be run immediately after the command being checked. |
| tar -t | List archive entries without extracting them. |

Verified archive contents include var/www/html/index.html, index.nginx-debian.html, index.html.save, etc/nginx/nginx.conf, sites-available/default, sites-enabled/default and srv/labshare/member-test.txt. The index.html.save entry exists in the archive, but its contents and origin were not inspected.

**Scope and limits:** This is an on-demand local backup within the same guest, not a scheduled backup or an off-VM/off-host copy. No backup of account/group databases, SSH host keys or UFW rules was included. Nginx's referenced snakeoil private key is outside these source paths, so the archive must not be represented as a complete TLS/server image. No ACL or extended-attribute backup options were used.

## Milestone 16 — Extract a homepage copy and verify its contents

**Where:** LNX01 sampath SSH session, using sudo for protected backup paths.

~~~bash
sudo mkdir -p /var/backups/linuxsysadminlab/restore-test
sudo tar -xzpf /var/backups/linuxsysadminlab/baseline.tar.gz -C /var/backups/linuxsysadminlab/restore-test var/www/html/index.html
sudo sha256sum /var/www/html/index.html /var/backups/linuxsysadminlab/restore-test/var/www/html/index.html
~~~

| Command / option | Meaning and purpose |
|---|---|
| mkdir -p .../restore-test | Prepare a separate extraction destination. |
| tar -x | Extract rather than create an archive. |
| -zpf | Read gzip compression, preserve file permissions and use the specified archive filename. |
| -C .../restore-test | Extract beneath the test directory, avoiding a write to the live homepage. |
| var/www/html/index.html | Select only this archive member; extraction recreates its relative parent directories. |
| sha256sum FILE1 FILE2 | Compute SHA-256 content fingerprints for the live original and extracted copy. Matching hashes show identical contents at comparison time. |

**Screenshot-verified result:** Extraction returned without a displayed error; both SHA-256 hashes match:

~~~text
423b901e8298b4eacd656774ae33fd1c27f7ca28ea80682593ea630fa5487a8d
~~~

The test verified the homepage's content round trip through the archive. It did not yet demonstrate recovery of a deleted live file, restoration of all source trees, account ownership mapping on another machine, or a timed/scheduled/off-VM backup.


## Milestone 17 — Recover a deleted shared file and verify content and access

**Where:** LNX01, sampath SSH session. The protected shared folder requires sudo for sampath's administrative recovery actions.

**Evidence:** Screenshots show the original SHA-256, confirmed removal, restoration from the baseline archive, matching post-restore hashes, original ownership/mode and successful read as labuser.

### Record the original and simulate deletion

~~~bash
sudo sha256sum /srv/labshare/member-test.txt
sudo rm -i /srv/labshare/member-test.txt
sudo ls -l /srv/labshare/member-test.txt
~~~

- sha256sum records the original content fingerprint.
- rm removes the exact lab test file; -i asks for confirmation. The user answered “yes.”
- ls was supplied to verify absence, but the user instead repeated rm -i. Its “No such file or directory” result verifies the file was already missing. Do not record an ls absence result that was not shown.
- This was a controlled deletion of a previously archived test file.

### Restore the exact archive member

~~~bash
sudo tar -xzpf /var/backups/linuxsysadminlab/baseline.tar.gz -C / srv/labshare/member-test.txt
sudo sha256sum /srv/labshare/member-test.txt
sudo ls -l /srv/labshare/member-test.txt
sudo -u labuser cat /srv/labshare/member-test.txt
~~~

| Command / option | Meaning and purpose |
|---|---|
| tar -x | Extract the selected archive member. |
| -z | Read gzip-compressed input. |
| -p | Restore recorded permissions. |
| -f | Select baseline.tar.gz as the archive input. |
| -C / | Restore the selected relative path beneath filesystem root, to its original location. |
| srv/labshare/member-test.txt | Extract only this file; do not extract the entire archive over the live system. |
| sha256sum | Compare restored content with the previously recorded original hash. |
| ls -l | Inspect restored ownership, group, mode and size. |
| sudo -u labuser cat | Run the read as labuser, testing the intended account's actual access rather than root's bypass privileges. |

**Original and restored SHA-256, screenshot-verified:**

~~~text
83e74747733b0dd866dc3c887feb1c5a7b27cc9f352592bbe412453a47a102f6
~~~

The post-restore screenshot shows two repeated sha256sum checks with the same value. Final listing shows **-rw-rw-r--**, owner **labuser**, group **labteam**, size **53 bytes**. Reading as labuser displays:

~~~text
Created by labuser for the Linux administration lab.
~~~

**Outcome:** The deleted file was recovered from the existing baseline archive with matching contents, original ownership/permissions and usable access by labuser. The restored file's nonmember denial was not rerun; earlier directory-access denial tests remain documented separately. No recovery time was measured. Scheduling and a copy outside the VM remain pending.


## Milestone 18 — Verify the clock and test a reusable backup script

**Where:** LNX01, sampath SSH session.

~~~bash
timedatectl
~~~

Screenshot confirms America/Chicago (CDT, -0500 at capture), system clock synchronized=yes, NTP service active, RTC in local TZ=no. NTP means Network Time Protocol; RTC means Real-Time Clock. The schedule will follow Chicago local time, including seasonal offset changes.

The following script was created using a quoted here-document:

~~~bash
sudo tee /usr/local/sbin/linuxlab-backup.sh <<'EOF'
#!/bin/bash
set -eu
umask 077

backup_dir="/var/backups/linuxsysadminlab"
mkdir -p "$backup_dir"

archive=$(mktemp "$backup_dir/backup-$(date +%Y%m%d-%H%M%S)-XXXXXX.tar.gz")

tar -czf "$archive" -C / var/www/html etc/nginx srv/labshare
gzip -t "$archive"
tar -tzf "$archive" > /dev/null

printf 'Backup verified: %s\n' "$archive"
EOF
sudo chmod 700 /usr/local/sbin/linuxlab-backup.sh
sudo /usr/local/sbin/linuxlab-backup.sh
~~~

| Line / command | Meaning and purpose |
|---|---|
| sudo tee ... <<'EOF' | Write the literal script as root without requiring an interactive editor. |
| #!/bin/bash | Select Bash as interpreter. |
| set -eu | Exit on unhandled command failures or unset-variable use. |
| umask 077 | Restrict newly created files/directories to their owner; does not retroactively change existing directory modes. |
| backup_dir=... | Set the destination variable. |
| mkdir -p | Ensure the destination exists. |
| archive=$(mktemp ...) | Capture the path of a new unique archive file; mktemp replaces XXXXXX with random characters, avoiding filename collisions. |
| date +%Y%m%d-%H%M%S | Add year/month/day and 24-hour time to the filename. |
| tar -czf ... -C / ... | Create a gzip archive of the website, Nginx configuration and shared directory using relative paths. |
| gzip -t | Check compressed-stream integrity. |
| tar -tzf ... > /dev/null | Verify tar can enumerate archive entries; suppress the listing. |
| printf | Print success and the archive path after the checks pass. |
| chmod 700 | Restrict script read/write/execute to root. |
| sudo /usr/local/sbin/linuxlab-backup.sh | Run an initial manual test. |

**Evidence:** Screenshot shows script creation, chmod and manual execution followed by “Backup verified:” and a timestamped archive path under /var/backups/linuxsysadminlab. This verifies script execution and archive checks, not an extraction of that specific newly generated archive. Actual file recovery was demonstrated separately using baseline.tar.gz.

**Current script limits:** It does not implement retention, off-VM transfer, application quiescing, deletion of partial archives on failure, or backup of users/groups/firewall/SSH state. Failures before the final message leave the task failed; a partial archive may remain and should not be treated as verified. The baseline archive is not overwritten by these uniquely named script backups.

## Milestone 19 — Schedule backups with systemd and test the service

**Where:** LNX01 sampath SSH session; all writes and service mutations use sudo.

### Service definition

~~~bash
sudo tee /etc/systemd/system/linuxlab-backup.service <<'EOF'
[Unit]
Description=Linux lab backup

[Service]
Type=oneshot
User=root
ExecStart=/usr/local/sbin/linuxlab-backup.sh
EOF
~~~

- [Unit] contains the description.
- [Service] describes execution.
- Type=oneshot runs the finite task, then exits.
- User=root gives access to protected source and destination paths.
- ExecStart specifies the executable script.
- The service is not left active after successful completion and does not need its own boot enablement: its timer activates it.

### Timer definition

~~~bash
sudo tee /etc/systemd/system/linuxlab-backup.timer <<'EOF'
[Unit]
Description=Daily Linux lab backup schedule

[Timer]
OnCalendar=*-*-* 02:00:00
Persistent=true

[Install]
WantedBy=timers.target
EOF
~~~

- OnCalendar schedules daily at 02:00 in the VM's local America/Chicago zone, subject to systemd timer accuracy.
- The matching timer name activates linuxlab-backup.service.
- Persistent=true causes a catch-up invocation when reactivated after a missed calendar event; it does not run while the VM is powered off or create one backup for every missed day.
- WantedBy=timers.target allows boot enablement through the timers target.

### Load, enable and inspect

~~~bash
sudo systemctl daemon-reload
sudo systemctl enable --now linuxlab-backup.timer
systemctl list-timers linuxlab-backup.timer --no-pager
~~~

| Command | Meaning and verified result |
|---|---|
| daemon-reload | Reload unit definitions into systemd. |
| enable --now ...timer | Enable at boot and start now; screenshot shows the created timers.target.wants symlink. |
| list-timers ... --no-pager | Show timer scheduling. Screenshot: next run Thu 2026-10-29 02:00:00 CDT, approximately 15 hours away; LAST was empty at capture. |

### Manually invoke the service and check its journal

~~~bash
sudo systemctl start linuxlab-backup.service
sudo journalctl -u linuxlab-backup.service -n 15 --no-pager
~~~

- systemctl start invokes the same service the timer will activate without changing the calendar schedule.
- journalctl reads the system journal; -u selects the backup service; -n 15 selects the latest fifteen entries; --no-pager prints directly.
- Screenshot journal at October 28, 10:35:21 shows Starting → Backup verified with a timestamped archive path → Deactivated successfully → Finished.
- “Deactivated successfully” is expected for this oneshot task, not an error.

**Outcome:** Timer configured/enabled with a visible next-run time; manual execution through systemd and journal success verified. An actual calendar-triggered backup, missed-run catch-up and persistence across reboot have **not yet been observed**. No backup retention is configured.


## Milestone 20 — Copy the baseline backup to Windows and verify transfer integrity

**Evidence:** Ubuntu screenshot confirms creation of a user-readable transfer copy and its SHA-256. Windows screenshots show SCP 100% completion (7719 bytes) and the full matching SHA-256.

### Prepare a restricted transfer copy on LNX01

**Where:** Existing sampath SSH session on Ubuntu.

~~~bash
sudo install -o sampath -g sampath -m 600 /var/backups/linuxsysadminlab/baseline.tar.gz /home/sampath/linuxlab-baseline.tar.gz
sha256sum /home/sampath/linuxlab-baseline.tar.gz
~~~

- install copies the archive and applies specified ownership/mode; it is not installing a software package here.
- -o sampath and -g sampath set owner/group.
- -m 600 gives only the owner read/write access.
- The original protected baseline remains in /var/backups/linuxsysadminlab.
- sha256sum records the transfer copy's fingerprint before download.
- Command succeeded without displayed error; the exact file mode was requested by the command rather than independently checked in an ls result.

### Download from a new Windows PowerShell window

**Where:** Windows host, prompt PS C:\Users\PSK>, outside any SSH session.

~~~powershell
New-Item -ItemType Directory -Path "$HOME\LinuxSysAdminLab-Backups" -Force
scp -P 2222 sampath@127.0.0.1:/home/sampath/linuxlab-baseline.tar.gz "$HOME\LinuxSysAdminLab-Backups\linuxlab-baseline.tar.gz"
Get-FileHash -Algorithm SHA256 "$HOME\LinuxSysAdminLab-Backups\linuxlab-baseline.tar.gz"
(Get-FileHash -Algorithm SHA256 "$HOME\LinuxSysAdminLab-Backups\linuxlab-baseline.tar.gz").Hash
~~~

| Command / argument | Meaning and purpose |
|---|---|
| New-Item -ItemType Directory | Create the Windows destination directory. |
| $HOME | Existing Windows user-profile variable, used without redefining it; screenshot resolves to C:\Users\PSK. |
| -Force | Accept an existing directory. |
| scp | Secure Copy client; transfers over SSH. |
| -P 2222 | Uppercase P selects the forwarded SSH port (ssh uses lowercase -p instead). |
| sampath@127.0.0.1:/home/... | Source account, Windows loopback endpoint and guest source path. |
| Get-FileHash -Algorithm SHA256 | Calculate the downloaded archive's SHA-256 fingerprint. |
| (...).Hash | Print the complete hash property, avoiding table-column truncation with ellipses. |

Verified Windows destination:

~~~text
C:\Users\PSK\LinuxSysAdminLab-Backups\linuxlab-baseline.tar.gz
~~~

**Ubuntu and Windows SHA-256 match** (letter case is irrelevant):

~~~text
784c5a71377d815e6ec30716c988f6d73713169636ea2737380415c090c0001b
~~~

The first Windows table shortened the hash; a follow-up full-property display verified the entire value. Do not treat a matching truncated prefix alone as a completed integrity check.

**Outcome and limits:** A verified copy exists outside the guest VM on the same Windows computer. This is not a copy on a different physical device or a cloud/off-site backup. The transfer was manual, not included in the daily timer. No restore from the Windows copy has been tested. The user subsequently confirmed removing the temporary Ubuntu transfer copy with rm -i /home/sampath/linuxlab-baseline.tar.gz; no independent post-removal listing was supplied. This removes only the staging copy, preserving the protected original and Windows copy. Windows destination ACLs were not inspected.


## Milestone 21 — Generate a dedicated SSH key and verify key authentication

### Generate on Windows

**Where:** New Windows PowerShell window at a PS C:\...> prompt.

~~~powershell
New-Item -ItemType Directory -Path "$HOME\.ssh" -Force
ssh-keygen -t ed25519 -f "$HOME\.ssh\linuxlab_ed25519" -C "sampath-linuxlab"
~~~

- New-Item ensures the standard .ssh directory exists.
- ssh-keygen generates a public/private key pair.
- -t ed25519 selects the Ed25519 algorithm.
- -f selects a dedicated lab filename rather than overwriting a default key.
- -C adds a descriptive comment.
- The user reported generation completed. They were instructed to use a private passphrase and decline any overwrite prompt.
- Private key: Windows user profile .ssh\linuxlab_ed25519. Public key: matching .pub file.
- The later successful test prompted for the private key passphrase, confirming a passphrase-protected key was used.
- No passphrase, password, or private key content is stored in this guide.

### Append the public key on Ubuntu

**Where:** Windows PowerShell, outside an SSH shell.

~~~powershell
Get-Content "$HOME\.ssh\linuxlab_ed25519.pub" | ssh -p 2222 sampath@127.0.0.1 'umask 077; mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys'
~~~

| Part | Meaning and purpose |
|---|---|
| Get-Content ... .pub | Read only the public key on Windows. |
| Pipe to ssh | Send that public text over the authenticated SSH connection to the remote command's input. |
| -p 2222 | Use the host's forwarded SSH endpoint. |
| Remote umask 077 | Restrict newly created paths to their owner. |
| mkdir -p ~/.ssh | Ensure the remote sampath SSH directory exists. |
| cat >> ~/.ssh/authorized_keys | Append the incoming public key to the allowed-key file, preserving existing entries. Repeating may add duplicates. |
| chmod 700 ~/.ssh | Restrict directory access to its owner. |
| chmod 600 ~/.ssh/authorized_keys | Restrict authorized-key file read/write to its owner. |

Screenshot shows this command completed and used Ubuntu account-password authentication for the setup connection. The private key remained on Windows.

### Require public-key authentication for a fresh test

**Where:** Windows PowerShell.

~~~powershell
ssh -i "$HOME\.ssh\linuxlab_ed25519" -o IdentitiesOnly=yes -o PreferredAuthentications=publickey -o PasswordAuthentication=no -p 2222 sampath@127.0.0.1
~~~

- -i chooses the dedicated private key.
- IdentitiesOnly=yes restricts identities considered to configured/explicit keys.
- PreferredAuthentications=publickey restricts this test's authentication preference to public key.
- PasswordAuthentication=no disables password fallback in this client invocation.
- The passphrase prompt unlocks the local private key; it is distinct from the Ubuntu account password.
- Screenshot confirms the private-key passphrase prompt followed by the Ubuntu 26.04.1 welcome banner and sampath@lnx01 shell prompt.

**Outcome:** Public-key login works through Windows loopback port 2222 to LNX01. These client options do not disable password authentication on the server. Server password-authentication configuration has not been changed. No ssh-agent configuration or private-key backup has been performed.


## Milestone 22 — Check resources and expose Linux metrics with Node Exporter

**Where:** LNX01 sampath SSH session.

~~~bash
free -h
df -h /
sudo apt install prometheus-node-exporter
systemctl status prometheus-node-exporter --no-pager
curl -fsS --max-time 10 http://localhost:9100/metrics -o /tmp/linuxlab-node-metrics.txt
head -n 15 /tmp/linuxlab-node-metrics.txt
~~~

| Command | Meaning, purpose and evidence |
|---|---|
| free -h | Show readable memory/swap usage. Screenshot: 3.3 GiB total RAM, 2.2 GiB available, 3.8 GiB swap with 0 B used at capture. |
| df -h / | Show root filesystem capacity. Screenshot: /dev/sda2, 39G total, 12G used, 25G available, 34% used. |
| sudo apt install prometheus-node-exporter | Install Ubuntu's packaged host-metrics exporter. Installation command output was not supplied, but the subsequent service screenshot confirms it is present. |
| systemctl status ... --no-pager | Screenshot: active (running), enabled, executable /usr/bin/prometheus-node-exporter, listening on port 9100. |
| curl -fsS --max-time 10 ... -o ... | Download local metrics with HTTP failures treated as errors (-f), quiet output with errors shown (-sS), ten-second limit, and output saved to the named temporary file (-o). |
| head -n 15 | Display the first fifteen lines of the downloaded metrics. |

Screenshot confirms valid Prometheus-format output: HELP descriptions, TYPE declarations and sample values, including apt_autoremove_pending, apt_package_cache_timestamp_seconds and Go runtime metrics. The displayed first lines are not a full list of available host metrics.

The checks were local inside LNX01. No port 9100 UFW allow rule or VirtualBox forwarding rule was added in this workflow. Service listening-address scope beyond the shown port has not been independently restricted or inspected.

## Milestone 23 — Install Prometheus and verify Node Exporter collection

**Where:** LNX01 sampath SSH session.

~~~bash
sudo apt install prometheus
systemctl status prometheus --no-pager
sudo cat /etc/prometheus/prometheus.yml
curl -fsS --max-time 10 'http://localhost:9090/api/v1/query?query=up%7Bjob%3D%22node%22%7D'
~~~

| Command | Meaning, purpose and evidence |
|---|---|
| sudo apt install prometheus | Supplied to install the metrics collector/time-series server. Subsequent config and API results confirm it is available. |
| systemctl status prometheus --no-pager | Supplied to check running/boot state; a separate status screenshot was not provided, so enabled-at-boot status is unverified. |
| sudo cat ...prometheus.yml | Display the actual existing configuration before deciding whether an edit is needed; screenshot supplied. |
| curl ... /api/v1/query?... | Query the local Prometheus HTTP API on 9090. Encoded expression is up{job="node"}. This is an instant query, not a configuration change. |

### Existing configuration inspected; no edit required

The supplied configuration screenshot shows:

~~~yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    monitor: 'example'
~~~

Existing scrape jobs include prometheus at localhost:9090 (five-second job-level scrape interval and timeout) and:

~~~yaml
- job_name: node
  static_configs:
    - targets: ['localhost:9100']
~~~

The node job inherits the global 15-second interval. “Scrape” means collect a metrics snapshot from a target. The file also has an Alertmanager target localhost:9093, but Alertmanager operation and alert rules were not tested.

### Collection result

Screenshot of the API response shows status=success, resultType=vector, metric name up, instance localhost:9100, job node, with value **1**. This verifies successful latest scraping of the Node Exporter job, beyond merely checking that both services start.

No Prometheus config replacement/reload was needed. No Windows UI access, Grafana installation/dashboard, retention tuning, alerting, or exporter-outage experiment has been performed yet. Monitoring currently runs inside LNX01 rather than a separate monitoring VM.


## Milestone 24 — Open Prometheus through SSH and resolve a clock warning

**Where:** A new Windows PowerShell window outside an SSH shell.

~~~powershell
ssh -i "$HOME\.ssh\linuxlab_ed25519" -p 2222 -N -o ExitOnForwardFailure=yes -L 127.0.0.1:9090:127.0.0.1:9090 sampath@127.0.0.1
~~~

- -i selects the lab key, -p selects the existing VirtualBox SSH-forwarded endpoint.
- -N keeps a forwarding-only connection open without a remote shell.
- -L listens on Windows loopback port 9090 and forwards over SSH to port 9090 on Ubuntu loopback.
- ExitOnForwardFailure=yes exits if it cannot establish the requested forwarding listener; it does not guarantee the final application will always be reachable.
- Keep the window open while browsing http://127.0.0.1:9090 on Windows.
- No additional guest UFW or VirtualBox NAT rule for port 9090 was added.

**Evidence:** Browser screenshot confirms the Prometheus interface loaded. Initially it warned of approximately 84.57–84.58 seconds difference between browser and server clocks.

The user was instructed to enable Windows automatic time and click Sync now under Settings > Time & language > Date & time. Ubuntu's check:

~~~bash
timedatectl
~~~

showed America/Chicago, system clock synchronized=yes and NTP active. A subsequent browser screenshot shows the warning gone. Windows's sync-success screen was not supplied; record the observed warning resolution rather than attributing a measured correction to a specific host.

Additional screenshot context showed PowerShell New-Item commands accidentally entered at the Ubuntu prompt and returning “command not found.” Correct Windows execution of those earlier tasks is already verified; no Linux package installation was needed to address those context errors.

### Browser queries

In the Prometheus Expression field, the user ran:

~~~promql
up{job="node"}
~~~

and reported completion of the expected Console/Graph check. The API had already verified up=1 in milestone 23. The next query was:

~~~promql
100 * (1 - node_memory_MemAvailable_bytes{job="node"} / node_memory_MemTotal_bytes{job="node"})
~~~

It estimates used RAM percent using total minus available memory; available includes reclaimable memory. The user confirmed the graph worked. No screenshot of that specific Prometheus RAM graph was supplied; later Grafana screenshots independently show the same query returning data.

## Milestone 25 — Install Grafana, verify health and sign in through SSH

### Repository installation

**Where:** LNX01 sampath SSH session. Stable OSS packages were selected.

~~~bash
sudo apt install apt-transport-https wget gnupg
sudo mkdir -p /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/grafana.asc https://apt.grafana.com/gpg-full.key
sudo chmod 644 /etc/apt/keyrings/grafana.asc
echo "deb [signed-by=/etc/apt/keyrings/grafana.asc] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
sudo apt update
sudo apt install grafana
sudo systemctl enable --now grafana-server
systemctl status grafana-server --no-pager
curl -fsS --max-time 10 http://localhost:3000/api/health
~~~

| Command / part | Meaning and purpose |
|---|---|
| apt install prerequisites | Provide HTTPS transport/download and signing-key tooling. Completion reported; full package output not captured. |
| mkdir -p /etc/apt/keyrings | Ensure the repository key directory exists. |
| wget -O ...grafana.asc URL | Download the official signing key to the specified file. |
| chmod 644 ...grafana.asc | Make the public verification key readable by APT. |
| echo ... signed-by=... \| sudo tee ...grafana.list | Write the stable Grafana source, scoped to this repository key. This replaces that dedicated list file rather than appending duplicates. |
| apt update | Refresh package metadata including the new source; no error reported. |
| apt install grafana | Install the OSS package; user reported completion. |
| systemctl enable --now | Enable at boot and start immediately. |
| systemctl status ... | Screenshot: active (running), enabled; initially only six seconds into startup with database migrations in progress. |
| curl ... /api/health | Check HTTP responsiveness and application database status on port 3000. |

### Initial readiness delay

The first health request returned curl error 7 (connection refused). The service status showed it was still starting/migrating. Waiting and retrying were instructed; the actual delay was not measured.

~~~bash
sudo journalctl -u grafana-server -n 40 --no-pager
~~~

This diagnostic command displays the latest forty journal entries for Grafana. The screenshot showed INFO-level plugin installation/initialization. The follow-up health response confirms **database=ok** and **version=13.2.4**. Successful readiness after startup supports a transient initialization delay; no configuration or firewall repair was needed or performed.

### Open the Grafana interface

**Where:** Another new Windows PowerShell window, left open as a tunnel.

~~~powershell
ssh -i "$HOME\.ssh\linuxlab_ed25519" -p 2222 -N -o ExitOnForwardFailure=yes -L 127.0.0.1:3000:127.0.0.1:3000 sampath@127.0.0.1
~~~

This forwards Windows loopback 3000 through SSH to Ubuntu loopback 3000. Browser screenshot confirms the login page at the instructed Windows URL http://127.0.0.1:3000. The default first-login account was used as instructed; the user was prompted to choose a private replacement password. The subsequent screenshot confirms an authenticated home page. No password is recorded; completion of the password-change form was not separately screenshot-inspected.

Grafana's service is enabled for boot; the Windows forwarding process is manual and must stay open or be restarted for browser access after it closes.

## Milestone 26 — Connect Prometheus and build the RAM/CPU dashboard

### Data source

**Where:** Grafana web interface on Windows; backend queries execute from Grafana on LNX01.

Instructions: Connections > Data sources > Add new data source > Prometheus; URL **http://localhost:9090**; Save & test. Completion was reported, but no connection-test success screenshot was supplied.

The suggested data-source name was Prometheus-LNX01. Actual later screenshots show the selected source is **prometheus**. Use that actual name in future instructions/export work. Successful live panel graphs confirm the data source is working. Here localhost resolves on LNX01 because Grafana's backend makes the request.

### Dashboard and RAM panel

**Dashboard:** LNX01 System Monitoring.

The installed UI offered a new dashboard with an Add sidebar, then a Panel box with a plus sign. Selecting it opened the panel editor. The actual workflow used Code query mode, Run queries, Time series, Panel options and Standard options. No need to document each unsuccessful navigation click.

~~~promql
100 * (1 - node_memory_MemAvailable_bytes{job="node"} / node_memory_MemTotal_bytes{job="node"})
~~~

**Title:** LNX01 RAM Usage. **Unit:** Percent (0-100). **Min:** 0. **Max:** 100.

- MemAvailable/total is the available fraction.
- Subtract from one for used fraction, multiply by 100 for percentage.
- The range query plots historical samples as a time series.
- Screenshots confirm a populated graph, percentage axis 0–100 and the correct title. At a later capture the displayed historical minimum was 33.2% and maximum 51.6%; these are point-in-time observations, not capacity thresholds.

The user saved and returned to the dashboard. The named dashboard breadcrumb and subsequent two-panel view confirm it exists.

### CPU panel

~~~promql
100 * (1 - avg by (instance) (rate(node_cpu_seconds_total{job="node",mode="idle"}[5m])))
~~~

**Title:** LNX01 CPU Usage. **Visualization:** Time series. **Unit:** Percent (0-100). **Min:** 0. **Max:** 100.

- node_cpu_seconds_total records cumulative CPU time by mode/core.
- mode="idle" selects idle time.
- rate(...[5m]) computes a per-second rate over a five-minute window.
- avg by(instance) averages idle rate across cores for each server.
- Subtract from one and multiply by 100 for average non-idle CPU percent.
- Screenshot confirms the query and plotted data. The final dashboard screenshot confirms both RAM and CPU panels together, correctly titled with percentage axes from 0 to 100.
- The screenshot is still in dashboard edit mode (“Exit edit” visible); Save appears inactive. The user followed save instructions; an independent reload/persistence test has not been performed.
- Last six hours is the displayed time range; older blank sections reflect the available collection history, not a proven outage.

**Remaining dashboard work:** Disk usage, refresh/time-range refinement, export of dashboard JSON and controlled monitoring/alert tests have not been completed. Alerting is not configured. Existing backups do not yet include /etc/prometheus, /etc/grafana, Grafana's database or the new backup script/systemd definitions.


## Milestone 27 — Add root disk monitoring and export the dashboard

**Where:** Grafana web interface on Windows, using the existing SSH tunnel and the prometheus data source.

Added a third Time series panel:

~~~promql
100 * (1 - node_filesystem_avail_bytes{job="node",mountpoint="/"} / node_filesystem_size_bytes{job="node",mountpoint="/"})
~~~

**Title:** LNX01 Root Disk Usage. **Unit:** Percent (0-100). **Min/Max:** 0/100.

- mountpoint="/" selects the root filesystem.
- avail_bytes is space available to non-root users; size_bytes is total filesystem size.
- The expression measures space unavailable to ordinary users, including used blocks and filesystem reservations. It is not exactly the same percentage calculation as df's Use% on filesystems with reserved blocks.
- Screenshot confirms all three panels with data: RAM, CPU and root disk. The disk series identifies /dev/sda2 and ext4, with a value near 40% at capture.
- No disk-filling test was performed.

The user was instructed to set Last 1 hour and 30-second refresh, save, and exit edit mode; completion was reported. A later screenshot independently confirms Last 1 hour, 30s and the normal Edit button (rather than Exit edit).

### Export as JSON

The export workflow used the dashboard's separate Export control, not its Share internally/externally/snapshot menu. In the observed layout the Export icon was on the far-right vertical toolbar (down arrow into tray). Instructions were to choose Export as code, Classic model, and Share dashboard with another instance if available, then Download file.

Suggested filename:

~~~text
LNX01-System-Monitoring.json
~~~

**Evidence:** The user confirmed downloading and saving the file on the Windows Desktop. The actual file, downloaded filename, model choice and JSON contents have not been uploaded or inspected here. No import/recreation test has been done.

JSON means JavaScript Object Notation. The dashboard export captures layout, queries and display settings, not Prometheus metric history or a complete Grafana installation backup. Exported data-source references may need mapping on another installation. Preserve the actual export for the final repository; do not invent a verified export from screenshots.

## Milestone 28 — Demonstrate monitoring target failure and recovery

**Where:** LNX01 sampath SSH session.

~~~bash
sudo systemctl stop prometheus-node-exporter
curl -fsS --max-time 10 'http://localhost:9090/api/v1/query?query=up%7Bjob%3D%22node%22%7D'
sudo systemctl start prometheus-node-exporter
curl -fsS --max-time 10 'http://localhost:9090/api/v1/query?query=up%7Bjob%3D%22node%22%7D'
~~~

| Step | Meaning and evidence |
|---|---|
| systemctl stop exporter | Supplied to deliberately interrupt metric serving. The stop command line is not in the provided crop. |
| Wait about 20 seconds | Supplied to allow a new scrape after the configured 15-second interval. Exact wait duration was not measured. |
| Query up{job="node"} | First screenshot confirms API status=success and sample value 0 for localhost:9100, job node: Prometheus is responding but its exporter scrape failed. |
| systemctl start exporter | Supplied to restore metric serving; command line not visible in the result screenshot. |
| Wait and query again | Follow-up screenshot confirms status=success and up=1 for the same job/instance. |

**Outcome:** Prometheus detected the controlled exporter outage and successful recovery (1 previously → 0 during test → 1 after recovery). API success describes successful query execution; the up sample separately describes target reachability. This does not prove an entire server outage, website outage, alert rule or external notification. No notification/alert has been configured. Recovery duration was not measured.


## Milestone 29 — Save a post-monitoring VM recovery point

**Evidence:** The user confirmed completing the supplied shutdown and snapshot procedure. Snapshot properties have not been independently inspected.

~~~bash
sudo poweroff
~~~

**Where:** LNX01 sampath SSH session; requests a normal guest shutdown and disconnects SSH/tunnels.

**Where next:** Windows VirtualBox Manager, LNX01 > Snapshots > Take.

- Reported snapshot name: **LNX01-Monitoring-Backup**.
- Supplied description: SSH keys, firewall, users, Nginx, backup recovery, daily backup timer, and monitoring dashboard configured.
- This is a later recovery point than LNX01-Updated-Baseline and follows the verified Ubuntu release upgrade.
- It depends on the VM disks; separate Windows archive and dashboard export remain necessary project artifacts.
- Later instructions asked the user to restart LNX01 for management access; successful later SSH confirms it was running again.

## Milestone 30 — Create, install and update the management VM

**Role:** MGMT01 will be the Ansible control node; LNX01 will be the managed node. Both use the LinuxLab NAT Network.

**Evidence:** VM creation/network setup and Ubuntu installation/reboot confirmed by user report. A subsequent terminal screenshot verifies account/hostname context, guest address and routes.

| Setting | Supplied value / evidence |
|---|---|
| VirtualBox VM name | MGMT01, completion reported |
| VM base folder | C:\LinuxSysAdminLab, instructed |
| ISO | Existing ubuntu-24.04.2-desktop-amd64.iso |
| RAM / CPUs | 4096 MB / 2, instructed and covered by creation completion report, not independently inspected |
| New disk | 30 GB dynamically allocated, instructed |
| Installation | Manual, unattended disabled |
| Adapter 1 | NAT Network LinuxLab, Cable Connected, completion reported |
| Account | sampath, screenshot-verified |
| Hostname | **MGMT01**, uppercase in actual prompt (lowercase mgmt01 had been suggested) |
| Interface | enp0s3 UP, screenshot-verified |
| Current DHCP IPv4 | 10.20.20.4/24 |
| Gateway / route | default via 10.20.20.1 dev enp0s3 proto dhcp src 10.20.20.4 metric 100 |
| Connected network | 10.20.20.0/24 |
| OS | Ubuntu installed from the 24.04.2 Desktop ISO by report; standalone /etc/os-release output not supplied, so exact post-update point release remains unverified |

Installation instructions used Interactive/Default selection, Erase disk within this new VM, review of the 30 GB virtual disk, private password, password-required login and America/Chicago. Account full name/timezone settings were not independently queried. Installation and reboot were reported complete.

### Graphics warning during installer boot

A screenshot showed vmwgfx “unsupported hypervisor” and related DRM messages during MGMT01 startup. Guidance: allow time to continue; if stuck before installation began, power off only MGMT01 and retry the installer in safe graphics mode. The user later confirmed successful installation/reboot. The exact action that resolved the warning is unconfirmed; do not claim a graphics-controller change, safe-graphics selection or reinstall was performed.

### Identity/network checks supplied

**Where:** MGMT01 Ubuntu Terminal.

~~~bash
hostname
cat /etc/os-release
ip -br address
ip route
~~~

The last two outputs are screenshot-verified above. Prompt confirms MGMT01 identity; standalone hostname and OS output not supplied.

### Package updates

~~~bash
sudo apt update
sudo apt upgrade
sudo reboot
~~~

**Where:** MGMT01 Ubuntu Terminal as sampath.

- apt update refreshes repository metadata.
- apt upgrade applies package updates; instructed to inspect errors and confirm Y, then wait for completion.
- reboot reloads updated components.
- User confirmed completion after instructions; exact APT counts and post-reboot release not captured.
- Guidance was to leave a separate full 26.04 release-upgrade offer for later. No management-VM release upgrade has been reported.

## Milestone 31 — Establish MGMT01-to-LNX01 SSH and dedicated key access

### Direct guest-to-guest connection

**Where:** MGMT01 Terminal, with both VMs running.

~~~bash
ssh sampath@10.20.20.3
hostname
exit
~~~

- Direct connection uses guest port 22 over LinuxLab, not Windows forwarded port 2222.
- Initial screenshot returned “No route to host,” before authentication.
- Guidance was to verify LNX01 was running and inspect its address/routes.
- A retry screenshot reached the host-key prompt at the same address, so reachability recovered; no cause or network-setting change was confirmed.
- The shown ED25519 fingerprint matched earlier LNX01 SSH prompts. The user was instructed to type the full yes, enter LNX01 account password, check hostname and exit.
- User response “es” was interpreted as yes to expected lnx01 hostname; standalone hostname result is not screenshot-verified.
- Do not claim a static guest address was assigned.

### Create MGMT01's separate key

~~~bash
ssh-keygen -t ed25519 -f ~/.ssh/ansible_ed25519 -C "MGMT01-Ansible"
~~~

A screenshot of an attempted command showed an extra space in “~/ .ssh/...”, producing “Too many arguments.” It did not demonstrate successful key creation. Corrected command:

~~~bash
ssh-keygen -t ed25519 -f /home/sampath/.ssh/ansible_ed25519 -C "MGMT01-Ansible"
~~~

- ssh-keygen generates a dedicated public/private pair.
- -t selects Ed25519; -f selects one complete filename; -C adds a label.
- User confirmed creation.
- A passphrase was recommended and overwrite refusal instructed, but the final SSH test screenshot contains no passphrase prompt. Whether this management key is passphrase-protected is **not verified**. Do not confuse it with the separately verified Windows passphrase-protected key.
- The private management key stays on MGMT01; no private key content or passphrase is recorded.

### Install public key and verify a key-only client login

**Where:** MGMT01 Terminal.

~~~bash
ssh-copy-id -i /home/sampath/.ssh/ansible_ed25519.pub sampath@10.20.20.3
ssh -i /home/sampath/.ssh/ansible_ed25519 -o IdentitiesOnly=yes -o PreferredAuthentications=publickey -o PasswordAuthentication=no sampath@10.20.20.3
exit
~~~

| Command / option | Meaning and evidence |
|---|---|
| ssh-copy-id -i ...pub | Supplied to append the public key to LNX01 sampath's authorized keys, initially authenticating with LNX01 account password. Its output is not captured. Subsequent successful key test verifies authorized key access is in place. |
| ssh -i ...ansible_ed25519 | Select MGMT01's private key. |
| IdentitiesOnly=yes | Limit offered identities to explicit/configured keys. |
| PreferredAuthentications=publickey | Use public-key authentication for this test. |
| PasswordAuthentication=no | Disable password fallback in this client command, without changing server policy. |
| exit | End remote session and return to MGMT01. |

Screenshot verifies the full key-test command, successful Ubuntu 26.04.1 login on LNX01, source address 10.20.20.4 in the login banner, remote sampath@lnx01 prompt, exit, connection closed and return to sampath@MGMT01.

The banner reports **19 immediately available updates** on LNX01 at this point. They have not been applied in this step. Earlier zero-update observations were point-in-time; the final checklist should revisit package maintenance.

**Outcome:** The management node can authenticate to LNX01 over guest networking using its own SSH key. Ansible installation, inventory, modules, privilege escalation and playbooks are still pending. There is no evidence yet that an ssh-agent is loaded; if a passphrase-protected key prompts during automation, handle it through an agent rather than storing its passphrase.


## Milestone 32 — Install Ansible on MGMT01 and repair the shell PATH

**Where:** MGMT01 Terminal as sampath.

~~~bash
sudo apt install pipx
pipx install --include-deps ansible
/home/sampath/.local/bin/ansible --version
pipx ensurepath
export PATH="$HOME/.local/bin:$PATH"
ansible --version
command -v ansible ssh mkdir
~~~

| Command | Meaning and evidence |
|---|---|
| sudo apt install pipx | Supplied to install the isolated Python application manager. A screenshot starts with an earlier pipx-not-found message, followed by a successful pipx installation command; exact APT output not supplied. |
| pipx install --include-deps ansible | Install the application plus exposed dependency commands in the user's isolated pipx environment, without sudo. Screenshot: ansible package 14.5.0, Python 3.12.3. |
| Full-path ansible --version | Bypass missing PATH configuration. Screenshot: ansible-core 2.21.5, executable /home/sampath/.local/bin/ansible, config file=None, Jinja 3.1.6, PyYAML 6.0.3. |
| pipx ensurepath | Add the user application bin directory to future shell startup configuration; screenshot reports success. |
| export PATH=...:$PATH | Supplied to preserve existing command paths while adding the user's application directory for the current shell. |
| command -v ansible ssh mkdir | Verify lookup for Ansible and ordinary system commands. |

### PATH troubleshooting

The user initially entered $PSTH rather than $PATH. This left the current search path without standard system directories. Correcting the spelling by appending the already-damaged PATH did not restore them. A screenshot showed only the Ansible executable found; ssh and mkdir were absent from lookup.

Opening a fresh terminal was suggested, but a fresh-session reset was not confirmed. The successful explicit recovery command was:

~~~bash
export PATH="/home/sampath/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
command -v ansible ssh mkdir
~~~

Screenshot confirms all three paths:
- /home/sampath/.local/bin/ansible
- /usr/bin/ssh
- /usr/bin/mkdir

This restores the current shell. No evidence shows the typo was written into a shell startup file. Do not claim a startup-file edit, login-session reset or permanent system PATH replacement. pipx ensurepath persistence was reported by the tool but has not been tested in a separately confirmed fresh session.

## Milestone 33 — Create the inventory and verify remote module execution

**Where:** MGMT01 Terminal.

~~~bash
mkdir -p /home/sampath/LinuxSysAdminLab/ansible
cd /home/sampath/LinuxSysAdminLab/ansible
cat > inventory.ini <<'EOF'
[linux_servers]
lnx01 ansible_host=10.20.20.3 ansible_user=sampath ansible_ssh_private_key_file=/home/sampath/.ssh/ansible_ed25519 ansible_python_interpreter=/usr/bin/python3
EOF
ansible-inventory -i inventory.ini --graph
ansible -i inventory.ini linux_servers -m ansible.builtin.ping
~~~

| Setting / command | Meaning and purpose |
|---|---|
| mkdir -p and cd | Create and enter the automation working directory. |
| cat > ... <<'EOF' | Write the literal INI inventory; > replaces existing file contents. |
| [linux_servers] | Define the managed-server group. |
| lnx01 | Inventory alias for the host. |
| ansible_host=10.20.20.3 | Use the current guest address; it remains DHCP assigned. |
| ansible_user=sampath | Remote SSH login account. |
| ansible_ssh_private_key_file | Select the dedicated MGMT01 private key locally; never copy its private contents into the repository. |
| ansible_python_interpreter=/usr/bin/python3 | Select Python on LNX01 for module execution. |
| ansible-inventory -i ... --graph | Parse inventory and show group/host membership without making remote changes. |
| ansible ... -m ansible.builtin.ping | Execute the Python-based connectivity test via SSH. This is not an ICMP/network ping. |

**Evidence:** Screenshot confirms group linux_servers contains lnx01. A following screenshot confirms **lnx01 SUCCESS**, changed=false, ping=pong. This verifies SSH and Python module execution from MGMT01.

No playbook had yet run at this milestone. No Ansible configuration file was created; inventory is selected explicitly with -i.

## Milestone 34 — Diagnose privilege escalation and select sudo.ws per inventory

### Initial Ansible sudo test

**Where:** MGMT01 automation directory.

~~~bash
ansible -i inventory.ini linux_servers -b -K -m ansible.builtin.command -a "id -u"
~~~

- -b enables become (privilege escalation).
- -K prompts interactively for the remote sudo password.
- command executes id -u, which prints the effective UID.
- Expected root UID is 0, but the first attempt failed with **Timeout (12s) waiting for privilege escalation prompt**, reported as UNREACHABLE.
- That result did not prove SSH/network failure or an incorrect password. The non-elevated ping had already passed.

### Check sudo on LNX01 directly

**From MGMT01:**

~~~bash
ssh -t -i /home/sampath/.ssh/ansible_ed25519 sampath@10.20.20.3
~~~

-t allocates a terminal for interactive sudo diagnostics.

**Inside the remote sampath@lnx01 shell:**

~~~bash
sudo -k
sudo id -u
sudo --version | head -n 2
command -v sudo.ws
exit
~~~

| Command | Meaning and observed result |
|---|---|
| sudo -k | Invalidate cached sudo authentication, so the test requires credentials. |
| sudo id -u | Screenshot confirms prompt [sudo: authenticate] Password: and output 0. The account has working elevation. |
| sudo --version \| head -n 2 | Identify implementation; screenshot: sudo-rs 0.2.13-0ubuntu1.2. |
| command -v sudo.ws | Locate the alternative implementation; screenshot: /usr/bin/sudo.ws. |
| exit | Return to MGMT01. |

Ansible/sudo-rs prompt compatibility was investigated using upstream documentation/issues. These diagnostics establish manual sudo success and the two implementations. The exact underlying prompt-handling defect was not conclusively isolated by verbose tracing.

### Test the alternative without changing the OS default

**Where:** MGMT01 automation directory.

~~~bash
ansible -i inventory.ini linux_servers -b -K -e ansible_become_exe=/usr/bin/sudo.ws -m ansible.builtin.command -a "id -u"
~~~

-e supplies a variable for this invocation. ansible_become_exe selects the executable on the managed host. Screenshot confirms **lnx01 CHANGED | rc=0**, followed by **0**.

CHANGED is the command module's default reporting for an executed command; this identity check itself did not alter system settings.

### Persist only the Ansible setting

~~~bash
cat >> inventory.ini <<'EOF'

[linux_servers:vars]
ansible_become_exe=/usr/bin/sudo.ws
EOF
ansible -i inventory.ini linux_servers -b -K -m ansible.builtin.command -a "id -u"
~~~

- >> appends without replacing the host definition.
- [linux_servers:vars] supplies a group variable.
- The final test omits -e, demonstrating the saved inventory setting is used.
- Screenshot confirms another **rc=0** and UID **0**.

**Outcome:** Password-based privilege escalation from Ansible works using /usr/bin/sudo.ws for the managed group. The OS default sudo remains unchanged, password authentication is still required for this Ansible elevation, and no NOPASSWD policy or stored password was created. At this point inventory, connection and elevation tests pass; first playbook creation/execution remains pending.


## Milestone 35 — Apply the web-server playbook and verify idempotence

**Where:** MGMT01, /home/sampath/LinuxSysAdminLab/ansible, controlling LNX01 through the existing inventory/key and sudo.ws setting.

### Playbook supplied and checked

~~~bash
cat > webserver.yml <<'EOF'
---
- name: Maintain the LNX01 web server
  hosts: linux_servers
  become: true

  tasks:
    - name: Ensure Nginx is installed
      ansible.builtin.apt:
        name: nginx
        state: present

    - name: Ensure Nginx is running and enabled
      ansible.builtin.service:
        name: nginx
        state: started
        enabled: true

    - name: Create an administration record
      ansible.builtin.copy:
        dest: /etc/linuxlab-managed.txt
        content: |
          Managed by Ansible
          Control node: MGMT01
          Project: LinuxSysAdminLab
        owner: root
        group: root
        mode: '0644'
EOF
ansible-playbook -i inventory.ini webserver.yml --syntax-check
~~~

| Setting / command | Meaning and purpose |
|---|---|
| YAML | YAML Ain't Markup Language, a structured text format whose indentation defines nesting. |
| hosts: linux_servers | Select the inventory group. |
| become: true | Run tasks with elevation using the saved group sudo.ws executable. |
| ansible.builtin.apt state: present | Ensure Nginx is installed; does not request a full OS/package upgrade or reinstall an already-present package. |
| ansible.builtin.service | Ensure Nginx is started and enabled at boot; correct those states if they differ. |
| ansible.builtin.copy | Maintain a small administration record at /etc/linuxlab-managed.txt with exact supplied contents, root:root ownership and 0644 mode. |
| --syntax-check | Validate the playbook without applying tasks; screenshot returned “playbook: webserver.yml” with no error. |

The website homepage is not managed/replaced by this playbook. It demonstrates a limited web-server baseline, not full reconstruction of the entire lab. No backup, monitoring, accounts, firewall or repository-provisioning tasks are included.

### First execution

~~~bash
ansible-playbook -i inventory.ini webserver.yml -K
~~~

-K prompts for LNX01's sudo password; no password is stored in the inventory/playbook.

Screenshot confirms Gathering Facts, Nginx package and service tasks reported ok; administration record reported changed. Recap: **ok=4, changed=1, unreachable=0, failed=0, skipped=0**.

Gathering Facts is an automatic remote information-gathering step. The changed count is a subset of successful tasks, not an additional task count. Existing package/service state was already correct.

### Repeat execution / idempotence

The exact same command was run again:

~~~bash
ansible-playbook -i inventory.ini webserver.yml -K
~~~

Screenshot confirms all four steps ok and recap **ok=4, changed=0, unreachable=0, failed=0, skipped=0**.

**Outcome:** The playbook applied its initial record and made no further changes when rerun against matching state. This is observed idempotence for this playbook on the current host, not proof of all future changes or complete-server reproducibility.

## Milestone 36 — Correct stopped-service drift with the playbook

### Deliberately change the managed service state

**Where:** MGMT01 automation directory.

~~~bash
ansible -i inventory.ini linux_servers -b -K -m ansible.builtin.service -a "name=nginx state=stopped"
curl -I --max-time 5 http://10.20.20.3
~~~

- The service module was supplied to stop Nginx remotely with sudo; its execution output was not captured.
- The first curl attempt on MGMT01 reported command not found, which did not establish website state.
- The user installed the client on MGMT01:

~~~bash
sudo apt install curl
~~~

Screenshot confirms curl installation from noble-updates, version 8.5.0-2ubuntu10.16, and then a repeated HTTP test returning curl error 7, failed to connect to 10.20.20.3 port 80. That failed request directly verifies unavailability at test time. The package output also confirms MGMT01 was still using Ubuntu Noble repositories, and reported one package not upgraded; no follow-up was performed on that package here.

### Rerun desired-state configuration and check HTTP

~~~bash
ansible-playbook -i inventory.ini webserver.yml -K
curl -I --max-time 5 http://10.20.20.3
~~~

Instructions predicted the Nginx service task would report changed, failed/unreachable would be zero, and HTTP would return 200 OK. The user responded **“yes”**; this is interpreted as confirmation of those expected recovery results. No screenshot of this final play recap or HTTP response was provided, so exact changed/task counts are not claimed.

**Outcome:** Service drift correction by rerunning the playbook and successful HTTP recovery are recorded as user-confirmed, supported by directly captured earlier playbook behavior and outage evidence. This was operator-invoked automation, not a continuously running self-healing controller. No autonomous trigger, alert or scheduled playbook run was configured.


## Milestone 37 — Final service and backup-journal checks

**Where:** LNX01 sampath SSH session reached from MGMT01.

~~~bash
ssh -i /home/sampath/.ssh/ansible_ed25519 sampath@10.20.20.3
systemctl is-active nginx prometheus-node-exporter prometheus grafana-server linuxlab-backup.timer
systemctl list-timers linuxlab-backup.timer --no-pager
sudo journalctl -u linuxlab-backup.service --since today --no-pager
~~~

The ssh command is issued on MGMT01; the following checks execute inside LNX01.

- is-active checks each named unit; screenshot confirms **five active lines** in the listed order.
- list-timers shows next run **Thu 2026-10-29 02:00:00 CDT** and LAST **Wed 2026-10-28 10:33:13 CDT**.
- LAST records a timer trigger, not proof that a corresponding backup succeeded or that a daily 02:00 event occurred.
- journalctl selects the backup service (-u), entries since local midnight (--since today), printed without a pager.
- Screenshot shows the known **10:35:21** successful service execution: Starting, Backup verified, Deactivated successfully, Finished. This corresponds to the earlier manual service test. No successful 02:00 daily run is claimed.
- No separate 10:33:13 execution result is visible in the supplied journal output; that difference is left unresolved rather than presented as proof of a successful catch-up run.

**Outcome:** The five services/timer were active at final check, with a future daily backup scheduled and a successful manual backup execution recorded.

## Milestone 38 — Collect actual configuration sources and inspect uploaded archives

### Package LNX01 files

**Where:** LNX01 sampath SSH shell.

~~~bash
sudo tar -czf /home/sampath/LinuxSysAdminLab-LNX01-files.tar.gz -C / usr/local/sbin/linuxlab-backup.sh etc/systemd/system/linuxlab-backup.service etc/systemd/system/linuxlab-backup.timer etc/nginx/sites-available/default etc/prometheus/prometheus.yml var/www/html/index.html etc/linuxlab-managed.txt
sudo chown sampath:sampath /home/sampath/LinuxSysAdminLab-LNX01-files.tar.gz
chmod 600 /home/sampath/LinuxSysAdminLab-LNX01-files.tar.gz
tar -tzf /home/sampath/LinuxSysAdminLab-LNX01-files.tar.gz
~~~

- tar packages an explicit seven-file allowlist, not whole /etc or a VM disk.
- chown permits sampath to download the archive; chmod 600 restricts it to its owner.
- Listing screenshot confirms all seven expected entries.

### Package Ansible sources and stage on LNX01

**Where:** Exit the LNX01 SSH session to return to MGMT01.

~~~bash
exit
tar -czf /home/sampath/LinuxSysAdminLab-Ansible-files.tar.gz -C /home/sampath/LinuxSysAdminLab ansible/inventory.ini ansible/webserver.yml
tar -tzf /home/sampath/LinuxSysAdminLab-Ansible-files.tar.gz
scp -i /home/sampath/.ssh/ansible_ed25519 /home/sampath/LinuxSysAdminLab-Ansible-files.tar.gz sampath@10.20.20.3:/home/sampath/
~~~

The relative tar entries keep the two Ansible files organized. scp uses MGMT01's dedicated key to stage the archive on LNX01 for Windows retrieval.

### Download to Windows

**Where:** Windows PowerShell at PS C:\...>, outside any Ubuntu terminal.

~~~powershell
New-Item -ItemType Directory -Path "$HOME\LinuxSysAdminLab-ProjectFiles" -Force
scp -i "$HOME\.ssh\linuxlab_ed25519" -P 2222 sampath@127.0.0.1:/home/sampath/LinuxSysAdminLab-LNX01-files.tar.gz "$HOME\LinuxSysAdminLab-ProjectFiles"
scp -i "$HOME\.ssh\linuxlab_ed25519" -P 2222 sampath@127.0.0.1:/home/sampath/LinuxSysAdminLab-Ansible-files.tar.gz "$HOME\LinuxSysAdminLab-ProjectFiles"
~~~

- New-Item creates the destination in the Windows profile; $HOME is used without modification.
- scp -i selects the Windows private key; uppercase -P selects forwarded port 2222.
- Windows path screenshot resolves the directory to C:\Users\PSK\LinuxSysAdminLab-ProjectFiles.
- Two attempted New-Item commands in MGMT01 returned command not found; user subsequently opened the correct Windows PowerShell and created the directory.
- Initial Windows LNX01 archive transfer completed 100% (**2675 bytes**).
- Initial Ansible archive transfer failed “No such file or directory” on LNX01. Recreating/staging it from MGMT01 was instructed and reported complete.
- The retried Windows Ansible archive transfer screenshot shows 100% (**589 bytes**).

### Inspect actual user-uploaded archives

Both original .tar.gz files were attached and read directly on October 28. Members were inspected as data without executing the scripts or applying guest configurations. Each member was a small regular file with a relative path and no parent traversal component.

| Archive / member | Verified bytes | Findings |
|---|---:|---|
| LNX01: usr/local/sbin/linuxlab-backup.sh | 330 | Matches the supplied timestamped, restricted local tar backup script with gzip/list checks. |
| LNX01: etc/systemd/system/linuxlab-backup.service | 115 | oneshot, User=root, correct ExecStart. |
| LNX01: etc/systemd/system/linuxlab-backup.timer | 136 | Daily 02:00, Persistent=true, timers.target. |
| LNX01: etc/nginx/sites-available/default | 2412 | Actual default HTTP site: listen 80 IPv4/IPv6, /var/www/html root, index.html first; TLS directives commented out. |
| LNX01: etc/prometheus/prometheus.yml | 1429 | Existing prometheus localhost:9090 and node localhost:9100 jobs; global 15s, self-scrape 5s. Alertmanager localhost:9093 configured but not verified operational. |
| LNX01: var/www/html/index.html | 302 | Custom Linux Administration Lab homepage matches observed browser content. |
| LNX01: etc/linuxlab-managed.txt | 66 | Actual file matches the Ansible task's intended contents. |
| Ansible: ansible/inventory.ini | 233 | lnx01 .3, sampath account, dedicated MGMT01 key path, Python3 path and group sudo.ws override. |
| Ansible: ansible/webserver.yml | 632 | Actual three-task web-server baseline matches the tested playbook. |

No passwords, private key contents or tokens were found in these nine inspected text files. The inventory contains a private-key **path**, not the key itself. No public permission change, GitHub write, new repository or publication has occurred for the Linux project.

**At this milestone:** Dashboard JSON had not yet been attached. Milestone 39 records its subsequent upload and verification; milestone 40 records final packaging.


## Milestone 39 — Inspect the actual Grafana export and prepare a portable derivative

**Evidence:** The user uploaded LNX01-System-Monitoring.json. It parsed as a Dashboard resource with apiVersion=dashboard.grafana.app/v2, rather than the previously suggested Classic export. Preserve actual model choice when describing this artifact.

Verified title: LNX01 System Monitoring. Three time-series panels are present: LNX01 RAM Usage, LNX01 CPU Usage and LNX01 Root Disk Usage. All use unit percent and a 0–100 range. The actual queries match those recorded in milestones 26–27. Time settings are now-1h to now, autoRefresh=30s, timezone=browser.

The raw file includes local metadata and references Prometheus data-source UID bg2lvgb15s7wgf. It contains no collected metric history, login password or private key. Those resource IDs are instance identifiers, not credentials.

### Preserve original and create an importable variant

The repository includes:

- dashboards/LNX01-System-Monitoring.original-v2.json: exact uploaded bytes, including source-instance metadata.
- dashboards/LNX01-System-Monitoring.portable-classic.json: a derivative constructed from the original queries, visualization settings and grid positions. It uses a DS_PROMETHEUS import input in place of the source instance's fixed data-source UID and omits local identity metadata.

The derivative parsed and was checked for three matching queries, percent ranges, layout positions, one-hour time range and 30-second refresh. It was **not live-import tested** on a second Grafana instance. The original remains the authoritative export of the actual dashboard; the derivative is a prepared portability aid, not evidence of a second deployed dashboard.

JSON stands for JavaScript Object Notation. A data-source UID identifies Grafana's configured backend connection; it is distinct from Linux user IDs and from the Prometheus instance label localhost:9100.

## Milestone 40 — Package the completed build record and validate deliverables

**Where:** Documentation preparation workspace, separate from the user's Windows host and both guest VMs.

The nine source files from the two uploaded archives were copied without content changes into the repository layout. The original dashboard V2 JSON was preserved. A README, operations notes, validation record, topology diagram, selected real lab screenshots, source fingerprints, editable guide and PDF reading copy were added. These authored repository notes do not claim to have changed the running VMs.

### Artifact checks

- Inspect archive members as small regular relative-path files; do not execute arbitrary archive content.
- Parse the actual Ansible and Prometheus YAML and dashboard JSON.
- Check the backup script with bash -n (syntax only, no backup execution in this workspace).
- Confirm repository source bytes match the uploaded archive members.
- Confirm both dashboard models preserve the three expected expressions and percent units/ranges.
- Check packaged text for credentials/private-key blocks and exclude VM disks, ISOs, database files and backup payloads.
- Generate the PDF, render it to page images and visually inspect representative dense pages, tables, code, navigation and screenshots.
- Build and inspect the ZIP as a repository-root upload package, with no enclosing extra folder.

The validation record in docs/VALIDATION.md distinguishes local file checks from guest execution evidence. Neither a local YAML parse nor an artifact syntax check substitutes for the captured Ansible runs in the lab. The ZIP is ready for GitHub upload; no new Linux GitHub repository or commit has been created in this workflow.

### Resume wording grounded in this lab

- Built a two-VM Ubuntu administration lab with SSH key access, UFW rules, group-controlled permissions and an Nginx site; verified allowed/denied access and controlled service recovery.
- Implemented local backups with a daily systemd timer, verified deleted-file restoration using SHA-256 and access checks, and monitored RAM/CPU/disk with Prometheus and Grafana.
- Managed Nginx from a separate Ansible control VM, demonstrated an unchanged repeat run (changed=0) and corrected deliberately stopped-service drift by rerunning the playbook.

Avoid claiming production uptime, cloud deployment, autonomous self-healing, disaster recovery on independent hardware, alert notifications or a fully automated lab rebuild.

## Current progress, remaining work, and limitations — updated October 28, 2026

| Area | Current evidence / status |
|---|---|
| OS | 24.04.2 installed initially, later 26.04.1 screenshot-verified after release upgrade and reboot. |
| Recovery point | LNX01-Updated-Baseline and later LNX01-Monitoring-Backup snapshots reported created. |
| Networking | LinuxLab NAT prefix and enabled DHCP screenshot-verified; guest enp0s3 10.20.20.3/24. Static addressing/reservation pending. |
| SSH | Local login screenshot-verified; Windows port-forwarded login and fresh post-firewall connection confirmed by user report and supporting screenshots. Password login demonstrated earlier; dedicated key login now verified in milestone 21. |
| Firewall | Active default-deny incoming, allow outgoing, SSH 22 rule verified; HTTP 80 allowance instructed and functioning web access demonstrated. |
| Accounts / permissions | labuser, labteam and directory mode verified; member create/read and nonmember read/write denial screenshot-verified. |
| Website / logs | Nginx active and boot-enabled, local 200 response, custom webpage, access-log review verified. |
| Service recovery | Failed local request, Nginx start, recovered HTTP 200 and restored custom page screenshot-verified; status/journal diagnostic output not supplied. |
| SSH keys | Dedicated passphrase-protected Ed25519 key generated, public key installed and key-only client test screenshot-verified. Server password authentication has not been disabled. |
| Backups / restoration | Local baseline archive listed successfully; separate homepage extraction verified with matching SHA-256 hashes. Deleted shared file restored with matching hash, original permissions/ownership and labuser read access. Daily timer enabled, next run visible, manual systemd execution successful; Windows baseline copy hash-verified on the same physical computer; calendar-triggered run, retention and automated off-VM transfers pending. |
| Monitoring | Node Exporter/Prometheus verified; Windows SSH tunnels working; clock warning resolved; Grafana 13.2.4 healthy, authenticated, data source working, RAM/CPU/root-disk dashboard screenshot-verified, 1h/30s view verified; JSON export to Desktop reported; exporter outage/recovery up=0 then 1 verified. Export contents verified in milestone 39; derivative live import and alerting unverified. |
| Automation | MGMT01 installed/updated by report, DHCP .4 network verified, dedicated guest-to-guest key login to LNX01 verified. Ansible 14.5.0/core 2.21.5 installed via pipx; PATH repaired, inventory/ping verified, root elevation verified using saved sudo.ws override. Web-server playbook syntax/first run/idempotence screenshot-verified; stopped-service drift correction and HTTP recovery user-confirmed. Final service checks passed; actual inventory/playbook sources uploaded and inspected. |
| Portfolio | Actual LNX01 and Ansible archives uploaded and inspected; original V2 dashboard attached/inspected and portable Classic derivative prepared. Final documentation/PDF/GitHub package assembled; no Linux repository published. |
| Windows lab storage | Deletion/move of DC01, FS01 and CLIENT01 still unconfirmed. |

Future milestones will record completed work and meaningful troubleshooting rather than every click or short acknowledgement. Passwords and private keys remain excluded.

### Additional terminology

| Term | Meaning / role |
|---|---|
| UFW | Uncomplicated Firewall — manages guest firewall policy. |
| TCP | Transmission Control Protocol — transport used for SSH and the current HTTP site. |
| HTTP | Hypertext Transfer Protocol — web requests/responses; current lab uses unencrypted HTTP. |
| HTML | Hypertext Markup Language — structures the custom homepage. |
| UID / GID | User ID / Group ID — numeric account and group identifiers. |
| setgid / SGID | Set group ID — on this directory, causes new entries to inherit its owning group. |
| Loopback / localhost | The local machine in the command's current execution context. |
| Port forwarding | Maps a host listening address/port to a guest address/port. |
| Socket activation | A listening socket starts its associated service when needed. |
| systemd / systemctl | Linux service manager and the command used to inspect/control its units. |
| Snapshot | VM recovery point that depends on original virtual disk files. |

### Additional official references

- Ubuntu release upgrades: https://ubuntu.com/desktop/docs/en/latest/how-to/upgrade-ubuntu-desktop/
- Ubuntu SSH socket activation: https://discourse.ubuntu.com/t/sshd-now-uses-socket-based-activation-ubuntu-22-10-and-later/30189
- Ubuntu OpenSSH: https://ubuntu.com/server/docs/how-to/security/openssh-server/
- Nginx documentation: https://nginx.org/en/docs/

- systemd timer reference: https://www.freedesktop.org/software/systemd/man/latest/systemd.timer.html

- Node Exporter guide: https://prometheus.io/docs/guides/node-exporter/

- Grafana APT installation: https://grafana.com/docs/grafana/latest/setup-grafana/installation/debian/
- Grafana first sign-in: https://grafana.com/docs/grafana/latest/setup-grafana/sign-in-to-grafana/

- Grafana export documentation: https://grafana.com/docs/grafana/latest/visualizations/dashboards/share-dashboards-panels/

- Ansible pipx installation: https://docs.ansible.com/projects/ansible/latest/intro_installation.html
- Ubuntu sudo implementation differences: https://ubuntu.com/server/docs/reference/other-tools/sudo-rs/
- Upstream sudo-rs compatibility investigation: https://github.com/ansible/ansible/issues/85837
