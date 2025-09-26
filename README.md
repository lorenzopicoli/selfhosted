## Current services

| Name               | Container/VM | Version   | Last update  | Type      | Status     | Notes                                                                                                                                                                                                                                                                               |
| ------------------ | ------------ | --------- | ------------ | --------- | ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Vaultwarden        | Confidant    | 1.32.5    | Nov 23, 2024 | Container | Working    |                                                                                                                                                                                                                                                                                     |
| Unifi controller   | Gatekeeper   | 8.0.7     | Nov 11, 2023 | VM        | Needs work | [Image moved (read og image message)](https://github.com/linuxserver/docker-unifi-network-application). But new image requires a separate mongodb instance... Need to check how it will affect the resources that I have to allocate for this in proxmox. No HyperBackup configured |
| Traefik            | RaspberryPi  | 3.2.1     | Nov 29, 2024 | Container | Working    |                                                                                                                                                                                                                                                                                     |
| Syncthing          | Obsidian     | 1.28.0    | Nov 23, 2024 | Container | Working    |                                                                                                                                                                                                                                                                                     |
| Pihole             | Gatekeeper   | 2024.07.0 | Nov 11, 2023 | VM        | Working    |                                                                                                                                                                                                                                                                                     |
| NPM                | Gatekeepr    | 2.12.1    | Nov 11, 2023 | VM        | Working    |                                                                                                                                                                                                                                                                                     |
| Spotify-Mongo      | Radioactive  | 6.0.5     |              | Container | Working    | Can't update because of Raspberry Pi's architecture                                                                                                                                                                                                                                 |
| Spotify Server     | RaspberryPi  | 1.11.0    | Nov 29, 2023 | Container | Working    |                                                                                                                                                                                                                                                                                     |
| Spotify Client     | RaspberryPi  | 1.11.0    | Nov 29, 2023 | Container | Working    |                                                                                                                                                                                                                                                                                     |
| Location Tracker   | L-tracker    | In-house  | Feb 22, 2024 | Container | Deprecated | Read comments on Obsidian about docker compose version change and ansible. Assertion for running containers not working                                                                                                                                                             |
| Forgejo            | Forgejo      | 9.0.2     | Nov 23, 2024 | Container | Working    |                                                                                                                                                                                                                                                                                     |
| Lofinance          | lofinance    | latest    | Nov 30, 2024 | Container | Working    |                                                                                                                                                                                                                                                                                     |
| Hoarder            | hoarder      | 0.19.0    | Dec 16, 2024 | Container | Working    |                                                                                                                                                                                                                                                                                     |
| Dozzle             | dozzle       | 8.9.0     | Dec 20, 2024 | Container | Working    |                                                                                                                                                                                                                                                                                     |
| Uptime Kuma        | uptime-kuma  | 1         | Dec 20, 2024 | Container | Working    |                                                                                                                                                                                                                                                                                     |
| Mgob               | mgob         | 2.0.27    | Dec 20, 2024 | Container | Working    |                                                                                                                                                                                                                                                                                     |
| Hares              | hares        | main      | Jan 13, 2025 | Container | Working    |                                                                                                                                                                                                                                                                                     |
| Owntracks recorder | owntracks    | 0.9.9-41  | Jan 14, 2025 | Container | Working    |                                                                                                                                                                                                                                                                                     |
| Owntracks frontend | owntracks    | 2.15.3    | Jan 14, 2025 | Container | Working    |                                                                                                                                                                                                                                                                                     |

---

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
    - Ether2-workstation: tagged because the beelink also connects here with a switch
  - Current untagged: empty
- Work/Guest VLAN _inactive_:
  - ID: 30
  - Current tagged:
    - bridge-LAN
    - ether5-WLAN: Does tagging itself
  - Current Untagged: empty

## Wifi

TODO

## TODOs:
