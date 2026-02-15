# ----------------------------
# Select distro at build time
# ----------------------------
ARG DISTRO=ubuntu

# ============================
# Ubuntu Stage
# ============================
FROM ubuntu:24.04 AS ubuntu

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG USERNAME=zippo
ARG UID=1001
ARG GID=1001

ENV USERNAME=${USERNAME}
ENV HOME=/home/${USERNAME}

RUN apt -y update && \
    apt -y install \
        ca-certificates git tar vim jq curl ripgrep luarocks fontconfig \
        sudo make gcc unzip wget rsync tmux \
        python3 python3-pip python3-venv python3-pynvim && \
    apt -y clean && rm -rf /var/lib/apt/lists/*

# ============================
# Arch Stage
# ============================
FROM archlinux:latest AS arch

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG USERNAME=zippo
ARG UID=1001
ARG GID=1001

ENV USERNAME=${USERNAME}
ENV HOME=/home/${USERNAME}

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
        ca-certificates git tar vim jq curl ripgrep luarocks fontconfig \
        sudo make gcc unzip wget rsync tmux \
        python python-pip python-virtualenv python-pynvim && \
    pacman -Scc --noconfirm

# ============================
# Final Stage (select distro)
# ============================
FROM ${DISTRO}

ARG USERNAME=zippo
ARG UID=1001
ARG GID=1001

ENV USERNAME=${USERNAME}
ENV HOME=/home/${USERNAME}
ENV PATH="$HOME/.local/bin:$PATH"
ENV APPIMAGE_EXTRACT_AND_RUN=1

# Create user
RUN groupadd -g ${GID} ${USERNAME} && \
    useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USERNAME} && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR ${HOME}
USER ${USERNAME}

# Python venv
RUN python3 -m venv ${HOME}/.venvs && \
    source ${HOME}/.venvs/bin/activate && \
    pip install --upgrade pip setuptools wheel && \
    pip install ansible ansible-lint pynvim pylint

# Copy files
RUN mkdir -p .config/{tmux,nvim}

COPY --chown=${USERNAME}:${USERNAME} ./install_nvim_dependance.sh ${HOME}/install_nvim_dependance.sh
COPY --chown=${USERNAME}:${USERNAME} ./.bashrc ${HOME}/.bashrc
COPY --chown=${USERNAME}:${USERNAME} ./tmux.conf ${HOME}/.config/tmux/tmux.conf
COPY --chown=${USERNAME}:${USERNAME} ./.ansible ${HOME}/.ansible
COPY --chown=${USERNAME}:${USERNAME} ./nvim_add/ /tmp/nvim_add

RUN ${HOME}/.venvs/bin/ansible-galaxy collection install \
    -r ${HOME}/.ansible/collections/requirements.yml --force

RUN chmod +x ${HOME}/install_nvim_dependance.sh
RUN ${HOME}/install_nvim_dependance.sh

ENTRYPOINT ["/bin/bash"]
CMD ["-l"]

