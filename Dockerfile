ARG UBUNTU_VERSION=24.04

FROM ubuntu:${UBUNTU_VERSION}

LABEL org.opencontainers.image.authors="<echo 'YW5kcmVhc0BrcnVobG1hbm4uZGV2Cg==' | base64 -d>" \
    org.opencontainers.image.title="TF2 Classified Server" \
    org.opencontainers.image.source="https://github.com/kruhlmann/tf2classified-server" \
    org.opencontainers.image.description="Runs a TF2 Classified mod server" \
    org.opencontainers.image.licenses="MIT"

ENV DEBIAN_FRONTEND=noninteractive \
    USERNAME=steamuser \
    TF2_APPID=232250 \
    TF2_CLASSIFIED_APPID=3557020 \
    TF_METAMOD_VERSION=2.0.0-git1389 \
    TF_SOURCEMOD_VERSION=1.13.0-git7301

RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y \
    ca-certificates \
    curl \
    wget \
    tar \
    lib32gcc-s1 \
    lib32stdc++6 \
    libcurl3-gnutls:i386 \
    libsdl2-2.0-0:i386 \
    libbz2-1.0:i386 \
    zlib1g:i386 \
    gosu \
    && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /opt/steamcmd \
    && mkdir -p /usr/local/bin \
    && curl -fsSL \
    https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
    | tar -xz -C /opt/steamcmd \
    && chmod +x /opt/steamcmd/steamcmd.sh \
    && chmod +x /opt/steamcmd/linux32/steamcmd
RUN mkdir -p /opt/tf2classified-modding \
    && curl -fsSL \
    "https://mms.alliedmods.net/mmsdrop/2.0/mmsource-${TF_METAMOD_VERSION}-linux.tar.gz" \
    | tar -xz -C /opt/tf2classified-modding \
    && curl -fsSL \
    "https://sm.alliedmods.net/smdrop/1.13/sourcemod-${TF_SOURCEMOD_VERSION}-linux.tar.gz" \
    | tar -xz -C /opt/tf2classified-modding
RUN useradd \
    --create-home \
    --home-dir /home/${USERNAME} \
    --shell /bin/bash \
    ${USERNAME}

COPY ./entrypoint /entrypoint
COPY ./entrypoint.d /entrypoint.d/
COPY ./bin/* /usr/local/bin

WORKDIR /home/${USERNAME}

ENTRYPOINT ["/entrypoint"]
CMD ["tf-start-server"]
