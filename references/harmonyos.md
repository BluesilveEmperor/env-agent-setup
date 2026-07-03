# HarmonyOS 开发环境配置指南

## 环境概述

HarmonyOS开发环境用于开发华为鸿蒙操作系统应用程序。主要包括DevEco Studio、DevEco Code（AI编程助手）、Hvigor构建工具、HDC调试工具等。

## 系统要求

- **操作系统**：Windows 10/11 (64-bit)、macOS 11.0+
- **内存**：最低8GB，推荐16GB
- **磁盘空间**：至少20GB可用空间
- **网络**：需要网络连接下载SDK和工具（国内网络优先使用镜像源）

## 需要安装的组件

| 组件 | 版本 | 用途 | 安装方式 |
|------|------|------|---------|
| DevEco Studio | 最新 | 官方IDE | 官网下载 |
| DevEco Code | 最新 | AI编程助手 | DevEco Studio插件 |
| HarmonyOS SDK | API 9+ | 开发工具包 | DevEco Studio |
| Hvigor | 最新 | 构建工具 | 项目自带 |
| HDC | 最新 | 调试工具 | SDK自带 |
| Node.js | 14.18.3+ | 运行环境 | Chocolatey/Homebrew |

## 安装步骤

### 步骤1：安装Node.js

#### Windows (Chocolatey)
```powershell
choco install nodejs-lts -y
```

#### macOS (Homebrew)
```bash
brew install node
```

### 步骤2：下载DevEco Studio

**国内网络优化**：如遇下载慢或无法访问，可使用SteamCommunity302加速GitHub访问。

1. 访问华为开发者官网：https://developer.huawei.com/consumer/cn/deveco-studio/
2. 下载最新版本的DevEco Studio
3. 运行安装程序，按向导完成安装

### 步骤3：配置DevEco Studio

1. 首次启动DevEco Studio
2. 选择默认配置或自定义配置
3. 等待SDK下载和安装完成

### 步骤4：配置环境变量（可选）

#### Windows
```powershell
# 设置DEVECO_STUDIO_PATH
[System.Environment]::SetEnvironmentVariable("DEVECO_STUDIO_PATH", "C:\Program Files\Huawei\DevEco Studio", "Machine")
```

#### macOS
```bash
# 添加到 ~/.bashrc 或 ~/.zshrc
export DEVECO_STUDIO_PATH="/Applications/DevEco-Studio.app/Contents"
```

### 步骤5：安装HarmonyOS SDK

1. 打开DevEco Studio
2. 进入 Tools → SDK Manager
3. 选择需要的API版本
4. 点击Apply下载安装

### 步骤6：配置模拟器

1. 进入 Tools → Device Manager
2. 创建新的模拟器设备
3. 选择设备类型和系统版本
4. 下载系统镜像
5. 启动模拟器

### 步骤7：安装DevEco Code（AI编程助手）

DevEco Code是华为官方的AI编程助手，集成在DevEco Studio中。

1. 打开DevEco Studio
2. 进入 File → Settings → Plugins
3. 搜索"DevEco Code"
4. 点击Install安装
5. 重启DevEco Studio
6. 配置AI模型（可选）

**DevEco Code功能**：
- 智能代码补全
- 代码生成与重构
- 错误检测与修复
- 代码解释与文档生成

## 配置步骤

### 项目配置

在项目根目录的 `build-profile.json5` 中配置：
```json5
{
  "app": {
    "signingConfigs": [],
    "products": [
      {
        "name": "default",
        "signingConfig": "default",
        "compatibleSdkVersion": "4.0.0(10)",
        "runtimeOS": "HarmonyOS"
      }
    ]
  }
}
```

### Hvigor配置

在 `hvigor/hvigor-config.json5` 中配置：
```json5
{
  "modelVersion": "4.0.2",
  "dependencies": {
    "@ohos/hypium": "1.0.6"
  }
}
```

## AI Agent配置

### DevEco Code配置

DevEco Code是华为官方的AI编程助手，配置步骤见上方"步骤7"。

### 其他AI Agent配置

如需配置其他AI Agent（claude-code、opencode、hermes、openclaw），请参考 [references/ai-agents.md](ai-agents.md)。

### OpenHarmony Skills安装

配置鸿蒙开发环境后，建议安装OpenHarmony全链路skills，提升开发效率。

**自动安装**：本skill会自动检测本地AI Agent并安装以下skills：

| Skills类别 | 包含的Skills | 用途 |
|-----------|-------------|------|
| **ArkTS** | arkts-sta-playground, arkts-static-spec, openharmony-arkts-layer | ArkTS语法、静态检查、语言层 |
| **ArkUI** | arkui-api-design, arkui-menu-debug, arkuix-module-adapter | ArkUI API设计、菜单调试、模块适配 |
| **DFX** | ohos-issue-graphics-cppcrash-analysis, ohos-issue-graphics-sysfreeze-analysis, oh-memory-leak-detection | CppCrash分析、系统冻屏分析、内存泄漏检测 |
| **构建** | build-error-analyzer, compile-analysis, openharmony-build | 构建错误分析、编译分析、构建工具 |
| **代码检查** | code-checker, code-problem-analyzer, comprehensive-code-review | 代码检查、问题分析、综合审查 |

详细安装步骤见 [references/ohos-skills-install.md](ohos-skills-install.md)

### Cangjie（仓颉）Skills安装

若项目使用仓颉语言开发鸿蒙应用，建议安装CangjieSkills，提供仓颉语言专业知识支持。

**仓库地址**：https://gitcode.com/Cangjie-SIG/CangjieSkills

**安装命令**：
```bash
# 通用仓颉开发Skills
npx skills add https://gitcode.com/Cangjie-SIG/CangjieSkills.git -a opencode -y

# 鸿蒙应用开发Skills（推荐）
npx skills add https://gitcode.com/Cangjie-SIG/CangjieSkills.git#cangjie-harmonyos -a opencode -y
```

**CangjieSkills列表**：

| 分类 | Skill | 说明 |
|------|-------|------|
| **鸿蒙开发** | cangjie-harmonyos-doc-search | 基于Openviking的鸿蒙开发文档语义检索 |
| | harmonyos-project-init | 从零初始化可运行的仓颉鸿蒙项目模板 |
| | harmonyos-requirements | 鸿蒙需求分析与设计Skill |
| | harmonyos-build | 标准构建与日志采集 |
| | harmonyos-evolution | 沉淀BUILD SUCCESSFUL后的已验证经验 |
| | harmonyos-stdx | 鸿蒙项目stdx依赖自动解压与配置 |
| | harmonyos-app-diagnose | 构建成功后采集截图与控件树、抓取hilog日志 |
| **仓颉语言** | cangjie-lang-features | 仓颉语言核心特性优先参考（语法、类型、泛型、并发等） |
| **互操作** | cangjie_arkts_interop | 仓颉与ArkTS互操作实战（@Interop宏优先） |
| **标准库** | cangjie-std | 仓颉标准库常用功能速查（核心类型、集合、IO、网络等） |
| | cangjie-stdx | 仓颉扩展标准库速查（JSON、日志、HTTP、WebSocket等） |
| **文档兜底** | cangjie-original-docs | 仓颉语言/标准库/扩展标准库/工具链原始文档 |

**安装示例**：
```powershell
# 为OpenCode安装鸿蒙仓颉Skills
npx skills add https://gitcode.com/Cangjie-SIG/CangjieSkills.git#cangjie-harmonyos -a opencode -y

# 为Claude安装鸿蒙仓颉Skills
npx skills add https://gitcode.com/Cangjie-SIG/CangjieSkills.git#cangjie-harmonyos -a claude-code -y
```

**注意事项**：
- 请在全局环境配置好仓颉通用版本工具链，全局可引用cjpm等工具
- 如果项目需要使用stdx，建议手动下载所需版本的stdx并解压到项目根目录

## 验证步骤

### 验证DevEco Studio
1. 打开DevEco Studio
2. 检查SDK路径配置
3. 检查模拟器状态

### 验证DevEco Code
1. 打开DevEco Studio
2. 进入 Settings → Plugins → Installed
3. 确认DevEco Code已安装
4. 创建或打开一个ArkTS文件
5. 测试代码补全功能

### 验证HDC
```bash
# 查看HDC版本
hdc -v

# 列出已连接设备
hdc list targets
```

### 验证构建工具
```bash
# 查看Hvigor版本
node "<DevEco Studio>/tools/hvigor/bin/hvigorw.js" --version
```

### 验证OpenHarmony Skills
```powershell
# 检查Claude skills目录
Get-ChildItem "C:\Users\GLY\.claude\skills" | Where-Object { $_.Name -match "arkts|arkui|ohos" }

# 检查OpenCode skills目录
Get-ChildItem "C:\Users\GLY\.config\opencode\skills" | Where-Object { $_.Name -match "arkts|arkui|ohos" }
```

## 预计时间

- DevEco Studio安装：10-20分钟
- DevEco Code安装：5-10分钟
- SDK下载安装：20-40分钟
- 模拟器配置：10-20分钟
- OpenHarmony Skills安装：5-10分钟
- 完整环境配置：1-2小时

## 注意事项

1. **系统要求**：确保操作系统版本符合要求
2. **磁盘空间**：SDK和模拟器镜像需要大量空间（20GB+）
3. **网络要求**：下载SDK和组件需要稳定的网络连接
4. **国内网络**：如遇GitHub访问问题，使用SteamCommunity302加速
5. **Node.js版本**：确保Node.js版本≥14.18.3
6. **许可证协议**：首次使用模拟器需要接受许可证协议
7. **AI Agent**：配置鸿蒙环境后建议安装OpenHarmony全链路skills

## 常见问题

### 1. DevEco Studio无法启动
- 检查系统版本是否符合要求
- 检查是否安装了必要的依赖
- 以管理员身份运行

### 2. SDK下载失败
- 检查网络连接
- 使用SteamCommunity302加速GitHub
- 配置代理服务器
- 尝试使用国内镜像

### 3. 模拟器启动失败
- 检查VT-x/AMD-V是否在BIOS中启用
- 检查Hyper-V是否冲突
- 尝试使用不同版本的系统镜像

### 4. HDC无法连接设备
- 重启HDC服务：`hdc kill && hdc start`
- 检查USB调试是否启用
- 检查USB驱动是否安装

### 5. 构建失败
- 检查Node.js版本
- 检查项目配置文件
- 清理构建缓存：`hvigorw clean`

### 6. DevEco Code无法使用
- 检查插件是否正确安装
- 重启DevEco Studio
- 检查网络连接（AI模型需要网络）

## 相关资源

- [HarmonyOS开发者官网](https://developer.huawei.com/consumer/cn/harmonyos)
- [DevEco Studio下载](https://developer.huawei.com/consumer/cn/deveco-studio/)
- [HarmonyOS文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides)
- [DevEco CLI工具](deveco-cli) - 使用devecocli命令行工具简化开发流程
- [OpenHarmony Skills](https://github.com/openharmonyinsight/openharmony-skills) - 全链路skills仓库
- [SteamCommunity302](https://steamcommunity.com/chatgroups/) - GitHub加速工具
