# FireflyIII

### What is it used for

Personal finance tracking.

### Migrating/restoring backup

Backup restoration should go smoothly. The only thing is that a new personal token might have to be generated and updated in the env vars

### Importing

To import you have to use the extension or somehow have a CSV of the transactions.
Then if you used the extension you can copy the `import_config.json` file from the Google Drive under the `Super duper final CSV export` folder. With that file all the import configurations should be set. After importing please move the CSV file to the appropriate folder and also make sure to create a copy of the import_config with the appropriate name so I know which config was used to import them.

Now there are two other files there, One to export from the old PSQL database to the CSV files and another one which I believe generates the import_config file for all the existing CSVs. None of them should ever be needed in practice.

### Gotchas

#### Add nginx config

The importer might send some big headers (?) so need to make sure that the reverse proxy can actually handle that. Specially for NGINX it's important to set this configuration:

```
  proxy_buffer_size   128k;
  proxy_buffers   4 256k;
  proxy_busy_buffers_size   256k;
```

#### Add UI importer timeouts

I had a note to write about this, but I forgot what it was. But apparently I had error with timeouts when doing my initial import with the UI. So in that case if you're doing a big import I suggest that the command line is used.

I _think_ the command to run that is:

```
sudo docker exec -it firefly-importer php artisan importer:auto-import /tmp/import???
```

### Env vars

All env vars in the compose-task
