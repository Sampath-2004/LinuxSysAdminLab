# Validation record and practical limits

## Performed in the actual lab

Guest results were reported by the operator and/or supplied as screenshots. The detailed guide labels the evidence for each milestone.

| Check | Result / evidence |
|---|---|
| Group access | labuser created/read; nonmember sampath read/write denied, screenshots |
| Deleted-file recovery | original/restored SHA-256 matched; owner/group/mode and labuser read verified |
| Windows backup copy | full SHA-256 matched guest staging copy |
| Nginx recovery | failed request before start, HTTP 200 and custom page after start |
| Ansible connectivity/elevation | ping=pong and root UID=0 with sudo.ws |
| Ansible first run | ok=4 changed=1 unreachable=0 failed=0, screenshot |
| Ansible repeat | ok=4 changed=0 unreachable=0 failed=0, screenshot |
| Service drift | stopped-service HTTP failure captured; playbook recovery/HTTP 200 confirmed by operator |
| Prometheus target | up=1 initially, up=0 during exporter stop, up=1 after recovery |
| Grafana | health database=ok, version 13.2.4; three live metric panels |
| Final services | five active states; timer next run visible |
| Backup execution | successful manual systemd job in journal; no actual daily 02:00 success observed |

## Checked while preparing these files

- Both uploaded tar archives contained the expected nine small regular source files, with relative paths and no parent traversal entries.
- Repository copies preserve the bytes of those nine uploaded sources. SOURCE_SHA256SUMS.txt records their fingerprints.
- bash -n accepted the actual backup script. This syntax check did not run a backup here.
- The actual Ansible and Prometheus YAML parsed successfully; three playbook tasks and the localhost:9100 node target were verified structurally.
- Uploaded dashboard V2 JSON parsed and contained RAM, CPU and root-disk time-series panels, percent units, min/max 0/100, now-1h and 30s refresh.
- A derived Classic model preserves the three queries, display settings and grid positions, replacing the local data-source UID with an import-time input. It is structurally checked, not live-import tested.
- Text files were checked for private-key blocks, passwords/tokens and accidental private credential content. No such credentials are included.
- The PDF was rendered for visual inspection. No new claim of guest execution comes from local artifact checks.

## Limits to retain in a resume or demonstration

This is a learning lab with operator-invoked automation and local services. It has no TLS configuration, alert notifications, retention policy, static IP reservation or full-system automated rebuild. Backups omit later monitoring/automation configuration; same-laptop Windows storage is not off-site disaster recovery. Ansible was not scheduled as a self-healing service. Backup service success and a timer LAST timestamp are not proof of a successful daily calendar run. Installed packages may need updates after the captured checks.
