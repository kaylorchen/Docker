# Version 1.0
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
# 维护者
LABEL maintainer="kaylor.chen@qq.com"


RUN apt update && \
    apt install -y openvpn easy-rsa vim systemd systemd-sysv iproute2 kmod wget openssl ca-certificates iptables && \
    apt clean

RUN sed -i "s/archive.ubuntu.com/mirrors.cloud.tencent.com/g" /etc/apt/sources.list && \
    sed -i "s/security.ubuntu.com/mirrors.cloud.tencent.com/g" /etc/apt/sources.list && \
    sed -i "s/ports.ubuntu.com/mirrors.cloud.tencent.com/g" /etc/apt/sources.list && \
    apt clean

# 设置容器启动时默认执行的命令
CMD ["bash", "-c", "/etc/openvpn/start.sh"]
