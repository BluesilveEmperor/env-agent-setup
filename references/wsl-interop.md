# WSL 与 Windows 互操作配置指南

## 环境概述

WSL2提供了一套完整的与Windows宿主机的互操作机制，包括文件互访、程序互调、端口转发和环境变量共享。本文档详细介绍如何配置和验证这些互操作功能。

## /etc/wsl.conf 配置说明

`/etc/wsl.conf` 是WSL实例内的配置文件，控制WSL发行版的行为。每次WSL启动时读取。

### 完整配置模板

```text
[boot]
systemd=true                          # 是否启用systemd（需要WSL2 0.67.6+）

[interop]
enabled=true                          # 启用互操作（WSL调用Windows程序）
appendWindowsPath=true                # Windows PATH追加到WSL PATH

[automount]
enabled=true                          # 自动挂载Windows磁盘
mountFsTab=true                       # 使用/etc/fstab配置
root=/mnt/                            # 挂载根目录
options="metadata,umask=22,fmask=11"  # 挂载选项（启用权限支持）

[network]
generateResolvConf=true               # 自动生成DNS配置
generateHosts=true                    # 自动生成/etc/hosts
```

### 配置项详细说明

#### [interop] 互操作配置

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| enabled | true | 是否允许WSL启动Windows程序。设为false则无法在WSL中运行notepad.exe等 |
| appendWindowsPath | true | 是否将Windows PATH追加到WSL的$PATH。设为false则WSL无法直接找到Windows程序 |

#### [automount] 自动挂载配置

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| enabled | true | 是否自动挂载Windows磁盘到/mnt/ |
| root | /mnt/ | Windows磁盘的挂载根目录 |
| options | "metadata,umask=22,fmask=11" | 挂载选项。metadata启用Linux权限支持 |

#### [boot] 启动配置

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| systemd | false | 是否启用systemd。启用后服务可自启动 |
| command | "" | WSL启动时自动执行的命令 |

#### [network] 网络配置

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| generateResolvConf | true | 是否自动生成/etc/resolv.conf |
| generateHosts | true | 是否自动生成/etc/hosts |

### 应用配置

修改 `/etc/wsl.conf` 后需要重启WSL实例才能生效：

```powershell
# 在Windows PowerShell中执行
wsl --shutdown
# 然后重新启动WSL
wsl -d <distro>
```

## 文件互访

### 从Windows访问WSL文件

#### 通过文件资源管理器访问

```text
路径格式：\\wsl$\<distro-name>\
示例：\\wsl$\Ubuntu\home\myuser\projects
```

#### 在WSL中使用explorer.exe

```bash
# 在当前WSL目录打开Windows资源管理器
explorer.exe .

# 打开指定目录
explorer.exe /home/myuser/projects
```

#### 通过PowerShell访问

```powershell
# 使用wslpath转换路径
wsl -d Ubuntu -- wslpath -w /home/myuser/projects
# 输出: \\wsl$\Ubuntu\home\myuser\projects

# 直接访问
Get-ChildItem "\\wsl$\Ubuntu\home\myuser"
```

#### 网络驱动器映射

```powershell
# 将WSL文件系统映射为网络驱动器
net use W: \\wsl$\Ubuntu
# 之后可通过 W: 盘访问
```

### 从WSL访问Windows文件

#### 通过/mnt/挂载点访问

```bash
# Windows C盘
ls /mnt/c/

# 访问用户目录
ls /mnt/c/Users/<username>/

# 访问Program Files
ls /mnt/c/Program\ Files/
```

#### 文件权限问题

WSL2默认使用metadata挂载选项支持Linux权限，如遇权限问题：

```bash
# 检查挂载选项
mount | grep drvfs

# 如果没有metadata选项，在/etc/wsl.conf中添加
[automount]
options = "metadata,umask=22,fmask=11"
```

#### 性能建议

- **在WSL内操作WSL文件性能最佳**：使用 `/home/` 目录而非 `/mnt/c/`
- **跨文件系统操作较慢**：在 `/mnt/c/` 上执行git、npm等操作比WSL本地文件系统慢5-10倍
- **推荐做法**：项目代码放在WSL内（`/home/myuser/projects/`），通过 `explorer.exe .` 在Windows中编辑

## 程序互调

### WSL调用Windows程序

WSL可以直接调用Windows的.exe程序：

```bash
# 打开记事本
notepad.exe /home/myuser/file.txt

# 打开资源管理器
explorer.exe .

# 使用VS Code打开项目
code.cmd /home/myuser/projects/myapp

# 调用PowerShell
powershell.exe -Command "Get-Process"

# 调用Windows的ping
ping.exe google.com

# 调用Windows的ipconfig
ipconfig.exe
```

### Windows调用WSL命令

从Windows PowerShell/CMD中通过 `wsl` 命令执行WSL内命令：

```powershell
# 执行单条命令
wsl -d Ubuntu -- ls -la /home

# 执行带sudo的命令
wsl -d Ubuntu -- sudo apt update

# 使用管道连接Windows和WSL命令
dir | wsl -d Ubuntu -- grep ".txt"

# 将WSL输出保存到Windows文件
wsl -d Ubuntu -- cat /etc/os-release > os_info.txt

# 在WSL中处理Windows文件
wsl -d Ubuntu -- grep "pattern" /mnt/c/data/file.txt
```

### PATH共享机制

当 `[interop] appendWindowsPath=true`（默认）时：

```bash
# 在WSL中查看PATH，会包含Windows路径
echo $PATH | tr ':' '\n' | grep mnt

# Windows程序可通过名称直接调用
which notepad.exe
# 输出: /mnt/c/WINDOWS/system32/notepad.exe

# 如果不需要Windows PATH（减少PATH长度）
# 在 /etc/wsl.conf 中设置
[interop]
appendWindowsPath = false
```

## 网络与端口转发

### localhost转发机制

WSL2支持从Windows直接访问WSL内运行的服务（Windows 10 1903+ / Windows 11默认启用）：

```bash
# 在WSL中启动服务
python3 -m http.server 8000

# 从Windows浏览器访问
# 直接访问 http://localhost:8000 即可
```

### WSL2 IP地址获取

```bash
# 获取WSL2实例IP
ip addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'

# 或使用hostname
hostname -I | awk '{print $1}'
```

```powershell
# 从Windows端获取WSL IP
wsl -d Ubuntu -- hostname -I
```

### 端口转发配置

#### 自动转发（默认行为）

WSL2的localhost转发默认启用，无需额外配置。WSL内监听的端口自动映射到Windows的localhost。

#### .wslconfig中的localhostForwarding配置

```text
# %USERPROFILE%\.wslconfig
[wsl2]
localhostForwarding=true    # 默认true，启用localhost转发
```

#### 手动端口转发（特殊需求）

```powershell
# 将Windows端口转发到WSL（WSL IP为172.x.x.x）
$wslIP = (wsl -d Ubuntu -- hostname -I).Trim()
netsh interface portproxy add v4tov4 listenport=8080 listenaddress=0.0.0.0 connectport=8080 connectaddress=$wslIP

# 查看转发规则
netsh interface portproxy show v4tov4

# 删除转发规则
netsh interface portproxy delete v4tov4 listenport=8080 listenaddress=0.0.0.0
```

### 防火墙配置

如需从其他机器访问WSL服务：

```powershell
# 添加防火墙规则
New-NetFirewallRule -DisplayName "WSL" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8080
```

## .wslconfig 资源控制

`%USERPROFILE%\.wslconfig` 是Windows端的WSL全局配置文件，控制所有WSL2实例的资源使用。

### 完整配置模板

```text
[wsl2]
memory=8GB                    # WSL2最大内存（建议为物理内存的50%）
processors=4                  # 处理器数量（建议为物理核心的50%）
swap=2GB                      # 交换空间大小
localhostForwarding=true       # localhost端口转发
nestedVirtualization=true      # 嵌套虚拟化（Docker需要）

[experimental]
autoMemoryReclaim=gradual     # 自动内存回收（Windows 11 22H2+）
sparseVhd=true                # 磁盘空间自动回收
```

### 配置项说明

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| memory | 物理内存50% | WSL2虚拟机最大内存 |
| processors | 物理核心数 | WSL2可用的处理器数量 |
| swap | 物理内存25% | 交换空间大小 |
| localhostForwarding | true | 是否启用localhost转发 |
| nestedVirtualization | true | 是否启用嵌套虚拟化 |
| autoMemoryReclaim | disabled | 自动内存回收（gradual/dropcache） |
| sparseVhd | false | 磁盘空间自动回收 |

### 自动推荐配置

根据系统物理内存自动推荐合理的配置：

```powershell
# 获取系统内存（GB）
$totalMemoryGB = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)

# 推荐配置
$wslMemory = [math]::Round($totalMemoryGB * 0.5)  # 50%物理内存
$wslSwap = [math]::Round($totalMemoryGB * 0.25)   # 25%物理内存
$wslProcessors = [math]::Round((Get-CimInstance Win32_Processor).NumberOfLogicalProcessors / 2)

# 生成.wslconfig
$wslConfig = @"
[wsl2]
memory=$($wslMemory)GB
processors=$wslProcessors
swap=$($wslSwap)GB
localhostForwarding=true

[experimental]
autoMemoryReclaim=gradual
sparseVhd=true
"@

$wslConfig | Set-Content -Path "$env:USERPROFILE\.wslconfig" -Encoding UTF8
```

### 应用配置

修改 `.wslconfig` 后需要重启所有WSL实例：

```powershell
wsl --shutdown
```

## 验证步骤

### 验证文件互访

```powershell
# 从Windows访问WSL文件
Test-Path "\\wsl$\Ubuntu\home"

# 从WSL访问Windows文件
wsl -d Ubuntu -- test -d /mnt/c/Users && echo "OK" || echo "FAIL"
```

### 验证程序互调

```bash
# 在WSL中调用Windows程序
notepad.exe --version 2>&1 || explorer.exe . 2>&1

# 检查interop状态
cat /proc/sys/fs/binfmt_misc/WSLInterop
```

### 验证端口转发

```bash
# 在WSL中启动测试服务
python3 -m http.server 8765 &

# 在Windows中测试访问
curl http://localhost:8765

# 清理
kill %1
```

## 预计时间

- /etc/wsl.conf配置：2分钟
- .wslconfig配置：2分钟
- 互操作验证：3分钟
- 完整互操作配置：5-10分钟

## 注意事项

1. **重启生效**：修改 `/etc/wsl.conf` 或 `.wslconfig` 后需运行 `wsl --shutdown` 重启WSL
2. **文件性能**：跨文件系统（/mnt/c）操作性能较差，建议项目放在WSL内
3. **metadata挂载**：确保 `[automount] options` 包含 `metadata` 以支持Linux权限
4. **localhost转发**：Windows防火墙可能阻断外部访问，需添加规则
5. **systemd支持**：WSL2 0.67.6+ 才支持systemd，旧版本无法使用

## 常见问题

### 1. Windows程序在WSL中调用失败

```bash
# 检查interop是否启用
cat /etc/wsl.conf | grep -A5 interop

# 确认appendWindowsPath
echo $PATH | tr ':' '\n' | head -20
```

### 2. /mnt/c 挂载权限异常

```bash
# 检查挂载选项
mount | grep drvfs

# 修复：在/etc/wsl.conf中添加metadata选项
[automount]
options = "metadata,umask=22,fmask=11"

# 重启WSL后生效
```

### 3. localhost端口无法访问

```powershell
# 检查.wslconfig
Get-Content "$env:USERPROFILE\.wslconfig"

# 确认localhostForwarding=true
# 重启WSL
wsl --shutdown
```

### 4. WSL占用内存过高

```powershell
# 配置.wslconfig限制内存
# 参考"自动推荐配置"章节
# 启用autoMemoryReclaim=gradual
```

## 相关资源

- WSL2基础安装 → [references/wsl-setup.md](wsl-setup.md)
- 开发环境配置 → [references/wsl-dev-env.md](wsl-dev-env.md)
- 高级功能 → [references/wsl-advanced.md](wsl-advanced.md)
- 实例管理 → [references/wsl-management.md](wsl-management.md)
