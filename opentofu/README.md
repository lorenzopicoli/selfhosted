Run

```
read -rs 'PGPASSWORD?PostgreSQL password: '
export PGPASSWORD
```

And create `secrets.auto.tfvars` with:

```
PROXMOX_VE_API_TOKEN = ""
ROUTEROS_PASSWORD = ""
```
