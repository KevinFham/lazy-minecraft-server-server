# lazy-minecraft-server-server

Minecraft server [docker compose](https://github.com/itzg/docker-minecraft-server) setup for friends. Uses [lazymc](https://github.com/timvisee/lazymc/tree/master) to rest an idle minecraft server container. Runs a systemd service which executes a custom bash script to check for running containers, shutting down the machine when none are up.

## Install Docker Compose

I find installing docker on Ubuntu via `sudo apt install docker.io` much more consistent.

Follow the [docs](https://docs.docker.com/compose/install/linux/#install-using-the-repository) to install docker compose

## Deployment

Rename `.example-env` to `.env` and configure as needed. Note that whitelist is on.

Allow server ports if ufw is enabled:

```bash
# Server Port (in .env, this will be USE_HOST_PORT)
sudo ufw allow 25565

# SimpleVoiceChat Mod (in .env, this will be USE_HOST_PORT_VC)
sudo ufw allow 24454/udp
```

Copy or create system links for:

- `whitelisted_containers_for_shutdown.txt`

  ```bash
  cp whitelisted_containers_for_shutdown.txt /usr/local/etc/
  ```

- `scripts/check_mc_container_down.sh`

  ```bash
  cp scripts/check_mc_container_down.sh /usr/local/bin/
  ```

- `scripts/is_mc_container_down.sh` (Currently not being used)

  ```bash
  cp scripts/is_mc_container_down.sh /usr/local/bin/
  ```

- `minecraft-container-shutdown.service`

  ```bash
  cp minecraft-container-shutdown.service /etc/systemd/system/
  ```

Enable the shutdown service

```bash
sudo systemctl enable minecraft-container-shutdown.service
sudo systemctl start minecraft-container-shutdown.service
```
