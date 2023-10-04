# Authelia

### What is it used for

Authelia handles part of the authorization and authentication in this stack.


If a service doesn't offer authentication Authelia is used as a Traefik middleware to make sure that the service can be safely made available online.

To add Authelia as a middleware to authenticate a service simply add the following label:

```
  - traefik.http.routers.<router>.middlewares=authelia-auth@docker
```

### Open questions

I'm still debating wether I should turn it on for every service I host and have two layers. Or configure it as a SSO option for services that support that like Portainer.

### Volumes

Config volume is stored in this folder. There's another folder mounted on the host system which stores data related to the statefullness of Authelia. From my tests it seems good to be backed up, but not a must have.

### Env vars

To run this container you must create a `.env` file in this folder. Here's the .env's template

```
AUTHELIA_JWT_SECRET=
AUTHELIA_SESSION_SECRET=
AUTHELIA_STORAGE_PASSWORD=
AUTHELIA_STORAGE_ENCRYPTION_KEY=
AUTHELIA_NOTIFIER_SMTP_HOST=
AUTHELIA_NOTIFIER_SMTP_PORT=587
AUTHELIA_NOTIFIER_SMTP_TIMEOUT=5s
AUTHELIA_NOTIFIER_SMTP_USERNAME=lorenzo@picco.li
AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE=
AUTHELIA_NOTIFIER_SMTP_IDENTIFIER=localhost
AUTHELIA_NOTIFIER_SMTP_SENDER="Authenzo <lorenzo@picco.li>"
AUTHELIA_NOTIFIER_SMTP_SUBJECT="[Authelia] {title}"
AUTHELIA_NOTIFIER_SMTP_STARTUP_CHECK_ADDRESS=lorenzo@picco.li
AUTHELIA_NOTIFIER_SMTP_DISABLE_REQUIRE_TLS=false
AUTHELIA_NOTIFIER_SMTP_DISABLE_HTML_EMAILS=false
AUTHELIA_NOTIFIER_SMTP_DISABLE_STARTTLS=false
AUTHELIA_NOTIFIER_SMTP_TLS_MINIMUM_VERSION=TLS1.2
AUTHELIA_NOTIFIER_SMTP_TLS_MAXIMUM_VERSION=TLS1.3
AUTHELIA_NOTIFIER_SMTP_TLS_SKIP_VERIFY=false
AUTHELIA_NOTIFIER_SMTP_TLS_SERVER_NAME=

```

You should also create a `users_database.yml` file under `config`. Template:

```
# This file can be used if you do not have an LDAP set up.

# List of users
users:
  lorenzo:
    displayname: "Lorenzo"
    # https://www.authelia.com/reference/guides/passwords/#passwords
    password: <hash>
    email: lorenzo@picco.li
    groups:
      - admins
      - dev
```

To generate a hash: https://www.authelia.com/reference/guides/passwords/#passwords