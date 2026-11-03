## Current services

| Name                                                 | Backup     | Version       | Last update  | Type      | Status  | Notes                                                                                                                                                 |
| ---------------------------------------------------- | ---------- | ------------- | ------------ | --------- | ------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Lomnia](https://lorenzomodolo.com/projects/lomnia/) | Not yet    | latest        | Mar 22, 2026 | Container | Working |                                                                                                                                                       |
| Vaultwarden                                          | Yes        | 1.37.4-alpine | Nov 1, 2026  | Container | Working |                                                                                                                                                       |
| Unifi controller                                     | Yes        | 5.1.42        | Nov 2, 2026  | Container | Working |                                                                                                                                                       |
| Traefik                                              | Not yet    | 3.6.1         | Nov 14, 2025 | Container | Working | Has some logs about using deprecated syntax. Should probably take some time to drop this in favor of npm or npm in favour of traefik across the board |
| Syncthing                                            | Not yet    | 2.0.11        | Nov 14, 2025 | Container | Working |                                                                                                                                                       |
| Technitium                                           | Code ready | 15.4.0        | Mar 22, 2026 | Container | Working |                                                                                                                                                       |
| NPM                                                  | Not yet    | 2.14.0        | Mar 22, 2026 | Container | Working |                                                                                                                                                       |
| Spotify-Mongo                                        | Not yet    | 6.0.5         |              | Container | Working | Can't update because of Raspberry Pi's architecture                                                                                                   |
| Spotify Server                                       | Not yet    | 1.14.0        | Nov 14, 2025 | Container | Working |                                                                                                                                                       |
| Spotify Client                                       | Not yet    | 1.14.0        | Nov 14, 2025 | Container | Working |                                                                                                                                                       |
| Forgejo                                              | Yes        | 17.0.1        | Nov 1, 2026  | Container | Working |                                                                                                                                                       |
| Forgejo Actions Runner                               | No need    | 13.2.1        | Nov 2, 2026  | Container | Working |                                                                                                                                                       |
| Lofinance                                            | No need    | main          | Nov 1, 2026  | Container | Working |                                                                                                                                                       |
| Hoarder                                              | Not yet    | 0.31.0        | Mar 22, 2026 | Container | Working |                                                                                                                                                       |
| Dozzle                                               | Not yet    | v10.1.2       | Nov 1, 2026  | Container | Working |                                                                                                                                                       |
| Uptime Kuma                                          | Not yet    | 2.2.1         | Mar 22, 2026 | Container | Working |                                                                                                                                                       |
| Mgob                                                 | Not yet    | 2.0.27        | Dec 20, 2024 | Container | Working |                                                                                                                                                       |
| Owntracks recorder                                   | Yes        | 1.0.4-47      | Nov 2, 2026  | Container | Working |                                                                                                                                                       |
| Owntracks frontend                                   | Yes        | 2.15.3        | Nov 1, 2026  | Container | Working |                                                                                                                                                       |
| RouterOS                                             | Yes        |               | Nov 2, 2026  | Router    | Working |                                                                                                                                                       |
| Backrest manager                                     | Yes        |               | Nov 2, 2026  | Container | Working |                                                                                                                                                       |
| Restic gateway (rclone)                              | No need    |               | Nov 2, 2026  | Container | Working |                                                                                                                                                       |
| SFTP receiver (atmoz/sftp)                           | Files only |               | Nov 2, 2026  | Container | Working |                                                                                                                                                       |

## Backups

### Backup types

| Type    | How it runs                                                                                                                                      | Storage route                                                                            |
| ------- | ------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------- |
| Agent   | A systemd timer on the service host creates a consistent export, then calls the local Backrest plan. The plan's own backup schedule is disabled. | Local Backrest/Restic agent through the manager's append-only rclone gateway to B2.      |
| SFTP    | The device's scheduler uploads files to the manager's SFTP receiver. A separate Backrest plan on the manager backs up the receiving directory.   | SFTP to the manager, then directly to B2 through the manager's `b2-admin` rclone remote. |
| Manager | Backrest schedules a plan for its own configuration directory. No host systemd timer is involved.                                                | Directly to B2 through the manager's `b2-admin` rclone remote.                           |

### Backup schedule and coverage

| Service                   | Type    | Runs on                  | Backup time                                                                                 | Data covered                                                                              |
| ------------------------- | ------- | ------------------------ | ------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| Technitium                | Agent   | `pihole`                 | Daily at 01:00, America/Toronto, after setup                                                | Validated API ZIP with settings, zones, apps, DHCP scopes, authentication and statistics. |
| Vaultwarden               | Agent   | `confidant`              | Daily at 02:00, America/Toronto                                                             | Consistent SQLite export, Vaultwarden files and settings.                                 |
| Forgejo                   | Agent   | `forgejo`                | Daily at 03:00, America/Toronto                                                             | PostgreSQL dump and Forgejo data. Forgejo is stopped until the backup finishes.           |
| OwnTracks recorder        | Agent   | `owntracks`              | Daily at 04:00, America/Toronto                                                             | Recorder store and configuration archives. Recording resumes before the upload.           |
| OwnTracks frontend        | Agent   | `owntracks`              | Same 04:00 OwnTracks run                                                                    | Shares the recorder's backup plan. The frontend container is redeployed from Compose.     |
| UniFi controller          | Agent   | `unifi-controller`       | Daily at 05:00, America/Toronto                                                             | UniFi Network `.unf` export.                                                              |
| RouterOS                  | SFTP    | Router, then `bamanager` | Upload daily at 05:30 in the router's time zone; Backrest cron `0 6 * * *`, Local, at 06:00 | Dated `.backup` and `.rsc` files under `/sources/uploads/backup-routeros/incoming`.       |
| Backrest manager settings | Manager | `bamanager`              | Cron `0 4 * * *`, Local; daily at 04:00                                                     | Backrest configuration mounted at `/sources/bamanager-config`.                            |

All systemd calendar timers explicitly use America/Toronto, including the
Forgejo runner cleanup timer at 04:00. Agent timers add up to five minutes of
randomized delay and catch up after a missed run when the host starts again.
Keep the router's time zone aligned so its upload finishes before the 06:00 Backrest run.

### Retention and maintenance

These settings apply to all configured backup repositories and plans. The cron
schedules use Backrest's Local clock, America/Toronto.

| Operation | Cron, Local  | When                             | Settings                                           |
| --------- | ------------ | -------------------------------- | -------------------------------------------------- |
| Prune     | `30 5 1 * *` | First day of each month at 05:30 | Maximum unused after prune: 10%.                   |
| Check     | `0 7 1 * *`  | First day of each month at 07:00 | Read Data %: 100.                                  |
| Forget    | `0 5 * * *`  | Daily at 05:00                   | Keep 14 daily, 8 weekly, and 12 monthly snapshots. |

Prune and Check are repository settings. Retention belongs to each plan, with
Forget scheduled on the repository. Services marked Not yet or No need in the
services table have no backup plan listed here.

The RouterOS plan backs up the receiving folder without checking upload
freshness. A successful Backrest run can therefore contain older uploads.
Forget removes snapshots; it does not remove dated files still present in the
SFTP directory, which remain included in later snapshots. The manager settings
plan covers Backrest's configuration, not the whole manager host or the SFTP
server's SSH host-key volume.

---

## Log retention

The inventory separates `linux_servers` from `routers`. Linux maintenance
playbooks, including `linux-logging.yml` and `reclaim-space.yml`, target
`linux_servers`; RouterOS uses `routeros.yml`. Ansible's `all` group includes
both servers and routers.

Application playbooks include `tasks/linux-setup.yml` for shared package,
kernel and logging configuration. That task file includes `tasks/ssh.yml`
for the server account, sudo privileges, SSH keys and login settings.

Linux hosts use a 300 MiB persistent system journal limit, with individual files
limited to 30 MiB. Temporary journals in RAM are limited to 50 MiB, with 5 MiB
files. Journald rotates files and deletes the oldest archived files automatically.
Active journal files can cause usage to exceed the configured limit slightly.
Applying a changed policy also rotates and vacuums existing journals immediately.
These limits cover journald, not Docker logs or every file under `/var/log`.
Package-managed text logs retain their existing logrotate rules; the shared task
installs logrotate and enables its timer without replacing those rules.

The policy is included in the shared Linux setup. To apply it without deploying
applications, run from this repository:

```sh
ansible-playbook -i inventory.yml linux-logging.yml --limit pihole
# All Linux inventory hosts, excluding RouterOS:
ansible-playbook -i inventory.yml linux-logging.yml
```

Inventory variables `linux_journal_max_use`, `linux_journal_max_file_size`,
`linux_journal_runtime_max_use`, and `linux_journal_runtime_max_file_size` can
override those defaults per host or group. There is no additional age limit.

Technitium writes new logs to the console. Docker's `local` driver retains three
100 MiB files with compression, for approximately 300 MiB of log messages.
Use Dozzle or `docker logs dns-server` to read these logs. Technitium's Logs tab
and API backup no longer contain new log files; configuration and statistics
backups continue. Statistics retention is unchanged. See the
[Technitium setup](tasks/services/internal/technitium/README.md#log-rotation).

## General info

Most of the magic happens over /ansible.

My current homelab consists of:

- Hardware:
  - Mikrotik router
  - Thrifted switch
  - Unifi AP LR
  - HP Prodesk Mini G4
    - i5-8500T
    - 8GB SODIM DDR4
    - 500GB SSD
  - Raspberry Pi 4 4GB
  - Workstation
    - AMD Ryzen 588X
    - GTX 1060 3GB
    - 64GB DDR4
    - 1 500GB SSD (Linux)
    - 1TB M2 SSD (Windows)
  - Synology NAS
  - Beelink Mini S12 Pro
    - N100
    - 16GB DDR4
    - 500GB M.2

## ISP

- 500mb fiber connection
- Connection is made through PPPoE configured on the mikrotik router.
  - PPPoE requires VLAN tagging of 40

## Virtual Machines

All VMs are run on Proxmox.

All machines have a default firewall policy of accept outgoing and drop incoming.

## Network

#### Divided into VLANs

- Public VLAN (tag 20)
- Secure VLAN (tag 60)
- Native VLAN (tag 1)
- Work VLAN _Inactive_
- Guest VLAN (tag 30) _Inactive_
- WAN VLAN (tag 40). Used to talk with Ebox

Secure and Native VLANs probably shouldn´t be treated the same, but currently they are exactly the same thing in practice

#### WAN list contains

- PPPoE-Out1
- vlanWAN (VLAN used for internet connection)
- ether1-WAN

#### Router Firewall

TODO: ADD WIREGUARD CHANGES HERE

- Mikrotik firewall layer protects network primarily
  - Input chain
    - Established, related untracked are accepted
    - Drop invalid
    - Accept ICMP so pings should be allowed on the router
    - Accept local loopback not sure why
    - Secure VLAN is allowed to access the router through the INPUT chain
    - Native VLAN is allowed to access the router through the INPUT chain
    - Drop everything coming from the WAN list. So this should block the router from being accessible over the internet
    - Drop all other inputs
  - Forward chain
    - Allow the public VLAN to access the internet (in public, out pppoe-out1)
    - Allow secure VLAN to access all other VLANs
    - Allow Native VLAN to access all other VLANs
    - Allow ipsec
    - Fastrack established/related
    - Accept established/related
    - Accept DST NAT if out interface is public. So pretty much even if I DST NAT to my secure VLAN by mistake this should only allow the public VLAN to be accessed externally
    - Allow public VLAN to access private VLAN 192.168.40.2 machine on port 53 using TCP and UDP. This is because I want the pi traffic to use Pihole as DNS.
    - Drop invalid
    - Drop from WAN not DSTNATed
    - Drop all other

#### DHCP

Mikrotik serves a DHCP server with 3 different pools for different networks

- Secure VLAN uses 192.168.40.x
- Public VLAN uses 192.168.20.x
- Guest VLAN uses 192.168.30.x _Inactive_

#### Bridge configuration

Router has a bridge configured as follows:

- Dynamic VLAN should have:
  - ID: 1
  - Current tagged: empty
  - Current untagged:
    - bridge-LAN (itself)
    - ether3-Proxmox (webportal uses the native VLAN no specific reason I think)
    - ether5-WLAN the unifi AP uses native VLAN because it does the tagging itself on the wifi SSIDs. So I'm not sure how I could have it not use the native VLAN since it does the tagging itself.
    - ether2-Workstation. Mostly because I've locked the secure VLAN by mistake and it's good to have raw access to the router through this interface
- Public VLAN:
  - ID: 20
  - Current tagged:
    - bridge-LAN
    - ether3-Proxmox: because mongo db for the spotify runs on proxmox. So proxmox tags one machine to VLAN 20
    - ether5-WLAN: I was thinking of making guests use the public network. Not sure if a good or bad idea
  - Current Untagged:
    - ether4-PI so everything that comes out of ether4 is tagged as public. That's where the pi is connected
- Secure VLAN:
  - ID: 60
  - Current tagged:
    - Bridge-LAN
    - ether3-Proxmox: Proxmox uses private network primarily, but it does the tagging itself
    - ether5-WLAN: Unifi provides an SSID for secure network. It does the tagging itself
    - Ether2-workstation: tagged because the beelink also connects here with a switch
  - Current untagged: empty
- Work/Guest VLAN _inactive_:
  - ID: 30
  - Current tagged:
    - bridge-LAN
    - ether5-WLAN: Does tagging itself
  - Current Untagged: empty

### Restricted local application deployments

Application playbooks such as `lofinance.yml` include
`tasks/local-deployable.yml` to configure deployment from Forgejo Actions. The
shared public key is forced to run `/usr/local/sbin/local-deploy`; it cannot
open a shell or forward ports. The command pulls only the configured Compose
services, waits for readiness, restores their previous images if deployment
fails, and removes replaced images after a successful deployment.

Store the matching private key once as the user-level Forgejo Actions secret
`DEPLOY_SSH_KEY`. Private registry credentials are optional for public packages;
for private packages, add `LOCAL_DEPLOY_REGISTRY_USERNAME` and
`LOCAL_DEPLOY_REGISTRY_TOKEN` with `read:package` scope to `env_vars.yml`.
