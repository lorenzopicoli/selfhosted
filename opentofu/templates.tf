resource "proxmox_download_file" "debian_13_lxc" {
  content_type = "vztmpl"
  datastore_id = "local"
  file_name    = "debian-13-standard_13.6-1_amd64.tar.zst"
  node_name    = "proxmox"
  url          = "http://download.proxmox.com/images/system/debian-13-standard_13.6-1_amd64.tar.zst"
  overwrite    = false

}
