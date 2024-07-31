FROM kaylor/l4t-base:r36.2.0_base 

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
# 维护者
LABEL maintainer="kaylor.chen@qq.com"

RUN yes "2" | update-alternatives --config cuda

RUN apt update && \
		yes ' ' | apt install -y --no-install-recommends curl && \
		curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
		echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://mirrors.cloud.tencent.com/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null && \
		apt update && \
		apt install -y --no-install-recommends ros-humble-ros-base ros-dev-tools && \
		apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

