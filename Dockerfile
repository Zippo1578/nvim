FROM ubuntu:24.04

LABEL maintainer="stefzippo@gmail.com"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG USERNAME=zippo
ARG UID=1001
ARG GID=1001

ENV USERNAME=${USERNAME}
ENV HOME=/home/${USERNAME}

RUN apt -y update && \
    apt -y install ca-certificates git tar vim jq curl ripgrep luarocks fontconfig sudo make xclip gcc unzip wget \
        python3 python3-pip python3-venv python3-pynvim && \
    apt -y remove neovim && \
    apt -y clean && rm -rf /var/lib/apt/lists/*

# Create group & user
RUN groupadd -g ${GID} ${USERNAME} && \
    useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USERNAME} && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR ${HOME}

# Copy files
COPY --chown=${USERNAME}:${USERNAME} ./install_nvim_dependance.sh /tmp/install_nvim_dependance.sh
COPY --chown=${USERNAME}:${USERNAME} ./.bashrc ${HOME}/.bashrc

RUN chmod +x /tmp/install_nvim_dependance.sh

USER ${USERNAME}

ENV PATH="$HOME/.local/bin:$PATH"
ENV APPIMAGE_EXTRACT_AND_RUN=1

RUN python3 -m venv ${HOME}/.venvs && \
    source ${HOME}/.venvs/bin/activate && \
    pip install --upgrade pip setuptools wheel && \
    pip install ansible ansible-lint pynvim

RUN /tmp/install_nvim_dependance.sh

ENTRYPOINT ["/bin/bash"]
CMD ["-l"]

