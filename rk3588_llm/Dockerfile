FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
# ENV TZ=Asia/Shanghai
# 维护者
LABEL maintainer="kaylor.chen@qq.com"

RUN apt update && \
    apt install -y --no-install-recommends python3 python-is-python3 && \
    apt install -y --no-install-recommends python3-dev python3-pip python3-tk

COPY rk3588_llm/requirements_rwkv7.txt requirements.txt

RUN pip3 install -r requirements.txt && && pip3 cache purge

COPY rk3588_llm/rkllm_toolkit-1.2.1-cp310-cp310-linux_x86_64.whl rkllm_toolkit-1.2.1-cp310-cp310-linux_x86_64.whl

RUN pip3 install rkllm_toolkit-1.2.1-cp310-cp310-linux_x86_64.whl && && pip3 cache purge

