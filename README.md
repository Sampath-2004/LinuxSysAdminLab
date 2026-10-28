# LinuxSysAdminLab

A two-VM Linux administration lab by **Sampath Kumar Peddagolla**: administer an Ubuntu web server, enforce access controls, test backups and recovery, collect metrics, and manage service state from an Ansible control VM.

## Demonstrated work

- Nginx serves a custom HTML page; access logs and a controlled outage/recovery were examined.
- SSH public-key login works from Windows and from MGMT01 to LNX01; UFW permits SSH and HTTP.
- A group-controlled directory allows labuser access and denies nonmembers without elevation.
- A local tar backup was inspected; a deleted file was restored with matching SHA-256, ownership and permissions, and tested as labuser.
- A daily 02:00 America/Chicago systemd timer is enabled. A manual service run succeeded; an actual 02:00 run was not observed during the build.
- A Windows copy of the baseline backup was verified with a matching full SHA-256.
- Prometheus scrapes Node Exporter; Grafana displays RAM, CPU and root-disk usage. A controlled exporter outage produced up=0, then up=1 after recovery.
- The Ansible webserver playbook produced changed=1 initially and changed=0 on repetition. A stopped Nginx service was corrected on rerun, with final HTTP recovery confirmed by the operator.

## Lab environment

| Machine | Role | Observed address | Observed OS / tooling |
|---|---|---|---|
| LNX01 / lnx01 | Web server, monitoring, local backup | 10.20.20.3/24 | Ubuntu 26.04.1 LTS, Grafana 13.2.4 |
| MGMT01 | Ansible control node | 10.20.20.4/24 | Ubuntu Noble repositories; Ansible 14.5.0 / core 2.21.5 via pipx, Python 3.12.3 |
| Windows host | VirtualBox, browser and SSH client | Loopback for forwarding | SSH 2222, HTTP 8080; SSH tunnels for 9090 and 3000 |

LinuxLab is a VirtualBox NAT Network, 10.20.20.0/24, with DHCP and gateway 10.20.20.1. Guest addresses are current DHCP leases, not static reservations. Adjust the inventory and forwarding targets if leases change.

## Start here

1. Read [the full project guide](docs/project-guide.md) for the build sequence, exact commands, their execution context, explanations and evidence.
2. Use [operations notes](docs/OPERATIONS.md) to reconnect, inspect services and run the existing automation.
3. See [validation and limits](docs/VALIDATION.md) to distinguish guest execution evidence from local artifact checks.
4. Import [the portable dashboard](dashboards/LNX01-System-Monitoring.portable-classic.json), selecting your own Prometheus data source. The [original V2 export](dashboards/LNX01-System-Monitoring.original-v2.json) is also preserved.
5. Open the [PDF reading copy](docs/LinuxSysAdminLab_Complete_Project_Guide.pdf) for a formatted guide. Use original source files or Markdown for copying long commands.

## Source layout

| Folder | Contents |
|---|---|
| ansible | Actual tested inventory and limited web-server playbook |
| scripts | Actual timestamped local backup script |
| systemd | Actual backup oneshot service and daily timer |
| configs | Actual Nginx site and Prometheus configuration |
| site | Custom homepage |
| dashboards | Original V2 export and derived portable Classic model |
| evidence | Collected administration record and source checksums |
| images | Selected actual lab screenshots and a topology diagram |
| docs | Build guide, PDF, operations and validation notes |

## Reuse prerequisites

This repository is a build record and a small tested automation example. It is not a complete unattended deployment of the two VMs.

Before running Ansible, prepare a reachable Ubuntu target, Python, SSH, your own authorized key and a sudo-capable account. Update ansible/inventory.ini for your address, username and key path. The group variable uses /usr/bin/sudo.ws, which was verified on LNX01; verify that binary exists on your target or choose its supported sudo executable. Do not disable host-key verification.

The backup script expects /var/www/html, /etc/nginx and /srv/labshare to exist. Installing the timer requires copying its files to /etc/systemd/system and the script to /usr/local/sbin with appropriate root ownership/permissions, then daemon-reload and enable --now. Follow the full guide rather than executing arbitrary files as a bulk installer.

## Scope

No passwords, private keys, VM disks, installation ISOs, backup payloads or Grafana database are included. Dashboard thresholds are display settings, not alert rules. The original Grafana export references a local data-source UID; the derived portable model prompts for a data source but has not been live-import tested. The backup covers the three documented source trees, not the whole system, later monitoring configuration or account databases. Retention, automatic external copies, TLS, alert notifications and static addressing are follow-up work.

The completed Windows lab is a separate project: https://github.com/Sampath-2004/SysAdminLab
