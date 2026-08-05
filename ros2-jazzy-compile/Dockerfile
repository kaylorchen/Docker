# ROS2 Jazzy (Ubuntu 24.04) 多架构 (amd64 / arm64) 基础编译环境
# 构建 (BuildKit):
#   x86:   docker build --platform linux/amd64 -t ros2-jazzy-compile-amd64:latest .
#   arm64: docker build --platform linux/arm64 -t ros2-jazzy-compile-arm64:latest .
# 不指定 --platform 时，默认构建宿主机架构。基础镜像按目标平台自动拉取。

FROM ros:jazzy

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
LABEL maintainer="kaylor.chen@qq.com"

# 替换 Ubuntu 源为腾讯云镜像
#   amd64: archive.ubuntu.com/ubuntu       -> mirrors.cloud.tencent.com/ubuntu
#   arm64: ports.ubuntu.com/ubuntu-ports   -> mirrors.cloud.tencent.com/ubuntu-ports
# 24.04 使用 deb822 格式 /etc/apt/sources.list.d/ubuntu.sources，同时兼容旧 /etc/apt/sources.list
RUN sed -i -e "s|http://ports.ubuntu.com/ubuntu-ports/|http://mirrors.cloud.tencent.com/ubuntu-ports/|g" \
           -e "s|http://archive.ubuntu.com/ubuntu/|http://mirrors.cloud.tencent.com/ubuntu/|g" \
           -e "s|http://security.ubuntu.com/ubuntu/|http://mirrors.cloud.tencent.com/ubuntu/|g" \
           /etc/apt/sources.list.d/ubuntu.sources 2>/dev/null; \
    sed -i -e "s|http://ports.ubuntu.com/ubuntu-ports/|http://mirrors.cloud.tencent.com/ubuntu-ports/|g" \
           -e "s|http://archive.ubuntu.com/ubuntu/|http://mirrors.cloud.tencent.com/ubuntu/|g" \
           -e "s|http://security.ubuntu.com/ubuntu/|http://mirrors.cloud.tencent.com/ubuntu/|g" \
           /etc/apt/sources.list 2>/dev/null; \
    true

# 替换 ROS2 源为清华镜像 (24.04 使用 ros2.sources deb822 格式)
# 清华镜像不支持 deb-src，需要去掉
RUN sed -i "s|http://packages.ros.org/ros2/ubuntu|https://mirrors.tuna.tsinghua.edu.cn/ros2/ubuntu|g" /etc/apt/sources.list.d/ros2.sources 2>/dev/null; \
    sed -i "s|http://packages.ros.org/ros2/ubuntu|https://mirrors.tuna.tsinghua.edu.cn/ros2/ubuntu|g" /etc/apt/sources.list.d/ros2.list 2>/dev/null; \
    sed -i "s|Types: deb deb-src|Types: deb|g" /etc/apt/sources.list.d/ros2.sources 2>/dev/null; \
    true

RUN apt update && \
    apt install -y --no-install-recommends \
        dh-python debhelper git devscripts fakeroot python3-bloom cmake equivs \
        ros-jazzy-cv-bridge \
        ros-jazzy-pcl-ros \
        ros-jazzy-pcl-conversions \
        ros-jazzy-pcl-msgs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
