# selfhosted-vps

My setup for self-hosting a bunch of services on a VPS with a public IP. The VPS also acts as the window to my home server with a dynamic IP. 

All of the services run in docker containers. Some host config is required which is described below.

![Alt text](diagram.webp?raw=true "Diagram")

## Services

Some services are hosted directly on VPS and others are hosted on the home server.

### Hosted directly on VPS

- [Traefik](https://traefik.io/traefik) - The reverse proxy.
- [Authelia](https://www.authelia.com/) - Almost all services use Authelia for authentication. Some services have their own auth. Check `docker/authelia/configuration.yml` for the config for each service.
- [Crowdsec](https://www.crowdsec.net/) - Blocks malicious IPs.
- [Wireguard](https://www.wireguard.com/) - Used to tunnel traffic to the home server.
- [IT-tools](https://github.com/CorentinTh/it-tools) - Collection of handy online tools for developers, with great UX. 
- [Watchtower](https://github.com/containrrr/watchtower) - Notifies when docker image updates are available
- [Stirling-pdf](https://github.com/Stirling-Tools/Stirling-PDF) - Allows you to perform various operations on PDF files 
- [Prometheus](https://github.com/prometheus/prometheus) - Server for storing and querying telemetry
- [Node exporter](https://github.com/prometheus/node_exporter) - Exports the VPS's metrics to prometheus
- [Grafana](https://github.com/grafana/grafana) - Dashboarding and monitoring
- [Vaultwarden](https://github.com/dani-garcia/vaultwarden) - Password manager
- [Backrest](https://github.com/garethgeorge/backrest/) - Awesome Web-UI for backup management built on top of [restic](https://restic.net/).
- [Apprise](https://github.com/caronc/apprise) - Configurable web service for sending notifications.
- [Paperless-ngx](https://docs.paperless-ngx.com/) - Document management. A BIG upgrade over storing them in Google drive.
- [Gatus](https://github.com/TwiN/gatus) - Simple webapp monitoring. I find it better than uptime-kuma because I can store the config in code.
- [Linkwarden](https://github.com/linkwarden/linkwarden) - Bookmarking tool
- [Readeck](https://readeck.org/en/) - One more bookmarking tool
- [Filebrowser](https://github.com/gtsteffaniak/filebrowser) - Web based file explorer for uploading/downloading files to/from VPS quickly.

## Installation

1. Start with Ubuntu LTS
1. [Enable Unattended Upgrades](https://help.ubuntu.com/community/AutomaticSecurityUpdates)
1. Clone this repo
1. Sign into any private docker registries
1. Install [Docker](https://docs.docker.com/engine/install/)

```bash
cd selfhosted-vps

# install logrotate
sudo apt update
sudo apt install logrotate

# install sqlite3
sudo apt install sqlite3

# enable logrotate
sudo cp etc/traefik-logrotate.conf /etc/logrotate.d/
sudo cp etc/authelia-logrotate.conf /etc/logrotate.d/
sudo cp etc/vaultwarden-logrotate.conf /etc/logrotate.d/
sudo systemctl restart logrotate
```

## Updating VPS IP in the Cloudflare DNS

- Clone the github repo `https://github.com/K0p1-Git/cloudflare-ddns-updater`.
- Update the variables in the script.
- Add the script to crontab to run every hour.

## Docker

[Set up docker daemon.json](https://www.reddit.com/r/selfhosted/comments/1az6mqa/psa_adjust_your_docker_defaultaddresspool_size/). Otherwise, you may end up with subnet ranges inside your containers that overlap with the real LAN and make hosts unreachable.
Edit the `/etc/docker/daemon.json` file:

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "default-address-pools": [
    {
      "base": "172.16.0.0/12",
      "size": 24
    }
  ],
  "metrics-addr": "0.0.0.0:9323"
}
```

```
cd docker
cp .env.example .env # edit this
docker compose up -d
```

### Wireguard setup

After the `wireguard` docker container is created, add the following lines to the `wireguard/config/wg_confs/wg0.conf` file in the `[Interface]` section:

```
PostUp = iptables -t nat -A PREROUTING -i eth+ -p tcp --dport 80 -j DNAT --to-destination 10.13.13.2
PostUp = iptables -t nat -A PREROUTING -i eth+ -p tcp --dport 443 -j DNAT --to-destination 10.13.13.2
PostDown = iptables -t nat -D PREROUTING -i eth+ -p tcp --dport 80 -j DNAT --to-destination 10.13.13.2
PostDown = iptables -t nat -D PREROUTING -i eth+ -p tcp --dport 443 -j DNAT --to-destination 10.13.13.2
```

This will forward the the ports 80 and 443 of the `wireguard` docker container to the `homeServer` peer.

Use the .conf file from the `wireguard/config/peer_homeServer` directory as the wireguard config in the home server.

### Authelia setup

Authelia data is already setup to be backed up using backrest. But we still need to setup daily database backup because the the DB might be
in use when backrest is backing it up. Add the `crons/authelia-backup.sh` script to root's cron to run daily which does this.

```
6 2 * * * /home/ubuntu/selfhosted-vps/crons/authelia-backup.sh || curl -X POST -F "body=Authelia DB backup failed!" http://127.0.0.1:8000/notify/apprise
```

### Crowdsec setup

- Add `crons/crowsec-hub-upgrade.sh` script to root's cron to run daily which upgrades the definitions from the Crowdsec hub.

```
0 * * * * /home/ubuntu/selfhosted-vps/crons/crowsec-hub-upgrade.sh || curl -X POST -F "body=Crowdsec hub upgrade failed!" http://127.0.0.1:8000/notify/apprise
```

- Login to the [Crowdsec console](https://app.crowdsec.net) and enroll the node by following the instructions.

#### Install crowdsec-firewall-bouncer

This is used to modify iptables rules to block SSH logins, for example.

This is taken from [Firewall | Crowdsec](https://docs.crowdsec.net/u/bouncers/firewall/):

```
# install the repositories
curl -s https://install.crowdsec.net | sudo sh

sudo apt install crowdsec-firewall-bouncer-iptables
```

Get the API key for the bouncer by running

```
docker exec crowdsec cscli bouncers add bouncer-firewall
```

Copy the file `./etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml` to `/etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml`

Edit the file `/etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml` and edit the `api_key` field.

### Backups

Some data is backed up using [backrest](https://github.com/garethgeorge/backrest) (restic). The following paths are backed up:

- Vaultwarden: `/var/lib/docker-data/vaultwarden`
- Apprise: `/var/lib/docker-data/apprise/config`
- Authelia: `/var/lib/docker-data/authelia/config`
- Backrest: `/var/lib/docker-data/backrest/config`

Unfortunately, the backrest config cannot be checked-in because it doesn't support env variable interpolation: https://github.com/garethgeorge/backrest/issues/788.
Hence, when setting up for the first time, the repository and backup schedule needs to be configured through the backrest web UI.

In case of data loss, restore the latest snapshot using [restic](https://github.com/restic/restic).

### Vaultwarden setup

Vaultwarden data is already setup to be backed up using backrest. But we still need to setup daily database backup because the the DB might be
in use when backrest is backing it up. Add the `crons/vaultwarden-backup.sh` script to root's cron to run daily which does this.

```
3 2 * * * /home/ubuntu/selfhosted-vps/crons/vaultwarden-backup.sh || curl -X POST -F "body=Vaultwarden DB backup failed!" http://127.0.0.1:8000/notify/apprise
```

### Grafana setup

- Generate a random password with more than 60 characters. Set it in the `.env` file in the variable `GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET`.
- Generate argon2 hash using Authelia docker image `docker run --rm -it authelia/authelia:latest authelia crypto hash generate argon2`. Put the hash in the file `/var/lib/docker-data/authelia/secrets/oidc/grafana_client_secret.txt`

### Paperless-ngx setup

Add the `crons/paperless-backup.sh` script to root's cron to run daily.

```
5 2 * * * /home/ubuntu/selfhosted-vps/crons/paperless-backup.sh || curl -X POST -F "body=Paperless-ngx DB backup failed!" http://127.0.0.1:8000/notify/apprise
```

#### Restoring backup

- Restore the backup to to `/var/lib/docker-data/paperless-ngx`

We don't back up some data so we need to regenerate it:

- Generate the document thumbnails: https://docs.paperless-ngx.com/administration/#thumbnails
- Generate the index: https://docs.paperless-ngx.com/administration/#index
- Train the classifier: https://docs.paperless-ngx.com/administration/#managing-the-automatic-matching-algorithm
