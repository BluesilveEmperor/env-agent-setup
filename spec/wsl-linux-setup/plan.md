# Implementation Plan: WSL Linux 环境配置能力

**Input**: Feature specification from `spec/wsl-linux-setup/spec.md`

## Summary

为现有 `env-agent-setup` skill 添加 WSL2 Linux 环境配置能力。用户可以在 Windows 上通过 WSL2 安装各种 Linux 发行版（Ubuntu、Debian、CentOS、Arch、openSUSE、Kali、Fedora 等），按需配置开发环境（Git、Python、Node.js、Java、Rust、Go、C/C++），并实现 WSL 与 Windows 之间的完整互操作。额外支持 WSLg GUI 应用、Docker Desktop WSL2 后端集成、WSL 内 SSH 服务配置。所有配置均针对国内网络环境优化。

## Technical Context

**Language/Version**: Markdown 文档 + PowerShell 5.1 脚本（与现有 skill 一致）
**Primary Dependencies**: Windows WSL2 命令行工具（`wsl.exe`）、PowerShell、各 Linux 发行版包管理器
**Storage**: 文件系统（`/etc/wsl.conf`、`%USERPROFILE%/.wslconfig`、各镜像源配置文件）
**Testing**: 手动验证 + PowerShell 检测脚本
**Target Platform**: Windows 10 19041+ / Windows 11（仅 WSL2）
**Project Type**: Skill 文档和配置脚本（与现有项目类型一致）
**Performance Goals**: WSL2 安装和初始化在 5 分钟内完成（不含下载）
**Constraints**: 需要管理员权限、需要虚拟化支持、国内网络优化
**Scale/Scope**: 支持所有 Microsoft Store 官方 WSL 发行版 + 导入式安装，8+ 种开发环境配置

## Project Structure

### Documentation (this feature)

```text
spec/wsl-linux-setup/
├── spec.md              # Feature specification
├── plan.md              # This file
└── tasks.md             # Task breakdown (to be generated)
```

### Source Code (repository root)

```text
env-agent-setup/
├── SKILL.md                        # 主文档（需更新：添加 WSL 识别和导航）
├── references/
│   ├── ai-agents.md                # 已有，不需改动
│   ├── android.md                  # 已有，不需改动
│   ├── common.md                   # 已有，需更新：添加 WSL 相关通用配置
│   ├── harmonyos.md                # 已有，不需改动
│   ├── nodejs.md                   # 已有，不需改动
│   ├── ohos-skills-install.md      # 已有，不需改动
│   ├── python.md                   # 已有，不需改动
│   ├── wsl-setup.md                # 【新增】WSL2 基础安装与发行版配置指南
│   ├── wsl-dev-env.md              # 【新增】WSL 内开发环境配置指南
│   ├── wsl-interop.md              # 【新增】WSL 与 Windows 互操作配置指南
│   ├── wsl-advanced.md             # 【新增】WSLg/Docker/SSH 高级功能配置指南
│   └── wsl-management.md           # 【新增】WSL 实例管理与维护指南
├── scripts/
│   ├── detect-env.ps1              # 已有，需更新：添加 WSL 检测函数
│   ├── push.ps1                    # 已有，不需改动
│   ├── setup-wsl.ps1               # 【新增】WSL2 一键安装与配置脚本
│   └── setup-wsl-dev-env.ps1       # 【新增】WSL 内开发环境一键配置脚本
└── evals/
    └── evals.json                  # 已有，需更新：添加 WSL 相关评测用例
```

**Structure Decision**: 在现有 skill 的 `references/` 目录下新增 5 个 WSL 专题文档，在 `scripts/` 目录下新增 2 个配置脚本，同时更新 `SKILL.md`、`common.md`、`detect-env.ps1`、`evals.json` 四个已有文件。这种增量式扩展方式与现有项目结构完全一致，不会破坏已有功能。

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| 5 个新参考文档而非 1 个合并文档 | WSL 功能覆盖面广（安装/开发环境/互操作/高级/管理），合并会导致单文件过长（800+ 行），不符合现有每个 references 文件 200-300 行的模式 | 单文件合并方案可读性差，难以维护 |

## Research & Decisions

### Decision 1: WSL2 安装方式选择

- **Decision**: 优先使用 `wsl --install` 一键安装命令（Windows 10 19044+ / Windows 11），对旧版本使用分步启用方式
- **Rationale**: `wsl --install` 是微软官方推荐方式，自动启用所需功能并安装默认 Ubuntu；分步方式作为兼容回退方案
- **Alternatives considered**: 纯手动分步启用（用户体验差）、仅支持 `wsl --install`（旧版本不兼容）

### Decision 2: CentOS 安装策略

- **Decision**: 使用 GitHub 社区提供的 CentOS rootfs tar 文件通过 `wsl --import` 导入安装
- **Rationale**: CentOS 在 Microsoft Store 无官方发行版，社区 tar 文件是目前最成熟的方案
- **Alternatives considered**: 使用 Docker 导出（步骤多且需 Docker）、使用第三方 Store 版本（不可靠）

### Decision 3: WSL 内开发环境安装方式

- **Decision**: 根据发行版自动选择包管理器（apt/yum/dnf/pacman/zypper），对特定工具使用官方安装器（nvm/fnm、rustup、Go 官方 tar）
- **Rationale**: 不同发行版包管理器不同，直接使用包管理器安装最稳定；但某些工具（如 Node.js、Rust）官方推荐使用版本管理器安装
- **Alternatives considered**: 全部使用包管理器安装（版本过旧）、全部使用官方安装器（部分发行版不兼容）

### Decision 4: 国内镜像源配置策略

- **Decision**: 在 WSL 内为每个发行版和每个工具都配置国内镜像源，与现有 skill 的国内优化策略一致
- **Rationale**: 国内用户下载速度是关键痛点，为 apt/pip/npm/cargo/go 等统一配置镜像源
- **Alternatives considered**: 仅配置系统级镜像源（工具级下载仍然慢）、使用代理（需要额外配置）

### Decision 5: WSL 内执行命令的方式

- **Decision**: 从 Windows PowerShell 使用 `wsl -d <distro> -- <command>` 方式在指定发行版内执行命令
- **Rationale**: skill 运行在 Windows PowerShell 环境中，需要从 Windows 端远程执行 WSL 内命令；`wsl -d` 可指定目标发行版
- **Alternatives considered**: 让用户手动进入 WSL 执行（不是自动化）、使用 SSH 连接 WSL（需要先配置 SSH，循环依赖）

### Decision 6: Docker Desktop WSL2 后端集成

- **Decision**: 引导用户安装 Docker Desktop 并在 Settings > General 中勾选 "Use the WSL 2 based engine"，然后在 Resources > WSL Integration 中启用对应发行版
- **Rationale**: Docker Desktop 官方支持 WSL2 后端，配置简单且性能优秀
- **Alternatives considered**: 在 WSL 内直接安装 Docker Engine（需 systemd 支持，配置复杂）

### Decision 7: WSLg 配置策略

- **Decision**: Windows 11 用户 WSLg 默认可用无需额外配置；Windows 10 用户引导安装 WSLg 补丁包并验证 GUI 功能
- **Rationale**: WSLg 在 Windows 11 21H2+ 中已内置，仅在 Windows 10 场景需要额外步骤
- **Alternatives considered**: 不区分版本统一安装补丁（Windows 11 用户无需此步骤）、使用第三方 X Server（体验不如 WSLg）

### Decision 8: WSL 内 SSH 服务配置

- **Decision**: 在 WSL 内安装 openssh-server，配置端口（默认 22 或用户指定），配置密钥认证，并说明 Windows 端端口转发设置
- **Rationale**: SSH 服务便于远程访问和 IDE 集成（如 VS Code Remote-SSH），是常见开发需求
- **Alternatives considered**: 使用 Windows OpenSSH（不运行在 WSL 环境）、不配置 SSH（限制了远程开发场景）

## Data Model

### WSL 环境状态数据

```text
WSLStatus {
  wsl_installed: boolean           // WSL 功能是否已启用
  wsl_default_version: number      // 默认 WSL 版本（1 或 2）
  wsl_kernel_updated: boolean      // WSL2 内核是否已更新
  windows_version: string          // Windows 版本号（如 10.0.19045）
  virtualization_enabled: boolean  // 虚拟化是否启用
  distros: WSLDistro[]             // 已安装的发行版列表
  wslg_available: boolean          // WSLg 是否可用
  docker_desktop_integrated: boolean  // Docker Desktop 是否已集成 WSL2
}

WSLDistro {
  name: string                     // 发行版名称（如 Ubuntu、Debian）
  state: "Running" | "Stopped" | "Installing"  // 运行状态
  wsl_version: number              // WSL 版本（1 或 2）
  default: boolean                 // 是否为默认发行版
  package_manager: string          // 包管理器类型（apt/yum/dnf/pacman/zypper）
  dev_envs: DevEnv[]               // 已配置的开发环境列表
  mirror_configured: boolean       // 是否已配置国内镜像源
  interop_enabled: boolean         // 互操作是否启用
}

DevEnv {
  name: string                     // 环境名称（如 git、python、nodejs）
  installed: boolean               // 是否已安装
  version: string                  // 安装版本
  mirror_configured: boolean       // 是否已配置镜像源
  verified: boolean                // 是否已验证可用
}
```

### 支持的发行版映射

```text
DistroConfig {
  name: string                     // WSL 注册名称
  store_name: string               // Microsoft Store 安装名
  package_manager: string          // 主包管理器
  install_method: "store" | "import"  // 安装方式
  import_source: string?           // 导入源（仅 import 方式）
  mirror_template: string          // 镜像源配置模板
  init_commands: string[]          // 初始化命令
}

支持列表：
- Ubuntu         → store, apt
- Ubuntu-20.04   → store, apt
- Ubuntu-22.04   → store, apt
- Ubuntu-24.04   → store, apt
- Debian         → store, apt
- openSUSE-Leap  → store, zypper
- SLES           → store, zypper
- Kali-Linux     → store, apt
- Archlinux      → store, pacman
- Fedora         → store, dnf
- CentOS         → import, yum (从 GitHub tar 导入)
```

### 开发环境配置映射

```text
DevEnvConfig {
  name: string                     // 环境标识
  display_name: string             // 显示名称
  description: string              // 描述
  packages: map<package_manager, string[]>  // 各包管理器的安装包名
  post_install: map<package_manager, string[]>  // 安装后配置命令
  mirror_config: MirrorConfig?     // 镜像源配置
  verify_commands: string[]        // 验证命令
}

支持列表：
- git      → apt/yum/dnf/pacman/zypper, 配置 user.name/email, SSH 密钥
- python   → apt/yum/dnf/pacman/zypper, pip + 清华/阿里云镜像
- nodejs   → nvm/fnm 安装, npm 镜像源
- java     → apt/yum/dnf/pacman/zypper, JAVA_HOME
- rust     → rustup, Cargo 中科大镜像
- go       → 官方 tar 安装, goproxy.cn
- cpp      → apt/yum/dnf/pacman/zypper (gcc/g++/cmake/make)
- docker   → Docker Desktop WSL2 后端
```

## Contracts & Interfaces

### SKILL.md 新增内容接口

SKILL.md 需要在以下位置新增 WSL 相关内容：
1. **快速导航表**：新增 WSL 行
2. **环境类型识别规则表**：新增 WSL 类型行（关键词：WSL、Linux、Ubuntu、子系统、Subsystem）
3. **各环境详细指南表**：新增 5 行 WSL 参考文档链接
4. **检查清单**：新增 WSL 相关检查项

### detect-env.ps1 新增检测函数接口

```text
function Test-WSLEnvironment {
  返回: @{
    environment = "wsl"
    detected = boolean
    components = @(
      @{ name = "WSL"; installed; version; status }
      @{ name = "WSL2 Kernel"; installed; version; status }
      @{ name = "WSLg"; installed; version; status }
      @{ name = "Docker Desktop WSL2"; installed; version; status }
    )
    distros = @(
      @{ name; state; wsl_version; default; package_manager }
    )
    environment_variables = @{
      WSL_DISTRO_NAME = string?
    }
  }
}
```

### setup-wsl.ps1 脚本接口

```text
参数:
  -Action: "install" | "install-distro" | "init-distro" | "configure-interop" | "status"
  -Distro: string (发行版名称，如 Ubuntu、Debian)
  -InstallLocation: string (安装位置，可选)
  -NoMirror: switch (不配置镜像源)

功能:
  install:         安装 WSL2 基础环境
  install-distro:  安装指定发行版
  init-distro:     初始化已安装的发行版（更新系统、配置镜像源、创建用户）
  configure-interop: 配置 WSL 与 Windows 互操作
  status:          显示 WSL 状态信息
```

### setup-wsl-dev-env.ps1 脚本接口

```text
参数:
  -Distro: string (目标发行版名称)
  -Environments: string[] (要配置的开发环境列表: git,python,nodejs,java,rust,cpp,go)
  -All: switch (配置所有开发环境)
  -SkipMirror: switch (跳过镜像源配置)
  -SkipVerify: switch (跳过验证)

功能:
  根据用户选择的环境列表，在指定 WSL 发行版内安装和配置开发工具
  自动检测发行版的包管理器并选择正确的安装命令
  每个环境安装后自动验证
  生成配置结果报告
```

### wsl.conf 配置模板

```text
[boot]
systemd=true|false                    # 是否启用 systemd

[interop]
enabled=true                          # 启用互操作
appendWindowsPath=true                # Windows PATH 追加到 WSL PATH

[automount]
enabled=true                          # 自动挂载 Windows 磁盘
mountFsTab=true                       # 使用 /etc/fstab 配置
root=/mnt/                            # 挂载根目录
options="metadata,umask=22,fmask=11"  # 挂载选项（启用权限支持）

[network]
generateResolvConf=true               # 自动生成 DNS 配置
```

### .wslconfig 配置模板

```text
[wsl2]
memory=8GB           # WSL2 最大内存
processors=4         # 处理器数量
swap=2GB             # 交换空间大小
localhostForwarding=true  # localhost 端口转发

[experimental]
autoMemoryReclaim=gradual  # 自动内存回收
sparseVhd=true             # 磁盘空间自动回收
```
