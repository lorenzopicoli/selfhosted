# Pihole

### What is it used for

Pihole is a DNS sink hole. We add lists of domains to block and by using pihole as our DNS server we can block ads, trackers and other nasty things

I assign a static IP to pihole so we can use it as the DNS server and we know the IP won't change

### Gotchas

Turning on "Conditional forwarding" might seem interesting to get hostnames properly, but it caused really weird issues where devices wouldn´t call PI so local DNS wouldn´t work. I think they might have been calling pihole, but it would forward to the router. It was weird

### Open questions

- How can I use pihole to connect through wireguard to local containers without ever opening them to the web? Is pihole even a part of this equation?

### Volumes

There are two volumes that are used by pihole. They are not necessarily essential as I can always fetch all lists again and I don't mind that much losing statistics, but it would be annoying so I like to think that backing up pihole data is essential

### Env vars

```
WEBPASSWORD=
```
