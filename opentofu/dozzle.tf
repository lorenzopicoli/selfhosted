resource "proxmox_virtual_environment_container" "dozzle" {
  delete_unreferenced_disks_on_destroy = false
  description                          = ""
  environment_variables                = {}
  hook_script_file_id                  = ""
  migrate                              = false
  node_name                            = "proxmox"
  pool_id                              = null
  protection                           = false
  purge_on_destroy                     = true
  start_on_boot                        = true
  started                              = true
  tags                                 = ["192.168.40.25"]
  template                             = false
  timeout_clone                        = 1800
  timeout_create                       = 1800
  timeout_delete                       = 60
  timeout_migrate                      = 1800
  timeout_update                       = 1800
  unprivileged                         = true
  vm_id                                = 102
  console {
    enabled   = true
    tty_count = 2
    type      = "tty"
  }
  cpu {
    architecture = "amd64"
    cores        = 2
    limit        = 0
  }
  disk {
    acl           = false
    datastore_id  = "local-lvm"
    mount_options = []
    quota         = false
    replicate     = false
    size          = 6
  }
  features {
    fuse    = false
    keyctl  = false
    mknod   = false
    mount   = []
    nesting = true
  }
  initialization {
    hostname = "dozzle"
    ip_config {
      ipv4 {
        address = "dhcp"
        gateway = ""
      }
    }
  }
  memory {
    dedicated = 1024
    swap      = 512
  }
  network_interface {
    bridge       = "vmbr0"
    enabled      = true
    firewall     = true
    host_managed = false
    mac_address  = "BC:24:11:D1:0E:07"
    mtu          = 0
    name         = "eth0"
    rate_limit   = 0
    vlan_id      = 60
  }
  operating_system {
    template_file_id = proxmox_download_file.debian_13_lxc.id
    type             = "debian"
  }

  lifecycle {
    ignore_changes = [
      timeout_start,
      # To not rebuild the existing LXC
      operating_system[0].template_file_id,
    ]
  }
}

resource "proxmox_virtual_environment_firewall_options" "dozzle" {
  node_name    = "proxmox"
  container_id = proxmox_virtual_environment_container.dozzle.vm_id

  enabled       = true
  dhcp          = true
  ndp           = true
  radv          = false
  macfilter     = true
  ipfilter      = false
  log_level_in  = "nolog"
  log_level_out = "nolog"
  input_policy  = "DROP"
  output_policy = "ACCEPT"
}

resource "proxmox_virtual_environment_firewall_rules" "dozzle" {
  container_id = proxmox_virtual_environment_container.dozzle.vm_id
  node_name    = "proxmox"
  vm_id        = null
  rule {
    action         = "ACCEPT"
    comment        = ""
    dest           = ""
    dport          = "8080"
    enabled        = true
    iface          = ""
    log            = "nolog"
    macro          = ""
    proto          = "tcp"
    security_group = ""
    source         = ""
    sport          = ""
    type           = "in"
  }
  rule {
    security_group = proxmox_virtual_environment_cluster_firewall_security_group.basics.name
    enabled        = true
  }
}

resource "routeros_ip_dhcp_server_lease" "dozzle" {
  ___id___               = null
  ___path___             = null
  address                = "192.168.40.25"
  address_lists          = ""
  allow_dual_stack_queue = null
  always_broadcast       = null
  block_access           = null
  client_id              = "ff:11:d1:e:7:0:1:0:1:2e:f6:47:17:bc:24:11:d1:e:7"
  comment                = null
  dhcp_option            = ""
  dhcp_option_set        = null
  disabled               = false
  insert_queue_before    = null
  lease_time             = null
  mac_address            = "BC:24:11:D1:0E:07"
  rate_limit             = null
  server                 = "dhcp-SECURE"
  use_src_mac            = null
}
