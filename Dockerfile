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
# 模式一：远程下载大文件
RUN if [ "${MODE}" = "remote" ]; then \
        echo "===== 模式一：远程下载大文件 ====="; \
        wget -O /tmp/NVIDIA-installer.run https://download.nvidia.com/XFree86/Linux-x86_64/535.274.02/NVIDIA-Linux-x86_64-535.274.02.run --progress=bar:force; \
    fi

# 模式二：复制本地大文件到容器
COPY --chmod=644 NVIDIA-installer.run /tmp/NVIDIA-installer.run \
    || echo "===== 非本地模式，跳过 COPY ====="

RUN  bash /tmp/NVIDIA-installer.run --accept-license \
			      --install-libglvnd \
                              --no-questions --no-kernel-module-source \
			      --no-nvidia-modprobe --no-kernel-module \
			      --disable-nouveau \
                              --no-backup \
                              --ui=none \
 && rm -f /tmp/NVIDIA-installer.run \
 && nvidia-xconfig --preserve-busid --enable-all-gpus -connected-monitor=DFP-0,DFP-1,DFP-2,DFP-3


# =========== dcv & sshd ================
RUN cd /tmp && curl -fkLO https://d1uj6qtbmh3dt5.cloudfront.net/2024.0/Servers/nice-dcv-2024.0-18131-ubuntu2204-x86_64.tgz \
    && tar -zxvf *tgz && cd n* && rm *server* \
    && curl -fkLO https://github.com/Z841973620/nice-dcv-docker/releases/download/deb/nice-dcv-server_2024.0.18131-1-cracked_amd64.deb \
    && dpkg -i *server* *web* *xdcv* \
    && usermod -aG video dcv \
    && cd ~ && rm -rf /tmp/*

ADD dcvserver.service /usr/lib/systemd/system/
ADD *.sh /usr/local/bin/

EXPOSE 22 8443

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"] 
