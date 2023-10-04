# Traefik

### What is it used for

Traefik handles reverse-proxy, that means that traefik is the service that is exposed to the internet and handles routing all traffic to the correct services. It makes sure I only need to open one port and it can also handle basic authentication.


Traefik is one of the few services that are open to the web. Ports 80 and 443 are handled by Traefik and that's why it has a static IP.


### Open questions

- Should I switch it out by cloudflare tunnel? Are they the same thing?

### Volumes

It has one volume which is basically one file called `acme.json`. It's very important to have it backed up as it as all the certificates to serve HTTPS.

### Env vars

No env vars