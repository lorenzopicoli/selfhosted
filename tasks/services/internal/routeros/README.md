# RouterOS backups

`routeros.yml` installs the `backup-routeros` script and a daily RouterOS
scheduler entry at 05:30 in the router's configured time zone. The schedule is
defined in `backup-task.yml`, beside the script, like the server backup timers.
Ansible connects only during deployment; RouterOS runs the backups itself.

## Prerequisites

- Install `community.routeros` on the Ansible controller with
  `ansible-galaxy collection install community.routeros`. The API modules also
  need `librouteros` in Ansible's Python environment. For the existing pipx
  installation, use `pipx inject ansible librouteros`.
- Use RouterOS 7 with SSH known-host validation support. The
  script expects the ISO date format used since RouterOS 7.10.
- Enable the router's `api` service on the management network. Ansible connects
  directly to the router's IP using the unencrypted RouterOS API on port 8728.
  This is the native API protocol, separate from HTTP and the WebFig service.
  No hostname, TLS certificate, or CA file is required.
- The API user needs `api,read,write,policy,test,ftp,sensitive` permissions to
  manage the script and scheduler and run its backup operations. Use an
  existing management account or provision a dedicated account separately.
- Deploy the manager's [device upload receiver](../bamanager/README.md#device-uploads)
  with `bamanager.yml`. It creates the `backup-routeros` SFTP account and
  `/incoming` directory on port 2022. Configure the Backrest repository, plan,
  documented there. No command hooks are needed. The Restic gateway on port 8080
  serves the Linux agents; RouterOS uses the separate SFTP listener.
- Enable `known-hosts-validation` under `/ip/ssh` and pin the SFTP server's
  public host key under `/ip/ssh/known-hosts`. The script refuses to transfer
  files with validation disabled, and Fetch rejects unknown or changed keys.
  Keep `known-hosts-trusted-subnets` empty so it cannot bypass verification.

## Variables

Add these to the existing, untracked `env_vars.yml`:

```yaml
ROUTEROS_API_PORT: 8728
ROUTEROS_API_USERNAME: ansible
ROUTEROS_API_PASSWORD: '<management password>'
ROUTEROS_BACKUP_PASSWORD: '<binary backup encryption password>'
ROUTEROS_BACKUP_SFTP_PORT: 2022
ROUTEROS_BACKUP_SFTP_USERNAME: backup-routeros
ROUTEROS_BACKUP_SFTP_PASSWORD: '<upload account password>'
ROUTEROS_BACKUP_SFTP_PATH: /incoming
```

All variables above are required. The router's address and the manager's
SFTP address come from their `ansible_host` entries in `inventory.yml`, like
the other machines. The same SFTP username, password, and port configure both
sides. `/incoming` is the account's upload directory in the SFTP container.
Router administrators can read the credentials in the installed script.

## Deployment

```sh
ansible-playbook -i inventory.yml bamanager.yml
ansible-playbook -i inventory.yml routeros.yml --check
ansible-playbook -i inventory.yml routeros.yml
```

The API module updates entries named `backup-routeros` and leaves other scripts
and scheduler entries alone. Deployment does not run a backup or change the
router's clock, firewall, users, or management services. This playbook is separate
from `run_all.yml`, which deploys the Linux servers.

After deployment, test from the router terminal:

```routeros
/system/script/run backup-routeros
/log/print where message~"RouterOS backup"
```

Verify a scheduled run as well, since scheduler permissions can differ from
interactive permissions. Both managed entries use the same policy set.

## Output and recovery

Each run sends `routeros-YYYY-MM-DD-HHMMSS.backup` and the matching `.rsc`
export to the manager's SFTP container. Backrest backs up that receiving folder
on its normal schedule. A router-side success message confirms SFTP delivery;
verify the Backrest snapshot separately to confirm offsite storage. There is
no custom manifest, validation worker, or cleanup hook.

The script prevents overlapping runs and deletes temporary files on success
or failure. It does not delete remote history. The `.rsc` file contains plaintext
secrets, including the script's credentials, so keep the receiving directory
private and include it only in encrypted backups.

Keep the binary backup password outside the router. Restore `.backup` files to
the original device using the same RouterOS version. Use the text export as a
reference when rebuilding on replacement hardware. Text exports omit system
user passwords, installed certificates, and SSH keys. Export certificates and
private keys separately if you need them for recovery.

See the [Ansible RouterOS API module](https://docs.ansible.com/projects/ansible/latest/collections/community/routeros/api_modify_module.html),
[RouterOS backup documentation](https://manual.mikrotik.com/docs/getting-started/configuration-management/backup/),
and [RouterOS export documentation](https://manual.mikrotik.com/docs/getting-started/configuration-management/).
