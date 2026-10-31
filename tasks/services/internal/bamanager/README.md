# Backup manager

This runs two containers:

- Backrest is the management, restore, retention and verification UI.
- rclone `serve restic` is the LAN-only append-only upload gateway to B2.

The gateway has a write-only B2 key. Backrest separately receives an
administrative rclone configuration so it can apply retention and prune old
Restic data. The manager configuration is also exposed read-only at
`/sources/bamanager-config` so the manager can back itself up with a native
Backrest plan. See the repository-level `BACKUPS.md` for deployment and setup.
