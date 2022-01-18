# Helper Repo - Docker MySQL

Helper Repo for setting up Docker Container with multiple MySQL databases. Used in production and development.

Idea from this blog article:

<https://onexlab-io.medium.com/docker-compose-mysql-multiple-database-fe640938e06b>

## Setup

The `db` folder will be our local volume for the database. Inside the `init` folder you can generate the databases. Inside the `init` you may need to adapt the user to your db user as stated in the `.env` file.

## Network

Other containers need to attach to the custom created network `btree-db-network`.

```bash
# Docker-compose.yml - of your other container
version: "3.3"

services:
  your-service:
    ....

networks:
  default:
    external: true
    name: btree-docker-mysql_btree-db-network
```

The hostname is the container name, eg. for database connection use `DATABASE_HOST=DockerMySQL` and you need to use the internal port of the mysql container `3306` not the exposed one.

PS: You need to use Docker-compose Version > 2 also in your other containers to use the network command.

## Backup

May look into following option for production safety: <https://hub.docker.com/r/databack/mysql-backup>