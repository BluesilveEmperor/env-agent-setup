# 通用配置原则和最佳实践

## 国内网络环境配置

### 网络环境说明

本skill针对国内网络环境进行了优化，所有配置方案优先使用国内镜像源和替代方案。

### GitHub访问解决方案

当配置过程中需要访问GitHub时：

1. **检测是否已安装SteamCommunity302**
2. **如未安装，引导用户下载并启用**
3. **提供国内镜像源替代方案**

### SteamCommunity302配置

**下载地址**：https://steamcommunity.com/chatgroups/

**使用步骤**：
1. 下载并安装SteamCommunity302
2. 启动SteamCommunity302
3. 启用"加速GitHub"功能
4. 验证GitHub访问：`ping github.com`

**检测命令**：
```powershell
# 检测GitHub访问
ping github.com

# 检测SteamCommunity302是否运行
Get-Process -Name "SteamCommunity302" -ErrorAction SilentlyContinue
```

### 国内镜像源

| 工具 | 镜像源 | 配置命令 |
|------|--------|---------|
| npm | npmmirror | `npm config set registry https://registry.npmmirror.com` |
| pip | 清华镜像 | `pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple` |
| Maven | 阿里云镜像 | 配置settings.xml |
| Go | goproxy.cn | `go env -w GOPROXY=https://goproxy.cn,direct` |
| Cargo | 中科大镜像 | 配置config.toml |
| apt | 清华镜像 | 修改sources.list |
| apt | 阿里云镜像 | 修改sources.list |
| yum | 华为镜像 | 替换CentOS-Base.repo |
| dnf | 华为镜像 | 替换fedora.repo |
| pacman | 中科大镜像 | 修改/etc/pacman.d/mirrorlist |
| zypper | 清华镜像 | 替换repo |

### WSL Linux 发行版镜像源配置

WSL内的Linux发行版与物理机Linux使用相同的镜像源配置方式。以下为各发行版的国内镜像源配置命令：

#### Ubuntu/Debian（apt 清华镜像）
```bash
# 备份原始源
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak

# Ubuntu 替换为清华源
sudo sed -i 's@//.*archive.ubuntu.com@//mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list
sudo sed -i 's@//.*security.ubuntu.com@//mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list

# Debian 替换为清华源
sudo sed -i 's@//.*deb.debian.org@//mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list
sudo sed -i 's@//.*security.debian.org@//mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list

# 更新索引
sudo apt update
```

#### CentOS（yum 华为镜像）
```bash
# 备份原始源
sudo cp -a /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak

# 替换为华为源（CentOS 7）
sudo sed -i 's@//.*mirror.centos.org@//repo.huaweicloud.com@g' /etc/yum.repos.d/CentOS-Base.repo

# 更新索引
sudo yum makecache
```

#### Fedora（dnf 华为镜像）
```bash
# 备份原始源
sudo cp -a /etc/yum.repos.d/fedora.repo /etc/yum.repos.d/fedora.repo.bak

# 替换为华为源
sudo sed -i 's@//.*fedora mirrors@//repo.huaweicloud.com@g' /etc/yum.repos.d/fedora.repo

# 更新索引
sudo dnf makecache
```

#### Arch（pacman 中科大镜像）
```bash
# 备份原始源
sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

# 添加中科大镜像到文件开头
echo 'Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch' | sudo tee /etc/pacman.d/mirrorlist > /dev/null

# 更新索引
sudo pacman -Sy
```

#### openSUSE（zypper 清华镜像）
```bash
# 备份原始源
sudo cp -a /etc/zypp/repos.d/ /etc/zypp/repos.d.bak/

# 替换为清华源
sudo sed -i 's@//.*download.opensuse.org@//mirrors.tuna.tsinghua.edu.cn/opensuse@g' /etc/zypp/repos.d/*.repo

# 更新索引
sudo zypper refresh
```

### GitHub镜像站

| 镜像站 | 地址 | 用途 |
|--------|------|------|
| ghproxy | https://ghproxy.com/ | 克隆仓库、下载文件 |
| gitclone | https://gitclone.com/ | 克隆仓库 |
| gitee | https://gitee.com/ | 代码托管 |

---

## 包管理器选择

### Windows
- **首选**：Chocolatey (choco)
- **备选**：winget (Windows Package Manager)
- **开发工具**：scoop

### macOS
- **首选**：Homebrew
- **备选**：MacPorts

### Linux
- **Debian/Ubuntu**：apt
- **CentOS/RHEL**：yum/dnf
- **Arch**：pacman
- **openSUSE/SLES**：zypper
- **Fedora**：dnf

### WSL Linux（按发行版自动选择）
WSL内的包管理器与物理机Linux一致，根据安装的发行版自动使用对应包管理器：
- **Ubuntu/Debian/Kali** → apt
- **CentOS** → yum
- **Fedora** → dnf
- **Arch** → pacman
- **openSUSE/SLES** → zypper

> **注意**：WSL内安装软件使用 `wsl -d <distro> -- sudo <包管理器> install <包名>` 从Windows端远程执行。

## 环境变量配置

### PATH配置原则

1. **系统级PATH**：所有用户可用的工具
2. **用户级PATH**：当前用户专用的工具
3. **项目级PATH**：项目特定的工具版本

### 常见环境变量

| 变量 | 用途 | 示例 |
|------|------|------|
| JAVA_HOME | JDK安装路径 | `C:\Program Files\Java\jdk-17` |
| ANDROID_HOME | Android SDK路径 | `D:\Android\Sdk` |
| GOPATH | Go工作空间 | `C:\Users\username\go` |
| CARGO_HOME | Rust工具链 | `C:\Users\username\.cargo` |
| NVM_HOME | Node版本管理 | `C:\Users\username\AppData\Roaming\nvm` |
| DEVECO_STUDIO_PATH | DevEco Studio路径 | `C:\Program Files\Huawei\DevEco Studio` |

## 版本管理工具

### Node.js版本管理
- **Windows/macOS/Linux**：nvm-windows / nvm / fnm
- **推荐**：fnm (Fast Node Manager)

### Python版本管理
- **Windows/macOS/Linux**：pyenv / conda
- **推荐**：pyenv + virtualenv

### Java版本管理
- **Windows/macOS/Linux**：SDKMAN!
- **推荐**：SDKMAN! + jEnv

### Go版本管理
- **Windows/macOS/Linux**：gvm / goenv
- **推荐**：官方安装包 + goenv

### Rust版本管理
- **Windows/macOS/Linux**：rustup (官方)

## 镜像源配置

### 国内镜像源

#### npm镜像
```bash
npm config set registry https://registry.npmmirror.com
```

#### pip镜像
```bash
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
```

#### Maven镜像
```xml
<mirror>
  <id>aliyun</id>
  <mirrorOf>central</mirrorOf>
  <name>Aliyun Maven</name>
  <url>https://maven.aliyun.com/repository/central</url>
</mirror>
```

#### Go模块镜像
```bash
go env -w GOPROXY=https://goproxy.cn,direct
```

#### Cargo镜像
```toml
[source.crates-io]
replace-with = 'ustc'

[source.ustc]
registry = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"
```

## 安装顺序原则

1. **先安装基础工具**：包管理器、版本控制
2. **再安装运行时**：语言环境、框架
3. **最后安装开发工具**：IDE、插件、扩展
4. **最后安装AI Agent和Skills**：配置AI助手和开发技能

## 验证原则

1. **版本验证**：`<tool> --version`
2. **路径验证**：`where <tool>` (Windows) / `which <tool>` (Unix)
3. **功能验证**：运行简单的测试命令
4. **环境变量验证**：`echo $<VAR>` (Unix) / `echo %<VAR>%` (Windows)

## 常见问题处理

### 权限问题
- Windows：以管理员身份运行终端
- macOS/Linux：使用sudo

### 网络问题
- 配置代理
- 使用镜像源
- 使用SteamCommunity302加速GitHub
- 手动下载安装包

### 路径问题
- 避免路径中包含空格
- 避免路径中包含中文
- 使用短路径（8.3格式）

### 版本冲突
- 使用版本管理工具
- 配置环境变量切换
- 使用容器化环境（Docker）

### AI Agent配置
- 配置国内镜像源加速npm
- 使用SteamCommunity302加速GitHub
- 手动安装skills到Agent目录
