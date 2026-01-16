# Version 1.0
FROM ultralytics/ultralytics:8.4.3

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
# 维护者
LABEL maintainer="kaylor.chen@qq.com"

RUN sed -i "s/archive.ubuntu.com/mirrors.cloud.tencent.com/g" /etc/apt/sources.list && \
    sed -i "s/security.ubuntu.com/mirrors.cloud.tencent.com/g" /etc/apt/sources.list && \
	sed -i.bak  -e 's/^\(\s*\)# \(a += random.choice(\[-180, -90, 0, 90\])\)/\1\2/' /ultralytics/ultralytics/data/augment.py
RUN apt-get update && \
    apt-get install -y --no-install-recommends libgl-dev libglib2.0-0 python-is-python3 vim && \
    pip install onnx tensorboard && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


