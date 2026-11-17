# ROS2 Humble (Ubuntu 22.04) arm64 交叉编译基础环境
# 构建 (BuildKit):
#   arm64: docker build --platform linux/arm64 -t ros2-humble-compile-arm64:latest .
# 不指定 --platform 时，默认构建宿主机架构。基础镜像按目标平台自动拉取。

FROM ros:humble

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
LABEL maintainer="kaylor.chen@qq.com"

# 替换 Ubuntu 源为腾讯云镜像
#   amd64: archive.ubuntu.com/ubuntu       -> mirrors.cloud.tencent.com/ubuntu
#   arm64: ports.ubuntu.com/ubuntu-ports   -> mirrors.cloud.tencent.com/ubuntu-ports
# 22.04 主要使用 /etc/apt/sources.list，同时兼容 deb822 格式 ubuntu.sources
RUN sed -i -e "s|http://ports.ubuntu.com/ubuntu-ports/|http://mirrors.cloud.tencent.com/ubuntu-ports/|g" \
           -e "s|http://archive.ubuntu.com/ubuntu/|http://mirrors.cloud.tencent.com/ubuntu/|g" \
           -e "s|http://security.ubuntu.com/ubuntu/|http://mirrors.cloud.tencent.com/ubuntu/|g" \
           /etc/apt/sources.list /etc/apt/sources.list.d/ubuntu.sources 2>/dev/null; \
    true

# 替换 ROS2 源为清华镜像 (Humble 使用 ros2.list deb 格式, 兼容 ros2.sources deb822)
# 清华镜像不支持 deb-src，需要去掉
RUN sed -i "s|http://packages.ros.org/ros2/ubuntu|https://mirrors.tuna.tsinghua.edu.cn/ros2/ubuntu|g" \
           /etc/apt/sources.list.d/ros2.list /etc/apt/sources.list.d/ros2.sources 2>/dev/null; \
    sed -i "/^deb-src /d" /etc/apt/sources.list.d/ros2.list 2>/dev/null; \
    sed -i "s|Types: deb deb-src|Types: deb|g" /etc/apt/sources.list.d/ros2.sources 2>/dev/null; \
    true

RUN apt update && \
    apt install -y --no-install-recommends \
        dh-python debhelper git devscripts fakeroot python3-bloom cmake equivs \
        ros-humble-cv-bridge \
        ros-humble-pcl-ros \
        ros-humble-pcl-conversions \
        ros-humble-pcl-msgs \
        ros-humble-image-transport && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
