# ROS2 Humble 开发环境（清华源 + apt-fast + CycloneDDS）

基于 `ros:humble-ros-base`（Ubuntu 22.04 jammy）的 ROS 2 Humble 开发环境，支持 **amd64 (x86)** 和 **arm64** 两种架构，一个 Dockerfile 按目标架构自动适配镜像源。

镜像内配置：

- **Ubuntu 源 → 清华镜像**：amd64 用 `mirrors.tuna.tsinghua.edu.cn/ubuntu`，arm64 自动改用 `ubuntu-ports` 路径
- **ROS2 源 → 清华镜像**：`packages.ros.org` 替换为 `mirrors.tuna.tsinghua.edu.cn/ros2`
- **kaylordut 私有源**：按 http://apt.renesas.kaylordut.com/ 页面的方法添加（GPG 公钥 + `signed-by` 绑定），含通用通道 `all stable` 和版本通道 `jammy stable`
- **apt-fast**：直接从私有源安装（1.11.1，自动带 aria2 后端），多线程下载，后续安装包均走 apt-fast
- **iproute2**：`ip` / `ss` 等网络调试工具
- **vim**：编辑器
- **ROS 2 demo 包**：`ros-humble-demo-nodes-cpp`、`ros-humble-demo-nodes-py`
- **ros2-cyclonedds-config**（私有源）：安装时自动生成 `/etc/ros/dds/cyclonedds.xml` 和 service-environment.conf，并把 `RMW_IMPLEMENTATION` / `CYCLONEDDS_URI` / `ROS_DOMAIN_ID` 写入用户 shell rc，附带 `cyclonedds-setup` 命令可重新配置

## 目录结构

```
ros2-dev/
├── Dockerfile      # 多架构构建脚本 (amd64 / arm64 自适应)
├── compose.yml     # Docker Compose: 后台常驻运行, profiles 区分架构
├── dds/
│   └── cyclonedds.xml  # CycloneDDS 配置 (挂载进容器, 重建不丢)
└── README.md       # 本文件
```

## 构建镜像

### 前置要求

- Docker（BuildKit 默认已启用）
- 宿主机构建时需能访问：清华镜像、`http://apt.renesas.kaylordut.com/`（私有源，需在内网或 VPN 环境）

### 本机架构构建（默认 amd64）

```bash
docker build -t ros2-humble-dev:latest .
```

### 指定架构构建（amd64 / arm64 双架构）

基础镜像按 `--platform` 自动拉取对应架构，Dockerfile 内用 `dpkg --print-architecture` 自动选择清华源路径，无需任何改动：

```bash
# x86
docker build --platform linux/amd64 -t ros2-humble-dev-amd64:latest .

# arm64（x86 主机上交叉构建需 qemu/binfmt，或用 arm64 主机直接构建）
docker build --platform linux/arm64 -t ros2-humble-dev-arm64:latest .

# 或用 buildx 一次构建两个架构
docker buildx build --platform linux/amd64,linux/arm64 -t ros2-humble-dev:latest .
```

> **注意**：从 Docker Hub 拉取基础镜像在国内可能很慢。若卡住，可用国内镜像加速，
> 例如 `docker pull docker.m.daocloud.io/library/ros:humble-ros-base`，
> 再打回原标签：`docker tag docker.m.daocloud.io/library/ros:humble-ros-base ros:humble-ros-base`

## Docker Compose（后台常驻）

`compose.yml` 用 **profiles** 区分两个架构，一个文件兼容两个版本，后台常驻运行（`restart: unless-stopped`，开机自启）。宿主机 `~/work` 挂载到容器内**相同路径** `/home/kaylor/work`。

- **`network_mode: host`**：容器直通宿主网络，ROS2/DDS 才能与局域网设备（如香橙派）通信——Docker 桥接网络的 NAT 会破坏 DDS 的 locator 宣告和单播发现，详见 [ros2-dev 调试记录](#dds-跨机通信调试记录)
- **`dds/cyclonedds.xml` 挂载**：CycloneDDS 配置放在宿主机 `dds/` 目录并挂载进容器，改配置和重建容器互不影响（容器内临时改的配置会在 recreate 时丢失）

```bash
# x86 环境（后台启动）
docker compose --profile amd64 up -d

# ARM 环境（x86 主机上需 qemu/binfmt 模拟）
docker compose --profile arm64 up -d

# 两个环境同时运行
docker compose --profile amd64 --profile arm64 up -d

# 进入容器（容器名区分架构）
docker exec -it ros2-humble-dev-amd64 bash   # x86
docker exec -it ros2-humble-dev-arm64 bash   # ARM

# 查看日志 / 停止
docker compose --profile amd64 logs -f
docker compose --profile amd64 down
```

## 运行

```bash
docker run -it --rm ros2-humble-dev:latest bash
# 或进入 compose 起的容器:
docker exec -it ros2-humble-dev-amd64 bash
```

**交互式 shell 进入后无需手动 source**：ROS2 环境（`/etc/bash.bashrc`）和 CycloneDDS 变量（`/root/.bashrc`）都会自动加载，`ros2` 命令直接可用。

`ros2-cyclonedds-config` 已在构建时把 CycloneDDS 相关环境变量写入 `/root/.bashrc`，**交互式 shell** 自动生效；`bash -c` 等非交互方式不读 `.bashrc`，需手动 export（见下）。如需重新配置运行 `cyclonedds-setup`。

### 验证 demo 通信（两个终端）

```bash
# 终端 1（talker 发布）
docker exec -it <容器名> bash -c '
  export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
  export CYCLONEDDS_URI=file:///etc/ros/dds/cyclonedds.xml
  source /opt/ros/humble/setup.bash
  ros2 run demo_nodes_cpp talker'

# 终端 2（listener 订阅，能收到消息即通信正常，走 CycloneDDS）
docker exec -it <容器名> bash -c '
  export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
  export CYCLONEDDS_URI=file:///etc/ros/dds/cyclonedds.xml
  source /opt/ros/humble/setup.bash
  ros2 run demo_nodes_py listener'
```

## 验证安装

```bash
docker run --rm ros2-humble-dev:latest bash -c '
  echo "=== apt 源 ==="; grep -rh "^deb " /etc/apt/sources.list /etc/apt/sources.list.d/;
  echo "=== apt-fast ==="; which apt-fast;
  echo "=== 已装包 ==="; dpkg -l | grep -E "ros-humble-demo-nodes|cyclonedds-config|rmw-cyclonedds"'
```

预期输出：`deb` 行全部指向清华镜像和 `apt.renesas.kaylordut.com`；`/usr/local/bin/apt-fast` 存在；`ros-humble-demo-nodes-cpp`、`ros-humble-demo-nodes-py`、`ros2-cyclonedds-config`、`ros-humble-rmw-cyclonedds-cpp` 均已安装。

## apt-fast 用法

容器内装新包时用 `apt-fast` 代替 `apt install`（自动多线程下载）：

```bash
apt-fast update              # 同 apt update
apt-fast install <包名>      # 多线程下载后安装
apt-fast upgrade             # 升级
apt-fast clean               # 清理下载目录
```

配置位于 `/etc/apt-fast.conf`；带 `-y` 时自动进入免交互下载模式（`DOWNLOADBEFORE`），适合脚本/CI 环境。
