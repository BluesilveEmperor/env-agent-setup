# AI Agent 配置指南

## 概述

本指南介绍如何配置各种AI Agent开发助手，包括：
- claude-code
- opencode
- hermes
- deveco-code
- openclaw

## 国内网络环境注意事项

由于网络环境限制，配置AI Agent时可能遇到以下问题：
1. 无法访问GitHub下载依赖
2. 无法连接到国外API服务
3. 包管理器下载速度慢

### 解决方案

#### 1. SteamCommunity302
SteamCommunity302可以加速GitHub访问：
- 下载地址：https://steamcommunity.com/chatgroups/
- 安装后启用"加速GitHub"功能
- 验证：`ping github.com`

#### 2. 国内镜像源
使用国内镜像源加速下载：
- npm：https://registry.npmmirror.com
- pip：https://pypi.tuna.tsinghua.edu.cn/simple
- Go：https://goproxy.cn

#### 3. 代理配置
配置代理服务器访问国外服务：
```bash
export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890
```

---

## AI Agent概览

| Agent | 说明 | Skills目录 | 安装方式 |
|-------|------|-----------|---------|
| **claude-code** | Anthropic Claude Code | `~/.claude/skills/` | npm |
| **opencode** | OpenCode AI助手 | `~/.config/opencode/skills/` | npm |
| **hermes** | Hermes AI助手 | `~/.hermes/skills/` | 手动安装 |
| **deveco-code** | 华为DevEco Code | DevEco Studio插件 | IDE插件 |
| **openclaw** | OpenClaw AI助手 | `~/.openclaw/skills/` | 手动安装 |

---

## claude-code 配置

### 安装

```bash
# 使用npm安装
npm install -g @anthropic-ai/claude-code

# 或使用yarn
yarn global add @anthropic-ai/claude-code
```

### 国内网络安装

如遇npm安装慢或失败，配置镜像源：
```bash
npm config set registry https://registry.npmmirror.com
npm install -g @anthropic-ai/claude-code
```

### 配置

1. 运行 `claude` 启动
2. 按提示完成初始化配置
3. 配置API密钥（如需要）

### Skills目录

- **位置**：`C:\Users\GLY\.claude\skills\`
- **安装skills**：
```bash
# 安装OpenHarmony skills
npx skills add openharmonyinsight/openharmony-skills --path C:\Users\GLY\.claude\skills\
```

---

## opencode 配置

### 安装

```bash
# 使用npm安装
npm install -g opencode
```

### 国内网络安装

```bash
npm config set registry https://registry.npmmirror.com
npm install -g opencode
```

### 配置

1. 运行 `opencode` 启动
2. 按提示完成初始化配置
3. 配置AI模型（可选）

### Skills目录

- **位置**：`C:\Users\GLY\.config\opencode\skills\`
- **安装skills**：
```bash
# 安装OpenHarmony skills
npx skills add openharmonyinsight/openharmony-skills --path C:\Users\GLY\.config\opencode\skills\
```

---

## hermes 配置

### 安装

Hermes需要手动安装：

1. 访问GitHub仓库：https://github.com/nicepkg/hermes
2. 下载最新版本
3. 解压到本地目录
4. 添加到PATH环境变量

### 国内网络安装

如遇GitHub访问问题，使用SteamCommunity302加速：
1. 安装并启动SteamCommunity302
2. 启用"加速GitHub"功能
3. 重新尝试下载

### 配置

1. 运行 `hermes` 启动
2. 按提示完成初始化配置

### Skills目录

- **位置**：`~/.hermes/skills/`（需手动创建）
- **安装skills**：手动复制skills目录

---

## deveco-code 配置

### 安装

DevEco Code是DevEco Studio的插件：

1. 打开DevEco Studio
2. 进入 File → Settings → Plugins
3. 搜索"DevEco Code"
4. 点击Install安装
5. 重启DevEco Studio

### 配置

1. 打开DevEco Studio
2. 进入 Settings → DevEco Code
3. 配置AI模型（可选）
4. 启用代码补全和智能提示

### 功能

- 智能代码补全
- 代码生成与重构
- 错误检测与修复
- 代码解释与文档生成

---

## openclaw 配置

### 安装

OpenClaw需要手动安装：

1. 访问GitHub仓库
2. 下载最新版本
3. 解压到本地目录
4. 添加到PATH环境变量

### 国内网络安装

如遇GitHub访问问题，使用SteamCommunity302加速。

### 配置

1. 运行 `openclaw` 启动
2. 按提示完成初始化配置

### Skills目录

- **位置**：`~/.openclaw/skills/`（需手动创建）
- **安装skills**：手动复制skills目录

---

## Skills安装通用方法

### 使用npx skills安装

```bash
# 安装整个仓库
npx skills add openharmonyinsight/openharmony-skills

# 安装单个Skill
npx skills add openharmonyinsight/openharmony-skills --skill <skill_name>

# 指定安装路径
npx skills add openharmonyinsight/openharmony-skills --path <skills_directory>
```

### 手动安装

1. 克隆仓库：
```bash
git clone https://github.com/openharmonyinsight/openharmony-skills.git
```

2. 复制skills到Agent目录：
```bash
# Claude
cp -r openharmony-skills/skills/* ~/.claude/skills/

# OpenCode
cp -r openharmony-skills/skills/* ~/.config/opencode/skills/
```

---

## 验证安装

### 验证Agent安装

```bash
# Claude
claude --version

# OpenCode
opencode --version

# Hermes
hermes --version
```

### 验证Skills安装

```powershell
# Claude skills
Get-ChildItem "C:\Users\GLY\.claude\skills" | Select-Object Name

# OpenCode skills
Get-ChildItem "C:\Users\GLY\.config\opencode\skills" | Select-Object Name
```

---

## 常见问题

### 1. npm安装慢或失败
- 配置国内镜像源：`npm config set registry https://registry.npmmirror.com`
- 使用VPN或代理
- 使用SteamCommunity302加速GitHub

### 2. GitHub无法访问
- 安装并启用SteamCommunity302
- 使用国内镜像源
- 手动下载安装包

### 3. Skills安装失败
- 检查网络连接
- 使用`--path`指定正确的安装路径
- 手动复制skills目录

### 4. Agent无法启动
- 检查PATH环境变量
- 检查依赖是否安装
- 查看错误日志

---

## 相关资源

- [Claude Code](https://github.com/anthropics/claude-code)
- [OpenCode](https://github.com/opencode-ai/opencode)
- [Hermes](https://github.com/nicepkg/hermes)
- [DevEco Code](https://developer.huawei.com/consumer/cn/deveco-studio/)
- [OpenHarmony Skills](https://github.com/openharmonyinsight/openharmony-skills)
- [SteamCommunity302](https://steamcommunity.com/chatgroups/)
