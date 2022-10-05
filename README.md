# Helper Repo - Docker MariaDB

Helper Repo for setting up Docker Container with multiple MariaDB databases. Used in production and development.

- [Repo - b.tree Server API](https://github.com/HannesOberreiter/btree_server)
  - Live: <https://api.btree.at>
  - Beta: <https://api-beta.btree.at>
- [Private Repo - b.tree Frontend](https://github.com/HannesOberreiter/btree_vue)
  - Live: <https://app.btree.at>
  - Beta: <https://beta.btree.at>
- [Repo - b.tree Database](https://github.com/HannesOberreiter/btree_database)
- [Private Repo - b.tree iOS](https://github.com/HannesOberreiter/btree_ios)

## Setup

The `maria` folder will be our local volume for the database. Inside the `init-maria` you can add scripts which are run on a new database instance. The user access on created tables must be the same as in your `.env` file.

## Network

Other containers need to attach to the custom created network `btree-maria-network`.

```bash
# Docker-compose.yml - of your other container
version: "3.8"

services:
  your-service:
    ....

networks:
  default:
    external: true
    name: btree-docker-mysql_btree-maria-network
```

The hostname is the container name, eg. for database connection use `DATABASE_HOST=DockerMariaDB` and you need to use the internal port of the mysql container `3306` not the exposed one.

PS: You need to use Docker-compose Version > 2 also in your other containers to use the network command.

## Docker Image upgrade

Use `docker compose pull` to get latest images, then `docker_compose down && docker compose up -d`. Use `docker image prune -af` to remove unused images.

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

Backups are done twice daily with [databack/mysql-backup](https://hub.docker.com/r/databack/mysql-backup). The backups are saved to Amazon AWS S3 storage.

### Restoration

See [docker-compose-beta.yml](docker-compose-beta.yml) how the container can restore a backup from AWS S3 storage. After DB restoration `mysqlcheck --auto-repair --optimize --all-databases --verbose` must be run, otherwise performance is bad. This will happen automatically if  the `post-restore` folder script is added to the docker volume.

## Other Server Stuff

### Docker Compose Files

[docker-compose-beta.yml](docker-compose-beta.yml): Is used for a secondary MariaDB instance running a specific version our database. This is used for data restoration tests and can be used for beta testing, as [api-beta.btree.at](https://api-beta.btree.at) is connected to the same network it.

[docker-compose-live.yml](docker-compose-live.yml): Is used for a main MariaDB instance and backups are saved twice a day to AWS S3. The main api server [api.btree.at](https://api.btree.at) is connected to the same network.

### Daily Cron-Jobs

To keep the server updated and clean of memory leaks I restart it daily and perform updates daily:

```bash
# Custom CronJobs
# etc/crontab
0 2 * * * root /usr/bin/apt update -q -y >> /var/log/apt/automaticupdates.log
0 3 * * * root /usr/bin/apt upgrade -q -y >> /var/log/apt/automaticupdates.log
0 4 * * * root /sbin/reboot
@reboot   root sleep 5000 && root/repos/update_images.sh
```

In addition docker containers are auto updated to latest version and clean up of docker system on reboot.

```bash
#!/bin/bash
# update_images.sh (chmod +x ./update_images.sh)
cd /root/repos/beekeepernews-api
docker compose pull
docker compose up -d
cd /root/repos/btree-server
# docker-compose pull
docker compose up -d
cd /root/repos/btree-server-beta
docker compose pull
docker compose up -d

# Cleanup
docker image prune -a -f
docker container prune -f
docker volume prune -f
docker network prune -f
```
