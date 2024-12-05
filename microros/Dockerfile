# Version 1.0
FROM microros/base:humble

SHELL [ "/bin/bash", "-c" ]
ENV SHELL=/bin/bash
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
# 维护者
LABEL maintainer="kaylor.chen@qq.com"

# RUN sed -i "s/archive.ubuntu.com/mirrors.cloud.tencent.com/g" /etc/apt/sources.list && \
#     sed -i "s/security.ubuntu.com/mirrors.cloud.tencent.com/g" /etc/apt/sources.list && \
#     sed -i "s/ports.ubuntu.com/mirrors.cloud.tencent.com/g" /etc/apt/sources.list

RUN apt-get update && \
    source /opt/ros/humble/setup.bash && \ 
    source /uros_ws/install/setup.bash && \ 
    cd /uros_ws && \
    ros2 run micro_ros_setup create_firmware_ws.sh freertos olimex-stm32-e407 && \
    ros2 run micro_ros_setup configure_firmware.sh add_two_ints_service -t udp -i 192.168.111.111 -p 8888 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*



