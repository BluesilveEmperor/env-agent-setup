# WSLg/Docker/SSH 高级功能配置指南

## 环境概述

本文档介绍WSL2的三个高级功能：WSLg（GUI应用支持）、Docker Desktop WSL2后端集成、WSL内SSH服务配置。这些功能基于WSL2基础环境，为用户提供更完整的开发体验。

## WSLg GUI 应用配置

### 概述

WSLg（Windows Subsystem for Linux GUI）允许在WSL2中运行Linux GUI应用，窗口直接显示在Windows桌面上。

### Windows 11（默认可用）

Windows 11 21H2+ 内置WSLg支持，无需额外配置：

```bash
# 验证WSLg可用
echo $DISPLAY
# 应输出类似 :0

echo $WAYLAND_DISPLAY
# 应输出 wayland-0

# 测试GUI应用
sudo apt install -y x11-apps
xeyes
xcalc
```

### Windows 10 WSLg 补丁安装

Windows 10需要额外安装WSLg支持包：

```powershell
# 确保WSL2已更新到最新版本
wsl --update

# 安装GUI支持（WSL2 0.47+）
# WSLg会随wsl --update自动安装

# 验证WSLg
wsl -d Ubuntu -- bash -c "echo $DISPLAY"
```

如果WSLg不可用，尝试以下步骤：

```powershell
# 1. 更新WSL到最新预览版
wsl --update --pre-release

# 2. 重启WSL
wsl --shutdown

# 3. 进入WSL验证
wsl -d Ubuntu -- bash -c "ls /tmp/.X11-unix/"
```

### 常用GUI应用安装

```bash
# 安装文本编辑器
sudo apt install -y gedit        # GNOME文本编辑器
sudo apt install -y vim-gtk3     # GVim

# 安装浏览器
sudo apt install -y firefox      # Firefox（需启用systemd）

# 安装开发工具
sudo apt install -y code         # VS Code（推荐使用Windows版VS Code的Remote-WSL扩展）

# 安装终端
sudo apt install -y gnome-terminal

# 安装系统监控
sudo apt install -y htop         # 终端工具，不需要GUI
sudo apt install -y gnome-system-monitor
```

### GPU 加速支持

WSLg支持GPU加速（需要合适的GPU驱动）：

```bash
# 检查GPU信息
nvidia-smi  # NVIDIA GPU

# 检查OpenGL支持
glxinfo | grep "OpenGL version"

# 安装OpenGL测试工具
sudo apt install -y mesa-utils
glxgears
```

**NVIDIA GPU**：安装NVIDIA CUDA on WSL驱动（Windows端）即可使用GPU加速。

**AMD/Intel GPU**：WSLg使用d3d12后端，大多数情况下开箱即用。

### 常见GUI问题排查

| 问题 | 原因 | 解决方案 |
|------|------|---------|
| `$DISPLAY` 为空 | WSLg未启用 | 运行 `wsl --update` 更新WSL |
| GUI窗口不显示 | X11 socket缺失 | 检查 `/tmp/.X11-unix/` 是否存在 |
| 性能差/卡顿 | GPU加速未启用 | 安装对应GPU的WSL驱动 |
| 音频不工作 | PulseAudio未配置 | 检查 `$PULSE_SERVER` 环境变量 |
| 中文乱码 | 缺少中文字体 | 安装字体：`sudo apt install -y fonts-noto-cjk` |

---

## Docker Desktop WSL2 后端集成

### 概述

Docker Desktop支持WSL2后端，在WSL2内运行Docker引擎，性能优于Hyper-V后端。

### 前提条件

- Windows 10 19044+ 或 Windows 11
- WSL2已安装并运行
- Docker Desktop已安装

### Docker Desktop 安装

```powershell
# 方式一：使用winget安装
winget install Docker.DockerDesktop

# 方式二：使用Chocolatey安装
choco install docker-desktop -y

# 方式三：手动下载安装
# 下载地址：https://www.docker.com/products/docker-desktop/
```

### 启用WSL2后端

1. 启动Docker Desktop
2. 进入 **Settings > General**
3. 勾选 **"Use the WSL 2 based engine"**
4. 点击 **Apply & Restart**

### 启用发行版集成

1. 进入 **Settings > Resources > WSL Integration**
2. 开启 **"Enable integration with my default WSL distro"**
3. 对需要使用Docker的发行版逐个开启集成开关
4. 点击 **Apply & Restart**

### 验证Docker

```bash
# 在WSL中验证Docker
docker --version
docker run hello-world
docker info | grep "Operating System"
# 应显示基于WSL的Docker Engine

# 验证Docker Compose
docker compose version
```

### 国内Docker镜像加速

```bash
# 配置Docker镜像加速（在Docker Desktop Settings > Docker Engine中配置）
# 或在WSL内编辑 ~/.docker/daemon.json（如Docker未使用Desktop管理）
```

Docker Desktop Settings > Docker Engine 配置：

```json
{
  "registry-mirrors": [
    "https://mirror.ccs.tencentyun.com",
    "https://hub-mirror.c.163.com",
    "https://docker.mirrors.ustc.edu.cn"
  ]
}
```

### 不使用Docker Desktop（在WSL内直接安装Docker Engine）

如果不想使用Docker Desktop，可以在WSL内直接安装Docker Engine（需要systemd支持）：

```bash
# 1. 启用systemd（在/etc/wsl.conf中）
[boot]
systemd=true

# 2. 重启WSL后在WSL内安装Docker
# Ubuntu/Debian
sudo apt update
sudo apt install -y ca-certificates curl gnupg

# 添加Docker GPG密钥
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 添加Docker仓库（使用中科大镜像）
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 安装Docker Engine
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 3. 启动Docker服务
sudo systemctl start docker
sudo systemctl enable docker

# 4. 将用户添加到docker组
sudo usermod -aG docker $USER

# 5. 验证
docker --version
```

### 常见Docker问题

| 问题 | 原因 | 解决方案 |
|------|------|---------|
| Docker命令找不到 | 发行版未集成 | 在Docker Desktop中启用对应发行版的WSL集成 |
| Permission denied | 用户不在docker组 | `sudo usermod -aG docker $USER` |
| Cannot connect to Docker daemon | Docker服务未运行 | 启动Docker Desktop或在WSL内 `sudo systemctl start docker` |
| 拉取镜像超时 | 网络问题 | 配置国内Docker镜像加速 |

---

## SSH 服务配置

### 概述

在WSL内安装SSH服务，可从其他机器远程访问WSL实例，也便于VS Code Remote-SSH等工具连接。

### 安装openssh-server

```bash
# Ubuntu/Debian
sudo apt install -y openssh-server

# CentOS
sudo yum install -y openssh-server

# Fedora
sudo dnf install -y openssh-server

# Arch
sudo pacman -S --noconfirm openssh

# openSUSE
sudo zypper install -y openssh-server
```

### 配置sshd_config

```bash
# 编辑SSH配置
sudo vi /etc/ssh/sshd_config

# 推荐配置
Port 22                              # SSH端口（可改为其他端口如2222）
ListenAddress 0.0.0.0               # 监听所有地址
PermitRootLogin no                   # 禁止root登录
PasswordAuthentication yes           # 允许密码认证（初期调试用）
PubkeyAuthentication yes             # 启用密钥认证
AuthorizedKeysFile .ssh/authorized_keys  # 密钥文件路径
AllowUsers myuser                    # 允许的用户
```

### 生成SSH密钥

```bash
# 在客户端机器上生成密钥（非WSL内）
ssh-keygen -t ed25519 -C "your.email@example.com"

# 将公钥复制到WSL
# 方法1：使用ssh-copy-id
ssh-copy-id -p 22 myuser@<wsl-ip>

# 方法2：手动复制
# 将客户端的 ~/.ssh/id_ed25519.pub 内容追加到WSL的 ~/.ssh/authorized_keys
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "ssh-ed25519 AAAA... user@host" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

### 启动SSH服务

#### 方式一：systemd自动启动（推荐）

```bash
# 确保/etc/wsl.conf中启用systemd
[boot]
systemd=true

# 启用SSH服务自启动
sudo systemctl enable ssh
sudo systemctl start ssh

# 检查状态
sudo systemctl status ssh
```

#### 方式二：手动启动

```bash
# 启动SSH服务
sudo service ssh start

# 或直接运行
sudo /usr/sbin/sshd

# 检查是否运行
ps aux | grep sshd
```

### Windows端端口转发

WSL2使用虚拟网络，外部机器无法直接访问。需要配置Windows端口转发：

```powershell
# 获取WSL IP地址
$wslIP = (wsl -d Ubuntu -- hostname -I).Trim()

# 配置端口转发（将Windows 2222端口转发到WSL 22端口）
netsh interface portproxy add v4tov4 listenport=2222 listenaddress=0.0.0.0 connectport=22 connectaddress=$wslIP

# 添加防火墙规则
New-NetFirewallRule -DisplayName "WSL SSH" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 2222

# 查看转发规则
netsh interface portproxy show v4tov4
```

> **注意**：WSL2每次重启后IP可能变化，端口转发规则需要更新。可创建启动脚本自动更新。

### 自动更新端口转发脚本

```powershell
# 保存为 update-wsl-ssh-port.ps1
$wslIP = (wsl -d Ubuntu -- hostname -I).Trim()
if ($wslIP) {
    # 删除旧规则
    netsh interface portproxy delete v4tov4 listenport=2222 listenaddress=0.0.0.0 2>$null
    # 添加新规则
    netsh interface portproxy add v4tov4 listenport=2222 listenaddress=0.0.0.0 connectport=22 connectaddress=$wslIP
    Write-Host "WSL SSH端口转发已更新: $wslIP:22 -> 0.0.0.0:2222" -ForegroundColor Green
}
```

### 从外部机器SSH连接WSL

```bash
# 从同一局域网的其他机器连接
ssh -p 2222 myuser@<windows-ip>

# 使用密钥连接
ssh -p 2222 -i ~/.ssh/id_ed25519 myuser@<windows-ip>
```

### VS Code Remote-SSH配置

在客户端的 `~/.ssh/config` 中添加：

```text
Host wsl
    HostName <windows-ip>
    Port 2222
    User myuser
    IdentityFile ~/.ssh/id_ed25519
```

然后在VS Code中使用 Remote-SSH 连接到 `wsl` 即可。

### 常见SSH问题

| 问题 | 原因 | 解决方案 |
|------|------|---------|
| Connection refused | SSH服务未启动 | `sudo service ssh start` |
| Permission denied | 密钥或密码错误 | 检查authorized_keys权限(600)、检查sshd_config |
| Connection timeout | 端口转发未配置 | 配置netsh端口转发和防火墙规则 |
| Host key changed | WSL重装后host key变化 | 删除 `~/.ssh/known_hosts` 中旧条目 |
| SSH断开 | WSL自动休眠 | 配置wsl.conf保持WSL运行 |

## 预计时间

- WSLg验证：5分钟
- Docker Desktop集成：10-15分钟
- SSH服务配置：10-15分钟
- 端口转发配置：5分钟

## 注意事项

1. **WSLg版本要求**：Windows 11默认可用，Windows 10需WSL2 0.47+
2. **Docker Desktop推荐**：WSL2后端比Hyper-V后端性能更好
3. **systemd依赖**：SSH自启动和Docker Engine直接安装都需要systemd
4. **端口转发**：WSL2每次重启IP可能变化，端口转发需更新
5. **安全考虑**：SSH服务暴露在网络上时，建议禁用密码认证仅使用密钥

## 相关资源

- WSL2基础安装 → [references/wsl-setup.md](wsl-setup.md)
- 开发环境配置 → [references/wsl-dev-env.md](wsl-dev-env.md)
- 互操作配置 → [references/wsl-interop.md](wsl-interop.md)
- 实例管理 → [references/wsl-management.md](wsl-management.md)
- [Docker Desktop WSL2文档](https://docs.docker.com/desktop/wsl/)
