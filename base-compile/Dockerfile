ARG TAG
# Version 1.0
FROM ubuntu:${TAG}

ENV DEBIAN_FRONTEND=noninteractive
# ENV TZ=Asia/Shanghai
# 维护者
LABEL maintainer="kaylor.chen@qq.com"

# RUN sed -i "s/archive.ubuntu.com/mirrors.cloud.tencent.com/g" /etc/apt/sources.list && \
#     sed -i "s/security.ubuntu.com/mirrors.cloud.tencent.com/g" /etc/apt/sources.list && \
#     sed -i "s/ports.ubuntu.com/mirrors.cloud.tencent.com/g" /etc/apt/sources.list && \
RUN	apt update && \
		apt install -y --no-install-recommends dh-python debhelper git devscripts fakeroot python3-bloom cmake equivs && \
		apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

