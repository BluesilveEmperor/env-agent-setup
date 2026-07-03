---
name: env-agent-setup
description: >-
  开发环境与AI Agent配置助手。当用户提到"配置开发环境"、"搭建开发环境"、"setup development environment"、
  "安装开发工具"、"配置编程环境"、"安装SDK"、"配置IDE"、"开发环境搭建"、"配置AI Agent"、
  "安装claude-code"、"配置opencode"、"安装hermes"、"配置deveco-code"、"安装openclaw"等关键词时使用。
  支持Android、HarmonyOS、iOS、Web前端、Python、Java、C/C++、Rust、Go、Node.js等主流开发环境。
  支持配置claude-code、opencode、hermes、deveco-code、openclaw等AI Agent。
  支持WSL2 Linux环境配置（安装发行版、配置开发环境、互操作、高级功能）。
  国内网络环境优化，支持SteamCommunity302解决GitHub访问问题。
  若用户选择配置鸿蒙开发环境，自动检测本地AI Agent并安装OpenHarmony全链路skills（ArkUI/ArkTS/DFX等）。
  主动识别环境类型，提出配置方案，用户确认后自动执行配置。
  提供环境检测、组件安装、路径配置、验证测试等完整功能。
license: MIT
metadata:
  author: opencode-skills
  version: "2.0.0"
  created: "2026-06-22"
  keywords: ["dev-env", "setup", "environment", "配置", "开发环境", "安装", "SDK", "IDE", "AI Agent", "鸿蒙", "HarmonyOS", "WSL", "WSL2", "Linux"]
compatibility: >
  支持Windows、macOS、Linux系统。需要管理员权限或sudo权限进行系统级安装。
  部分环境需要网络连接下载安装包。国内网络环境优先使用镜像源。
---

# 开发环境与AI Agent配置助手

当用户要求配置开发环境时，使用本skill主动识别环境类型，提出配置方案，用户确认后自动执行配置。
若用户选择配置鸿蒙开发环境，自动检测本地已安装的AI Agent并安装OpenHarmony全链路skills。

## 快速导航

| 功能模块 | 说明 | 参考文档 |
|---------|------|---------|
| **环境类型识别** | 根据用户输入识别目标环境 | 本页 "环境类型识别" 章节 |
| **AI Agent配置** | 配置各类AI Agent开发助手 | [references/ai-agents.md](references/ai-agents.md) |
| **鸿蒙Skills安装** | 自动安装OpenHarmony全链路skills | [references/ohos-skills-install.md](references/ohos-skills-install.md) |
| **WSL Linux环境** | WSL2安装、发行版配置、开发环境、互操作 | [references/wsl-setup.md](references/wsl-setup.md) |
| **国内网络配置** | 国内网络环境优化方案 | 本页 "国内网络环境配置" 章节 |
| **各环境详细指南** | 各开发环境的详细配置步骤 | [references/](references/) 目录 |

---

## 工作流程

### 总则

1. **主动识别**：根据用户输入自动识别目标开发环境类型
2. **方案确认**：提出详细配置方案，等待用户确认
3. **自动配置**：用户确认后自动执行配置步骤
4. **错误处理**：根据实际环境灵活处理配置错误
5. **验证结果**：配置完成后验证环境是否正常工作
6. **鸿蒙特殊处理**：若选择鸿蒙环境，自动检测AI Agent并安装全链路skills

### 阶段决策树

```
阶段一 → 用户输入分析
  └─ 提取环境类型关键词 → 阶段二

阶段二 → 环境检测
  ├─ 检测成功 → 阶段三
  └─ 检测失败 → 提示手动检测，继续阶段三

阶段三 → 生成配置方案
  ├─ 普通环境 → 输出方案 → 等待用户确认
  ├─ 鸿蒙环境 → 检测AI Agent + 输出方案 → 等待用户确认
  └─ WSL Linux环境 → 检测WSL2状态 + 输出方案 → 等待用户确认

阶段四 → 用户确认？
  ├─ 确认 → 阶段五
  └─ 修改 → 重新生成方案

阶段五 → 执行配置
  ├─ 配置成功 → 阶段六
  └─ 配置失败 → 错误处理

阶段六 → 验证结果
  ├─ 验证成功 → 完成
  └─ 验证失败 → 重新配置
```

---

## 环境类型识别

### 识别规则

根据用户输入中的关键词识别目标环境：

| 环境类型 | 关键词 |
|---------|--------|
| **AI Agent** | claude-code、opencode、hermes、deveco-code、openclaw、AI、Agent、AI助手 |
| **Android** | Android、安卓、SDK、Gradle、ADB、Kotlin、Java Android |
| **HarmonyOS** | HarmonyOS、鸿蒙、DevEco、DevEco Code、ArkTS、ArkUI、Hvigor、HDC |
| **iOS** | iOS、iPhone、iPad、Xcode、Swift、Objective-C、CocoaPods |
| **Web前端** | Web、前端、React、Vue、Angular、TypeScript、JavaScript、HTML、CSS |
| **WSL Linux** | WSL、WSL2、Linux子系统、Ubuntu on Windows、Subsystem、wsl --install、WSL Linux |
| **Python** | Python、pip、conda、virtualenv、Django、Flask、FastAPI |
| **Java** | Java、JDK、Maven、Gradle、Spring、Tomcat |
| **C/C++** | C、C++、GCC、Clang、CMake、Make、Visual Studio |
| **Rust** | Rust、cargo、rustup |
| **Go** | Go、Golang、GOPATH |
| **Node.js** | Node、Node.js、npm、yarn、pnpm |

### 多环境识别

如果用户输入包含多种环境类型，按以下优先级处理：

1. **单一环境**：直接处理
2. **相关环境**：合并处理（如 Java + Android）
3. **多个独立环境**：询问用户优先处理哪个
4. **鸿蒙环境**：特殊处理，自动检测AI Agent并安装全链路skills
5. **WSL Linux环境**：先检测WSL2安装状态，再根据用户需求安装发行版或配置开发环境

---

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

### 国内镜像源配置

| 工具 | 镜像源 | 配置命令 |
|------|--------|---------|
| npm | npmmirror | `npm config set registry https://registry.npmmirror.com` |
| pip | 清华镜像 | `pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple` |
| Maven | 阿里云镜像 | 配置settings.xml |
| Go | goproxy.cn | `go env -w GOPROXY=https://goproxy.cn,direct` |
| Cargo | 中科大镜像 | 配置config.toml |
| apt | 清华镜像 | 修改sources.list（WSL内同样适用） |
| yum | 华为镜像 | 替换repo文件（CentOS WSL内适用） |
| dnf | 华为镜像 | 替换repo文件（Fedora WSL内适用） |
| pacman | 中科大镜像 | 修改/etc/pacman.d/mirrorlist（Arch WSL内适用） |
| zypper | 清华镜像 | 替换repo（openSUSE WSL内适用） |

> **WSL Linux环境说明**：在WSL内配置开发环境时，系统级包管理器（apt/yum/dnf/pacman/zypper）和语言级包管理器（pip/npm/cargo/go）均需配置国内镜像源。详细的WSL镜像源配置步骤见 [references/wsl-setup.md](references/wsl-setup.md) 和 [references/wsl-dev-env.md](references/wsl-dev-env.md)。

---

## 鸿蒙环境特殊处理

### 自动检测AI Agent

当用户选择配置鸿蒙开发环境时，自动检测本地已安装的AI Agent：

```powershell
# 检测已安装的AI Agent
$agents = @("claude", "opencode", "hermes", "deveco-code", "openclaw")
$installedAgents = @()

foreach ($agent in $agents) {
    if (Get-Command $agent -ErrorAction SilentlyContinue) {
        $installedAgents += $agent
    }
}
```

### 自动安装OpenHarmony Skills

检测到AI Agent后，在其各自的skills目录下安装OpenHarmony全链路skills：

| Skills类别 | 包含的Skills | 用途 |
|-----------|-------------|------|
| **ArkTS** | arkts-sta-playground, arkts-static-spec, openharmony-arkts-layer | ArkTS语法、静态检查、语言层 |
| **ArkUI** | arkui-api-design, arkui-menu-debug, arkuix-module-adapter | ArkUI API设计、菜单调试、模块适配 |
| **DFX** | ohos-issue-graphics-cppcrash-analysis, ohos-issue-graphics-sysfreeze-analysis, oh-memory-leak-detection | CppCrash分析、系统冻屏分析、内存泄漏检测 |
| **构建** | build-error-analyzer, compile-analysis, openharmony-build | 构建错误分析、编译分析、构建工具 |
| **代码检查** | code-checker, code-problem-analyzer, comprehensive-code-review | 代码检查、问题分析、综合审查 |

### 自动安装Cangjie（仓颉）Skills

若项目使用仓颉语言开发，自动安装CangjieSkills：

**仓库地址**：https://gitcode.com/Cangjie-SIG/CangjieSkills

**安装命令**：
```bash
# 鸿蒙应用开发Skills（推荐）
npx skills add https://gitcode.com/Cangjie-SIG/CangjieSkills.git#cangjie-harmonyos -a opencode -y
```

| Skills类别 | 包含的Skills | 用途 |
|-----------|-------------|------|
| **鸿蒙开发** | cangjie-harmonyos-doc-search, harmonyos-project-init, harmonyos-requirements | 鸿蒙文档检索、项目初始化、需求分析 |
| **构建调试** | harmonyos-build, harmonyos-evolution, harmonyos-app-diagnose | 构建日志、经验沉淀、应用诊断 |
| **仓颉语言** | cangjie-lang-features, cangjie_arkts_interop | 仓颉语言特性、ArkTS互操作 |
| **标准库** | cangjie-std, cangjie-stdx, cangjie-original-docs | 标准库、扩展库、原始文档 |

详细安装步骤见 [references/ohos-skills-install.md](references/ohos-skills-install.md)

---

## AI Agent配置

### 支持的AI Agent

| Agent | 说明 | 配置指南 |
|-------|------|---------|
| **claude-code** | Anthropic Claude Code | [references/ai-agents.md](references/ai-agents.md) |
| **opencode** | OpenCode AI助手 | [references/ai-agents.md](references/ai-agents.md) |
| **hermes** | Hermes AI助手 | [references/ai-agents.md](references/ai-agents.md) |
| **deveco-code** | 华为DevEco Code | [references/ai-agents.md](references/ai-agents.md) |
| **openclaw** | OpenClaw AI助手 | [references/ai-agents.md](references/ai-agents.md) |

详细配置步骤见 [references/ai-agents.md](references/ai-agents.md)

---

## 各环境详细指南

详细配置步骤见 [references/](references/) 目录：

| 环境类型 | 参考文档 |
|---------|---------|
| AI Agent | [references/ai-agents.md](references/ai-agents.md) |
| 鸿蒙Skills安装 | [references/ohos-skills-install.md](references/ohos-skills-install.md) |
| Android | [references/android.md](references/android.md) |
| HarmonyOS | [references/harmonyos.md](references/harmonyos.md) |
| iOS | [references/ios.md](references/ios.md) |
| Web前端 | [references/web-frontend.md](references/web-frontend.md) |
| Python | [references/python.md](references/python.md) |
| Java | [references/java.md](references/java.md) |
| C/C++ | [references/cpp.md](references/cpp.md) |
| Rust | [references/rust.md](references/rust.md) |
| Go | [references/go.md](references/go.md) |
| Node.js | [references/nodejs.md](references/nodejs.md) |
| WSL2 基础安装与发行版配置 | [references/wsl-setup.md](references/wsl-setup.md) |
| WSL 内开发环境配置 | [references/wsl-dev-env.md](references/wsl-dev-env.md) |
| WSL 与 Windows 互操作 | [references/wsl-interop.md](references/wsl-interop.md) |
| WSLg/Docker/SSH 高级功能 | [references/wsl-advanced.md](references/wsl-advanced.md) |
| WSL 实例管理与维护 | [references/wsl-management.md](references/wsl-management.md) |
| 通用原则 | [references/common.md](references/common.md) |

---

## 检查清单

### Critical（必须完成）

- [ ] 正确识别用户想要配置的环境类型
- [ ] 完成环境检测，获取当前状态
- [ ] 生成详细的配置方案
- [ ] 等待用户确认方案
- [ ] 执行配置步骤
- [ ] 验证配置结果
- [ ] 若为鸿蒙环境，检测AI Agent并安装全链路skills
- [ ] 若为WSL Linux环境，检测WSL2安装状态、发行版列表及开发环境配置状态

### Warning（建议完成）

- [ ] 提供多种安装方式选择
- [ ] 处理常见的配置错误
- [ ] 提供手动配置备选方案
- [ ] 记录配置过程和结果
- [ ] 国内网络环境使用镜像源
- [ ] WSL内为所有包管理器配置国内镜像源

### Info（可选改进）

- [ ] 优化配置方案，减少安装时间
- [ ] 提供配置后的使用建议
- [ ] 推荐相关的开发工具和插件
- [ ] 为WSL用户推荐Docker Desktop WSL2后端集成方案

---

## 常见问题

### 1. 如何处理需要重启的情况？

对于需要重启才能生效的配置：
1. 提示用户需要重启
2. 提供重启前的验证方法
3. 提供重启后的验证方法

### 2. 如何处理网络不稳定的情况？

1. 自动重试最多3次
2. 提供镜像源选项（如国内镜像）
3. 提供手动下载链接
4. 支持断点续传
5. 国内网络使用SteamCommunity302加速GitHub

### 3. 如何处理多版本共存？

1. 使用版本管理工具（如nvm、pyenv）
2. 配置环境变量切换
3. 提供版本切换命令

### 4. 如何处理企业网络限制？

1. 提供代理配置方法
2. 提供离线安装包
3. 提供手动配置指南
4. 使用国内镜像源

### 5. 鸿蒙环境如何安装OpenHarmony Skills？

1. 自动检测本地已安装的AI Agent
2. 在其skills目录下安装全链路skills
3. 详细步骤见 [references/ohos-skills-install.md](references/ohos-skills-install.md)

### 6. 如何配置WSL Linux开发环境？

1. 检测Windows版本和WSL2安装状态
2. 安装WSL2基础环境（如未安装）
3. 安装所需Linux发行版
4. 在WSL内配置开发环境（Git/Python/Node.js等）
5. 配置WSL与Windows互操作
6. 详细步骤见 [references/wsl-setup.md](references/wsl-setup.md)

---

## 参考文档

### 官方文档

- [Chocolatey](https://chocolatey.org/) - Windows包管理器
- [Homebrew](https://brew.sh/) - macOS包管理器
- [apt](https://ubuntu.com/tutorials/package-management) - Linux包管理器
- [SteamCommunity302](https://steamcommunity.com/chatgroups/) - GitHub加速工具
- [WSL官方文档](https://learn.microsoft.com/zh-cn/windows/wsl/) - WSL2 Linux子系统

### 相关skill

- **deveco-cli**: HarmonyOS开发工具链
- **deveco-studio-emulator**: HarmonyOS模拟器管理
- **deveco-studio-hvigor**: HarmonyOS构建工具
- **openharmony-skills**: OpenHarmony全链路skills仓库
