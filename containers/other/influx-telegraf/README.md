# Influx & Telegraf

### What is it used for

Influx is a database that is built specifically for time series data. So it works perfectly with Telegraf which is a service that runs and probes the machine for information which is then stored in Influx.

We use Influx as a data source in Grafana to monitor the host and containers.

Because Telegraf has to gather data from other containers, the host, the network, etc it has access to many many parts of the system. This is run as docker-compose to facilitate starting and maintaining, but it has access to all parts of the host.


### Open questions

- Influx seems to use a lot of CPU and memory. Considering changing

### Volumes

No data is essential here since it's just monitoring the machine. With that being said Influx data is stored in the default volume location and backing it up is a good idea.

Telegraf has a bunch of volumes which I don't even thing it's worth explaining. They are all to give it access to some part of the host machine

### Env vars

Env vars are needed to configure the Influx DB. A `.env` file should exist in this folder:

```
DOCKER_INFLUXDB_INIT_MODE=setup
DOCKER_INFLUXDB_INIT_USERNAME=telegraf
DOCKER_INFLUXDB_INIT_PASSWORD=
DOCKER_INFLUXDB_INIT_ORG=telegraf
DOCKER_INFLUXDB_INIT_BUCKET=telegraf
DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=
```

### How-to's

Influx has a UI which can be accessed by adding it to traefik and opening it up to the internet. This could change if I add a way to use wireguard to access containers