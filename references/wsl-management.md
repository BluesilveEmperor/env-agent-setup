# WSL 实例管理与维护指南

## 环境概述

本文档介绍WSL实例的管理与维护操作，包括发行版列表查看、默认发行版设置、启动/停止控制、备份导出与导入恢复、卸载清理等。掌握这些操作有助于高效管理多个WSL实例和保障数据安全。

## 发行版列表查看

### 查看所有已安装发行版

```powershell
# 列出已安装发行版及其状态
wsl -l -v

# 输出示例：
#   NAME            STATE           VERSION
# * Ubuntu          Running         2
#   Debian          Stopped         2
#   CentOS7         Stopped         2
```

> **注意**：`*` 标记表示当前默认发行版。

### 列出可安装的发行版

```powershell
# 列出Microsoft Store中可用的发行版
wsl --list --online

# 或使用简写
wsl -l -o
```

### 查看WSL全局状态

```powershell
# 查看WSL整体状态
wsl --status

# 输出包括：
# - 默认发行版
# - 默认WSL版本
# - 内核版本
# - Windows版本
```

### 获取特定发行版信息

```powershell
# 查看发行版详细信息
wsl -d Ubuntu -- bash -c "cat /etc/os-release"

# 查看发行版磁盘使用（vhdx文件大小）
Get-ChildItem "$env:LOCALAPPDATA\Packages" -Recurse -Filter "ext4.vhdx" | Select-Object FullName, @{Name="SizeMB";Expression={[math]::Round($_.Length/1MB,2)}}

# 查看导入发行版的磁盘位置
# 导入发行版的vhdx在导入时指定的目录中
```

## 默认发行版管理

### 设置默认发行版

```powershell
# 设置默认发行版（新终端窗口启动的发行版）
wsl --set-default Ubuntu

# 验证
wsl -l -v
# 默认发行版行首会显示 *
```

### 设置默认WSL版本

```powershell
# 设置新安装发行版默认使用WSL2
wsl --set-default-version 2

# 查看当前默认版本
wsl --status | Select-String "默认版本"
```

## 启停控制

### 关闭所有WSL实例

```powershell
# 终止所有运行中的WSL实例
wsl --shutdown

# 这会：
# - 停止所有运行中的发行版
# - 释放WSL2虚拟机资源
# - 下次启动时需要重新启动
```

### 终止特定发行版

```powershell
# 终止指定发行版
wsl -t Ubuntu
wsl --terminate Debian

# 验证已停止
wsl -l -v
```

### 启动特定发行版

```powershell
# 启动默认发行版
wsl

# 启动指定发行版
wsl -d Ubuntu

# 启动并执行命令
wsl -d Ubuntu -- bash -c "echo 'Hello from Ubuntu'"

# 以指定用户启动
wsl -d Ubuntu -u root

# 启动到指定目录
wsl -d Ubuntu --cd /home/myuser/projects
```

### WSL自动休眠

WSL2在空闲一段时间后会自动释放内存但不会完全关闭：

```text
# 在 %USERPROFILE%\.wslconfig 中配置
[experimental]
autoMemoryReclaim=gradual    # 自动回收未使用的内存
```

## 备份与恢复

### 导出发行版

```powershell
# 导出为tar文件
wsl --export Ubuntu D:\Backup\ubuntu-backup.tar

# 导出指定发行版
wsl --export Debian D:\Backup\debian-backup.tar

# 导出过程可能较慢（取决于发行版大小）
# 典型Ubuntu约1-3GB
```

### 导入恢复发行版

```powershell
# 导入tar文件为新发行版
# 格式：wsl --import <名称> <安装位置> <tar文件>
wsl --import Ubuntu-Restored D:\WSL\Ubuntu D:\Backup\ubuntu-backup.tar

# 导入后验证
wsl -l -v

# 注意：导入的发行版默认用户为root
# 需要手动配置默认用户
```

### 迁移发行版到其他磁盘

```powershell
# 步骤1：导出当前发行版
wsl --export Ubuntu D:\Backup\ubuntu-migration.tar

# 步骤2：注销原发行版
wsl --unregister Ubuntu

# 步骤3：导入到新位置
wsl --import Ubuntu D:\WSL\Ubuntu D:\Backup\ubuntu-migration.tar

# 步骤4：验证
wsl -l -v

# 步骤5：设置默认用户
# 在/etc/wsl.conf中添加
wsl -d Ubuntu -- bash -c "cat > /etc/wsl.conf << 'EOF'
[user]
default=myuser
EOF"

# 步骤6：重启WSL使配置生效
wsl --shutdown

# 清理临时备份文件
Remove-Item D:\Backup\ubuntu-migration.tar
```

### 定期备份脚本

```powershell
# 保存为 backup-wsl.ps1
param(
    [Parameter(Mandatory=$true)]
    [string]$Distro,
    [string]$BackupDir = "D:\WSL-Backup"
)

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupFile = Join-Path $BackupDir "$Distro-$timestamp.tar"

# 创建备份目录
if (-not (Test-Path $BackupDir)) {
    New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
}

Write-Host "正在备份 $Distro 到 $backupFile ..." -ForegroundColor Cyan
wsl --export $Distro $backupFile

if (Test-Path $backupFile) {
    $sizeMB = [math]::Round((Get-Item $backupFile).Length / 1MB, 2)
    Write-Host "备份完成！文件大小: $sizeMB MB" -ForegroundColor Green
} else {
    Write-Host "备份失败！" -ForegroundColor Red
}
```

## 卸载与清理

### 卸载发行版

```powershell
# 卸载指定发行版（数据会丢失！）
wsl --unregister Ubuntu

# 验证已卸载
wsl -l -v
```

> **警告**：`--unregister` 会永久删除发行版及其中所有数据，请先备份！

### 卸载WSL功能

```powershell
# 禁用WSL功能
dism.exe /online /disable-feature /featurename:Microsoft-Windows-Subsystem-Linux /norestart

# 禁用虚拟机平台
dism.exe /online /disable-feature /featurename:VirtualMachinePlatform /norestart

# 重启生效
Restart-Computer
```

### 磁盘空间回收

WSL2使用vhdx虚拟磁盘，删除文件后磁盘不会自动缩小。需要手动压缩：

```powershell
# 步骤1：关闭WSL
wsl --shutdown

# 步骤2：找到vhdx文件
# Store安装的发行版
$vhdxPath = Get-ChildItem "$env:LOCALAPPDATA\Packages" -Recurse -Filter "ext4.vhdx" | Select-Object -ExpandProperty FullName

# 导入的发行版
# vhdx在导入时指定的安装目录中

# 步骤3：压缩vhdx（需要diskpart管理员权限）
# 打开管理员CMD
diskpart
# 在diskpart中执行：
# select vdisk file="<vhdx完整路径>"
# compact vdisk
# detach vdisk
# exit
```

### 使用sparseVhd自动回收

Windows 11 22H2+ 支持自动磁盘空间回收：

```text
# 在 %USERPROFILE%\.wslconfig 中配置
[experimental]
sparseVhd=true
```

## 常见维护操作

### 更新WSL

```powershell
# 更新WSL到最新版本
wsl --update

# 更新到预发布版本
wsl --update --pre-release

# 查看WSL版本
wsl --version
```

### 更新发行版内的系统

```powershell
# 更新Ubuntu
wsl -d Ubuntu -- bash -c "sudo apt update && sudo apt upgrade -y"

# 更新Debian
wsl -d Debian -- bash -c "sudo apt update && sudo apt upgrade -y"

# 更新CentOS
wsl -d CentOS7 -- bash -c "sudo yum update -y"
```

### 查看WSL资源使用

```powershell
# 查看WSL进程
Get-Process -Name "vmmem" -ErrorAction SilentlyContinue | Select-Object Name, CPU, @{Name="MemoryMB";Expression={[math]::Round($_.WorkingSet64/1MB,2)}}

# 查看WSL2虚拟机信息
wsl -d Ubuntu -- bash -c "free -h && nproc"
```

### 重置发行版

```powershell
# 通过Windows设置重置（仅Store安装的发行版）
# 设置 > 应用 > 已安装的应用 > 找到发行版 > 高级选项 > 重置

# 或通过命令行重置
# 先导出备份（如需要）
wsl --export Ubuntu D:\Backup\ubuntu-reset-backup.tar
# 注销
wsl --unregister Ubuntu
# 重新安装
wsl --install -d Ubuntu
```

## 预计时间

- 列表查看：1分钟
- 设置默认发行版：1分钟
- 启停控制：1分钟
- 导出备份：5-15分钟（取决于发行版大小）
- 导入恢复：5-15分钟
- 磁盘压缩：5-10分钟
- 卸载清理：2分钟

## 注意事项

1. **备份优先**：执行 `--unregister` 前务必先 `--export` 备份
2. **导入用户问题**：通过 `--import` 恢复的发行版默认用户为root，需手动配置
3. **磁盘空间**：WSL2的vhdx文件可能比实际使用量大很多，定期压缩
4. **IP变化**：WSL2每次启动IP可能变化，影响端口转发配置
5. **数据安全**：重要项目建议同时使用git远程仓库备份

## 常见问题

### 1. 如何找回已卸载的发行版？

如果未备份就执行了 `--unregister`，数据无法恢复。只能重新安装。

### 2. 如何减小WSL磁盘占用？

```powershell
# 1. 清理发行版内的包缓存
wsl -d Ubuntu -- bash -c "sudo apt clean && sudo apt autoremove -y"

# 2. 压缩vhdx（参考"磁盘空间回收"章节）

# 3. 启用sparseVhd自动回收
```

### 3. 如何将发行版从C盘迁移到D盘？

参考"迁移发行版到其他磁盘"章节，使用 `--export` + `--unregister` + `--import` 三步操作。

### 4. WSL启动很慢怎么办？

```powershell
# 检查是否有过多的Windows PATH
wsl -d Ubuntu -- bash -c "echo $PATH | tr ':' '\n' | wc -l"

# 如果PATH过长，可禁用appendWindowsPath
# 在/etc/wsl.conf中设置
[interop]
appendWindowsPath = false
```

## 相关资源

- WSL2基础安装 → [references/wsl-setup.md](wsl-setup.md)
- 开发环境配置 → [references/wsl-dev-env.md](wsl-dev-env.md)
- 互操作配置 → [references/wsl-interop.md](wsl-interop.md)
- 高级功能 → [references/wsl-advanced.md](wsl-advanced.md)
