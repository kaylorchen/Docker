# Version 1.0
FROM nvcr.io/nvidia/isaac-sim:4.5.0

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
# 维护者
LABEL maintainer="kaylor.chen@qq.com"

RUN sed -i "s/archive.ubuntu.com/mirrors.cloud.tencent.com/g" /etc/apt/sources.list && \
    sed -i "s/security.ubuntu.com/mirrors.cloud.tencent.com/g" /etc/apt/sources.list && \
    sed -i "s/ports.ubuntu.com/mirrors.cloud.tencent.com/g" /etc/apt/sources.list
RUN pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu128 && pip cache purge
