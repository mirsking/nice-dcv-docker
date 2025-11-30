FROM ubuntu:22.04 as dcv

USER root

ENV SHELL=/bin/bash
ENV DEBIAN_FRONTEND=noninteractive
ENV container docker

LABEL maintainer "mk <mk@gmail.com>"

RUN sed -i 's@//.*archive.ubuntu.com@//mirrors.zju.edu.cn@g' /etc/apt/sources.list

# =========== nvidia driver =================
# Install tools
RUN apt update && apt install -y tar sudo less vim lsof firewalld net-tools pciutils \
                   file wget kmod ca-certificates binutils kbd \
                   python3-pip jq bc xz-utils && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install gdm & ssh
RUN apt update && apt install -y --no-install-recommends \
    openssh-server \
    tar vim wget kmod htop software-properties-common apt-transport-https sudo pciutils ca-certificates xz-utils locales curl \
    mesa-utils libxvmc-dev xserver-xorg-core xserver-xorg xserver-xorg-dev xorg x11-utils xauth xinit openbox xfonts-base xterm \
    ubuntu-desktop-minimal gnome-shell gnome-terminal gdm3 libglfw3-dev libgles2-mesa-dev libglew-dev glew-utils libvdpau1 libxcb-damage0 libxcb-xtest0 \
    && apt clean && rm -rf /var/lib/apt/lists/*

ARG MODE="remote"  # 默认模式：远程下载
ENV NVIDIA_VISIBLE_DEVICES all
# ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_DRIVER_CAPABILITIES all

COPY resources/placehold resources/NVIDIA-Linux-x86_64-535.274.02.run /tmp/
RUN if [ -f "/tmp/NVIDIA-Linux-x86_64-535.274.02.run" ]; then \
        echo "===== get nvidia installer in local ====="; \
        mv /tmp/NVIDIA-Linux-x86_64-535.274.02.run /tmp/NVIDIA-installer.run; \
    else \
        wget -O /tmp/NVIDIA-installer.run https://download.nvidia.com/XFree86/Linux-x86_64/535.274.02/NVIDIA-Linux-x86_64-535.274.02.run ; \
    fi; \
    bash /tmp/NVIDIA-installer.run --accept-license \
			      --install-libglvnd \
                              --no-questions --no-kernel-module-source \
			      --no-nvidia-modprobe --no-kernel-module \
			      --disable-nouveau \
                              --no-backup \
                              --ui=none \
    && rm -f /tmp/NVIDIA-installer.run \
    && nvidia-xconfig --preserve-busid --enable-all-gpus -connected-monitor=DFP-0,DFP-1,DFP-2,DFP-3


# =========== dcv & sshd ================
RUN apt update && apt install -y --no-install-recommends \
    dbus-x11 keyutils \
    && apt clean && rm -rf /var/lib/apt/lists/*

COPY resources/placehold resources/nice-dcv-2024.0-18131-ubuntu2204-x86_64.tgz /tmp/nice-dcv.tgz
COPY resources/placehold resources/nice-dcv-server_2024.0.18131-1-cracked_amd64.deb /tmp/nice-dcv-server.deb

RUN if [ -f "/tmp/nice-dcv.tgz" ]; then \
        echo "===== get nice dcv installer in local ====="; \
    else \
        wget -O /tmp/nice-dcv.tgz https://d1uj6qtbmh3dt5.cloudfront.net/2024.0/Servers/nice-dcv-2024.0-18131-ubuntu2204-x86_64.tgz ;\
        wget -O /tmp/nice-dcv-server.deb https://github.com/Z841973620/nice-dcv-docker/releases/download/deb/nice-dcv-server_2024.0.18131-1-cracked_amd64.deb ;\
    fi; \
    cd /tmp \
    && tar -zxvf nice-dcv.tgz && cd n* \
    && rm *server* && cp /tmp/nice-dcv-server.deb . \
    && dpkg -i *server* *web* *xdcv* \
    && usermod -aG video dcv \
    && cd ~ && rm -rf /tmp/*

ADD resources/dcvserver.service /usr/lib/systemd/system/

# timezone
RUN ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone

ADD *.sh /usr/local/bin/

EXPOSE 22 8443

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"] 
