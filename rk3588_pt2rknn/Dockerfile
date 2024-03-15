# Version 1.0
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
# ENV TZ=Asia/Shanghai
# 维护者
LABEL maintainer="kaylor.chen@qq.com"

# RUN sed -i "s/archive.ubuntu.com/mirrors.cloud.tencent.com/g" /etc/apt/sources.list && \
#     sed -i "s/security.ubuntu.com/mirrors.cloud.tencent.com/g" /etc/apt/sources.list && \
#     sed -i "s/ports.ubuntu.com/mirrors.cloud.tencent.com/g" /etc/apt/sources.list && \
COPY rk3588_pt2rknn/requirements1.txt requirements1.txt

RUN	apt update && \
    apt install -y --no-install-recommends python3 python3-pip libgl-dev libglib2.0-0 python-is-python3

RUN pip install -r requirements1.txt

RUN apt install -y --no-install-recommends python3 python-is-python3 && \
    apt install -y --no-install-recommends python3-dev python3-pip gcc vim libprotobuf-dev zlib1g zlib1g-dev libsm6 && \
    apt install -y --no-install-recommends libgl1 libglib2.0-0 android-tools-adb

COPY rk3588_pt2rknn/rknn_toolkit2-1.6.0+81f21f4d-cp310-cp310-linux_x86_64.whl rknn_toolkit2-1.6.0+81f21f4d-cp310-cp310-linux_x86_64.whl

RUN pip install rknn_toolkit2-1.6.0+81f21f4d-cp310-cp310-linux_x86_64.whl

COPY rk3588_pt2rknn/requirements2.txt requirements2.txt

RUN pip install -r requirements2.txt

