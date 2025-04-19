# 使用 Ubuntu 22.04 作为基础镜像
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
ENV EMAIL="kaylor.chen@qq.com"
ENV API_KEY="your_api_key"
ENV ZONE_NAME="kaylordut.com"
ENV DOMAIN_NAME="shenzhen.kaylordut.com"
ENV SLEEP=300
# 维护者
LABEL maintainer="kaylor.chen@qq.com"

RUN sed -i "s/archive.ubuntu.com/mirrors.cloud.tencent.com/g" /etc/apt/sources.list && \
    sed -i "s/security.ubuntu.com/mirrors.cloud.tencent.com/g" /etc/apt/sources.list && \
    sed -i "s/ports.ubuntu.com/mirrors.cloud.tencent.com/g" /etc/apt/sources.list

# 安装 curl 和 wget（-y 自动确认安装）
RUN apt-get update && apt-get install -y curl wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
# 复制 cloudflare_ddns.sh 到镜像的 /app/ 目录
COPY cloudflare_ddns.sh /app/cloudflare_ddns.sh
COPY loop.sh /app/loop.sh

# 设置脚本可执行权限
RUN chmod +x /app/cloudflare_ddns.sh
RUN chmod +x /app/loop.sh

# 设置默认环境变量

# 设置工作目录
WORKDIR /app

# 默认运行 cloudflare_ddns.sh
CMD ["/app/loop.sh"]