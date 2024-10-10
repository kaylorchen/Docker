# Version 1.0
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
# 维护者
LABEL maintainer="kaylor.chen@qq.com"

RUN sed -i "s/archive.ubuntu.com/mirrors.cloud.tencent.com/g" /etc/apt/sources.list && \
    sed -i "s/security.ubuntu.com/mirrors.cloud.tencent.com/g" /etc/apt/sources.list && \
    sed -i "s/ports.ubuntu.com/mirrors.cloud.tencent.com/g" /etc/apt/sources.list

RUN apt-get update ;\
    apt-get install -y wget xz-utils git sudo systemd locales rsync acl aptly aria2 bc \
    binfmt-support bison btrfs-progs	build-essential ca-certificates ccache cpio \ 
    cryptsetup curl	debian-archive-keyring debian-keyring debootstrap device-tree-compiler \
    dialog dirmngr dosfstools dwarves f2fs-tools fakeroot flex gawk \
    gcc-arm-linux-gnueabihf gdisk gpg imagemagick jq kmod libbison-dev \
    libc6-dev-armhf-cross libelf-dev libfdt-dev libfile-fcntllock-perl \ 
    libfl-dev liblz4-tool libncurses-dev libpython2.7-dev libssl-dev \
	libusb-1.0-0-dev linux-base locales lzop ncurses-base ncurses-term \ 
    nfs-kernel-server ntpdate p7zip-full parted patchutils pigz pixz \
    pkg-config pv python3-dev python3-distutils qemu-user-static rsync swig \
    systemd-container u-boot-tools udev unzip uuid-dev wget whiptail zip \ 
    zlib1g-dev gcc-riscv64-linux-gnu distcc lib32ncurses-dev lib32stdc++6 \ 
    psmisc uuid uuid-runtime libc6-i386 python2 python3 fdisk; \
    echo "Asia/Shanghai" > /etc/timezone ; \
    apt-get clean ; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir workspace/toolchains -pv ;\
    cd workspace/toolchains ;\
    wget https://mirrors.tuna.tsinghua.edu.cn/armbian-releases/_toolchain/gcc-arm-11.2-2022.02-x86_64-aarch64-none-linux-gnu.tar.xz ; \
    wget https://mirrors.tuna.tsinghua.edu.cn/armbian-releases/_toolchain/gcc-linaro-7.4.1-2019.02-x86_64_aarch64-linux-gnu.tar.xz ; \
    tar -xvf gcc-arm-11.2-2022.02-x86_64-aarch64-none-linux-gnu.tar.xz ; \
    tar -xvf gcc-linaro-7.4.1-2019.02-x86_64_aarch64-linux-gnu.tar.xz ; \
    rm *.xz 
