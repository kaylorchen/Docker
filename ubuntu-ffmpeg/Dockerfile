# Version 1.0
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
# 维护者
LABEL maintainer="kaylor.chen@qq.com"

RUN sed -i "s/archive.ubuntu.com/mirrors.huaweicloud.com/g" /etc/apt/sources.list && \
    sed -i "s/security.ubuntu.com/mirrors.huaweicloud.com/g" /etc/apt/sources.list && \
    sed -i "s/ports.ubuntu.com/mirrors.huaweicloud.com/g" /etc/apt/sources.list
RUN apt-get update && \
    apt-get install -y --no-install-recommends ffmpeg intel-media-va-driver && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

