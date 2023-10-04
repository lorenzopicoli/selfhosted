# Unifi Controller

### What is it used for

Unifi controller takes care of my APs. It will collect statistics and keep information about their configuration.

### Gotchas

- It requires HTTPs so don´t try to reverse proxy it with HTTP
- It's important to add "unifi" as a domain on my local DNS and point it to the machine that runs this. This is because otherwise APs would stop being adopted for some reason after a few days (or 24h?)

### Volumes

It's good to backup the configuration so I don´t have to setup everything again (Vlans, SSIDs, etc).

Also I like to keep the statistics

### Env vars

Nothing. Password is saved in the config. There's an option to backup in the UI. Not sure if better to do on the UI or through the volume
