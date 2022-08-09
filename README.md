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

## Docker Image upgrade

Use `docker-compose pull` to get latest images, then `docker_compose down && docker-compose up -d`. Use `docker image prune -af` to remove unused images.

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

Backups are saved to Amazon AWS S3 storage.

Old: File destination is a secure Nextcloud server, were as the backup folder is mounted on linux with webDAV: <https://docs.nextcloud.com/server/23/user_manual/en/files/access_webdav.html#creating-webdav-mounts-on-the-linux-command>

## Other Server Stuff

To keep the server updated and clean of memory leaks I restart it daily and perform updates daily:

```bash
# Custom CronJobs
# etc/crontab
0 2 * * * root /usr/bin/apt update -q -y >> /var/log/apt/automaticupdates.log
0 3 * * * root /usr/bin/apt upgrade -q -y >> /var/log/apt/automaticupdates.log
0 4 * * * root /sbin/reboot
@reboot   root sleep 5000 && root/repos/update_images.sh
```

In addition docker containers are auto updated to latest version and cleanup of docker system on reboot.

```bash
# update_images.sh (chmod +x ./update_images.sh)
#!/bin/bash
cd /root/repos/beekeepernews-api
docker-compose pull
docker-compose up -d
cd /root/repos/btree-server
docker-compose pull
docker-compose up -d

# Cleanup
docker image prune -a -f
docker container prune -f
docker volume prune -f
docker network prune -f
```
