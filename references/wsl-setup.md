# WSL2 基础安装与发行版配置指南

## 环境概述

WSL2（Windows Subsystem for Linux 2）是微软提供的在Windows上运行Linux环境的兼容层。WSL2使用真正的Linux内核，提供完整的系统调用兼容性和更好的文件系统性能。本文档指导用户完成WSL2基础环境安装、Linux发行版安装与初始化配置。

## 系统要求

- **操作系统**：Windows 10 版本 2004+（内部版本 19041+）或 Windows 11
- **架构**：x64 或 ARM64
- **虚拟化**：BIOS/UEFI 中已启用 Intel VT-x 或 AMD-V
- **内存**：最低8GB，推荐16GB（WSL2使用Hyper-V虚拟机）
- **磁盘空间**：至少1GB用于WSL组件 + 每个发行版1-5GB
- **权限**：需要Windows管理员权限

### 系统要求检测

在安装WSL2前，先检测系统是否满足要求：

```powershell
# 检测Windows版本
[System.Environment]::OSVersion.Version
# 需要 Major=10, Build>=19041

# 检测虚拟化是否启用
Get-ComputerInfo -Property "HyperV*"
# HyperVisorPresent 应为 True

# 检测是否已安装WSL
wsl --version 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "WSL尚未安装" -ForegroundColor Yellow
}
```

## 需要安装的组件

| 组件 | 用途 | 安装方式 |
|------|------|---------|
| WSL 功能 | Windows子系统支持 | `wsl --install` 或 dism 启用 |
| 虚拟机平台 | WSL2 运行所需 | `wsl --install` 或 dism 启用 |
| WSL2 内核更新包 | Linux内核 | 自动下载或手动安装 |
| Linux 发行版 | 具体的Linux系统 | Store安装或import导入 |

## WSL2 一键安装

### 方式一：`wsl --install`（推荐，Windows 10 19044+ / Windows 11）

```powershell
# 以管理员身份运行 PowerShell

# 一键安装WSL2（自动启用功能+安装默认Ubuntu）
wsl --install

# 如仅需安装WSL2基础环境（不安装发行版）
wsl --install --no-distribution

# 安装完成后需重启电脑
```

### 方式二：分步启用（旧版本Windows或一键安装失败时）

```powershell
# 以管理员身份运行 PowerShell

# 步骤1：启用WSL功能
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

# 步骤2：启用虚拟机平台
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# 步骤3：重启电脑
Restart-Computer

# 步骤4：下载并安装WSL2内核更新包
# Windows 10 需手动下载：https://aka.ms/wsl2kernel
$wslUpdateUrl = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
$msiPath = "$env:TEMP\wsl_update_x64.msi"
Invoke-WebRequest -Uri $wslUpdateUrl -OutFile $msiPath
Start-Process msiexec.exe -ArgumentList "/i `"$msiPath`" /quiet" -Wait

# 步骤5：设置WSL2为默认版本
wsl --set-default-version 2
```

### 验证WSL2安装

```powershell
# 检查WSL版本
wsl --version

# 检查WSL状态
wsl --status

# 确认默认版本为2
wsl --status | Select-String "默认版本"
```

## 发行版安装

### Microsoft Store 发行版安装

所有Microsoft Store中可用的发行版均可通过命令行安装：

```powershell
# 查看可安装的发行版列表
wsl --list --online

# 安装指定发行版
wsl --install -d Ubuntu          # Ubuntu 最新LTS
wsl --install -d Ubuntu-22.04   # Ubuntu 22.04 LTS
wsl --install -d Ubuntu-24.04   # Ubuntu 24.04 LTS
wsl --install -d Debian         # Debian
wsl --install -d openSUSE-Leap  # openSUSE Leap
wsl --install -d SLES           # SUSE Linux Enterprise Server
wsl --install -d Kali-Linux     # Kali Linux
wsl --install -d Archlinux      # Arch Linux（预览版）

# Fedora 需单独安装（从Store搜索安装或使用以下命令）
wsl --install -d Fedora
```

### CentOS 导入安装（非Store发行版）

CentOS在Microsoft Store中没有官方版本，需要通过 `wsl --import` 导入：

```powershell
# 步骤1：创建安装目录
$installDir = "D:\WSL\CentOS7"
New-Item -ItemType Directory -Path $installDir -Force

# 步骤2：下载CentOS rootfs tar文件
# CentOS 7 社区版
$centosTarUrl = "https://github.com/CentOS/sig-cloud-instance-images/raw/CentOS-7-x86_64/docker/centos-7-docker.tar.xz"
$centosTarPath = "$env:TEMP\centos-7-docker.tar.xz"
Invoke-WebRequest -Uri $centosTarUrl -OutFile $centosTarPath

# 步骤3：导入CentOS到WSL
wsl --import CentOS7 $installDir $centosTarPath

# 步骤4：验证安装
wsl -l -v
```

### 安装后自动转换到WSL2

如果已安装的发行版运行在WSL1上，可以转换：

```powershell
# 查看所有发行版的WSL版本
wsl -l -v

# 将指定发行版转换为WSL2
wsl --set-version Ubuntu 2
```

## 发行版初始化配置

### 首次启动设置用户名密码

Store安装的发行版首次启动时会提示创建用户：

```text
Enter new UNIX username: myuser
New password: ********
Retype new password: ********
```

### 系统更新

各发行版系统更新命令：

| 发行版 | 更新命令 |
|--------|---------|
| Ubuntu/Debian/Kali | `sudo apt update && sudo apt upgrade -y` |
| CentOS | `sudo yum update -y` |
| Fedora | `sudo dnf upgrade -y` |
| Arch | `sudo pacman -Syu --noconfirm` |
| openSUSE/SLES | `sudo zypper refresh && sudo zypper update -y` |

### 国内镜像源配置

#### Ubuntu/Debian（清华镜像）
```bash
# 备份原始源
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak

# Ubuntu 替换为清华源
sudo sed -i 's@//.*archive.ubuntu.com@//mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list
sudo sed -i 's@//.*security.ubuntu.com@//mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list

# Debian 替换为清华源
sudo sed -i 's@//.*deb.debian.org@//mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list
sudo sed -i 's@//.*security.debian.org@//mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list

# Kali 替换为清华源
sudo sed -i 's@//.*http.kali.org@//mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list

# 更新索引
sudo apt update
```

#### CentOS（华为镜像）
```bash
# 备份原始源
sudo cp -a /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak

# 替换为华为源（CentOS 7）
sudo sed -i 's@//.*mirror.centos.org@//repo.huaweicloud.com@g' /etc/yum.repos.d/CentOS-Base.repo

# 更新索引
sudo yum makecache
```

#### Fedora（华为镜像）
```bash
sudo cp -a /etc/yum.repos.d/fedora.repo /etc/yum.repos.d/fedora.repo.bak
sudo sed -i 's@//.*fedora mirrors@//repo.huaweicloud.com@g' /etc/yum.repos.d/fedora.repo
sudo dnf makecache
```

#### Arch（中科大镜像）
```bash
sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
echo 'Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch' | sudo tee /etc/pacman.d/mirrorlist > /dev/null
sudo pacman -Sy
```

#### openSUSE（清华镜像）
```bash
sudo cp -a /etc/zypp/repos.d/ /etc/zypp/repos.d.bak/
sudo sed -i 's@//.*download.opensuse.org@//mirrors.tuna.tsinghua.edu.cn/opensuse@g' /etc/zypp/repos.d/*.repo
sudo zypper refresh
```

### 基础工具安装

```bash
# Ubuntu/Debian
sudo apt install -y curl wget git vim build-essential

# CentOS
sudo yum install -y curl wget git vim gcc gcc-c++ make

# Fedora
sudo dnf install -y curl wget git vim gcc gcc-c++ make

# Arch
sudo pacman -S --noconfirm curl wget git vim base-devel

# openSUSE
sudo zypper install -y curl wget git vim gcc gcc-c++ make
```

## WSL2 验证与排错

### 验证步骤

```powershell
# 1. 检查WSL版本信息
wsl --version

# 2. 检查WSL运行状态
wsl --status

# 3. 列出已安装发行版
wsl -l -v

# 4. 进入默认发行版验证
wsl -- bash -c "uname -a && cat /etc/os-release"
```

### 常见错误及解决方案

| 错误代码 | 原因 | 解决方案 |
|---------|------|---------|
| 0x80370102 | 虚拟化未启用 | 进入BIOS启用VT-x/AMD-V；检查Hyper-V是否启用 |
| 0x80070003 | 找不到文件 | 运行 `wsl --update` 更新WSL |
| 0x80370103 | 虚拟机平台未启用 | 运行 `dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart` |
| 0x8007007e | WSL组件损坏 | 运行 `wsl --update`；或卸载重装WSL |
| WSL2 requires a kernel update | 内核未更新 | 下载安装WSL2内核更新包 |
| Error: 0x80240438 | Windows Update服务问题 | 启用Windows Update服务后重试 |

### 重置WSL（最后手段）

```powershell
# 关闭所有WSL实例
wsl --shutdown

# 卸载指定发行版（数据会丢失）
wsl --unregister <distro-name>

# 重新安装
wsl --install -d <distro-name>
```

## 预计时间

- WSL2基础安装：5-10分钟（不含下载时间）
- 发行版安装：5-15分钟（取决于下载速度）
- 发行版初始化配置：5-10分钟
- 完整环境搭建：15-30分钟

## 注意事项

1. **仅支持WSL2**：本skill仅支持WSL2，不支持WSL1
2. **重启需求**：启用WSL功能和虚拟机平台后必须重启电脑
3. **磁盘空间**：WSL2发行版使用vhdx虚拟磁盘，空间会动态增长
4. **网络问题**：如安装过程中网络中断，重新运行安装命令即可
5. **管理员权限**：安装WSL功能需要管理员权限
6. **虚拟化**：确保BIOS/UEFI中虚拟化已启用
7. **CentOS导入**：CentOS需通过tar文件导入，首次进入默认为root用户

## 常见问题

### 1. 如何检查我的Windows版本是否支持WSL2？

```powershell
# 检查版本号
winver
# 需要 Windows 10 19041+ 或 Windows 11
```

### 2. 如何处理安装过程中需要重启？

安装WSL功能后会提示重启。重启后再次运行安装命令继续安装。

### 3. 如何为CentOS创建非root用户？

```bash
# 进入CentOS
wsl -d CentOS7

# 创建新用户
useradd -m -s /bin/bash myuser
passwd myuser

# 赋予sudo权限
yum install -y sudo
echo "myuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/myuser

# 设置为默认用户（退出WSL后在Windows端执行）
# 在Windows PowerShell中执行：
centos7.exe config --default-user myuser
```

### 4. 如何查看和更改默认发行版？

```powershell
# 查看当前默认发行版
wsl --list --verbose

# 设置默认发行版
wsl --set-default Ubuntu
```

## 相关资源

- [WSL官方文档](https://learn.microsoft.com/zh-cn/windows/wsl/)
- [WSL2内核更新包](https://aka.ms/wsl2kernel)
- [WSL GitHub](https://github.com/microsoft/WSL)
- 互操作配置 → [references/wsl-interop.md](wsl-interop.md)
- 开发环境配置 → [references/wsl-dev-env.md](wsl-dev-env.md)
- 高级功能 → [references/wsl-advanced.md](wsl-advanced.md)
- 实例管理 → [references/wsl-management.md](wsl-management.md)
