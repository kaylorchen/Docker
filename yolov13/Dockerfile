# Version 1.0
FROM python:3.11-bookworm
ENV DEBIAN_FRONTEND=noninteractive
# ENV TZ=Asia/Shanghai
# 维护者
LABEL maintainer="kaylor.chen@qq.com"

# RUN sed -i "s/archive.ubuntu.com/mirrors.cloud.tencent.com/g" /etc/apt/sources.list && \
#     sed -i "s/security.ubuntu.com/mirrors.cloud.tencent.com/g" /etc/apt/sources.list && \
#     sed -i "s/ports.ubuntu.com/mirrors.cloud.tencent.com/g" /etc/apt/sources.list && \
COPY yolov13/requirements.txt /

RUN apt-get update && apt-get -y install libgl-dev && apt-get clean &&\
    wget https://github.com/Dao-AILab/flash-attention/releases/download/v2.7.3/flash_attn-2.7.3+cu11torch2.2cxx11abiFALSE-cp311-cp311-linux_x86_64.whl && \
    pip install -r requirements.txt && \
    pip cache purge && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /*.whl


