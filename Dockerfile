# This image is based on the latest official PyTorch image, because it already contains CUDA, CuDNN, and PyTorch
FROM pytorch/pytorch:2.8.0-cuda12.9-cudnn9-runtime

# Installs Git, because ComfyUI and the ComfyUI Manager are installed by cloning their respective Git repositories
RUN apt update --assume-yes && \
    apt install --assume-yes \
        git \
        sudo \
        libgl1-mesa-glx \
        libglib2.0-0 \
        build-essential && \
    rm -rf /var/lib/apt/lists/*

# Define environment variables for the tags
ENV COMFYUI_TAG=v0.8.2
ENV COMFYUI_MANAGER_TAG=4.0.5

# Clones the ComfyUI repository and checks out the specified tag
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /opt/comfyui && \
    cd /opt/comfyui && \
    git checkout tags/$COMFYUI_TAG

# Clones the ComfyUI Manager repository and checks out the specified tag; ComfyUI Manager is an extension for ComfyUI that enables users to install
# custom nodes and download models directly from the ComfyUI interface; instead of installing it to "/opt/comfyui/custom_nodes/ComfyUI-Manager", which
# is the directory it is meant to be installed in, it is installed to its own directory; the entrypoint will symlink the directory to the correct
# location upon startup; the reason for this is that the ComfyUI Manager must be installed in the same directory that it installs custom nodes to, but
# this directory is mounted as a volume, so that the custom nodes are not installed inside of the container and are not lost when the container is
# removed; this way, the custom nodes are installed on the host machine
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git /opt/comfyui-manager && \
    cd /opt/comfyui-manager && \
    git checkout tags/$COMFYUI_MANAGER_TAG

# Installs the required Python packages for both ComfyUI and the ComfyUI Manager
RUN pip install \
    --requirement /opt/comfyui/requirements.txt \
    --requirement /opt/comfyui-manager/requirements.txt

# Sets the working directory to the ComfyUI directory
WORKDIR /opt/comfyui

# Exposes the default port of ComfyUI (this is not actually exposing the port to the host machine, but it is good practice to include it as metadata,
# so that the user knows which port to publish)
EXPOSE 8188

# Adds the startup script to the container; the startup script will create all necessary directories in the models and custom nodes volumes that were
# mounted to the container and symlink the ComfyUI Manager to the correct directory; it will also create a user with the same UID and GID as the user
# that started the container, so that the files created by the container are owned by the user that started the container and not the root user
ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]

# Adds the forwarding script to the container
ADD forward_args.sh /forward_args.sh
RUN chmod +x /forward_args.sh

# On startup, ComfyUI is started at its default port; the IP address is changed from localhost to 0.0.0.0, because Docker is only forwarding traffic
# to the IP address it assigns to the container, which is unknown at build time; listening to 0.0.0.0 means that ComfyUI listens to all incoming
# traffic; the auto-launch feature is disabled, because we do not want (nor is it possible) to open a browser window in a Docker container
CMD ["/bin/bash", "/forward_args.sh", "--listen", "0.0.0.0", "--port", "8188", "--disable-auto-launch", "--preview-method", "auto"]
