FROM ubuntu:22.04 as dcv

USER root

ENV SHELL=/bin/bash
ENV DEBIAN_FRONTEND=noninteractive
ENV container docker

LABEL maintainer "mk <mk@gmail.com>"

# =========== nvidia base ============== 
ENV NVARCH x86_64

ENV NVIDIA_REQUIRE_CUDA "cuda>=12.0 brand=tesla,driver>=470,driver<471 brand=unknown,driver>=470,driver<471 brand=nvidia,driver>=470,driver<471 brand=nvidiartx,driver>=470,driver<471 brand=geforce,driver>=470,driver<471 brand=geforcertx,driver>=470,driver<471 brand=quadro,driver>=470,driver<471 brand=quadrortx,driver>=470,driver<471 brand=titan,driver>=470,driver<471 brand=titanrtx,driver>=470,driver<471"
ENV NV_CUDA_CUDART_VERSION 12.0.146-1
ENV NV_CUDA_COMPAT_PACKAGE cuda-compat-12-0

RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg2 curl ca-certificates && \
    curl -fsSLO https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/${NVARCH}/cuda-keyring_1.0-1_all.deb && \
    dpkg -i cuda-keyring_1.0-1_all.deb && \
    apt-get purge --autoremove -y curl \
    && rm -rf /var/lib/apt/lists/*

ENV CUDA_VERSION 12.0.1

# For libraries in the cuda-compat-* package: https://docs.nvidia.com/cuda/eula/index.html#attachment-a
RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-cudart-12-0=${NV_CUDA_CUDART_VERSION} \
    ${NV_CUDA_COMPAT_PACKAGE} \
    && rm -rf /var/lib/apt/lists/*

# Required for nvidia-docker v1
RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf \
    && echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64

COPY NGC-DL-CONTAINER-LICENSE /

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

# =========== nvidia runtime ============== 
ENV NV_CUDA_LIB_VERSION 12.0.1-1
ENV NV_NVTX_VERSION 12.0.140-1
ENV NV_LIBNPP_VERSION 12.0.1.104-1
ENV NV_LIBNPP_PACKAGE libnpp-12-0=${NV_LIBNPP_VERSION}
ENV NV_LIBCUSPARSE_VERSION 12.0.1.140-1

ENV NV_LIBCUBLAS_PACKAGE_NAME libcublas-12-0
ENV NV_LIBCUBLAS_VERSION 12.0.2.224-1
ENV NV_LIBCUBLAS_PACKAGE ${NV_LIBCUBLAS_PACKAGE_NAME}=${NV_LIBCUBLAS_VERSION}

ENV NV_LIBNCCL_PACKAGE_NAME libnccl2
ENV NV_LIBNCCL_PACKAGE_VERSION 2.16.5-1
ENV NCCL_VERSION 2.16.5-1
ENV NV_LIBNCCL_PACKAGE ${NV_LIBNCCL_PACKAGE_NAME}=${NV_LIBNCCL_PACKAGE_VERSION}+cuda12.0

RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-libraries-12-0=${NV_CUDA_LIB_VERSION} \
    ${NV_LIBNPP_PACKAGE} \
    cuda-nvtx-12-0=${NV_NVTX_VERSION} \
    libcusparse-12-0=${NV_LIBCUSPARSE_VERSION} \
    ${NV_LIBCUBLAS_PACKAGE} \
    ${NV_LIBNCCL_PACKAGE} \
    && rm -rf /var/lib/apt/lists/*

# Keep apt from auto upgrading the cublas and nccl packages. See https://gitlab.com/nvidia/container-images/cuda/-/issues/88
RUN apt-mark hold ${NV_LIBCUBLAS_PACKAGE_NAME} ${NV_LIBNCCL_PACKAGE_NAME}

ENV NVIDIA_PRODUCT_NAME="CUDA"

# ============ nvida devel ============
ENV NV_CUDA_LIB_VERSION "12.0.1-1"

ENV NV_CUDA_CUDART_DEV_VERSION 12.0.146-1
ENV NV_NVML_DEV_VERSION 12.0.140-1
ENV NV_LIBCUSPARSE_DEV_VERSION 12.0.1.140-1
ENV NV_LIBNPP_DEV_VERSION 12.0.1.104-1
ENV NV_LIBNPP_DEV_PACKAGE libnpp-dev-12-0=${NV_LIBNPP_DEV_VERSION}

ENV NV_LIBCUBLAS_DEV_VERSION 12.0.2.224-1
ENV NV_LIBCUBLAS_DEV_PACKAGE_NAME libcublas-dev-12-0
ENV NV_LIBCUBLAS_DEV_PACKAGE ${NV_LIBCUBLAS_DEV_PACKAGE_NAME}=${NV_LIBCUBLAS_DEV_VERSION}

ENV NV_CUDA_NSIGHT_COMPUTE_VERSION 12.0.1-1
ENV NV_CUDA_NSIGHT_COMPUTE_DEV_PACKAGE cuda-nsight-compute-12-0=${NV_CUDA_NSIGHT_COMPUTE_VERSION}

ENV NV_NVPROF_VERSION 12.0.146-1
ENV NV_NVPROF_DEV_PACKAGE cuda-nvprof-12-0=${NV_NVPROF_VERSION}

ENV NV_LIBNCCL_DEV_PACKAGE_NAME libnccl-dev
ENV NV_LIBNCCL_DEV_PACKAGE_VERSION 2.16.5-1
ENV NCCL_VERSION 2.16.5-1
ENV NV_LIBNCCL_DEV_PACKAGE ${NV_LIBNCCL_DEV_PACKAGE_NAME}=${NV_LIBNCCL_DEV_PACKAGE_VERSION}+cuda12.0

RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-cudart-dev-12-0=${NV_CUDA_CUDART_DEV_VERSION} \
    cuda-command-line-tools-12-0=${NV_CUDA_LIB_VERSION} \
    cuda-minimal-build-12-0=${NV_CUDA_LIB_VERSION} \
    cuda-libraries-dev-12-0=${NV_CUDA_LIB_VERSION} \
    cuda-nvml-dev-12-0=${NV_NVML_DEV_VERSION} \
    ${NV_NVPROF_DEV_PACKAGE} \
    ${NV_LIBNPP_DEV_PACKAGE} \
    libcusparse-dev-12-0=${NV_LIBCUSPARSE_DEV_VERSION} \
    ${NV_LIBCUBLAS_DEV_PACKAGE} \
    ${NV_LIBNCCL_DEV_PACKAGE} \
    ${NV_CUDA_NSIGHT_COMPUTE_DEV_PACKAGE} \
    && rm -rf /var/lib/apt/lists/*

# Keep apt from auto upgrading the cublas and nccl packages. See https://gitlab.com/nvidia/container-images/cuda/-/issues/88
RUN apt-mark hold ${NV_LIBCUBLAS_DEV_PACKAGE_NAME} ${NV_LIBNCCL_DEV_PACKAGE_NAME}
ENV LIBRARY_PATH /usr/local/cuda/lib64/stubs

# =========== nvida devel cudnn =========
ENV NV_CUDNN_VERSION 8.8.0.121
ENV NV_CUDNN_PACKAGE_NAME "libcudnn8"

ENV NV_CUDNN_PACKAGE "libcudnn8=$NV_CUDNN_VERSION-1+cuda12.0"
ENV NV_CUDNN_PACKAGE_DEV "libcudnn8-dev=$NV_CUDNN_VERSION-1+cuda12.0"

LABEL com.nvidia.cudnn.version="${NV_CUDNN_VERSION}"

RUN apt-get update && apt-get install -y --no-install-recommends \
    ${NV_CUDNN_PACKAGE} \
    ${NV_CUDNN_PACKAGE_DEV} \
    && apt-mark hold ${NV_CUDNN_PACKAGE_NAME} \
    && rm -rf /var/lib/apt/lists/*


# =========== dcv & sshd ================
RUN apt update && apt install -y --no-install-recommends \
    openssh-server \
    tar vim wget kmod htop software-properties-common apt-transport-https sudo pciutils ca-certificates xz-utils locales curl \
    mesa-utils libxvmc-dev xserver-xorg-core xserver-xorg xserver-xorg-dev xorg x11-utils xauth xinit openbox xfonts-base xterm \
    ubuntu-desktop-minimal gnome-shell gnome-terminal gdm3 libglfw3-dev libgles2-mesa-dev libglew-dev glew-utils libvdpau1 libxcb-damage0 libxcb-xtest0 \
    && apt clean && rm -rf /var/lib/apt/lists/*

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
