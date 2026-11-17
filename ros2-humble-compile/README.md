# ROS2 Humble arm64 交叉编译环境

基于 `ros:humble`（Ubuntu 22.04）的 ROS 2 Humble **arm64** 编译环境。

> 宿主系统本身是 ROS 2 Humble（amd64），本环境仅用于在 x86 主机上经 qemu 模拟的
> **arm64** 交叉编译，故只提供 arm64 一个架构。

镜像内预装：

- **ROS 2 打包/编译工具**：`bloom`、`catkin`/`colcon` 相关工具、`dh-python`、`debhelper`、`devscripts`、`fakeroot`、`cmake`、`equivs`
- **cv_bridge**：`ros-humble-cv-bridge`（ROS Image 消息 <-> OpenCV 图像转换）
- **image_transport**：`ros-humble-image-transport`（图像传输/订阅发布插件）
- **PCL 相关库**：`ros-humble-pcl-ros`、`ros-humble-pcl-conversions`、`ros-humble-pcl-msgs`
- **OpenCV**（随 cv_bridge 自动安装）

## 目录结构

```
ros2-humble-compile/
├── Dockerfile      # arm64 构建脚本
├── compose.yml     # Docker Compose (仅 arm64)
└── README.md       # 本文件
```

## 构建镜像

使用 BuildKit，`--platform` 指定目标架构：

```bash
docker build --platform linux/arm64 -t ros2-humble-compile-arm64:latest .
```

> **注意**：从 Docker Hub 拉取基础镜像在国内可能很慢。若遇到卡住，可使用国内镜像源加速，
> 例如 `docker pull docker.m.daocloud.io/library/ros:humble`，然后打回 `ros:humble` 标签：
> `docker tag docker.m.daocloud.io/library/ros:humble ros:humble`
> （本机 Docker daemon 已配置 `docker.m.daocloud.io` / `docker.1ms.run` 加速器，
> 直接 `docker pull --platform linux/arm64 ros:humble` 即可自动走加速源。）

## Docker Compose 使用

`compose.yml` 强制 `linux/arm64` 平台，在 x86 主机上经 qemu/binfmt 模拟运行。
宿主机 `~/work` 挂载到容器内**相同路径** `/home/kaylor/work`，编译产物的绝对路径在容器内外一致。

```bash
# 启动 (需先构建好镜像)
docker compose up -d

# 进入容器
docker exec -it ros2-humble-compile-arm64 bash

# 进入后先 source ROS2 环境再工作
source /opt/ros/humble/setup.bash

# 查看日志
docker compose logs -f

# 停止
docker compose down
```

容器默认 `working_dir` 为 `/home/kaylor/work`，进入后可直接 cd 到你的工作路径，
例如 `cd ~/work/renesas/ros2_ws`。

> 若构建时个别依赖在 qemu 下安装失败，可进入容器手动 `apt install` 后
> `docker commit` 打新标签（参考 Jazzy 环境的 `:withdeps` 用法）。

## 验证安装

```bash
docker run --rm --platform linux/arm64 ros2-humble-compile-arm64:latest \
  bash -c 'dpkg -l | grep -E "ros-humble-(cv-bridge|pcl-ros|pcl-conversions|pcl-msgs|image-transport)"; \
  python3 -c "import cv2; print(\"OpenCV\", cv2.__version__)"'
```

预期输出包含 `ros-humble-cv-bridge`、`ros-humble-pcl-ros` 等包，以及 OpenCV 版本号。
