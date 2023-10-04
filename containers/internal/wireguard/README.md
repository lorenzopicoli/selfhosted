# Wireguard

### What is it used for

Wireguard is a secure VPN that allows me to not worry about being on a public network since all my traffic is securely routed through the server.


On top of that a lot of people use Wireguard to safely connect to their containers without ever opening them to the web.

I use wireguard-portal to manage the configuration through a GUI. I don't use it as a docker container through. I explain why in this issue: https://github.com/h44z/wg-portal/issues/156

As a snapshot of the issue:



> I wanted to share my setup running wg-portal without `network_mode: host`. As answered [here](https://github.com/h44z/wg-portal/issues/109) and [here](https://github.com/h44z/wg-portal/issues/22) this project [needs to have access](https://github.com/h44z/wg-portal/issues/134#issuecomment-1365897351) to the `wg0` interface to properly run.

> I run wireguard with the `linuxserver/wireguard` container and I'm installing `wg-portal` in the same container using their [custom scripts](https://www.linuxserver.io/blog/2019-09-14-customizing-our-containers). Here's how it looks like:

```
 - docker-compose.yml (with linuxserver/wireguard)
 - custom-cont.init.d
   - wireguard-portal-install.sh
 - custom-service-init.d
   - wireguard-portal.sh
```

> Then in `docker-compose.yml`
```
- ./custom-cont-init.d/:/custom-cont-init.d/
- ./custom-services.d/:/custom-services.d/
```


> To install wg-portal in `wireguard-porta-install.sh`

```
#!/usr/bin/with-contenv bash

echo "****** Installing wg-portal ******"
apt update
apt install golang-go -y
export PATH=$PATH:/usr/local/go/bin

git clone https://github.com/h44z/wg-portal.git /app/wg-portal-project
cd /app/wg-portal-project
# CGO_ENABLED=0 GOOS=linux /usr/lib/go-1.18/bin/go build -o wg-portal main.go
make build
cp ./dist/wg-portal /app/
rm -rf /app/wg-portal-project
```

> And then in `wireguard-portal.sh` to run
```
#!/usr/bin/with-contenv bash
echo "SYSTEM SERVICE"
exec \
    /app/wg-portal
```

> In the container logs there should be some errors which is wireguard-portal trying to init before wg0 is created, but right after it the server should be up and running.

> As far as I'm aware the only drawback is that not running wg-portal in a container makes it harder to keep updated with something like `Watchtower`, but it was a requirement for me to run wg-portal behind traefik which is not in network_mode: host.


-----


To run wireguard I need to add IP table rules for both the VPN and Web subnets. Not really sure why.

### Open questions

- How can I use pihole to connect through wireguard to local containers without ever opening them to the web? Is pihole even a part of this equation?

### Volumes

The only volume is the volume that stores the keys and peer information. This is highly sensitive data, but losing them is not a huge deal since we can always regenerate them. But to avoid the hassle of having to do that I recommend backing up the volume.

### Env vars

No env vars required