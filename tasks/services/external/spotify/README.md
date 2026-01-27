# Spotify analytics

### What is it used for

Fun spotify analytics

### Open questions

- Maybe I should switch to the linuxserver image?
  - I def should. The original image is kinda sketchy and not updated

### Volumes

Spotify data in mongo database. Good to backup otherwise I'd have to request a new export

Mongo DB is running on a different host because it doesn´t support the raspberry pi

### Env vars

SPOTIFY_PUBLIC = client id
SPOTIFY_SECRET = secret token

```
SPOTIFY_PUBLIC=
SPOTIFY_SECRET=
```
