# lazy-minecraft-server-server

Minecraft server [docker compose](https://github.com/itzg/docker-minecraft-server) setup for friends. Uses [lazymc](https://github.com/timvisee/lazymc/tree/master) to rest an idle minecraft server container. Runs a systemd service which executes a custom bash script to check for running containers, shutting down the machine when none are up.

## Install Dependencies

### Docker Compose

I find installing docker on Ubuntu via `sudo apt install docker.io` much more consistent.

Follow the [docs](https://docs.docker.com/compose/install/linux/#install-using-the-repository) to install docker compose

### frp

Depending on your configuration, you may need a VPS with a public IP address to route players to your server. This is especially true if you host your server under a home network, where you will not likely have a static IP and your ISP puts you under a CGNAT. 

[Digital Ocean](https://www.digitalocean.com) provides services for making a VPS for VERY cheap. If all you are doing is proxying traffic, you won't need a powerful machine with more than 1 GB of RAM.

Download [frp](https://github.com/fatedier/frp) onto both your VPS and the machine that will run your minecraft server. On Linux, you can move the `frpc` and `frps` executables into the `/usr/local/bin/` directory

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
