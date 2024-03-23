# Version 1.0
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
# 维护者
LABEL maintainer="kaylor.chen@qq.com"

RUN apt update && \
    apt install -y systemd systemd-sysv openvpn iproute2 kmod && \
    apt clean

# 添加挂载点
VOLUME [ "/sys/fs/cgroup" ]

# 使用systemd作为容器的PID 1
CMD ["/sbin/init"]

