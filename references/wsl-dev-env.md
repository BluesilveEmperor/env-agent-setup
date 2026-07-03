# WSL 内开发环境配置指南

## 环境概述

本文档指导用户在WSL2内的Linux发行版中按需配置开发环境。支持Git、Python、Node.js、Java、Rust、Go、C/C++等7种主流开发环境的安装与配置。所有配置均针对国内网络环境优化，使用国内镜像源加速下载。

## 包管理器自动识别

不同发行版使用不同的包管理器，本skill根据发行版名称自动识别：

| 发行版 | 包管理器 | 包安装命令 |
|--------|---------|-----------|
| Ubuntu / Ubuntu-* | apt | `sudo apt install -y <pkg>` |
| Debian | apt | `sudo apt install -y <pkg>` |
| Kali-Linux | apt | `sudo apt install -y <pkg>` |
| CentOS* | yum | `sudo yum install -y <pkg>` |
| Fedora | dnf | `sudo dnf install -y <pkg>` |
| Archlinux | pacman | `sudo pacman -S --noconfirm <pkg>` |
| openSUSE-Leap | zypper | `sudo zypper install -y <pkg>` |
| SLES | zypper | `sudo zypper install -y <pkg>` |

## 从Windows端执行WSL内命令

所有WSL内操作均从Windows PowerShell通过 `wsl -d` 命令远程执行：

```powershell
# 基本格式
wsl -d <distro> -- <command>

# 示例
wsl -d Ubuntu -- bash -c "sudo apt update"
wsl -d Ubuntu -- git --version
```

## Git 配置

### 安装Git

| 发行版 | 安装命令 |
|--------|---------|
| apt系 | `sudo apt install -y git` |
| yum系 | `sudo yum install -y git` |
| dnf系 | `sudo dnf install -y git` |
| pacman系 | `sudo pacman -S --noconfirm git` |
| zypper系 | `sudo zypper install -y git` |

### 配置用户信息

```bash
# 设置用户名和邮箱
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 设置默认分支名为main
git config --global init.defaultBranch main

# 设置默认编辑器
git config --global core.editor vim

# 查看配置
git config --global --list
```

### 配置SSH密钥

```bash
# 生成SSH密钥（ed25519推荐）
ssh-keygen -t ed25519 -C "your.email@example.com"

# 或使用RSA（兼容性更好）
ssh-keygen -t rsa -b 4096 -C "your.email@example.com"

# 启动ssh-agent
eval "$(ssh-agent -s)"

# 添加密钥到agent
ssh-add ~/.ssh/id_ed25519

# 复制公钥到剪贴板（用于添加到GitHub/GitLab）
cat ~/.ssh/id_ed25519.pub
```

### 配置Git凭据管理器

WSL2可使用Windows端的Git凭据管理器：

```bash
# 在WSL内设置（需要interop启用）
git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe"
```

## Python 配置

### 安装Python

| 发行版 | 安装命令 |
|--------|---------|
| apt系 | `sudo apt install -y python3 python3-pip python3-venv python3-dev` |
| yum系 | `sudo yum install -y python3 python3-pip python3-devel` |
| dnf系 | `sudo dnf install -y python3 python3-pip python3-devel` |
| pacman系 | `sudo pacman -S --noconfirm python python-pip` |
| zypper系 | `sudo zypper install -y python3 python3-pip python3-devel` |

### 配置pip国内镜像源

```bash
# 使用清华镜像
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

# 或使用阿里云镜像
pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/

# 配置信任主机
pip config set global.trusted-host pypi.tuna.tsinghua.edu.cn
```

### 安装virtualenv

```bash
# 安装virtualenv
pip install virtualenv

# 创建虚拟环境
python3 -m venv myenv

# 激活虚拟环境
source myenv/bin/activate

# 验证
python --version
pip --version
```

## Node.js 配置

### 通过nvm安装（推荐）

nvm是Node.js版本管理器，支持安装和管理多个Node.js版本：

```bash
# 安装nvm（使用国内镜像）
export NVM_SOURCE="https://ghproxy.com/https://github.com/nvm-sh/nvm.git"
curl -o- https://ghproxy.com/https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# 或使用官方地址
# curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# 加载nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# 设置Node.js镜像（国内加速）
export NVM_NODEJS_ORG_MIRROR=https://npmmirror.com/mirrors/node

# 安装最新LTS版本
nvm install --lts

# 设置默认版本
nvm use --lts
nvm alias default node

# 验证
node --version
npm --version
```

### 通过fnm安装（替代方案）

fnm是更快的Node.js版本管理器：

```bash
# 安装fnm
curl -fsSL https://fnm.vercel.app/install | bash

# 加载fnm
eval "$(fnm env)"

# 安装最新LTS版本
fnm install --lts
fnm use --lts

# 验证
node --version
```

### 配置npm国内镜像源

```bash
# 使用npmmirror镜像
npm config set registry https://registry.npmmirror.com

# 验证配置
npm config get registry

# 安装TypeScript（可选）
npm install -g typescript ts-node
```

## Java 配置

### 安装JDK

| 发行版 | JDK 17 安装命令 | JDK 11 安装命令 |
|--------|----------------|----------------|
| apt系 | `sudo apt install -y openjdk-17-jdk` | `sudo apt install -y openjdk-11-jdk` |
| yum系 | `sudo yum install -y java-17-openjdk-devel` | `sudo yum install -y java-11-openjdk-devel` |
| dnf系 | `sudo dnf install -y java-17-openjdk-devel` | `sudo dnf install -y java-11-openjdk-devel` |
| pacman系 | `sudo pacman -S --noconfirm jdk-openjdk` | `sudo pacman -S --noconfirm jdk11-openjdk` |
| zypper系 | `sudo zypper install -y java-17-openjdk-devel` | `sudo zypper install -y java-11-openjdk-devel` |

### 配置JAVA_HOME

```bash
# 查找Java安装路径
readlink -f $(which java) | sed "s:/bin/java::"

# 添加到 ~/.bashrc 或 ~/.zshrc
export JAVA_HOME=$(readlink -f $(which java) | sed "s:/bin/java::")
export PATH=$JAVA_HOME/bin:$PATH

# 重新加载配置
source ~/.bashrc

# 验证
java -version
javac -version
echo $JAVA_HOME
```

### 安装Maven

```bash
# 使用包管理器安装
# apt系
sudo apt install -y maven

# yum系
sudo yum install -y maven

# dnf系
sudo dnf install -y maven

# 或手动安装（获取最新版本）
MAVEN_VERSION="3.9.6"
wget https://mirrors.tuna.tsinghua.edu.cn/apache/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz
sudo tar xzf apache-maven-$MAVEN_VERSION-bin.tar.gz -C /opt/
echo 'export M2_HOME=/opt/apache-maven-'$MAVEN_VERSION >> ~/.bashrc
echo 'export PATH=$M2_HOME/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# 配置Maven阿里云镜像（见 references/common.md）
```

## Rust 配置

### 通过rustup安装

```bash
# 安装rustup（使用中科大镜像）
export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# 加载环境变量
source $HOME/.cargo/env

# 验证
rustc --version
cargo --version
rustup --version
```

### 配置Cargo国内镜像源

```bash
# 创建配置文件
mkdir -p ~/.cargo
cat > ~/.cargo/config.toml << 'EOF'
[source.crates-io]
replace-with = 'ustc'

[source.ustc]
registry = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"

[net]
git-fetch-with-cli = true
EOF

# 验证安装
cargo new hello_world
cd hello_world && cargo build && cargo run
```

### 安装常用组件

```bash
# 安装rustfmt和clippy
rustup component add rustfmt clippy

# 安装rust-analyzer（LSP）
rustup component add rust-analyzer
```

## Go 配置

### 通过官方tar安装（推荐）

```bash
# 获取最新版本号（示例为 1.22.0，请查询最新版本）
GO_VERSION="1.22.0"

# 下载（使用国内镜像）
wget https://mirrors.ustc.edu.cn/golang/go$GO_VERSION.linux-amd64.tar.gz

# 或使用官方地址
# wget https://go.dev/dl/go$GO_VERSION.linux-amd64.tar.gz

# 解压安装
sudo tar -C /usr/local -xzf go$GO_VERSION.linux-amd64.tar.gz

# 配置环境变量
echo 'export GOROOT=/usr/local/go' >> ~/.bashrc
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export PATH=$GOROOT/bin:$GOPATH/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# 验证
go version
```

### 配置GOPATH和goproxy镜像

```bash
# 设置GOPATH
go env -w GOPATH=$HOME/go

# 配置国内代理（goproxy.cn）
go env -w GOPROXY=https://goproxy.cn,direct

# 或使用阿里云代理
# go env -w GOPROXY=https://mirrors.aliyun.com/goproxy/,direct

# 验证
go env GOPROXY

# 测试下载
go get golang.org/x/tools
```

## C/C++ 配置

### 安装编译工具链

| 发行版 | 安装命令 |
|--------|---------|
| apt系 | `sudo apt install -y build-essential gcc g++ gdb cmake make` |
| yum系 | `sudo yum groupinstall -y "Development Tools" && sudo yum install -y cmake` |
| dnf系 | `sudo dnf groupinstall -y "Development Tools" && sudo dnf install -y cmake` |
| pacman系 | `sudo pacman -S --noconfirm base-devel gcc cmake make gdb` |
| zypper系 | `sudo zypper install -y gcc gcc-c++ cmake make gdb` |

### 验证编译环境

```bash
# 验证GCC
gcc --version
g++ --version

# 验证CMake
cmake --version

# 验证Make
make --version

# 编译测试
cat > /tmp/hello.c << 'EOF'
#include <stdio.h>
int main() {
    printf("Hello, WSL C!\n");
    return 0;
}
EOF
gcc /tmp/hello.c -o /tmp/hello && /tmp/hello

cat > /tmp/hello.cpp << 'EOF'
#include <iostream>
int main() {
    std::cout << "Hello, WSL C++!" << std::endl;
    return 0;
}
EOF
g++ /tmp/hello.cpp -o /tmp/hello_cpp && /tmp/hello_cpp
```

## 预计时间

- 单个环境配置：3-5分钟（不含下载时间）
- Git配置：3分钟
- Python配置：5分钟
- Node.js配置（含nvm）：5-8分钟
- Java配置：5分钟
- Rust配置（含rustup）：5-8分钟
- Go配置：5分钟
- C/C++配置：3-5分钟
- 全套环境配置：20-30分钟

## 注意事项

1. **版本管理器优先**：Node.js使用nvm/fnm、Rust使用rustup、Go使用官方tar，确保版本灵活管理
2. **镜像源必须配置**：国内网络环境下，必须配置国内镜像源否则下载极慢
3. **环境变量持久化**：所有环境变量配置写入 `~/.bashrc` 或 `~/.zshrc` 确保持久生效
4. **包管理器差异**：不同发行版包名可能不同，上述命令已按发行版分别列出
5. **互操作依赖**：WSL调用Windows程序（如git-credential-manager）需要interop启用

## 常见问题

### 1. nvm安装后命令找不到

```bash
# 手动加载nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
```

### 2. pip安装包超时

```bash
# 确认镜像源已配置
pip config list

# 临时使用镜像源
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple <package>
```

### 3. cargo build下载依赖慢

```bash
# 确认Cargo镜像已配置
cat ~/.cargo/config.toml

# 手动设置环境变量
export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
```

### 4. Go模块下载失败

```bash
# 检查GOPROXY配置
go env GOPROXY

# 重新设置
go env -w GOPROXY=https://goproxy.cn,direct
```

## 相关资源

- WSL2基础安装 → [references/wsl-setup.md](wsl-setup.md)
- 互操作配置 → [references/wsl-interop.md](wsl-interop.md)
- 高级功能 → [references/wsl-advanced.md](wsl-advanced.md)
- 实例管理 → [references/wsl-management.md](wsl-management.md)
- 通用镜像源配置 → [references/common.md](common.md)
