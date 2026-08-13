# ROS2 Humble (Ubuntu 22.04) 多架构 (amd64 / arm64) 开发环境
# 特性:
#   - Ubuntu 源换清华镜像 (amd64 → /ubuntu, arm64 → /ubuntu-ports)
#   - ROS2 源换清华镜像
#   - 添加 kaylordut 私有源 (http://apt.renesas.kaylordut.com/)
#   - apt-fast 直接从私有源安装 (自带 aria2 依赖), 之后的包都走 apt-fast
#   - ROS2 demo 包 + ros2-cyclonedds-config (CycloneDDS 自动配置)
# 说明: apt update / 安装 / 清理全部在同一层完成, 中间缓存不留在镜像层里
# 构建:
#   本机架构: docker build -t ros2-humble-dev:latest .
#   指定平台: docker buildx build --platform linux/amd64,linux/arm64 \
#               -t ros2-humble-dev:latest .

FROM ros:humble-ros-base

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
LABEL maintainer="kaylor.chen@qq.com"

RUN set -eux; \
    # 1. Ubuntu 源换清华: amd64 → /ubuntu, arm64 → /ubuntu-ports
    case "$(dpkg --print-architecture)" in \
        amd64) MIRROR="http://mirrors.tuna.tsinghua.edu.cn/ubuntu";; \
        arm64) MIRROR="http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports";; \
        *) echo "Unsupported arch: $(dpkg --print-architecture)" >&2; exit 1;; \
    esac; \
    sed -i -e "s|http://ports.ubuntu.com/ubuntu-ports|${MIRROR}|g" \
           -e "s|http://archive.ubuntu.com/ubuntu|${MIRROR}|g" \
           -e "s|http://security.ubuntu.com/ubuntu|${MIRROR}|g" \
           /etc/apt/sources.list; \
    # 2. ROS2 源换清华 (deb822 格式 ros2.sources; 清华不支持 deb-src, 去掉)
    sed -i -e "s|http://packages.ros.org/ros2/ubuntu|https://mirrors.tuna.tsinghua.edu.cn/ros2/ubuntu|g" \
           -e "s|^Types: deb deb-src|Types: deb|g" \
           /etc/apt/sources.list.d/ros2.sources; \
    # 3. 添加 kaylordut 私有源 (方法见 http://apt.renesas.kaylordut.com/)
    curl -fsSL http://apt.renesas.kaylordut.com/renesas_pai-public-key.asc \
        -o /usr/share/keyrings/renesas_pai-archive-keyring.asc; \
    . /etc/os-release; \
    { echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/renesas_pai-archive-keyring.asc] http://apt.renesas.kaylordut.com/ all stable"; \
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/renesas_pai-archive-keyring.asc] http://apt.renesas.kaylordut.com/ ${UBUNTU_CODENAME} stable"; } \
        > /etc/apt/sources.list.d/renesas_pai.list; \
    apt-get update; \
    # 4. 安装 apt-fast (来自私有源 jammy 通道, 自动带 aria2)
    apt-get install -y --no-install-recommends apt-fast; \
    # 5. 用 apt-fast 安装 iproute2 + vim + ROS2 demo 包 + CycloneDDS 自动配置 (私有源)
    #    + Foxglove 全家桶 (bridge 默认启动, rosbridge 兼容, MCAP 录制)
    apt-fast install -y --no-install-recommends \
        iproute2 \
        vim \
        iputils-ping \
        ros-humble-demo-nodes-cpp \
        ros-humble-demo-nodes-py \
        ros2-cyclonedds-config \
        ros-humble-foxglove-bridge \
        ros-humble-foxglove-compressed-video-transport \
        ros-humble-foxglove-msgs \
        ros-humble-rosbridge-suite \
        ros-humble-rosbag2-storage-mcap; \
    # 6. 交互式 shell 自动 source ROS2 环境 (exec 进去直接有 ros2 命令)
    printf '\n# ROS2 environment\nsource /opt/ros/humble/setup.bash\n' >> /etc/bash.bashrc; \
    # 7. 同层清理, 缓存不进镜像
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
