# Traefik

### What is it used for

Share files and overall storage solution

### Gotchas

- Config must be a volume in the default dir. I can't have it mapped to `./config` I have some errors I don't understand
- Have to make sure that traefik has a `data.picco.li` alias otherwise the openId call from within the container can't resolve properly and I can't login
with this error:
```
context deadline exceeded (Client.Timeout exceeded while awaiting headers
```

### Open questions

- How much can I trust owncloud security?
- Should I change all config properties by env vars?

### Volumes

It has two volumes. Config is called config, but it has sensitive data in there. Everything should be backed up

### Env vars

```
IDM_ADMIN_PASSWORD=
NOTIFICATIONS_SMTP_PASSWORD=
```