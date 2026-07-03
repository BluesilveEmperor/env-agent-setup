<#
.SYNOPSIS
    WSL 内开发环境一键配置脚本
.DESCRIPTION
    在指定的WSL发行版内按需安装和配置开发环境（Git、Python、Node.js、Java、Rust、Go、C/C++）
.PARAMETER Distro
    目标WSL发行版名称（如 Ubuntu、Debian）
.PARAMETER Environments
    要配置的开发环境列表（git,python,nodejs,java,rust,go,cpp）
.PARAMETER All
    配置所有开发环境
.PARAMETER SkipMirror
    跳过国内镜像源配置
.PARAMETER SkipVerify
    跳过安装后验证
.EXAMPLE
    .\setup-wsl-dev-env.ps1 -Distro Ubuntu -Environments git,python,nodejs
    .\setup-wsl-dev-env.ps1 -Distro Ubuntu -All
    .\setup-wsl-dev-env.ps1 -Distro Debian -Environments python -SkipMirror
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Distro,

    [Parameter(Mandatory=$false)]
    [ValidateSet("git", "python", "nodejs", "java", "rust", "go", "cpp")]
    [string[]]$Environments = @(),

    [switch]$All,

    [switch]$SkipMirror,

    [switch]$SkipVerify
)

$ErrorActionPreference = "Stop"

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

function Invoke-WSLCommand {
    param(
        [string]$Command,
        [int]$TimeoutSeconds = 300
    )
    try {
        $result = wsl -d $Distro -- bash -c $Command 2>&1
        return @{ Success = $true; Output = $result }
    } catch {
        return @{ Success = $false; Output = $_.Exception.Message }
    }
}

function Get-DistroPackageManager {
    try {
        $osInfo = wsl -d $Distro -- bash -c "cat /etc/os-release 2>/dev/null" 2>&1
        if ($osInfo -match "Ubuntu|Debian|Kali") { return "apt" }
        if ($osInfo -match "CentOS") { return "yum" }
        if ($osInfo -match "Fedora") { return "dnf" }
        if ($osInfo -match "Arch") { return "pacman" }
        if ($osInfo -match "openSUSE|SLES|SUSE") { return "zypper" }
    } catch {}
    # 根据名称推断
    if ($Distro -match "Ubuntu|Debian|Kali") { return "apt" }
    if ($Distro -match "CentOS") { return "yum" }
    if ($Distro -match "Fedora") { return "dnf" }
    if ($Distro -match "Arch") { return "pacman" }
    if ($Distro -match "openSUSE|SLES|SUSE") { return "zypper" }
    return "apt"
}

# ============================================================
# 环境安装函数
# ============================================================

# --- Git 安装配置 (T031) ---
function Install-GitEnv {
    Write-Step "配置 Git 开发环境"

    # 安装Git
    switch ($script:PackageManager) {
        "apt"    { Invoke-WSLCommand "sudo apt install -y git" }
        "yum"    { Invoke-WSLCommand "sudo yum install -y git" }
        "dnf"    { Invoke-WSLCommand "sudo dnf install -y git" }
        "pacman" { Invoke-WSLCommand "sudo pacman -S --noconfirm git" }
        "zypper" { Invoke-WSLCommand "sudo zypper install -y git" }
    }

    # 配置Git基本设置
    Write-Host "  配置Git基本设置..."
    Invoke-WSLCommand "git config --global init.defaultBranch main"
    Invoke-WSLCommand "git config --global core.editor vim"
    Invoke-WSLCommand "git config --global pull.rebase false"

    # 提示用户配置个人信息
    $gitUser = Invoke-WSLCommand "git config --global user.name" 
    $gitEmail = Invoke-WSLCommand "git config --global user.email"
    if ([string]::IsNullOrWhiteSpace(($gitUser.Output -join "").Trim())) {
        Write-Warn "请手动配置Git用户信息:"
        Write-Host '    wsl -d ' + $Distro + ' -- git config --global user.name "Your Name"'
        Write-Host '    wsl -d ' + $Distro + ' -- git config --global user.email "your.email@example.com"'
    }

    # 生成SSH密钥（如果不存在）
    $sshKey = Invoke-WSLCommand "test -f ~/.ssh/id_ed25519.pub && echo EXISTS || echo MISSING"
    if (($sshKey.Output -join "") -match "MISSING") {
        Write-Host "  生成SSH密钥..."
        Invoke-WSLCommand 'ssh-keygen -t ed25519 -C "dev@wsl" -f ~/.ssh/id_ed25519 -N ""'
        Write-Ok "SSH密钥已生成"
    } else {
        Write-Ok "SSH密钥已存在"
    }

    if (-not $SkipVerify) {
        $ver = Invoke-WSLCommand "git --version"
        Write-Ok "Git验证: $($ver.Output -join '')"
    }
}

# --- Python 安装配置 (T032) ---
function Install-PythonEnv {
    Write-Step "配置 Python 开发环境"

    # 安装Python
    switch ($script:PackageManager) {
        "apt"    { Invoke-WSLCommand "sudo apt install -y python3 python3-pip python3-venv python3-dev" }
        "yum"    { Invoke-WSLCommand "sudo yum install -y python3 python3-pip python3-devel" }
        "dnf"    { Invoke-WSLCommand "sudo dnf install -y python3 python3-pip python3-devel" }
        "pacman" { Invoke-WSLCommand "sudo pacman -S --noconfirm python python-pip" }
        "zypper" { Invoke-WSLCommand "sudo zypper install -y python3 python3-pip python3-devel" }
    }

    # 配置pip国内镜像源
    if (-not $SkipMirror) {
        Write-Host "  配置pip清华镜像源..."
        Invoke-WSLCommand 'pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple'
        Invoke-WSLCommand 'pip config set global.trusted-host pypi.tuna.tsinghua.edu.cn'
    }

    # 安装virtualenv
    Invoke-WSLCommand "pip install virtualenv"

    if (-not $SkipVerify) {
        $pyVer = Invoke-WSLCommand "python3 --version"
        $pipVer = Invoke-WSLCommand "pip3 --version"
        Write-Ok "Python验证: $($pyVer.Output -join '')"
        Write-Ok "pip验证: $($pipVer.Output -join '')"
    }
}

# --- Node.js 安装配置 (T033) ---
function Install-NodejsEnv {
    Write-Step "配置 Node.js 开发环境"

    # 安装nvm
    Write-Host "  安装nvm..."
    $nvmCheck = Invoke-WSLCommand "test -d ~/.nvm && echo EXISTS || echo MISSING"
    if (($nvmCheck.Output -join "") -match "MISSING") {
        # 使用ghproxy加速下载
        Invoke-WSLCommand 'curl -o- https://ghproxy.com/https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash'
        Write-Ok "nvm安装完成"
    } else {
        Write-Ok "nvm已存在"
    }

    # 设置Node.js镜像（国内加速）
    if (-not $SkipMirror) {
        Invoke-WSLCommand 'export NVM_NODEJS_ORG_MIRROR=https://npmmirror.com/mirrors/node && source ~/.nvm/nvm.sh && nvm install --lts && nvm use --lts && nvm alias default node'
    } else {
        Invoke-WSLCommand 'source ~/.nvm/nvm.sh && nvm install --lts && nvm use --lts && nvm alias default node'
    }

    # 配置npm镜像源
    if (-not $SkipMirror) {
        Write-Host "  配置npm npmmirror镜像源..."
        Invoke-WSLCommand 'source ~/.nvm/nvm.sh && npm config set registry https://registry.npmmirror.com'
    }

    if (-not $SkipVerify) {
        $nodeVer = Invoke-WSLCommand 'source ~/.nvm/nvm.sh && node --version'
        $npmVer = Invoke-WSLCommand 'source ~/.nvm/nvm.sh && npm --version'
        Write-Ok "Node.js验证: $($nodeVer.Output -join '')"
        Write-Ok "npm验证: $($npmVer.Output -join '')"
    }
}

# --- Java/Rust/Go/C++ 安装配置 (T034) ---
function Install-JavaEnv {
    Write-Step "配置 Java 开发环境"

    switch ($script:PackageManager) {
        "apt"    { Invoke-WSLCommand "sudo apt install -y openjdk-17-jdk" }
        "yum"    { Invoke-WSLCommand "sudo yum install -y java-17-openjdk-devel" }
        "dnf"    { Invoke-WSLCommand "sudo dnf install -y java-17-openjdk-devel" }
        "pacman" { Invoke-WSLCommand "sudo pacman -S --noconfirm jdk-openjdk" }
        "zypper" { Invoke-WSLCommand "sudo zypper install -y java-17-openjdk-devel" }
    }

    # 配置JAVA_HOME
    Invoke-WSLCommand 'JAVA_HOME=$(readlink -f $(which java) | sed "s:/bin/java::") && echo "export JAVA_HOME=$JAVA_HOME" >> ~/.bashrc && echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> ~/.bashrc'

    if (-not $SkipVerify) {
        $javaVer = Invoke-WSLCommand "java -version 2>&1 | head -1"
        Write-Ok "Java验证: $($javaVer.Output -join '')"
    }
}

function Install-RustEnv {
    Write-Step "配置 Rust 开发环境"

    # 使用中科大镜像安装rustup
    Write-Host "  安装rustup..."
    $rustCheck = Invoke-WSLCommand "test -d ~/.cargo && echo EXISTS || echo MISSING"
    if (($rustCheck.Output -join "") -match "MISSING") {
        if (-not $SkipMirror) {
            Invoke-WSLCommand 'export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static && export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup && curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y'
        } else {
            Invoke-WSLCommand 'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y'
        }
        Write-Ok "Rust安装完成"
    } else {
        Write-Ok "Rust已存在"
    }

    # 配置Cargo镜像源
    if (-not $SkipMirror) {
        Write-Host "  配置Cargo中科大镜像源..."
        $cargoConfig = "[source.crates-io]`nreplace-with = 'ustc'`n`n[source.ustc]`nregistry = `"sparse+https://mirrors.ustc.edu.cn/crates.io-index/`"`n`n[net]`ngit-fetch-with-cli = true"
        $cargoEscaped = $cargoConfig -replace "'", "'\''"
        Invoke-WSLCommand "mkdir -p ~/.cargo && echo '$cargoEscaped' > ~/.cargo/config.toml"
    }

    # 安装常用组件
    Invoke-WSLCommand 'source $HOME/.cargo/env && rustup component add rustfmt clippy'

    if (-not $SkipVerify) {
        $rustVer = Invoke-WSLCommand 'source $HOME/.cargo/env && rustc --version'
        $cargoVer = Invoke-WSLCommand 'source $HOME/.cargo/env && cargo --version'
        Write-Ok "Rust验证: $($rustVer.Output -join '')"
        Write-Ok "Cargo验证: $($cargoVer.Output -join '')"
    }
}

function Install-GoEnv {
    Write-Step "配置 Go 开发环境"

    # 获取最新Go版本（使用已知的稳定版本）
    $goVersion = "1.22.0"

    $goCheck = Invoke-WSLCommand "test -d /usr/local/go && echo EXISTS || echo MISSING"
    if (($goCheck.Output -join "") -match "MISSING") {
        Write-Host "  下载Go $goVersion ..."
        if (-not $SkipMirror) {
            Invoke-WSLCommand "wget -q https://mirrors.ustc.edu.cn/golang/go$goVersion.linux-amd64.tar.gz -O /tmp/go.tar.gz && sudo tar -C /usr/local -xzf /tmp/go.tar.gz && rm -f /tmp/go.tar.gz"
        } else {
            Invoke-WSLCommand "wget -q https://go.dev/dl/go$goVersion.linux-amd64.tar.gz -O /tmp/go.tar.gz && sudo tar -C /usr/local -xzf /tmp/go.tar.gz && rm -f /tmp/go.tar.gz"
        }
        Write-Ok "Go安装完成"
    } else {
        Write-Ok "Go已存在"
    }

    # 配置环境变量
    Invoke-WSLCommand 'grep -q "GOROOT" ~/.bashrc || echo ''export GOROOT=/usr/local/go'' >> ~/.bashrc'
    Invoke-WSLCommand 'grep -q "GOPATH" ~/.bashrc || echo ''export GOPATH=$HOME/go'' >> ~/.bashrc'
    Invoke-WSLCommand 'grep -q "/usr/local/go/bin" ~/.bashrc || echo ''export PATH=$GOROOT/bin:$GOPATH/bin:$PATH'' >> ~/.bashrc'

    # 配置goproxy镜像
    if (-not $SkipMirror) {
        Write-Host "  配置goproxy.cn镜像..."
        Invoke-WSLCommand '/usr/local/go/bin/go env -w GOPROXY=https://goproxy.cn,direct'
    }

    if (-not $SkipVerify) {
        $goVer = Invoke-WSLCommand '/usr/local/go/bin/go version'
        Write-Ok "Go验证: $($goVer.Output -join '')"
    }
}

function Install-CppEnv {
    Write-Step "配置 C/C++ 开发环境"

    switch ($script:PackageManager) {
        "apt"    { Invoke-WSLCommand "sudo apt install -y build-essential gcc g++ gdb cmake make" }
        "yum"    { Invoke-WSLCommand "sudo yum groupinstall -y 'Development Tools' && sudo yum install -y cmake" }
        "dnf"    { Invoke-WSLCommand "sudo dnf groupinstall -y 'Development Tools' && sudo dnf install -y cmake" }
        "pacman" { Invoke-WSLCommand "sudo pacman -S --noconfirm base-devel gcc cmake make gdb" }
        "zypper" { Invoke-WSLCommand "sudo zypper install -y gcc gcc-c++ cmake make gdb" }
    }

    if (-not $SkipVerify) {
        $gccVer = Invoke-WSLCommand "gcc --version | head -1"
        $gppVer = Invoke-WSLCommand "g++ --version | head -1"
        $cmakeVer = Invoke-WSLCommand "cmake --version | head -1"
        Write-Ok "GCC验证: $($gccVer.Output -join '')"
        Write-Ok "G++验证: $($gppVer.Output -join '')"
        Write-Ok "CMake验证: $($cmakeVer.Output -join '')"
    }
}

# ============================================================
# 验证与报告 (T035)
# ============================================================

function Show-InstallReport {
    Write-Step "配置结果汇总报告"

    Write-Host "  发行版: $Distro" -ForegroundColor White
    Write-Host "  包管理器: $script:PackageManager" -ForegroundColor White
    Write-Host ""

    $envResults = @()

    foreach ($env in $script:SelectedEnvs) {
        $result = @{ Name = $env; Installed = $false; Version = "N/A"; MirrorConfigured = $false }

        switch ($env) {
            "git" {
                $ver = Invoke-WSLCommand "git --version 2>/dev/null"
                $result.Installed = ($ver.Success -and ($ver.Output -join "") -match "git version")
                $result.Version = if ($result.Installed) { ($ver.Output -join "").Trim() } else { "N/A" }
                if (-not $SkipMirror) { $result.MirrorConfigured = $true }
            }
            "python" {
                $ver = Invoke-WSLCommand "python3 --version 2>/dev/null"
                $result.Installed = ($ver.Success -and ($ver.Output -join "") -match "Python")
                $result.Version = if ($result.Installed) { ($ver.Output -join "").Trim() } else { "N/A" }
                if (-not $SkipMirror) { $result.MirrorConfigured = $true }
            }
            "nodejs" {
                $ver = Invoke-WSLCommand 'source ~/.nvm/nvm.sh 2>/dev/null && node --version 2>/dev/null'
                $result.Installed = ($ver.Success -and ($ver.Output -join "") -match "v\d+")
                $result.Version = if ($result.Installed) { ($ver.Output -join "").Trim() } else { "N/A" }
                if (-not $SkipMirror) { $result.MirrorConfigured = $true }
            }
            "java" {
                $ver = Invoke-WSLCommand "java -version 2>&1 | head -1"
                $result.Installed = ($ver.Success -and ($ver.Output -join "") -match "version")
                $result.Version = if ($result.Installed) { ($ver.Output -join "").Trim() } else { "N/A" }
            }
            "rust" {
                $ver = Invoke-WSLCommand 'source $HOME/.cargo/env 2>/dev/null && rustc --version 2>/dev/null'
                $result.Installed = ($ver.Success -and ($ver.Output -join "") -match "rustc")
                $result.Version = if ($result.Installed) { ($ver.Output -join "").Trim() } else { "N/A" }
                if (-not $SkipMirror) { $result.MirrorConfigured = $true }
            }
            "go" {
                $ver = Invoke-WSLCommand '/usr/local/go/bin/go version 2>/dev/null'
                $result.Installed = ($ver.Success -and ($ver.Output -join "") -match "go version")
                $result.Version = if ($result.Installed) { ($ver.Output -join "").Trim() } else { "N/A" }
                if (-not $SkipMirror) { $result.MirrorConfigured = $true }
            }
            "cpp" {
                $ver = Invoke-WSLCommand "gcc --version 2>/dev/null | head -1"
                $result.Installed = ($ver.Success -and ($ver.Output -join "") -match "gcc")
                $result.Version = if ($result.Installed) { ($ver.Output -join "").Trim() } else { "N/A" }
            }
        }

        $envResults += $result
    }

    # 输出报告
    Write-Host "  环境名称    安装状态    版本信息                        镜像源配置" -ForegroundColor White
    Write-Host "  --------    --------    --------                        ----------" -ForegroundColor White
    foreach ($r in $envResults) {
        $installStatus = if ($r.Installed) { "[OK]" } else { "[FAIL]" }
        $mirrorStatus = if ($r.MirrorConfigured) { "已配置" } else { if ($r.Name -in @("java", "cpp")) { "N/A" } else { "未配置" } }
        $installColor = if ($r.Installed) { "Green" } else { "Red" }
        Write-Host "  $($r.Name.PadRight(10)) " -NoNewline
        Write-Host " $installStatus " -ForegroundColor $installColor -NoNewline
        Write-Host " $($r.Version.PadRight(30)) " -NoNewline
        Write-Host " $mirrorStatus"
    }

    Write-Host ""
    $successCount = ($envResults | Where-Object { $_.Installed }).Count
    $totalCount = $envResults.Count
    Write-Host "  总计: $successCount/$totalCount 环境安装成功" -ForegroundColor $(if ($successCount -eq $totalCount) { "Green" } else { "Yellow" })
}

# ============================================================
# 主逻辑
# ============================================================

# 检查发行版是否已安装
Write-Step "WSL 内开发环境配置"

Write-Host "  目标发行版: $Distro"
Write-Host "  指定环境: $($Environments -join ', ')"

try {
    $null = wsl -d $Distro -- echo "WSL OK" 2>&1
} catch {
    Write-Err "无法连接到发行版 '$Distro'。请确认发行版已安装且正在运行。"
    Write-Host "  检查已安装发行版: wsl -l -v"
    return
}

# 检测包管理器
$script:PackageManager = Get-DistroPackageManager
Write-Ok "检测到包管理器: $script:PackageManager"

# 确定要安装的环境列表
if ($All) {
    $script:SelectedEnvs = @("git", "python", "nodejs", "java", "rust", "go", "cpp")
    Write-Host "  选择: 全部环境"
} elseif ($Environments.Count -gt 0) {
    $script:SelectedEnvs = $Environments
    Write-Host "  选择: $($Environments -join ', ')"
} else {
    # 交互式选择
    Write-Host ""
    Write-Host "  请选择要配置的开发环境（输入编号，用逗号分隔）:" -ForegroundColor Yellow
    Write-Host "  1. git      - Git版本控制"
    Write-Host "  2. python   - Python开发环境"
    Write-Host "  3. nodejs   - Node.js开发环境"
    Write-Host "  4. java     - Java开发环境"
    Write-Host "  5. rust     - Rust开发环境"
    Write-Host "  6. go       - Go开发环境"
    Write-Host "  7. cpp      - C/C++开发环境"
    Write-Host "  a. all      - 全部环境"
    Write-Host ""

    $selection = Read-Host "请输入选择（如 1,2,3 或 a）"

    $envMap = @{
        "1" = "git"; "2" = "python"; "3" = "nodejs"; "4" = "java"
        "5" = "rust"; "6" = "go"; "7" = "cpp"; "a" = "all"
    }

    if ($selection -match "a" -or $selection -match "all") {
        $script:SelectedEnvs = @("git", "python", "nodejs", "java", "rust", "go", "cpp")
    } else {
        $script:SelectedEnvs = @()
        $parts = $selection -split ","
        foreach ($part in $parts) {
            $trimmed = $part.Trim()
            if ($envMap.ContainsKey($trimmed)) {
                $script:SelectedEnvs += $envMap[$trimmed]
            } elseif ($trimmed -in @("git", "python", "nodejs", "java", "rust", "go", "cpp")) {
                $script:SelectedEnvs += $trimmed
            }
        }
    }

    if ($script:SelectedEnvs.Count -eq 0) {
        Write-Err "未选择任何环境"
        return
    }

    Write-Host "  选择的环境: $($script:SelectedEnvs -join ', ')"
}

# 执行安装
foreach ($env in $script:SelectedEnvs) {
    switch ($env) {
        "git"    { Install-GitEnv }
        "python" { Install-PythonEnv }
        "nodejs" { Install-NodejsEnv }
        "java"   { Install-JavaEnv }
        "rust"   { Install-RustEnv }
        "go"     { Install-GoEnv }
        "cpp"    { Install-CppEnv }
    }
}

# 验证与报告
if (-not $SkipVerify) {
    Show-InstallReport
} else {
    Write-Step "完成"
    Write-Host "  已跳过验证（-SkipVerify）"
    Write-Host "  已配置环境: $($script:SelectedEnvs -join ', ')"
}
