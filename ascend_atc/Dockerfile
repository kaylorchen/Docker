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
    apt-get install -y gcc make net-tools python3 python3-dev python3-pip && \
    pip3 install attrs cython numpy==1.24.0 decorator sympy cffi pyyaml pathlib2 psutil protobuf==3.20 scipy requests absl-py -i https://pypi.tuna.tsinghua.edu.cn/simple && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY Ascend-cann-toolkit*.run /Ascend-cann-toolkit.run

RUN cd / && \
    chmod a+x Ascend-cann-toolkit.run && \
    yes 'Y' | ./Ascend-cann-toolkit.run --install --whitelist=atc && \
    rm Ascend-cann-toolkit.run


