import {
  to = proxmox_download_file.debian_13_lxc
  id = "proxmox/local:vztmpl/debian-13-standard_13.6-1_amd64.tar.zst"
}

import {
  to = proxmox_virtual_environment_container.dozzle
  id = "proxmox/102"
}

import {
  to = proxmox_virtual_environment_firewall_options.dozzle
  id = "container/proxmox/102"
}

import {
  to = proxmox_virtual_environment_firewall_rules.dozzle
  id = "container/proxmox/102"
}

import {
  to = proxmox_virtual_environment_cluster_firewall_security_group.basics
  id = "basics"
}

import {
  to = routeros_ip_dhcp_server_lease.dozzle
  id = "*2867"
}
