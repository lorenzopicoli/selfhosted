terraform {
  required_version = "= 1.13.5"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "= 0.120.0"
    }

    routeros = {
      source  = "terraform-routeros/routeros"
      version = "= 1.99.1"
    }
  }
}
