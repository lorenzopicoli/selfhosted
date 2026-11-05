# Proxmox
variable "PROXMOX_VE_API_TOKEN" {
  type      = string
  sensitive = true
  ephemeral = true
}

provider "proxmox" {
  endpoint  = "https://192.168.88.236:8006/"
  api_token = var.PROXMOX_VE_API_TOKEN
  # No certificate, that's why
  insecure  = true
}

# RouterOS
variable "ROUTEROS_PASSWORD" {
  type      = string
  sensitive = true
  ephemeral = true
}

provider "routeros" {
  hosturl  = "api://192.168.88.1:8728"
  username = "opentofu"
  password = var.ROUTEROS_PASSWORD
}
