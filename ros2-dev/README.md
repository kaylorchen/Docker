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
│   ├── cyclonedds.xml         # host 网络版 CycloneDDS 配置 (回退用)
│   └── cyclonedds-bridge.xml  # 桥接网络版 (方案 A, amd64 当前挂载)
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

`compose.yml` 用 **profiles** 区分两个架构，一个文件兼容两个版本，后台常驻运行（`restart: unless-stopped`，开机自启）。amd64 默认**不挂载**宿主机目录（工作目录为容器内 `/root/work`），如需挂载取消 compose 内注释并按需改路径；arm64 为交叉编译环境，挂载到相同路径 `/home/kaylor/work` 保证编译产物绝对路径一致。

- **amd64（方案 A）桥接网络 + 端口段发布**：容器保持网络隔离，`ports` 发布 UDP 7410-7461（domain 0，ParticipantIndex auto，每个容器内进程自动占 7410+2n / 7411+2n，最多 26 进程），XML 用 `ExternalNetworkAddress=192.168.111.111` 让对端回包经宿主机 DNAT 进容器——DDS 单播可跨桥接 NAT，原理详见 [DDS 跨机通信调试记录](#dds-跨机通信调试记录)
- **Foxglove WebSocket 端口**：`8765`（foxglove_bridge）/ `9090`（rosbridge_server）已映射，容器内装好对应的桥接包并启动后，Foxglove Studio 连 `ws://<宿主机IP>:<端口>` 即可
- **arm64** 保持 `network_mode: host`（纯交叉编译用途，不做 DDS 通信）
- **`dds/` 挂载**：CycloneDDS 配置放在宿主机 `dds/` 目录并挂载进容器，改配置和重建容器互不影响（容器内临时改的配置会在 recreate 时丢失）

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

## DDS 跨机通信调试记录

香橙派（192.168.111.143，WiFi）收不到容器 Hello World 的两个根因：

1. **Docker 桥接网络破坏 DDS 通信**：桥接 NAT 下容器报文中宣告的 locator 是容器内网 IP（172.18.0.2），对端路由不回去；且对端发往宿主机 7410 端口的单播 SPDP 无人监听（桥接默认不发布端口），包被内核丢弃。
2. **容器 recreate 丢失运行时配置**：容器内改的 `cyclonedds.xml` 存在可写层，重建即回退到镜像内版本。

**方案 A（当前 amd64 采用）**：桥接网络 + 端口段发布 + `ExternalNetworkAddress`：

- `ParticipantIndex=auto`：容器内每个 ROS2 进程自动取空闲索引，第 n 个进程占 **UDP 7410+2n（单播 SPDP）/ 7411+2n（数据）**；compose `ports` 发布 7410-7421 端口段（支持最多 6 个进程同时运行）→ 对端回包经 DNAT 进容器。**不要钉死 ParticipantIndex=0**：那会限制同一台机器上同时只能跑一个 ROS2 进程（第二个进程绑定 7410/7411 失败）；
- `ExternalNetworkAddress=192.168.111.111` 让宣告给对端的 locator 用宿主机 IP → 对端回包地址可路由；
- `Peer 127.0.0.1`：容器内进程间发现走回环——每个进程把 SPDP 送到 127.0.0.1:7410（index 0 进程），经回包/头发夹 DNAT 互相认识；
- 出方向经 SNAT 天然可达，两端 XML 关多播、单播互指（香橙派 Peer 指宿主机 IP）。

**端口公式**（排查用）：`7400 + 250×domain_id + 10 + 2×ParticipantIndex`（单播 SPDP），数据端口 +1。**换 `ROS_DOMAIN_ID` 时 compose 的 `ports` 必须同步改**（如 domain 1 → 7660/7661），双方 domain 必须一致。

**回退 host 方案**：`git checkout` 上一版 `compose.yml`，挂载改回 `dds/cyclonedds.xml`，`docker compose --profile amd64 up -d` 一次 recreate 即恢复。

**香橙派侧仅一处改动**：`ParticipantIndex` 0 → auto（理由同上：钉死 0 时 Pi 上同时只能跑一个 ROS2 进程，daemon 占着 7410/7411 后 echo 会绑定失败）。除此之外它眼中对端始终是 192.168.111.111（host 方案是宿主直连，方案 A 是宿主端口 DNAT），无需其他改动。
