# Grafana

### What is it used for

Grafana is basically a data visualizer. With it I create dashboards so I can visualize stats on the server, but also to create dashboards to view data on other personal databases


`initial-granfana-template` is a snapshot of the dashboard to monitor the server that I use to get started (see open questions).
`grafana.ini` is a config file.


### Open questions

- Not really sure how to better backup my dashboards. I need to test if they are stored in grafana_data at which point I can remove `initial-granfana-template`

### Volumes

`grafana.ini` is a config file and is mounted as a volume. Besides that there's another volume stored in the volumes folder that should be backed up.

### Env vars

No env vars are required

### How-to's

To add influx as a data source we have to configure it like this:
```
URL: http://influxdb:8086
Auth: No auth
Custom HTTP Header:
  Authorization  Token <auth token>
Database: telegraf
User: telegraf
Password: <password>
HTTP Method: POST
```