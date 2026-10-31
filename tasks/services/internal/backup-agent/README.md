# Backup agent

This shared task creates the persistent Backrest directories and the root-only
credential file used by host-side backup scripts. The Backrest container itself
is declared in each application's Compose file so its source mounts remain
explicit and easy to audit.
