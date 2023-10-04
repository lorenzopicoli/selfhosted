# Dynamic DNS updater

### What is it used for

This is service that will pretty much keep watching if my IP changes and update my DNS provider
to point to the new IP. This is useful if my ISP updates my IP.
Websites could be down for the duration of the updates so 5min I believe

### Volumes

I think this could keep historical data on how often it was updated and stuff like that, but I had some errors while trying to do that so there are no volumes currently.

### Env vars
