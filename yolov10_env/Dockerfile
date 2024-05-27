# Version 1.0
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
# ENV TZ=Asia/Shanghai
# 维护者
LABEL maintainer="kaylor.chen@qq.com"

# RUN sed -i "s/archive.ubuntu.com/mirrors.cloud.tencent.com/g" /etc/apt/sources.list && \
#     sed -i "s/security.ubuntu.com/mirrors.cloud.tencent.com/g" /etc/apt/sources.list && \
#     sed -i "s/ports.ubuntu.com/mirrors.cloud.tencent.com/g" /etc/apt/sources.list && \
COPY yolov10_env/requirements.txt /tmp/requirements.txt
RUN	apt update && \
	apt install -y --no-install-recommends python3 python3-pip && \
  pip install -r /tmp/requirements.txt

RUN apt install -y --no-install-recommends libgl-dev libglib2.0-0 python-is-python3 && \
    pip install onnx && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

