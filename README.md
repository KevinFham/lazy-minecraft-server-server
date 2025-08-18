# lazy-minecraft-server-server

Minecraft server [docker compose](https://github.com/itzg/docker-minecraft-server) setup for friends. Uses [lazymc](https://github.com/timvisee/lazymc/tree/master) to rest an idle minecraft server container. Runs a systemd service which executes a custom bash script to check for running containers, shutting down the machine when none are up.

## Install Docker Compose

I find installing docker on Ubuntu via `sudo apt install docker.io` much more consistent.

Follow the [docs](https://docs.docker.com/compose/install/linux/#install-using-the-repository) to install docker compose

```bash

```
