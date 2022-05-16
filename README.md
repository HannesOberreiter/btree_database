# Helper Repo - Docker MySQL and MariaDB

Helper Repo for setting up Docker Container with multiple MySQL and MariaDB databases. Used in production and development.

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

The hostname is the container name, eg. for database connection use `DATABASE_HOST=DockerMySQL` or `DATABASE_HOST=DockerMariaDB` and you need to use the internal port of the mysql container `3306` not the exposed one.

PS: You need to use Docker-compose Version > 2 also in your other containers to use the network command.

## Fixed IP for Reverse Proxy

To use a fixed IP range for your local ngnix reverse proxy you can set a subnet mask:

```yaml
networks:
  btree-db-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.18.0.0/16
```

In your `upstream.conf` you can use the ports of your services, eg:

```bash
# path: /etc/nginx/conf.d/upstream.conf

# Strapi server
upstream beekeeping_news_com_strapi {
    server 172.18.0.1:1337;
}
```

## Backups

Backups are done daily with `databack/mysql-backup`: <https://hub.docker.com/r/databack/mysql-backup>

File destination is a secure Nextcloud server, were as the backup folder is mounted on linux with webDAV: <https://docs.nextcloud.com/server/23/user_manual/en/files/access_webdav.html#creating-webdav-mounts-on-the-linux-command>
