# Python 开发环境配置指南

## 环境概述

Python开发环境用于开发Python应用程序。主要包括Python解释器、包管理器、虚拟环境工具和开发工具。

## 系统要求

- **操作系统**：Windows 10/11、macOS 10.14+、Linux
- **内存**：最低4GB，推荐8GB
- **磁盘空间**：至少2GB可用空间
- **网络**：需要网络连接安装包

## 需要安装的组件

| 组件 | 版本 | 用途 | 安装方式 |
|------|------|------|---------|
| Python | 3.11+ | 运行环境 | 官网/包管理器 |
| pip | 最新 | 包管理器 | Python自带 |
| virtualenv | 最新 | 虚拟环境 | pip |
| conda | 最新 | 环境管理 | 官网安装 |
| IDE | 最新 | 开发工具 | 官网安装 |

## 安装步骤

### 步骤1：安装Python

#### Windows (Chocolatey)
```powershell
choco install python311 -y
```

#### macOS (Homebrew)
```bash
brew install python@3.11
```

#### Linux (apt)
```bash
sudo apt update
sudo apt install python3.11 python3.11-venv python3.11-dev
```

### 步骤2：验证Python安装

```bash
python --version
pip --version
```

### 步骤3：配置pip镜像源

```bash
# 使用清华镜像
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

# 或使用阿里云镜像
pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/
```

### 步骤4：安装虚拟环境工具

```bash
# 安装virtualenv
pip install virtualenv

# 或使用Python内置的venv
python -m venv myenv
```

### 步骤5：创建虚拟环境

```bash
# 使用virtualenv
virtualenv myenv

# 使用venv
python -m venv myenv

# 激活虚拟环境
# Windows
myenv\Scripts\activate

# macOS/Linux
source myenv/bin/activate
```

### 步骤6：安装常用包

```bash
# 在虚拟环境中安装
pip install numpy pandas matplotlib scikit-learn
pip install flask django fastapi
pip install pytest black flake8
```

## 配置步骤

### IDE配置

#### VS Code
1. 安装Python扩展
2. 配置Python路径
3. 配置虚拟环境路径

#### PyCharm
1. 下载安装PyCharm
2. 配置Python解释器
3. 配置虚拟环境

### 环境变量配置

#### Windows
```powershell
# 设置PYTHON_HOME
[System.Environment]::SetEnvironmentVariable("PYTHON_HOME", "C:\Python311", "Machine")
```

#### macOS/Linux
```bash
# 添加到 ~/.bashrc 或 ~/.zshrc
export PYTHON_HOME=/usr/local/Cellar/python@3.11/3.11.4
export PATH=$PYTHON_HOME/bin:$PATH
```

## 验证步骤

### 验证Python
```bash
python --version
pip --version
python -c "import sys; print(sys.path)"
```

### 验证虚拟环境
```bash
# 检查虚拟环境是否激活
which python

# 检查已安装的包
pip list
```

## 预计时间

- Python安装：5-10分钟
- 虚拟环境配置：5-10分钟
- 常用包安装：10-20分钟
- 完整环境配置：30-60分钟

## 注意事项

1. **版本选择**：推荐使用Python 3.11+，支持最新特性
2. **虚拟环境**：强烈建议使用虚拟环境隔离项目依赖
3. **包管理**：大型项目建议使用poetry或pipenv
4. **IDE选择**：VS Code轻量级，PyCharm功能丰富

## 常见问题

### 1. Python命令找不到
- 检查Python安装路径
- 检查PATH环境变量
- 重启终端

### 2. pip安装包失败
- 检查网络连接
- 配置镜像源
- 使用`--user`选项安装到用户目录

### 3. 虚拟环境激活失败
- 检查虚拟环境路径
- 使用正确的激活命令
- 检查执行策略（Windows）

### 4. 包版本冲突
- 使用虚拟环境隔离
- 使用pip freeze > requirements.txt记录版本
- 使用pip install -r requirements.txt安装

## 相关资源

- [Python官网](https://www.python.org/)
- [pip文档](https://pip.pypa.io/)
- [virtualenv文档](https://virtualenv.pypa.io/)
- [conda文档](https://docs.conda.io/)
