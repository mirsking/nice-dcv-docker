FROM ubuntu:22.04 as dcv

USER root

ENV SHELL=/bin/bash
ENV DEBIAN_FRONTEND=noninteractive
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES all
ENV container docker

RUN apt update && apt install -y --no-install-recommends tar vim wget kmod htop software-properties-common apt-transport-https sudo pciutils ca-certificates xz-utils locales curl mesa-utils libxvmc-dev xserver-xorg-core xserver-xorg xserver-xorg-dev xorg x11-utils xauth xinit openbox xfonts-base xterm ubuntu-desktop-minimal gnome-shell gnome-terminal gdm3 libglfw3-dev libgles2-mesa-dev libglew-dev glew-utils libvdpau1 libxcb-damage0 libxcb-xtest0 && apt clean && rm -rf /var/lib/apt/lists/*
RUN cd /tmp && curl -fkLO https://d1uj6qtbmh3dt5.cloudfront.net/2024.0/Servers/nice-dcv-2024.0-18131-ubuntu2204-x86_64.tgz && tar -zxvf *tgz && cd n* && rm *server* && curl -fkLO https://github.com/Z841973620/nice-dcv-docker/releases/download/deb/nice-dcv-server_2024.0.18131-1-cracked_amd64.deb && dpkg -i *server* *web* *xdcv* && usermod -aG video dcv && cd ~ && rm -rf /tmp/*

ADD dcvserver.service /usr/lib/systemd/system/
ADD *.sh /usr/local/bin/

EXPOSE 8443

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
