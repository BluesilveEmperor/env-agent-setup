# 开发环境与AI Agent配置助手 (env-agent-setup)

一个用于自动配置开发环境和AI Agent的opencode skill。

## 功能特性

- **环境类型识别**：根据用户输入自动识别目标开发环境类型
- **AI Agent配置**：支持配置claude-code、opencode、hermes、deveco-code、openclaw等AI Agent
- **环境检测**：检测当前系统已安装的工具、AI Agent和OpenHarmony skills
- **配置方案生成**：根据检测结果生成详细的配置方案
- **自动配置**：用户确认后自动执行配置步骤
- **国内网络优化**：优先使用国内镜像源，支持SteamCommunity302加速GitHub
- **鸿蒙全链路**：配置鸿蒙环境时自动检测AI Agent并安装OpenHarmony全链路skills

## 支持的环境类型

- Android
- HarmonyOS（含DevEco Code、OpenHarmony Skills）
- iOS
- Web前端
- Python
- Java
- C/C++
- Rust
- Go
- Node.js
- AI Agent（claude-code、opencode、hermes、deveco-code、openclaw）

## 触发关键词

当用户提到以下关键词时，skill会自动触发：

- "配置开发环境"
- "搭建开发环境"
- "setup development environment"
- "安装开发工具"
- "配置编程环境"
- "安装SDK"
- "配置IDE"
- "开发环境搭建"
- "配置AI Agent"
- "安装claude-code"
- "配置opencode"
- "安装hermes"
- "配置deveco-code"
- "安装openclaw"

## 示例对话

**用户**：帮我配置一个Python开发环境

**助手**：我来帮你配置Python开发环境。首先让我检测一下你当前的系统环境...

**用户**：帮我配置鸿蒙开发环境

**助手**：好的，我来为你配置鸿蒙开发环境。让我先检测一下当前系统...
检测到已安装的AI Agent：claude, opencode
正在安装OpenHarmony全链路skills...

## 工作流程

1. **环境类型识别**：分析用户输入，识别目标环境
2. **环境检测**：检测当前系统已安装的工具
3. **AI Agent检测**（鸿蒙环境）：检测本地已安装的AI Agent
4. **配置方案生成**：生成详细的配置方案
5. **用户确认**：等待用户确认方案
6. **执行配置**：自动执行配置步骤
7. **Skills安装**（鸿蒙环境）：在AI Agent的skills目录安装OpenHarmony全链路skills
8. **验证结果**：验证配置是否成功

## 国内网络环境

本skill针对国内网络环境进行了优化：

### GitHub访问解决方案

如遇GitHub访问问题，可使用SteamCommunity302加速：
- 下载地址：https://steamcommunity.com/chatgroups/
- 安装后启用"加速GitHub"功能

### 国内镜像源

| 工具 | 镜像源 |
|------|--------|
| npm | https://registry.npmmirror.com |
| pip | https://pypi.tuna.tsinghua.edu.cn/simple |
| Go | https://goproxy.cn |

## OpenHarmony Skills

配置鸿蒙开发环境时，会自动安装以下全链路skills：

| 类别 | Skills |
|------|--------|
| **ArkTS** | arkts-sta-playground, arkts-static-spec, openharmony-arkts-layer |
| **ArkUI** | arkui-api-design, arkui-menu-debug, arkuix-module-adapter |
| **DFX** | ohos-issue-graphics-cppcrash-analysis, ohos-issue-graphics-sysfreeze-analysis, oh-memory-leak-detection |
| **构建** | build-error-analyzer, compile-analysis, openharmony-build |
| **代码检查** | code-checker, code-problem-analyzer, comprehensive-code-review |

## Cangjie（仓颉）Skills

若项目使用仓颉语言开发鸿蒙应用，会自动安装CangjieSkills：

**仓库来源**：https://gitcode.com/Cangjie-SIG/CangjieSkills

| 类别 | Skills |
|------|--------|
| **鸿蒙开发** | cangjie-harmonyos-doc-search, harmonyos-project-init, harmonyos-requirements |
| **构建调试** | harmonyos-build, harmonyos-evolution, harmonyos-app-diagnose |
| **仓颉语言** | cangjie-lang-features, cangjie_arkts_interop |
| **标准库** | cangjie-std, cangjie-stdx, cangjie-original-docs |

## 目录结构

```
env-agent-setup/
├── SKILL.md                    # 主文件
├── README.md                   # 使用说明
├── references/                 # 参考文档
│   ├── android.md             # Android配置指南
│   ├── harmonyos.md           # HarmonyOS配置指南
│   ├── ai-agents.md           # AI Agent配置指南
│   ├── ohos-skills-install.md # OpenHarmony Skills安装指南
│   ├── python.md              # Python配置指南
│   ├── nodejs.md              # Node.js配置指南
│   ├── java.md                # Java配置指南
│   ├── cpp.md                 # C/C++配置指南
│   ├── rust.md                # Rust配置指南
│   ├── go.md                  # Go配置指南
│   ├── web-frontend.md        # Web前端配置指南
│   ├── ios.md                 # iOS配置指南
│   └── common.md              # 通用原则
├── scripts/                   # 脚本目录
│   └── detect-env.ps1         # Windows环境检测脚本
└── evals/                     # 测试用例
    └── evals.json
```

## 错误处理策略

skill会根据实际环境灵活处理错误：

1. **网络错误**：自动重试、提供镜像源、使用SteamCommunity302加速GitHub
2. **权限错误**：提示以管理员身份运行
3. **依赖错误**：自动安装缺失的依赖
4. **版本错误**：推荐兼容版本
5. **配置错误**：自动修复常见问题
6. **磁盘错误**：提示清理磁盘空间

## 注意事项

1. 部分操作需要管理员权限
2. 下载SDK和工具需要网络连接
3. 国内网络优先使用镜像源
4. GitHub访问问题可使用SteamCommunity302
5. 配置完成后可能需要重启终端
6. 鸿蒙环境配置会自动检测AI Agent并安装skills

## 相关skill

- **deveco-cli**: HarmonyOS开发工具链
- **deveco-studio-emulator**: HarmonyOS模拟器管理
- **deveco-studio-hvigor**: HarmonyOS构建工具
- **openharmony-skills**: OpenHarmony全链路skills仓库

## 许可证

MIT License
