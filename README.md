| Name             | Container/VM | Version   | Last update  | Type      | Status     | Notes                                                                                                                                                       |
| ---------------- | ------------ | --------- | ------------ | --------- | ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Firefly          | Treasury     | latest    |              | Container | Legacy     | Moved to beancount                                                                                                                                          |
| FireflyDB        | Treasury     | latest    |              | Container | Legacy     | Moved to beancount                                                                                                                                          |
| FireflyImporter  | Treasury     | latest    |              | Container | Legacy     | Moved to beancount                                                                                                                                          |
| NBarr            | NBarr        | latest    |              | Container | Legacy     |                                                                                                                                                             |
| Vaultwarden      | Confidant    | 1.30.1    | Nov 11, 2023 | Container | Needs work | Need to update encryption type. Log in and go to account details, security and keys. Enable KDF algorithm. No HyperBackup configured (missing ansible only) |
| Unifi controller | Gatekeeper   | 8.0.7     | Nov 11, 2023 | VM        | Needs work | [Image moved (read og image message)](https://github.com/linuxserver/docker-unifi-network-application). No HyperBackup configured                           |
| Traefik          | RaspberryPi  | 2.11.0    | Mar 09, 2024 | Container | Needs work | v3 is out. Need to update. No HyperBackup configured                                                                                                        |
| Syncthing        | Obsidian     | 1.26.1    | Nov 11, 2023 | Container | Working    | Updating with Ansible will show an error, but it's fine. No HyperBackup configured                                                                          |
| Pihole           | Gatekeeper   | 2023.11.0 | Nov 11, 2023 | VM        | Working    | No HyperBackup configured                                                                                                                                   |
| NPM              | Gatekeepr    | 2.10.4    | Nov 11, 2023 | VM        | Working    | No HyperBackup configured                                                                                                                                   |
| DDNS updater     | Gatekeeper   | v2.5.0    | Nov 11, 2023 | VM        | Deprecated | Need to clean it up. Deprecated in favour of Mikrotik DDNS                                                                                                  |
| Spotify-Mongo    | Radioactive  | 6.0.5     |              | Container | Working    | Can't update because of Raspberry Pi's architecture                                                                                                         |
| Spotify Server   | RaspberryPi  | 1.7.3     | Nov 11, 2023 | Container | Working    |                                                                                                                                                             |
| Spotify Client   | RaspberryPi  | 1.7.3     | Nov 11, 2023 | Container | Working    |                                                                                                                                                             |
| Location Tracker | RaspberryPi  | 1.7.3     | Feb 22, 2024 | Container | Working    | Read comments on Obsidian about docker compose version change and ansible. Assertion for running containers not working                                     |

Most of the magic happens over /ansible.

My current homelab consists of:

- Hardware:
  - Mikrotik router
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

## ISP

- 500mb fiber connection
- Connection is made through PPPoE configured on the mikrotik router.
  - PPPoE requires VLAN tagging of 40

## Virtual Machines

All VMs are run on Proxmox.

There are a few firewall security groups configured:

- dns: accept all protocols on port 53 from all local network
- secure: drop all connections coming from the public VLAN by checking the IP range
- ssh-reacheable: allows ssh connections from all local IP ranges. Including public VLAN _problematic_
- unifi: allows tcp on 6789, udp on 1900, tcp on 8080, udp on 10001, udp on 3478, tcp on 8443
- webpage: allow tcp on 443, allow tcp on 80, allow icmp

All machines have a default firewall policy of accept outgoing and drop incoming.

The vm list is:

- **LCX** Treasury: handles finance related containers

  - Static lease of 192.168.40.17
  - 512MB of RAM
  - 10GB of disk
  - VLAN tag 60
  - Firewall
    - Overall goal: only accessible within secure VLANs and no exposure at all
    - Security group: secure
    - Security group: ssh-reacheable
    - Security group: webpage

- **LCX** Obsidian: handles keeping obsidian in sync with github repo

  - Static lease of 192.168.40.18
  - 1GB of RAM
  - 6GB of disk
  - VLAN tag 60
  - Firewall
    - Overall goal: only accessible within secure VLANs and no exposure at all
    - Security group: secure
    - Security group: ssh-reacheable
    - Other rules for ports described here: https://hub.docker.com/r/linuxserver/syncthing

- **LCX** Confidant: handles secrets and passwords

  - Static lease of 192.168.40.19
  - 1GB of RAM
  - 6GB of disk
  - VLAN tag 60
  - Firewall
    - Overall goal: only accessible within secure VLANs and no exposure at all
    - Security group: secure
    - Security group: ssh-reacheable
    - Security group: webpage
    - Allow TCP on 3012 for notifications I believe

- **LCX** NBArr: Watch 1stream.eu on VLC. Test project for now

  - Static lease of 192.168.40.21
  - 1GB of RAM
  - 7GB of disk
  - VLAN tag 60
  - Firewall
    - Overall goal: only accessible within secure VLANs and no exposure at all
    - Security group: secure
    - Security group: ssh-reacheable
    - Security group: webpage
    - Allow TCP and UDP on 3000 for the stream. Might not need UDP?

- **LCX** L-Tracker: Location tracker storage and server

  - Static lease of 192.168.40.27
  - 1GB of RAM
  - 5GB of disk
  - VLAN tag 60
  - Firewall
    - Overall goal: only accessible within secure VLANs and no exposure at all
    - Security group: secure
    - Security group: ssh-reacheable
    - Allow TCP on 3000 for the UI

- **VM** Gatekeeper: Entrance point for all devices on the network. Contains everything from DNS server to reverse proxy to AP controller.

  - Static lease of 192.168.40.2
  - 4GB of RAM
  - 32GB of disk
  - VLAN tag 60
  - Firewall
    - Overall goal: only accessible within secure VLANs. Should need to expose some things specially for DNS and possibly wireguard, but still a critical service.
    - Security group: secure
    - Security group: ssh-reacheable
    - Security group: webpage
    - Security group: dns
    - Security group: unifi
    - Allow TCP
      - 8000 (unifi?)
      - 53 from 192.168.20.5 (radioactive)
      - 53 from 192.168.20.3 (raspberry pi)
      - 8081 to access pihole if DNS is down
      - 81 to access reverse proxy if DNS is down
    - Allow UDP
      - 53 from 192.168.20.5 (radioactive)
      - 53 from 192.168.20.3 (raspberry pi)

- **VM** Radioactive: VM that contains services that can´t run on the PI, but must be accessible to the internet on the public network. Very resource hungry because of the Spotify mongo DB implementation. So it that application alone uses a lot of CPU and memory. This is a VM and not a container to add another layer of security in case of a breach
  - Static lease of 192.168.20.5
  - 2GB of RAM
  - 3 CPUs
  - 7GB of disk
  - VLAN tag 20
  - Firewall
    - Overall goal: To be treated like the raspberry pi is treated. No need to be too intense on firewall rules since the router should take care of most.
    - Allow TCP
      - 827017
    - Drop all others IN

## Network

#### Divided into VLANs:

- Public VLAN (tag 20)
- Secure VLAN (tag 60)
- Native VLAN (tag 1)
- Work VLAN _Inactive_
- Guest VLAN (tag 30) _Inactive_
- WAN VLAN (tag 40). Used to talk with Ebox

Secure and Native VLANs probably shouldn´t be treated the same, but currently they are exactly the same thing in practice

#### WAN list contains:

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
  - Current untagged:
    - Ether2-workstation: hmm... not sure why that's there... doesn't that mean that workstation should be tagged 60? But it has a .88 IP...
- Work/Guest VLAN _inactive_:
  - ID: 30
  - Current tagged:
    - bridge-LAN
    - ether5-WLAN: Does tagging tiself
  - Current Untagged: empty

## Wifi

TODO

## TODOs:
