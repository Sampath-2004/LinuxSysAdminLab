# Operating the existing lab

## Connect from Windows PowerShell

Keep LNX01 running. The VirtualBox LinuxLab rule forwards host loopback 2222 to LNX01:22.

```powershell
ssh -i "$HOME\.ssh\linuxlab_ed25519" -p 2222 sampath@127.0.0.1
```

Open separate PowerShell windows for each browser tunnel and leave them running:

```powershell
ssh -i "$HOME\.ssh\linuxlab_ed25519" -p 2222 -N -o ExitOnForwardFailure=yes -L 127.0.0.1:9090:127.0.0.1:9090 sampath@127.0.0.1
ssh -i "$HOME\.ssh\linuxlab_ed25519" -p 2222 -N -o ExitOnForwardFailure=yes -L 127.0.0.1:3000:127.0.0.1:3000 sampath@127.0.0.1
```

Browse Windows loopback: http://127.0.0.1:8080 for the site, :9090 for Prometheus, :3000 for Grafana. The HTTP 8080 rule is separate from the SSH tunnels. Ctrl+C closes a forwarding-only tunnel; Ubuntu shutdown also ends it.

## Inspect on LNX01

```bash
systemctl is-active nginx prometheus-node-exporter prometheus grafana-server linuxlab-backup.timer
sudo ufw status verbose
systemctl list-timers linuxlab-backup.timer --no-pager
sudo journalctl -u linuxlab-backup.service --since today --no-pager
curl -fsS --max-time 10 http://localhost:3000/api/health
```

is-active prints each state in the order given. A successful oneshot backup service may be inactive after finishing; the timer, not the finished job, should remain active. Inspect the journal for Backup verified and Finished, not only a timer LAST timestamp.

## Run the existing automation from MGMT01

```bash
cd /home/sampath/LinuxSysAdminLab/ansible
ansible-inventory -i inventory.ini --graph
ansible -i inventory.ini linux_servers -m ansible.builtin.ping
ansible-playbook -i inventory.ini webserver.yml --syntax-check
ansible-playbook -i inventory.ini webserver.yml -K
```

Enter LNX01's sudo password at BECOME password; never save it in the inventory. If the management key is passphrase-protected and is not already available through an agent, load it in the current management session using ssh-add with the dedicated key after ensuring an agent is available. Private keys stay outside the repository.

The playbook maintains only Nginx installation/service state and /etc/linuxlab-managed.txt. An unchanged repeat produced changed=0. An operator must invoke it; it is not a persistent self-healing service.

## Dashboard import

The portable Classic JSON is derived from the uploaded original. In Grafana use Dashboards > New > Import, upload the portable file, and choose your Prometheus data source when prompted. This import procedure has not been run on a second Grafana instance. The original V2 file is preserved for the source installation; it contains local resource metadata and a data-source UID. Do not describe the V2 export as a Classic export.

## Backup and recovery

```bash
sudo /usr/local/sbin/linuxlab-backup.sh
```

This creates a uniquely named gzip tar archive and checks gzip integrity plus tar readability. It does not automatically delete old archives or copy them outside the VM. A full disk can still break backups; monitor free space. Do not commit backup archives.

Before restoring an important file, list the archive, identify the exact member, and extract to a separate test directory first. The guide contains the tested SHA-256 and deleted-file recovery procedure. A backup on the same Windows laptop protects against some guest errors, not loss of that physical device.

## Maintenance follow-ups

- Apply available package updates in each VM during a planned window and recheck services afterward. LNX01's later login banner listed 19 updates; no final upgrade was performed.
- Verify an actual daily timer execution after 02:00, including its successful journal output.
- Reserve stable addresses or deliberately configure a non-conflicting static plan before relying on these DHCP targets long-term.
- Extend backup scope deliberately for monitoring settings, dashboard/database consistency and automation files; the current three-tree archive does not include them.
- Keep the original VM files for snapshot recovery. Do not delete them merely because repository files exist.
