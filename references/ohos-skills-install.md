# OpenHarmony Skills 安装指南

## 概述

本指南介绍如何在各AI Agent的skills目录下安装OpenHarmony全链路skills，覆盖ArkUI、ArkTS、DFX等开发场景。

## Skills来源

**仓库地址**：https://github.com/openharmonyinsight/openharmony-skills

**安装命令**：
```bash
# 安装整个仓库
npx skills add openharmonyinsight/openharmony-skills

# 安装单个Skill
npx skills add openharmonyinsight/openharmony-skills --skill <skill_name>
```

---

## 需要安装的Skills清单

### ArkTS相关

| Skill名称 | 说明 | 用途 |
|-----------|------|------|
| arkts-sta-playground | ArkTS STA实验场 | ArkTS语法测试和实验 |
| arkts-static-spec | ArkTS静态规范 | ArkTS静态类型检查规范 |
| openharmony-arkts-layer | ArkTS语言层 | ArkTS语言层开发和调试 |

### ArkUI相关

| Skill名称 | 说明 | 用途 |
|-----------|------|------|
| arkui-api-design | ArkUI API设计 | ArkUI API设计规范和最佳实践 |
| arkui-menu-debug | ArkUI菜单调试 | ArkUI菜单组件调试 |
| arkuix-module-adapter | ArkUI模块适配 | ArkUI模块适配和扩展 |

### DFX（故障分析）相关

| Skill名称 | 说明 | 用途 |
|-----------|------|------|
| ohos-issue-graphics-cppcrash-analysis | CppCrash分析 | C++崩溃故障日志分析 |
| ohos-issue-graphics-sysfreeze-analysis | 系统冻屏分析 | 系统冻屏故障日志分析 |
| oh-memory-leak-detection | 内存泄漏检测 | JS/ArkTS内存泄漏检测 |

### 构建相关

| Skill名称 | 说明 | 用途 |
|-----------|------|------|
| build-error-analyzer | 构建错误分析 | HarmonyOS构建错误分析 |
| compile-analysis | 编译分析 | 编译过程分析和优化 |
| openharmony-build | OpenHarmony构建 | OpenHarmony项目构建 |
| ohos-app-build-debug | 应用构建调试 | HarmonyOS应用构建和调试 |

### 代码检查相关

| Skill名称 | 说明 | 用途 |
|-----------|------|------|
| code-checker | 代码检查 | ArkTS/ArkUI代码检查 |
| code-problem-analyzer | 问题分析 | 代码问题分析和修复建议 |
| comprehensive-code-review | 综合代码审查 | 全面的代码审查 |
| oh-precommit-codecheck | 提交前检查 | 代码提交前检查 |

### AI Agent相关

| Skill名称 | 说明 | 用途 |
|-----------|------|------|
| harmonyos-ai-agent-skill | 鸿蒙AI Agent | 鸿蒙开发AI Agent技能 |

### Cangjie（仓颉）相关

**仓库地址**：https://gitcode.com/Cangjie-SIG/CangjieSkills

| Skill名称 | 说明 | 用途 |
|-----------|------|------|
| cangjie-harmonyos-doc-search | 鸿蒙文档语义检索 | 基于Openviking的鸿蒙开发文档语义检索 |
| harmonyos-project-init | 项目初始化 | 从零初始化可运行的仓颉鸿蒙项目模板 |
| harmonyos-requirements | 需求分析 | 鸿蒙需求分析与设计Skill |
| harmonyos-build | 构建日志 | 标准构建与日志采集 |
| harmonyos-evolution | 经验沉淀 | 沉淀BUILD SUCCESSFUL后的已验证经验 |
| harmonyos-stdx | stdx配置 | 鸿蒙项目stdx依赖自动解压与配置 |
| harmonyos-app-diagnose | 应用诊断 | 构建成功后采集截图与控件树、抓取hilog日志 |
| cangjie-lang-features | 仓颉语言特性 | 仓颉语言核心特性优先参考 |
| cangjie_arkts_interop | 仓颉ArkTS互操作 | 仓颉与ArkTS互操作实战 |
| cangjie-std | 仓颉标准库 | 仓颉标准库常用功能速查 |
| cangjie-stdx | 仓颉扩展库 | 仓颉扩展标准库速查 |
| cangjie-original-docs | 仓颉原始文档 | 仓颉语言/标准库/扩展标准库/工具链原始文档 |

---

## 各Agent安装路径

### Claude

**Skills目录**：`C:\Users\GLY\.claude\skills\`

**安装命令**：
```powershell
# 安装所有OpenHarmony skills
npx skills add openharmonyinsight/openharmony-skills --path "C:\Users\GLY\.claude\skills"

# 安装单个skill
npx skills add openharmonyinsight/openharmony-skills --skill arkts-sta-playground --path "C:\Users\GLY\.claude\skills"
```

### OpenCode

**Skills目录**：`C:\Users\GLY\.config\opencode\skills\`

**安装命令**：
```powershell
# 安装所有OpenHarmony skills
npx skills add openharmonyinsight/openharmony-skills --path "C:\Users\GLY\.config\opencode\skills"

# 安装单个skill
npx skills add openharmonyinsight/openharmony-skills --skill arkts-sta-playground --path "C:\Users\GLY\.config\opencode\skills"
```

### Hermes

**Skills目录**：`~/.hermes/skills/`（需手动创建）

**安装命令**：
```bash
# 创建目录
mkdir -p ~/.hermes/skills

# 手动复制skills
cp -r openharmony-skills/skills/* ~/.hermes/skills/
```

### OpenClaw

**Skills目录**：`~/.openclaw/skills/`（需手动创建）

**安装命令**：
```bash
# 创建目录
mkdir -p ~/.openclaw/skills

# 手动复制skills
cp -r openharmony-skills/skills/* ~/.openclaw/skills/
```

---

## 自动安装脚本

### PowerShell脚本

```powershell
# 检测已安装的AI Agent并安装OpenHarmony skills

$agents = @(
    @{Name="claude"; Path="$env:USERPROFILE\.claude\skills"},
    @{Name="opencode"; Path="$env:USERPROFILE\.config\opencode\skills"},
    @{Name="hermes"; Path="$env:USERPROFILE\.hermes\skills"},
    @{Name="openclaw"; Path="$env:USERPROFILE\.openclaw\skills"}
)

$installedAgents = @()

foreach ($agent in $agents) {
    if (Get-Command $agent.Name -ErrorAction SilentlyContinue) {
        $installedAgents += $agent
        Write-Host "检测到已安装: $($agent.Name)" -ForegroundColor Green
    }
}

if ($installedAgents.Count -eq 0) {
    Write-Host "未检测到已安装的AI Agent" -ForegroundColor Yellow
    Write-Host "请先安装Claude或OpenCode" -ForegroundColor Yellow
    exit 1
}

# 安装OpenHarmony skills
foreach ($agent in $installedAgents) {
    Write-Host "正在为 $($agent.Name) 安装OpenHarmony skills..." -ForegroundColor Cyan
    
    # 确保目录存在
    if (-not (Test-Path $agent.Path)) {
        New-Item -ItemType Directory -Path $agent.Path -Force | Out-Null
    }
    
    # 安装skills
    npx skills add openharmonyinsight/openharmony-skills --path $agent.Path
    
    Write-Host "$($agent.Name) 安装完成" -ForegroundColor Green
}

Write-Host "所有OpenHarmony skills安装完成" -ForegroundColor Green
```

### 使用方法

1. 保存上述脚本为 `install-ohos-skills.ps1`
2. 以管理员身份运行PowerShell
3. 执行脚本：`.\install-ohos-skills.ps1`

---

## 手动安装方法

### 步骤1：克隆仓库

```bash
git clone https://github.com/openharmonyinsight/openharmony-skills.git
```

### 步骤2：复制skills到Agent目录

```bash
# Claude
cp -r openharmony-skills/skills/* ~/.claude/skills/

# OpenCode
cp -r openharmony-skills/skills/* ~/.config/opencode/skills/

# Hermes
cp -r openharmony-skills/skills/* ~/.hermes/skills/

# OpenClaw
cp -r openharmony-skills/skills/* ~/.openclaw/skills/
```

---

## 国内网络安装

### 问题

GitHub访问慢或无法访问。

### 解决方案

#### 1. 使用SteamCommunity302

1. 下载安装SteamCommunity302：https://steamcommunity.com/chatgroups/
2. 启动SteamCommunity302
3. 启用"加速GitHub"功能
4. 重新执行安装命令

#### 2. 使用镜像站

```bash
# 使用GitHub镜像站克隆
git clone https://ghproxy.com/https://github.com/openharmonyinsight/openharmony-skills.git
```

#### 3. 手动下载ZIP

1. 访问 https://github.com/openharmonyinsight/openharmony-skills
2. 点击 Code → Download ZIP
3. 解压ZIP文件
4. 复制skills到Agent目录

---

## 验证安装

### 验证Claude skills

```powershell
Get-ChildItem "C:\Users\GLY\.claude\skills" | Where-Object { $_.Name -match "arkts|arkui|ohos" } | Select-Object Name
```

### 验证OpenCode skills

```powershell
Get-ChildItem "C:\Users\GLY\.config\opencode\skills" | Where-Object { $_.Name -match "arkts|arkui|ohos" } | Select-Object Name
```

### 预期输出

安装成功后，应该看到以下skills：

```
arkts-sta-playground
arkts-static-spec
arkui-api-design
arkui-menu-debug
arkuix-module-adapter
ohos-issue-graphics-cppcrash-analysis
ohos-issue-graphics-sysfreeze-analysis
oh-memory-leak-detection
build-error-analyzer
compile-analysis
openharmony-build
code-checker
code-problem-analyzer
comprehensive-code-review
harmonyos-ai-agent-skill
```

---

## 常见问题

### 1. npx skills命令不存在

```bash
# 全局安装skills工具
npm install -g @anthropic-ai/skills
```

### 2. 安装路径错误

检查Agent的skills目录位置：
- Claude：`~/.claude/skills/`
- OpenCode：`~/.config/opencode/skills/`

### 3. GitHub访问失败

使用SteamCommunity302加速或使用镜像站。

### 4. Skills不生效

重启AI Agent或重新加载skills。

---

## 相关资源

- [OpenHarmony Skills仓库](https://github.com/openharmonyinsight/openharmony-skills)
- [SteamCommunity302](https://steamcommunity.com/chatgroups/)
- [Claude Code](https://github.com/anthropics/claude-code)
- [OpenCode](https://github.com/opencode-ai/opencode)
