# ComfyUI Docker

This is a Docker image for [ComfyUI](https://www.comfy.org/), which makes it extremely easy to run ComfyUI on Linux and Windows WSL2. The image also includes the [ComfyUI Manager](https://github.com/ltdrdata/ComfyUI-Managergithub ) extension.

## Getting Started

To get started, you have to install [Docker](https://www.docker.com/). This can be either Docker Engine, which can be installed by following the [Docker Engine Installation Manual](https://docs.docker.com/engine/install/) or Docker Desktop, which can be installed by [downloading the installer](https://www.docker.com/products/docker-desktop/) for your operating system.

To enable the usage of NVIDIA GPUs, the NVIDIA Container Toolkit must be installed. The installation process is detailed in the [official documentation](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)

## Installation

The ComfyUI Docker image is available from the [GitHub Container Registry](https://ghcr.io). Installing ComfyUI is as simple as pulling the image and starting a container, which can be achieved using the following command:

```shell
docker run \
    --name comfyui \
    --detach \
    --restart unless-stopped \
    --env USER_ID="$(id -u)" \
    --env GROUP_ID="$(id -g)" \
    --volume "<path/to/models/folder>:/opt/comfyui/models:rw" \
    --volume "<path/to/custom/nodes/folder>:/opt/comfyui/custom_nodes:rw" \
    --publish 8188:8188 \
    --runtime nvidia \
    --gpus all \
    ghcr.io/btripoloni/comfyui-docker:latest
```

Please note, that the `<path/to/models/folder>` and `<path/to/custom/nodes/folder>` must be replaced with paths to directories on the host system where the models and custom nodes will be stored, e.g., `$HOME/.comfyui/models` and `$HOME/.comfyui/custom-nodes`, which can be created like so: `mkdir -p $HOME/.comfyui/{models,custom-nodes}`.

The `--detach` flag causes the container to run in the background and `--restart unless-stopped` configures the Docker Engine to automatically restart the container if it stopped itself, experienced an error, or the computer was shutdown, unless you explicitly stopped the container using `docker stop`. This means that ComfyUI will be automatically started in the background when you boot your computer. The two `--env` arguments inject the user ID and group ID of the current host user into the container. During startup, a user with the same user ID and group ID will be created, and ComfyUI will be run using this user. This ensures that files written to the volumes (e.g., models and custom nodes installed with the ComfyUI Manager) will be owned by the host system's user. Normally, the user inside the container is `root`, which means that the files that are written from the container to the host system are also owned by `root`. If you have run ComfyUI Docker without setting the environment variables, then you may have to change the owner of the files in the models and custom nodes directories: `sudo chown -r "$(id -un):$(id -gn)" <path/to/models/folder> <path/to/custom/nodes/folder>`. The `--runtime nvidia` and `--gpus all` arguments enable ComfyUI to access the GPUs of your host system. If you do not want to expose all GPUs, you can specify the desired GPU index or ID instead.

After the container has started, you can navigate to [localhost:8188](http://localhost:8188) to access ComfyUI.

If you want to stop ComfyUI, you can use the following commands:

```shell
docker stop comfyui
docker rm comfyui
```

> [!WARNING]
> While the custom nodes themselves are installed outside of the container, their requirements are installed inside of the container. This means that stopping and removing the container will remove the installed requirements. When the container is started again, the requirements will be automatically installed, but this may, depending on the number of custom nodes and their requirements, take some time.

## Updating

To update ComfyUI Docker to the latest version you have to first stop the running container, then pull the new version, optionally remove dangling images, and then restart the container:

```shell
docker stop comfyui
docker rm comfyui

docker pull ghcr.io/btripoloni/comfyui-docker:latest
docker image prune # Optionally remove dangling images

docker run \
    --name comfyui \
    --detach \
    --restart unless-stopped \
    --env USER_ID="$(id -u)" \
    --env GROUP_ID="$(id -g)" \
    --volume "<path/to/models/folder>:/opt/comfyui/models:rw" \
    --volume "<path/to/custom/nodes/folder>:/opt/comfyui/custom_nodes:rw" \
    --publish 8188:8188 \
    --runtime nvidia \
    --gpus all \
    ghcr.io/btripoloni/comfyui-docker:latest
```

## Building

If you want to use the bleeding edge development version of the Docker image, you can also clone the repository and build the image yourself:

```shell
git clone https://github.com/lecode-official/comfyui-docker.git
docker build --tag btripoloni/comfyui-docker:latest comfyui-docker
```

Now, a container can be started like so:

```shell
docker run \
    --name comfyui \
    --detach \
    --restart unless-stopped \
    --env USER_ID="$(id -u)" \
    --env GROUP_ID="$(id -g)" \
    --volume "<path/to/models/folder>:/opt/comfyui/models:rw" \
    --volume "<path/to/custom/nodes/folder>:/opt/comfyui/custom_nodes:rw" \
    --publish 8188:8188 \
    --runtime nvidia \
    --gpus all \
    btripoloni/comfyui-docker:latest
```

## Using Docker Compose

You can also use Docker Compose to manage the ComfyUI container. Below is an example `docker-compose.yml` file:

```yaml
version: '3.8'
services:
  comfyui:
    image: ghcr.io/btripoloni/comfyui-docker:latest
    container_name: comfyui
    restart: unless-stopped
    environment:
      - USER_ID=${UID}
      - GROUP_ID=${GID}
    volumes:
      - <path/to/models_folder>:/opt/comfyui/models:rw
      - <path/to/custom_nodes_folder>:/opt/comfyui/custom_nodes:rw
    ports:
      - "8188:8188"
    runtime: nvidia
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
```

Replace `<path/to/models_folder>` and `<path/to/custom_nodes_folder>` with the appropriate paths on your host system. To start the container, run:

```shell
docker-compose up -d
```

To stop the container, run:

```shell
docker-compose down
```

## New Features

- **Versioning**: The container versions now reflect the versions of ComfyUI, making it easier to access specific versions.
- **Command-line Arguments**: You can now pass arguments directly to ComfyUI from the command line. For example:

```shell
docker run \
    --name comfyui \
    --detach \
    --restart unless-stopped \
    --env USER_ID="$(id -u)" \
    --env GROUP_ID="$(id -g)" \
    --volume "<path/to/models/folder>:/opt/comfyui/models:rw" \
    --volume "<path/to/custom/nodes/folder>:/opt/comfyui/custom_nodes:rw" \
    --publish 8188:8188 \
    --runtime nvidia \
    --gpus all \
    ghcr.io/btripoloni/comfyui-docker:latest --argument1 --argument2
```

Replace `--argument1 --argument2` with the desired arguments for ComfyUI.

## License

The ComfyUI Docker image is licensed under the [MIT License](LICENSE). [ComfyUI](https://github.com/comfyanonymous/ComfyUI/blob/master/LICENSE) and the [ComfyUI Manager](https://github.com/ltdrdata/ComfyUI-Manager/blob/main/LICENSE.txt) are both licensed under the GPL 3.0 license.

### Credits

This repository is based on the original work by [lecode-official/comfyui-docker](https://github.com/lecode-official/comfyui-docker).
