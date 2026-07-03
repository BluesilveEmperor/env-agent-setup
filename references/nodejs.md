# Node.js 开发环境配置指南

## 环境概述

Node.js开发环境用于开发JavaScript/TypeScript应用程序。主要包括Node.js运行时、包管理器、版本管理工具和开发工具。

## 系统要求

- **操作系统**：Windows 10/11、macOS 10.14+、Linux
- **内存**：最低4GB，推荐8GB
- **磁盘空间**：至少2GB可用空间
- **网络**：需要网络连接安装包

## 需要安装的组件

| 组件 | 版本 | 用途 | 安装方式 |
|------|------|------|---------|
| Node.js | 18 LTS+ | 运行环境 | 官网/nvm |
| npm | 最新 | 包管理器 | Node.js自带 |
| yarn | 最新 | 包管理器 | npm |
| pnpm | 最新 | 包管理器 | npm |
| nvm | 最新 | 版本管理 | 官网安装 |
| TypeScript | 最新 | 类型系统 | npm |

## 安装步骤

### 步骤1：安装版本管理工具（推荐）

#### Windows (nvm-windows)
```powershell
# 下载安装nvm-windows
# https://github.com/coreybutler/nvm-windows/releases

# 或使用Chocolatey
choco install nvm -y
```

#### macOS/Linux (nvm)
```bash
# 安装nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# 重启终端后验证
nvm --version
```

### 步骤2：安装Node.js

```bash
# 使用nvm安装Node.js
nvm install 18
nvm use 18

# 验证安装
node --version
npm --version
```

### 步骤3：配置npm镜像源

```bash
# 使用淘宝镜像
npm config set registry https://registry.npmmirror.com

# 验证配置
npm config get registry
```

### 步骤4：安装常用全局包

```bash
# 安装常用工具
npm install -g typescript
npm install -g @types/node
npm install -g ts-node
npm install -g nodemon
npm install -g pm2
npm install -g yarn
npm install -g pnpm
```

### 步骤5：配置TypeScript

```bash
# 初始化TypeScript配置
tsc --init

# 编辑tsconfig.json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

## 配置步骤

### IDE配置

#### VS Code
1. 安装ESLint扩展
2. 安装Prettier扩展
3. 安装TypeScript扩展
4. 配置settings.json

#### WebStorm
1. 下载安装WebStorm
2. 配置Node.js路径
3. 配置代码风格

### 环境变量配置

#### Windows
```powershell
# 设置NODE_HOME
[System.Environment]::SetEnvironmentVariable("NODE_HOME", "C:\Program Files\nodejs", "Machine")
```

#### macOS/Linux
```bash
# 添加到 ~/.bashrc 或 ~/.zshrc
export NODE_HOME=/usr/local/Cellar/node/18.17.0
export PATH=$NODE_HOME/bin:$PATH
```

## 验证步骤

### 验证Node.js
```bash
node --version
npm --version
yarn --version
pnpm --version
```

### 验证TypeScript
```bash
tsc --version
ts-node --version
```

### 验证全局包
```bash
npm list -g --depth=0
```

## 预计时间

- Node.js安装：5-10分钟
- 版本管理工具：5-10分钟
- 全局包安装：10-20分钟
- 完整环境配置：30-60分钟

## 注意事项

1. **版本选择**：推荐使用LTS版本，稳定可靠
2. **版本管理**：强烈建议使用nvm管理多个Node.js版本
3. **包管理**：pnpm速度快，节省磁盘空间
4. **TypeScript**：现代JavaScript项目推荐使用TypeScript

## 常见问题

### 1. Node.js版本冲突
- 使用nvm切换版本
- 使用.nvmrc文件指定项目版本
- 使用容器化环境

### 2. npm安装包失败
- 检查网络连接
- 配置镜像源
- 使用`--registry`选项指定镜像

### 3. 全局包权限问题
- Windows：以管理员身份运行
- macOS/Linux：使用sudo或修复npm权限

### 4. TypeScript编译错误
- 检查tsconfig.json配置
- 检查类型定义包
- 使用`--skipLibCheck`选项

## 相关资源

- [Node.js官网](https://nodejs.org/)
- [npm文档](https://docs.npmjs.com/)
- [yarn文档](https://yarnpkg.com/)
- [pnpm文档](https://pnpm.io/)
- [TypeScript文档](https://www.typescriptlang.org/)
