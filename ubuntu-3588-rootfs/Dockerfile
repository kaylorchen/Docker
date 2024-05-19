# Version 1.0
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
# 维护者
LABEL maintainer="kaylor.chen@qq.com"

RUN sed -i "s/ports.ubuntu.com/mirrors.cloud.tencent.com/g" /etc/apt/sources.list

COPY kaylor-keyring.gpg /etc/apt/keyrings/
COPY rk3588-kaylor.list /etc/apt/sources.list.d/

RUN apt update && apt install -y --no-install-recommends gcc g++ cmake openssh-server &&  \
    echo "PermitRootLogin yes" | tee -a /etc/ssh/sshd_config

CMD [ "/etc/init.d/ssh", "start" ]
EXPOSE 22


RUN apt update && apt install -y --no-install-recommends vim libopencv-dev g++ gcc \
    fakeroot devscripts libspdlog-dev libsystemd-dev libcap-dev liblz4-dev \
    libgcrypt-dev libzstd-dev debhelper rknpu2-dev librockchip-mpp-dev librga-dev \
    libstb-dev libturbojpeg0-dev libjpeg-turbo8-dev librga2 libboost-dev \
    libboost-system1.74-dev kaylordut-dev