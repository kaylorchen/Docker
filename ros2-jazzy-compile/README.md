# ROS2 Jazzy 多架构编译环境

基于 `ros:jazzy`（Ubuntu 24.04）的 ROS 2 Jazzy 编译环境，支持 **amd64 (x86)** 和 **arm64** 两种架构，用一个 Docker Compose 文件统一管理。

镜像内预装：

- **ROS 2 打包/编译工具**：`bloom`、`catkin`/`colcon` 相关工具、`dh-python`、`debhelper`、`devscripts`、`fakeroot`、`cmake`、`equivs`
- **cv_bridge**：`ros-jazzy-cv-bridge`（ROS Image 消息 <-> OpenCV 图像转换）
- **PCL 相关库**：`ros-jazzy-pcl-ros`、`ros-jazzy-pcl-conversions`、`ros-jazzy-pcl-msgs`
- **OpenCV 4.6**（随 cv_bridge 自动安装）

## 目录结构

```
ros2-jazzy-compile/
├── Dockerfile      # 多架构构建脚本 (amd64 / arm64)
├── compose.yml     # Docker Compose: 一个文件兼容 amd64 + arm64 (profiles 区分)
└── README.md       # 本文件
```

## 构建镜像

使用 BuildKit，`--platform` 指定目标架构：

```bash
# x86
docker build --platform linux/amd64 -t ros2-jazzy-compile-amd64:latest .

# arm64 (若基础依赖已装好, 也可直接用已构建的 withdeps 镜像, 无需重新构建)
docker build --platform linux/arm64 -t ros2-jazzy-compile-arm64:latest .
```

不指定 `--platform` 时，默认构建宿主机架构。

> **注意**：从 Docker Hub 拉取基础镜像在国内可能很慢。若遇到卡住，可使用国内镜像源加速，
> 例如 `docker pull docker.m.daocloud.io/library/ros:jazzy`，然后打回 `ros:jazzy` 标签：
> `docker tag docker.m.daocloud.io/library/ros:jazzy ros:jazzy`

## Docker Compose 使用

`compose.yml` 用 **profiles** 区分两个架构，一个文件兼容两个版本，后台常驻运行。
宿主机 `~/work` 挂载到容器内**相同路径** `/home/kaylor/work`，编译产物的绝对路径在容器内外一致。

```bash
# x86 环境
docker compose --profile amd64 up -d

# ARM 交叉编译环境 (使用已装好依赖的 ros2-jazzy-compile-arm64:withdeps, 在 x86 上经 qemu 模拟)
docker compose --profile arm64 up -d

# 两个环境同时运行
docker compose --profile amd64 --profile arm64 up -d

# 进入容器 (容器名区分架构)
docker exec -it ros2-jazzy-compile-amd64 bash   # x86
docker exec -it ros2-jazzy-compile-arm64 bash   # ARM

# 进入后先 source ROS2 环境再工作
source /opt/ros/jazzy/setup.bash

# 查看日志
docker compose --profile amd64 logs -f

# 停止 (哪个 profile 起的就用哪个 down)
docker compose --profile amd64 down
docker compose --profile arm64 down
```

容器默认 `working_dir` 为 `/home/kaylor/work`，进入后可直接 cd 到你的工作路径，
例如 `cd ~/work/renesas/ros2_ws`。

## 验证安装

```bash
docker run --rm ros2-jazzy-compile-amd64:latest \
  bash -c 'dpkg -l | grep -E "ros-jazzy-(cv-bridge|pcl-ros|pcl-conversions|pcl-msgs)"; \
  python3 -c "import cv2; print(\"OpenCV\", cv2.__version__)"'
```

预期输出包含 `ros-jazzy-cv-bridge`、`ros-jazzy-pcl-ros` 等包，以及 OpenCV 版本号。
