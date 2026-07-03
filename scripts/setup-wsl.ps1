<#
.SYNOPSIS
    WSL2 一键安装与配置脚本
.DESCRIPTION
    安装WSL2基础环境、安装Linux发行版、初始化发行版配置、配置WSL与Windows互操作
.PARAMETER Action
    要执行的操作：install, install-distro, init-distro, configure-interop, status
.PARAMETER Distro
    目标发行版名称（如 Ubuntu、Debian、CentOS7）
.PARAMETER InstallLocation
    发行版安装位置（仅import方式安装时使用）
.PARAMETER NoMirror
    跳过国内镜像源配置
.EXAMPLE
    .\setup-wsl.ps1 -Action install
    .\setup-wsl.ps1 -Action install-distro -Distro Ubuntu
    .\setup-wsl.ps1 -Action init-distro -Distro Ubuntu
    .\setup-wsl.ps1 -Action configure-interop -Distro Ubuntu
    .\setup-wsl.ps1 -Action status
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("install", "install-distro", "init-distro", "configure-interop", "status")]
    [string]$Action,

    [Parameter(Mandatory=$false)]
    [string]$Distro = "",

    [Parameter(Mandatory=$false)]
    [string]$InstallLocation = "",

    [switch]$NoMirror
)

$ErrorActionPreference = "Stop"

# ============================================================
# 发行版配置映射
# ============================================================

$DistroConfigs = @{
    "Ubuntu"        = @{ StoreName = "Ubuntu";         PackageManager = "apt";    InstallMethod = "store" }
    "Ubuntu-20.04"  = @{ StoreName = "Ubuntu-20.04";   PackageManager = "apt";    InstallMethod = "store" }
    "Ubuntu-22.04"  = @{ StoreName = "Ubuntu-22.04";   PackageManager = "apt";    InstallMethod = "store" }
    "Ubuntu-24.04"  = @{ StoreName = "Ubuntu-24.04";   PackageManager = "apt";    InstallMethod = "store" }
    "Debian"        = @{ StoreName = "Debian";          PackageManager = "apt";    InstallMethod = "store" }
    "Kali-Linux"    = @{ StoreName = "Kali-Linux";      PackageManager = "apt";    InstallMethod = "store" }
    "openSUSE-Leap" = @{ StoreName = "openSUSE-Leap-15.6"; PackageManager = "zypper"; InstallMethod = "store" }
    "SLES"          = @{ StoreName = "SLES-15-SP5";     PackageManager = "zypper"; InstallMethod = "store" }
    "Archlinux"     = @{ StoreName = "Archlinux";       PackageManager = "pacman"; InstallMethod = "store" }
    "Fedora"        = @{ StoreName = "Fedora-42";       PackageManager = "dnf";    InstallMethod = "store" }
    "CentOS7"       = @{ StoreName = "CentOS7";         PackageManager = "yum";    InstallMethod = "import"; ImportSource = "https://github.com/CentOS/sig-cloud-instance-images/raw/CentOS-7-x86_64/docker/centos-7-docker.tar.xz" }
    "CentOS-7"      = @{ StoreName = "CentOS-7";        PackageManager = "yum";    InstallMethod = "import"; ImportSource = "https://github.com/CentOS/sig-cloud-instance-images/raw/CentOS-7-x86_64/docker/centos-7-docker.tar.xz" }
}

# ============================================================
# 辅助函数
# ============================================================

function Write-Step {
    param([string]$Message)
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "  $Message" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
}

function Write-Ok {
    param([string]$Message)
    Write-Host "  [OK] $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "  [WARN] $Message" -ForegroundColor Yellow
}

function Write-Err {
    param([string]$Message)
    Write-Host "  [ERROR] $Message" -ForegroundColor Red
}

function Test-WSLInstalled {
    try {
        $null = wsl --version 2>&1
        return $true
    } catch {
        return $false
    }
}

function Test-DistroInstalled {
    param([string]$Name)
    try {
        $list = wsl -l -v 2>&1
        # wsl输出可能使用Unicode，需要转换
        $listBytes = [System.Text.Encoding]::Unicode.GetBytes($list)
        $listStr = [System.Text.Encoding]::UTF8.GetString($listBytes)
        if ($listStr -match [regex]::Escape($Name) -or $list -match [regex]::Escape($Name)) {
            return $true
        }
        # 备用检测方法
        $distros = wsl -l 2>&1 | ForEach-Object { $_ -replace "`0", "" } | Where-Object { $_.Trim() -ne "" }
        foreach ($d in $distros) {
            if ($d -match [regex]::Escape($Name)) {
                return $true
            }
        }
        return $false
    } catch {
        return $false
    }
}

function Get-DistroPackageManager {
    param([string]$Name)
    if ($DistroConfigs.ContainsKey($Name)) {
        return $DistroConfigs[$Name].PackageManager
    }
    # 根据名称推断
    if ($Name -match "Ubuntu|Debian|Kali") { return "apt" }
    if ($Name -match "CentOS") { return "yum" }
    if ($Name -match "Fedora") { return "dnf" }
    if ($Name -match "Arch") { return "pacman" }
    if ($Name -match "openSUSE|SLES|SUSE") { return "zypper" }
    return "apt"  # 默认
}

function Invoke-WSLCommand {
    param(
        [string]$DistroName,
        [string]$Command
    )
    $result = wsl -d $DistroName -- bash -c $Command 2>&1
    return $result
}

# ============================================================
# Action: install - 安装WSL2基础环境
# ============================================================

function Install-WSL2 {
    Write-Step "安装WSL2基础环境"

    # 检查管理员权限
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Err "需要管理员权限运行此操作。请以管理员身份运行PowerShell。"
        return
    }

    # 检查Windows版本
    $osVersion = [System.Environment]::OSVersion.Version
    Write-Host "  Windows版本: $($osVersion.Major).$($osVersion.Minor).$($osVersion.Build)"

    if ($osVersion.Major -lt 10 -or ($osVersion.Major -eq 10 -and $osVersion.Build -lt 19041)) {
        Write-Err "Windows版本不满足WSL2要求（需要Windows 10 19041+或Windows 11）。"
        Write-Host "  当前版本: $($osVersion.Major).$($osVersion.Minor).$($osVersion.Build)"
        return
    }
    Write-Ok "Windows版本满足要求"

    # 检查虚拟化支持
    try {
        $hyperV = Get-ComputerInfo -Property "HyperVisorPresent" -ErrorAction SilentlyContinue
        if ($hyperV.HyperVisorPresent -eq $true) {
            Write-Ok "虚拟化已启用"
        } else {
            Write-Warn "无法确认虚拟化是否启用。如果后续安装失败，请检查BIOS中VT-x/AMD-V是否开启。"
        }
    } catch {
        Write-Warn "无法检测虚拟化状态，继续安装..."
    }

    # 检查是否已安装WSL
    if (Test-WSLInstalled) {
        Write-Warn "WSL已安装。检查版本信息："
        wsl --version
        return
    }

    # 尝试一键安装
    Write-Host "  正在安装WSL2（这可能需要几分钟）..."
    try {
        wsl --install --no-distribution 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Ok "WSL2安装命令执行成功"
            Write-Warn "可能需要重启电脑。重启后WSL2即可使用。"
        } else {
            Write-Warn "一键安装未成功，尝试分步启用..."
            Install-WSL2StepByStep
        }
    } catch {
        Write-Warn "一键安装失败，尝试分步启用..."
        Install-WSL2StepByStep
    }
}

function Install-WSL2StepByStep {
    Write-Host "  分步启用WSL2功能..."

    # 启用WSL功能
    Write-Host "  启用WSL功能..."
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart 2>&1 | Out-Null

    # 启用虚拟机平台
    Write-Host "  启用虚拟机平台..."
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart 2>&1 | Out-Null

    # 下载并安装WSL2内核更新包
    Write-Host "  下载WSL2内核更新包..."
    $wslUpdateUrl = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
    $msiPath = "$env:TEMP\wsl_update_x64.msi"
    try {
        Invoke-WebRequest -Uri $wslUpdateUrl -OutFile $msiPath -ErrorAction Stop
        Write-Host "  安装WSL2内核更新包..."
        Start-Process msiexec.exe -ArgumentList "/i `"$msiPath`" /quiet" -Wait
        Write-Ok "WSL2内核更新包安装完成"
    } catch {
        Write-Err "下载WSL2内核更新包失败: $_"
        Write-Host "  请手动下载: https://aka.ms/wsl2kernel"
        return
    }

    # 设置默认版本为WSL2
    Write-Host "  设置WSL默认版本为2..."
    wsl --set-default-version 2 2>&1 | Out-Null

    Write-Warn "WSL2基础环境安装完成。需要重启电脑后生效。"
}

# ============================================================
# Action: install-distro - 安装Linux发行版
# ============================================================

function Install-Distro {
    param([string]$DistroName)

    Write-Step "安装Linux发行版: $DistroName"

    if ([string]::IsNullOrWhiteSpace($DistroName)) {
        Write-Err "请指定发行版名称（-Distro 参数）。可用发行版："
        Write-Host "  Ubuntu, Ubuntu-22.04, Ubuntu-24.04, Debian, Kali-Linux,"
        Write-Host "  openSUSE-Leap, SLES, Archlinux, Fedora, CentOS7"
        return
    }

    # 检查WSL是否已安装
    if (-not (Test-WSLInstalled)) {
        Write-Err "WSL尚未安装。请先执行: .\setup-wsl.ps1 -Action install"
        return
    }

    # 检查发行版是否已安装
    if (Test-DistroInstalled $DistroName) {
        Write-Warn "发行版 '$DistroName' 已安装。如需重新初始化，请执行: .\setup-wsl.ps1 -Action init-distro -Distro $DistroName"
        return
    }

    $config = $null
    if ($DistroConfigs.ContainsKey($DistroName)) {
        $config = $DistroConfigs[$DistroName]
    } else {
        # 未知发行版，默认使用store安装
        Write-Warn "未知的发行版配置 '$DistroName'，尝试从Store安装..."
    }

    if ($null -ne $config -and $config.InstallMethod -eq "import") {
        # 通过import方式安装（如CentOS）
        Install-DistroByImport -DistroName $DistroName -Config $config
    } else {
        # 通过Store方式安装
        Install-DistroByStore -DistroName $DistroName
    }

    # 安装后自动初始化
    if (Test-DistroInstalled $DistroName) {
        Write-Ok "发行版 '$DistroName' 安装成功"
        Write-Host "  正在执行初始化配置..."
        Initialize-Distro -DistroName $DistroName
    }
}

function Install-DistroByStore {
    param([string]$DistroName)

    Write-Host "  通过Microsoft Store安装 '$DistroName'..."
    Write-Host "  这可能需要几分钟（下载取决于网络速度）..."

    try {
        wsl --install -d $DistroName 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Ok "Store安装命令执行成功"
        } else {
            Write-Warn "Store安装可能未完全成功，请检查输出信息"
        }
    } catch {
        Write-Err "Store安装失败: $_"
        Write-Host "  请尝试手动安装: wsl --install -d $DistroName"
    }
}

function Install-DistroByImport {
    param(
        [string]$DistroName,
        $Config
    )

    Write-Host "  通过import方式安装 '$DistroName'..."

    # 确定安装位置
    $installDir = $InstallLocation
    if ([string]::IsNullOrWhiteSpace($installDir)) {
        $installDir = "D:\WSL\$DistroName"
    }

    # 创建安装目录
    if (-not (Test-Path $installDir)) {
        New-Item -ItemType Directory -Path $installDir -Force | Out-Null
        Write-Ok "创建安装目录: $installDir"
    }

    # 下载tar文件
    $importSource = $Config.ImportSource
    if ([string]::IsNullOrWhiteSpace($importSource)) {
        Write-Err "未配置import源地址，无法导入安装"
        return
    }

    $tarFileName = Split-Path $importSource -Leaf
    $tarPath = Join-Path $env:TEMP $tarFileName

    Write-Host "  下载rootfs: $importSource"
    try {
        Invoke-WebRequest -Uri $importSource -OutFile $tarPath -ErrorAction Stop
        Write-Ok "下载完成: $tarPath"
    } catch {
        Write-Err "下载失败: $_"
        Write-Host "  请手动下载后执行: wsl --import $DistroName $installDir <tar文件路径>"
        return
    }

    # 导入到WSL
    Write-Host "  导入到WSL..."
    try {
        wsl --import $DistroName $installDir $tarPath 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Ok "导入成功"
        } else {
            Write-Err "导入失败"
            return
        }
    } catch {
        Write-Err "导入异常: $_"
        return
    }

    # 清理临时文件
    Remove-Item $tarPath -Force -ErrorAction SilentlyContinue
}

# ============================================================
# Action: init-distro - 初始化发行版配置
# ============================================================

function Initialize-Distro {
    param([string]$DistroName)

    Write-Step "初始化发行版: $DistroName"

    if ([string]::IsNullOrWhiteSpace($DistroName)) {
        Write-Err "请指定发行版名称（-Distro 参数）"
        return
    }

    if (-not (Test-DistroInstalled $DistroName)) {
        Write-Err "发行版 '$DistroName' 未安装。请先执行: .\setup-wsl.ps1 -Action install-distro -Distro $DistroName"
        return
    }

    $pkgManager = Get-DistroPackageManager $DistroName
    Write-Host "  检测到包管理器: $pkgManager"

    # 确保发行版正在运行
    Write-Host "  启动发行版..."
    $null = wsl -d $DistroName -- echo "WSL $DistroName started" 2>&1

    # 配置国内镜像源（除非指定 -NoMirror）
    if (-not $NoMirror) {
        Write-Host "  配置国内镜像源..."
        Configure-Mirror -DistroName $DistroName -PackageManager $pkgManager
    } else {
        Write-Warn "跳过镜像源配置（-NoMirror）"
    }

    # 更新系统
    Write-Host "  更新系统包..."
    Update-System -DistroName $DistroName -PackageManager $pkgManager

    # 安装基础工具
    Write-Host "  安装基础工具..."
    Install-BasicTools -DistroName $DistroName -PackageManager $pkgManager

    Write-Ok "发行版 '$DistroName' 初始化配置完成"
}

function Configure-Mirror {
    param(
        [string]$DistroName,
        [string]$PackageManager
    )

    switch ($PackageManager) {
        "apt" {
            # 检测是Ubuntu还是Debian还是Kali
            $osInfo = Invoke-WSLCommand $DistroName "cat /etc/os-release 2>/dev/null | grep -E '^ID=' | head -1"
            if ($osInfo -match "ubuntu") {
                Write-Host "    配置Ubuntu清华镜像源..."
                Invoke-WSLCommand $DistroName "sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak 2>/dev/null; sudo sed -i 's@//.*archive.ubuntu.com@//mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list; sudo sed -i 's@//.*security.ubuntu.com@//mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list"
            } elseif ($osInfo -match "debian") {
                Write-Host "    配置Debian清华镜像源..."
                Invoke-WSLCommand $DistroName "sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak 2>/dev/null; sudo sed -i 's@//.*deb.debian.org@//mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list; sudo sed -i 's@//.*security.debian.org@//mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list"
            } elseif ($osInfo -match "kali") {
                Write-Host "    配置Kali清华镜像源..."
                Invoke-WSLCommand $DistroName "sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak 2>/dev/null; sudo sed -i 's@//.*http.kali.org@//mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list"
            } else {
                Write-Host "    配置apt清华镜像源（通用）..."
                Invoke-WSLCommand $DistroName "sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak 2>/dev/null; sudo sed -i 's@//.*archive.ubuntu.com@//mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list"
            }
        }
        "yum" {
            Write-Host "    配置CentOS华为镜像源..."
            Invoke-WSLCommand $DistroName "sudo cp -a /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak 2>/dev/null; sudo sed -i 's@//.*mirror.centos.org@//repo.huaweicloud.com@g' /etc/yum.repos.d/CentOS-Base.repo 2>/dev/null"
        }
        "dnf" {
            Write-Host "    配置Fedora华为镜像源..."
            Invoke-WSLCommand $DistroName "sudo cp -a /etc/yum.repos.d/fedora.repo /etc/yum.repos.d/fedora.repo.bak 2>/dev/null; sudo sed -i 's@//.*fedora mirrors@//repo.huaweicloud.com@g' /etc/yum.repos.d/fedora.repo 2>/dev/null"
        }
        "pacman" {
            Write-Host "    配置Arch中科大镜像源..."
            Invoke-WSLCommand $DistroName "sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak 2>/dev/null; echo 'Server = https://mirrors.ustc.edu.cn/archlinux/`$repo/os/`$arch' | sudo tee /etc/pacman.d/mirrorlist > /dev/null"
        }
        "zypper" {
            Write-Host "    配置openSUSE清华镜像源..."
            Invoke-WSLCommand $DistroName "sudo cp -a /etc/zypp/repos.d/ /etc/zypp/repos.d.bak/ 2>/dev/null; sudo sed -i 's@//.*download.opensuse.org@//mirrors.tuna.tsinghua.edu.cn/opensuse@g' /etc/zypp/repos.d/*.repo 2>/dev/null"
        }
        default {
            Write-Warn "未知的包管理器 '$PackageManager'，跳过镜像源配置"
        }
    }
}

function Update-System {
    param(
        [string]$DistroName,
        [string]$PackageManager
    )

    switch ($PackageManager) {
        "apt"    { Invoke-WSLCommand $DistroName "sudo apt update && sudo apt upgrade -y" }
        "yum"    { Invoke-WSLCommand $DistroName "sudo yum makecache && sudo yum update -y" }
        "dnf"    { Invoke-WSLCommand $DistroName "sudo dnf makecache && sudo dnf upgrade -y" }
        "pacman" { Invoke-WSLCommand $DistroName "sudo pacman -Syu --noconfirm" }
        "zypper" { Invoke-WSLCommand $DistroName "sudo zypper refresh && sudo zypper update -y" }
        default  { Write-Warn "未知包管理器: $PackageManager" }
    }
}

function Install-BasicTools {
    param(
        [string]$DistroName,
        [string]$PackageManager
    )

    switch ($PackageManager) {
        "apt"    { Invoke-WSLCommand $DistroName "sudo apt install -y curl wget git vim" }
        "yum"    { Invoke-WSLCommand $DistroName "sudo yum install -y curl wget git vim" }
        "dnf"    { Invoke-WSLCommand $DistroName "sudo dnf install -y curl wget git vim" }
        "pacman" { Invoke-WSLCommand $DistroName "sudo pacman -S --noconfirm curl wget git vim" }
        "zypper" { Invoke-WSLCommand $DistroName "sudo zypper install -y curl wget git vim" }
        default  { Write-Warn "未知包管理器: $PackageManager" }
    }
}

# ============================================================
# Action: configure-interop - 配置WSL与Windows互操作
# ============================================================

function Configure-Interop {
    param([string]$DistroName)

    Write-Step "配置WSL与Windows互操作: $DistroName"

    if ([string]::IsNullOrWhiteSpace($DistroName)) {
        Write-Err "请指定发行版名称（-Distro 参数）"
        return
    }

    if (-not (Test-DistroInstalled $DistroName)) {
        Write-Err "发行版 '$DistroName' 未安装"
        return
    }

    # 生成 /etc/wsl.conf 配置
    Write-Host "  生成 /etc/wsl.conf 配置..."
    $wslConfContent = @"
[boot]
systemd=true

[interop]
enabled=true
appendWindowsPath=true

[automount]
enabled=true
mountFsTab=true
root=/mnt/
options=metadata,umask=22,fmask=11

[network]
generateResolvConf=true
generateHosts=true
"@

    # 将配置写入WSL
    $escapedContent = $wslConfContent -replace "'", "'\''"
    $writeCmd = "echo '$escapedContent' | sudo tee /etc/wsl.conf > /dev/null"
    Invoke-WSLCommand $DistroName $writeCmd

    Write-Ok "/etc/wsl.conf 配置完成"

    # 配置 .wslconfig 资源控制
    Write-Host "  配置 .wslconfig 资源控制..."
    Configure-WslConfig

    # 重启WSL使配置生效
    Write-Host "  重启WSL使配置生效..."
    wsl --shutdown 2>&1 | Out-Null
    Start-Sleep -Seconds 2

    # 验证互操作
    Write-Host "  验证互操作..."
    $interopCheck = Invoke-WSLCommand $DistroName "cat /etc/wsl.conf | grep -c 'enabled=true'"
    if ($interopCheck -ge 1) {
        Write-Ok "互操作配置验证成功"
    } else {
        Write-Warn "互操作配置验证未通过，请手动检查 /etc/wsl.conf"
    }

    Write-Ok "WSL与Windows互操作配置完成"
}

function Configure-WslConfig {
    # 获取系统资源信息
    $totalMemoryGB = [math]::Round((Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue).TotalPhysicalMemory / 1GB)
    if ($totalMemoryGB -eq 0) { $totalMemoryGB = 8 }

    $wslMemory = [math]::Max(2, [math]::Round($totalMemoryGB * 0.5))
    $wslSwap = [math]::Max(1, [math]::Round($totalMemoryGB * 0.25))
    $wslProcessors = [math]::Max(2, [math]::Round((Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue).NumberOfLogicalProcessors / 2))
    if ($wslProcessors -eq 0) { $wslProcessors = 2 }

    $wslConfigContent = @"
[wsl2]
memory=$wslMemory`GB
processors=$wslProcessors
swap=$wslSwap`GB
localhostForwarding=true
nestedVirtualization=true

[experimental]
autoMemoryReclaim=gradual
sparseVhd=true
"@

    $wslConfigPath = Join-Path $env:USERPROFILE ".wslconfig"
    $wslConfigContent | Set-Content -Path $wslConfigPath -Encoding UTF8
    Write-Ok ".wslconfig 已写入: $wslConfigPath"
    Write-Host "    memory=$wslMemory`GB, processors=$wslProcessors, swap=$wslSwap`GB"
}

# ============================================================
# Action: status - 显示WSL状态
# ============================================================

function Show-WSLStatus {
    Write-Step "WSL 环境状态"

    # WSL安装状态
    if (Test-WSLInstalled) {
        Write-Ok "WSL已安装"
        Write-Host ""
        Write-Host "  WSL版本信息:" -ForegroundColor White
        wsl --version 2>&1 | ForEach-Object { Write-Host "    $_" }

        Write-Host ""
        Write-Host "  WSL全局状态:" -ForegroundColor White
        wsl --status 2>&1 | ForEach-Object { Write-Host "    $_" }

        Write-Host ""
        Write-Host "  已安装发行版:" -ForegroundColor White
        $distroList = wsl -l -v 2>&1
        $distroList | ForEach-Object {
            $line = $_ -replace "`0", ""
            if ($line.Trim() -ne "") {
                Write-Host "    $line"
            }
        }
    } else {
        Write-Err "WSL未安装"
        Write-Host "  请执行: .\setup-wsl.ps1 -Action install"
    }

    # Windows版本
    Write-Host ""
    Write-Host "  Windows版本:" -ForegroundColor White
    $osVer = [System.Environment]::OSVersion.Version
    Write-Host "    $($osVer.Major).$($osVer.Minor).$($osVer.Build)"

    # 虚拟化状态
    try {
        $hyperV = Get-ComputerInfo -Property "HyperVisorPresent" -ErrorAction SilentlyContinue
        $virtStatus = if ($hyperV.HyperVisorPresent -eq $true) { "已启用" } else { "未启用" }
        Write-Host "  虚拟化状态: $virtStatus" -ForegroundColor White
    } catch {
        Write-Host "  虚拟化状态: 无法检测" -ForegroundColor Yellow
    }

    # .wslconfig状态
    $wslConfigPath = Join-Path $env:USERPROFILE ".wslconfig"
    if (Test-Path $wslConfigPath) {
        Write-Host "  .wslconfig: 已配置" -ForegroundColor White
    } else {
        Write-Host "  .wslconfig: 未配置" -ForegroundColor Yellow
    }
}

# ============================================================
# 主逻辑
# ============================================================

switch ($Action) {
    "install"            { Install-WSL2 }
    "install-distro"     { Install-Distro $Distro }
    "init-distro"        { Initialize-Distro $Distro }
    "configure-interop"  { Configure-Interop $Distro }
    "status"             { Show-WSLStatus }
}
