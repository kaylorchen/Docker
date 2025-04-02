FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
# 维护者
LABEL maintainer="kaylor.chen@qq.com"

RUN sed -i "s/archive.ubuntu.com/mirrors.huaweicloud.com/g" /etc/apt/sources.list && \
    sed -i "s/security.ubuntu.com/mirrors.huaweicloud.com/g" /etc/apt/sources.list 
RUN	apt update && \
    apt install -y --no-install-recommends x11-utils g++ gcc cmake sudo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
# 创建用户 kaylor，设置密码并赋予 sudo 权限
RUN useradd -m -s /bin/bash kaylor && \
    echo "kaylor:kaylor" | chpasswd && \
    usermod -aG sudo kaylor && \
    echo "kaylor ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# 创建工作目录并授权
RUN mkdir -p /home/kaylor/work && \
    chown -R kaylor:kaylor /home/kaylor
