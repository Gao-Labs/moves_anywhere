# README: `image_upload`

- Developer: Tim Fraser <tmf77@cornell.edu>
- April 2024

## Purpose

`/image_upload` is a folder for developing and building a Docker image for uploading a `data.csv` of data to be in an online MySQL database. This script is developed with the intentions of being used primarily by Cornell developers.

Basic idea:

1. Mount a folder/bucket as `cat-api/inputs/`
2. Use `cat-api/inputs/parameters.json` to share metadata, namely `dtablename`, the name of the table that data will be written to.
3. The file `cat-api/inputs/data.csv` will be read in and written to table `dtablename` in the database.
4. The file `cat-api/inputs/fieldtypes.r` will be sourced to generate a named vector of fieldtypes for table `dtablename`. This is not a mounted file, but you can edit it if you need to change your table fieldtypes. Updates to this strategy likely forthcoming.
5. The database's connection information is stored in `.Renviron`, including environmental variables `ORDERDATA_USERNAME`, `ORDERDATA_PASSWORD`, `ORDERDATA_HOST`, `ORDERDATA_PORT`, and `ORDERDATA_DBNAME`.
6. If uploading to a Google Cloud SQL database, you can also mount SSL certificates, which will allow Google to authenticate your connection.



### Mounts

These files/folders must be mounted.

```
VOLUME /cat-api/inputs # Data inputs folder
VOLUME /cat-api/.Renviron # Environmental variables for MySQL connection
```

These files can optionally be mounted. We use them for connecting to Google Cloud SQL databases.
```
VOLUME /cat-api/server-ca.pem # SSL certificates (Optional), if your MySQL connection requires that.
VOLUME /cat-api/client-cert.pem # SSL certificates (Optional), if your MySQL connection requires that.
VOLUME /cat-api/client-key.pem # SSL certificates (Optional), if your MySQL connection requires that.
```
