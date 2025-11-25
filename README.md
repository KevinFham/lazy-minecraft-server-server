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

Allow server ports if ufw is enabled:

```bash
# FRP_SERVER_PORT depends on your frps configuration 
sudo ufw allow $FRP_SERVER_PORT
sudo ufw allow 25565
sudo ufw allow 24454/udp
```

### frp Configuration

Each frp configuration file (`vps/frps.toml`, `vps/mc-server-proxy-client-frpc.toml`, and `mc-server-proxy-server-frpc.toml`) has parameter fields denoted by `{{ .Envs.SOME_ENV_VALUE }}`. Replace these fields with the relevant ports or keys, making sure to remove the curly braces

On a high level, the VPS hosts the frp server (typically on `FRP_SERVER_PORT=7000`) for client servers to connect to. The `frps` binary runs the `vps/frps.toml` configuration file to start this service. 

The confusing part comes after this. The Minecraft Server (mc-server) connects to the frp server on the VPS at `FRP_SERVER_ADDR:FRP_SERVER_PORT`, whereafter the mc-server then serves a secret TCP (STCP) service (this will be the minecraft server port `25565`) to ask the VPS to securely proxy (in which the `frpc` binary on mc-server runs the `mc-server-proxy-server-frpc.toml` file).

Then the VPS uses visitors to connect to the STCP services, proxying traffic it recieves from `MC_SERVER_FRP_PORT` to the end service on mc-server (e.g., port `mc-server:25565`). This is done using the `frpc` binary to run the `vps/mc-server-proxy-client-frpc.toml` file on the VPS.

Adding more minecraft servers into this proxying configuration means simply adding more STCP `[[proxies]]` in `mc-server-proxy-server-frpc.toml` on mc-server and adding the same number of `[[visitors]]` in `vps/mc-server-proxy-client-frpc.toml` on the VPS.

### VPS

- `vps/frps.toml`
  ```bash
  cp vps/frps.toml /usr/local/share/frp/
  ```

- `vps/mc-server-proxy-client-frpc.toml`

  ```bash
  cp vps/mc-server-proxy-client-frpc.toml /usr/local/share/frp/
  ```

- `home-proxy.service`

  ```bash
  cp vps/home-proxy.service /etc/systemd/system/
  sudo systemctl enable home-proxy.service
  sudo systemctl start home-proxy.service
  ```

- `vps/mc-server-proxy.service`

  ```bash
  cp vps/mc-server-proxy.service /etc/systemd/system/
  sudo systemctl enable mc-server-proxy.service
  sudo systemctl status mc-server-proxy.service
  ```

### Minecraft Machine

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

- `mc-server-proxy-server-frpc.toml`

  ```bash
  cp mc-server-proxy-server-frpc.toml /usr/local/share/frp/
  ```

- `scripts/check_mc_container_down.sh`

  ```bash
  cp scripts/check_mc_container_down.sh /usr/local/bin/
  ```

- `scripts/is_mc_container_down.sh` (Currently not being used)

  ```bash
  cp scripts/is_mc_container_down.sh /usr/local/bin/
  ```

- `services/minecraft-container-shutdown.service`

  ```bash
  cp services/minecraft-container-shutdown.service /etc/systemd/system/
  sudo systemctl enable minecraft-container-shutdown.service
  sudo systemctl start minecraft-container-shutdown.service
  ```

- `services/mc-server-proxy.service`

  ```bash
  cp services/mc-server-proxy.service /etc/systemd/system/
  sudo systemctl enable mc-server-proxy.service
  sudo systemctl status mc-server-proxy.service
  ```
