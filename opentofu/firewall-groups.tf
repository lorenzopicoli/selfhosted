resource "proxmox_virtual_environment_cluster_firewall_security_group" "basics" {
  comment      = ""
  container_id = null
  name         = "basics"
  node_name    = null
  vm_id        = null
  rule {
    action         = "ACCEPT"
    comment        = ""
    dest           = ""
    dport          = "7007"
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
    action         = "ACCEPT"
    comment        = ""
    dest           = ""
    dport          = ""
    enabled        = true
    iface          = ""
    log            = "nolog"
    macro          = ""
    proto          = "icmp"
    security_group = ""
    source         = ""
    sport          = ""
    type           = "in"
  }
  rule {
    action         = "ACCEPT"
    comment        = ""
    dest           = ""
    dport          = "22"
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
}
