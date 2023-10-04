# Vaultwarden

### What is it used for

Password manager that I can host myself. Works pretty well on all devices even if it's not as user friendly as something like 1password

### Gotchas

Important to make sure that the domain can resolve well and that it can use HTTPS. With that it's possible to keep syncing working with the Bitwarden apps. Obviously outside of the local LAN syncing wouldn´t work, but with a VPN it should be more than enough

### Volumes

One volume which is saved in the expected location. Must be backed up. Contains extremely sensitive information. If lost it's not the end of the world as data is stored locally on each device, but really shouldn't.

### Env vars

Check main doc for a template of .env. Since there's a lot of config. Here are the ones I'm using

```
WEBSOCKET_ENABLED=true
ORG_EVENTS_ENABLED=true
EVENTS_DAYS_RETAIN=
SIGNUPS_ALLOWED=false
SIGNUPS_VERIFY=true
PASSWORD_HINTS_ALLOWED=false
DOMAIN=https://pass.picco.li
SMTP_HOST=
SMTP_FROM=
SMTP_FROM_NAME=Lorenzo Vault
SMTP_PORT=587
SMTP_USERNAME=
SMTP_PASSWORD=
SMTP_TIMEOUT=15
```
