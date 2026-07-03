# Feature Specification: WSL Linux 环境配置能力

**Created**: 2026-07-04  
**Status**: Draft  
**Input**: 用户描述："为这个skill文件夹添加使用wsl配置各种linux系统并配置git,python等环境的能力"

## Overview

为现有的 `env-agent-setup` skill 添加 WSL（Windows Subsystem for Linux 2）环境配置能力，使用户能够在 Windows 系统上通过 WSL2 安装和配置各种 Linux 发行版，并在 WSL 内按需配置 Git、Python、Node.js、Java、Rust、Go、C/C++ 等开发环境。同时提供 WSL 与 Windows 宿主机之间的完整互操作配置，包括文件互访、程序互调、端口转发和环境变量共享。

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 安装 WSL2 基础环境 (Priority: P1)

用户在 Windows 上首次使用 WSL，需要启用 WSL2 功能、安装内核更新包、设置默认版本为 WSL2，为后续安装 Linux 发行版做准备。

**Why this priority**: WSL2 基础环境是所有后续操作的前提条件，没有 WSL2 就无法安装任何 Linux 发行版。

**Independent Test**: 可以通过运行 `wsl --status` 和 `wsl --version` 命令验证 WSL2 是否已正确安装和配置。

**Acceptance Scenarios**:

1. **Given** Windows 10 2004+ 或 Windows 11 系统，**When** 用户请求安装 WSL2，**Then** skill 自动检测 Windows 版本、启用 WSL 功能和虚拟机平台、下载安装 WSL2 内核更新包、设置默认版本为 WSL2
2. **Given** WSL2 已安装，**When** 用户再次请求安装 WSL2，**Then** skill 检测到已安装并跳过，提示当前状态
3. **Given** 系统不支持 WSL2（如旧版本 Windows），**When** 用户请求安装 WSL2，**Then** skill 提示版本不满足要求并给出升级建议

---

### User Story 2 - 安装和配置 Linux 发行版 (Priority: P1)

用户已安装 WSL2，需要安装特定的 Linux 发行版（Ubuntu、Debian、CentOS、Arch、openSUSE、Kali、Fedora 等），并进行初始化配置（设置用户名密码、更新系统、配置国内镜像源）。

**Why this priority**: 安装 Linux 发行版是 WSL 使用的核心需求，与 WSL2 基础安装同等重要，两者共同构成最小可用产品。

**Independent Test**: 可以通过 `wsl -l -v` 列出已安装的发行版，通过 `wsl -d <distro>` 进入指定发行版验证。

**Acceptance Scenarios**:

1. **Given** WSL2 已安装且可用，**When** 用户请求安装 Ubuntu，**Then** skill 执行 `wsl --install -d Ubuntu`，等待安装完成，引导用户设置用户名和密码，完成后更新系统并配置国内镜像源
2. **Given** WSL2 已安装，**When** 用户请求安装多个发行版（如 Ubuntu + Debian），**Then** skill 依次安装各发行版，每个安装完成后分别初始化配置
3. **Given** 用户不确定安装哪个发行版，**When** 询问推荐，**Then** skill 列出所有可用发行版及特点说明，推荐 Ubuntu 作为新手首选
4. **Given** 目标发行版已安装，**When** 用户请求再次安装，**Then** skill 检测到已存在并提示，询问是否重新初始化配置

---

### User Story 3 - 在 WSL 内按需配置开发环境 (Priority: P2)

用户已在 WSL 中安装了 Linux 发行版，需要在该发行版内按需配置开发工具，如 Git、Python、Node.js、Java、Rust、Go、C/C++ 等。用户可以自由选择需要配置哪些环境。

**Why this priority**: 开发环境配置是 WSL 使用的核心价值所在，但依赖前两个用户故事的完成。

**Independent Test**: 可以通过在 WSL 中运行 `git --version`、`python3 --version` 等命令逐一验证已安装的开发工具。

**Acceptance Scenarios**:

1. **Given** WSL 中已安装 Ubuntu，**When** 用户选择配置 Git 和 Python，**Then** skill 在 WSL 内执行 `sudo apt install git python3 python3-pip`，配置 Git 用户信息，配置 pip 国内镜像源，验证安装结果
2. **Given** WSL 中已安装 CentOS，**When** 用户选择配置全套开发环境，**Then** skill 在 WSL 内使用 yum/dnf 逐个安装所有开发工具，每个工具安装后验证
3. **Given** 用户未指定具体环境，**When** 进入配置流程，**Then** skill 提供交互式选择列表，列出所有可用环境供用户勾选
4. **Given** WSL 内某工具已安装，**When** 用户请求配置该工具，**Then** skill 检测已有版本，提示是否升级或重新配置

---

### User Story 4 - 配置 WSL 与 Windows 宿主机互操作 (Priority: P2)

用户需要 WSL 与 Windows 之间无缝协作，包括从 Windows 访问 WSL 文件（`\\wsl$`）、从 WSL 访问 Windows 文件（`/mnt/c`）、WSL 调用 Windows 程序、端口自动转发、环境变量共享等。

**Why this priority**: 互操作配置显著提升 WSL 使用体验，是 WSL2 的核心优势之一，但属于增强功能。

**Independent Test**: 可以通过在 WSL 中运行 `explorer.exe .` 打开 Windows 资源管理器，在 Windows 中访问 `\\wsl$\<distro>` 路径，或在 WSL 中访问 `/mnt/c/Users` 来验证。

**Acceptance Scenarios**:

1. **Given** WSL2 已安装并运行，**When** 用户请求配置互操作，**Then** skill 配置 `/etc/wsl.conf` 启用互操作功能（interop enabled=true）、自动挂载 Windows 磁盘（mount 磁盘到 /mnt）、配置 appendWindowsPath 使 Windows PATH 可在 WSL 中使用
2. **Given** 互操作已配置，**When** 用户需要端口转发，**Then** skill 确认 WSL2 的 localhost 转发已启用（默认行为），说明如何从 Windows 访问 WSL 中的服务
3. **Given** 互操作已配置，**When** 用户需要在 WSL 中调用 Windows 程序，**Then** skill 验证 `notepad.exe`、`explorer.exe` 等可在 WSL 中直接调用

---

### User Story 5 - WSL 实例管理与维护 (Priority: P3)

用户需要管理多个 WSL 实例，包括查看已安装发行版列表、设置默认发行版、启动/停止实例、导出/导入备份、卸载发行版等运维操作。

**Why this priority**: 管理维护功能提升了长期使用体验，但不是初始搭建的核心路径。

**Independent Test**: 可以通过 `wsl -l -v` 验证列表操作，通过 `wsl --export`/`wsl --import` 验证备份恢复功能。

**Acceptance Scenarios**:

1. **Given** 已安装多个 WSL 发行版，**When** 用户请求查看状态，**Then** skill 执行 `wsl -l -v` 并格式化展示各发行版的名称、状态和 WSL 版本
2. **Given** 已安装多个发行版，**When** 用户请求设置默认发行版，**Then** skill 执行 `wsl --set-default <distro>` 并验证
3. **Given** 用户需要备份发行版，**When** 请求导出，**Then** skill 执行 `wsl --export <distro> <filename.tar>` 导出为 tar 文件
4. **Given** 用户需要恢复备份，**When** 请求导入，**Then** skill 执行 `wsl --import <distro> <install-location> <filename.tar>` 从 tar 文件恢复

---

### Edge Cases

- Windows 系统版本低于 WSL2 最低要求（Windows 10 1903/内部版本 18362）时如何处理？
- 企业版 Windows 中 WSL 功能被组策略禁用时如何处理？
- WSL 安装过程中网络中断导致安装不完整时如何恢复？
- 磁盘空间不足以安装发行版时如何检测和提示？
- BIOS 中虚拟化（VT-x/AMD-V）未启用时 WSL2 无法启动如何处理？
- 在 WSL 内配置开发环境时 sudo 需要密码但用户未设置时如何处理？
- 多个 WSL 实例同时运行导致内存占用过高时如何优化（.wslconfig 配置）？
- CentOS 在 WSL 中没有官方 Microsoft Store 版本时如何通过导入方式安装？

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Skill MUST 能够检测当前 Windows 系统是否满足 WSL2 安装条件（版本、虚拟化支持）
- **FR-002**: Skill MUST 能够自动启用 Windows 的 WSL 功能和虚拟机平台功能
- **FR-003**: Skill MUST 能够下载并安装 WSL2 Linux 内核更新包
- **FR-004**: Skill MUST 能够设置 WSL 默认版本为 WSL2
- **FR-005**: Skill MUST 支持安装 Microsoft Store 中所有官方可用的 Linux 发行版（Ubuntu、Debian、CentOS、Arch、openSUSE、Kali、Fedora 等）
- **FR-006**: Skill MUST 支持通过导入方式安装非 Store 发行版（如 CentOS 通过 tar 文件导入）
- **FR-007**: Skill MUST 能够对已安装的发行版进行初始化配置（创建用户、更新系统、配置镜像源）
- **FR-008**: Skill MUST 提供交互式环境选择功能，让用户自由选择需要配置的开发环境（Git、Python、Node.js、Java、Rust、Go、C/C++ 等）
- **FR-009**: Skill MUST 根据不同 Linux 发行版使用对应的包管理器（apt/yum/dnf/pacman/zypper）安装开发工具
- **FR-010**: Skill MUST 能够在 WSL 内配置 Git（安装、设置 user.name/user.email、配置 SSH 密钥）
- **FR-011**: Skill MUST 能够在 WSL 内配置 Python（安装 Python3、pip、配置国内镜像源、安装 virtualenv/venv）
- **FR-012**: Skill MUST 能够在 WSL 内配置 Node.js（通过 nvm/fnm 安装、配置 npm 镜像源）
- **FR-013**: Skill MUST 能够在 WSL 内配置 Java（安装 JDK、配置 JAVA_HOME）
- **FR-014**: Skill MUST 能够在 WSL 内配置 Rust（通过 rustup 安装、配置 Cargo 镜像源）
- **FR-015**: Skill MUST 能够在 WSL 内配置 Go（安装、配置 GOPATH 和 goproxy 镜像）
- **FR-016**: Skill MUST 能够在 WSL 内配置 C/C++ 开发环境（安装 gcc/g++、cmake、make）
- **FR-017**: Skill MUST 能够配置 WSL 与 Windows 的互操作（/etc/wsl.conf 配置 interop、automount、appendWindowsPath）
- **FR-018**: Skill MUST 能够验证 Windows 与 WSL 的文件互访功能（`\\wsl$` 和 `/mnt/` 路径）
- **FR-019**: Skill MUST 能够验证 WSL 中调用 Windows 程序的功能
- **FR-020**: Skill MUST 能够确认 WSL2 的 localhost 端口转发功能正常工作
- **FR-021**: Skill MUST 提供环境检测功能，检测已安装的 WSL 发行版及其内部已配置的开发工具
- **FR-022**: Skill MUST 支持 WSL 实例管理操作（查看列表、设置默认、启动/停止、导出/导入、卸载）
- **FR-023**: Skill MUST 为国内网络环境优化，在 WSL 内配置国内镜像源（apt/pip/npm/cargo/go 等镜像）
- **FR-024**: Skill MUST 支持配置 `.wslconfig` 文件控制 WSL2 资源使用（内存、处理器数量、交换空间）
- **FR-025**: Skill MUST 在关键操作前进行安全检查（磁盘空间、权限、系统兼容性）

### Key Entities

- **WSL2 环境**: WSL2 运行时环境，包括 WSL 功能状态、内核版本、默认版本设置
- **Linux 发行版实例**: WSL 中安装的 Linux 发行版，包括名称、状态（运行/停止）、WSL 版本、安装位置
- **开发环境配置**: 在 WSL 内配置的开发工具集合，包括工具名称、版本、安装路径、配置状态
- **互操作配置**: WSL 与 Windows 之间的互操作设置，包括 wsl.conf 配置项、文件挂载状态、PATH 共享状态
- **镜像源配置**: 国内镜像源配置信息，包括各包管理器的镜像源地址和配置文件路径

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 用户能在 5 分钟内完成 WSL2 基础环境安装和验证（不含下载时间）
- **SC-002**: 用户能在 3 步操作内安装任意官方支持的 Linux 发行版并完成初始化配置
- **SC-003**: 用户选择开发环境后，每个工具的安装和配置在 3 分钟内自动完成（不含下载时间）
- **SC-004**: 95% 以上的首次配置用户能成功验证 WSL 与 Windows 的互操作功能
- **SC-005**: 国内用户在 WSL 内配置的所有包管理器均使用国内镜像源，下载速度提升 5 倍以上
- **SC-006**: 用户能在 2 分钟内完成 WSL 实例的备份导出或恢复导入操作

## Assumptions

- 目标系统为 Windows 10 版本 2004+（内部版本 19041+）或 Windows 11，支持 WSL2
- 用户具有 Windows 管理员权限以启用 WSL 功能
- 用户的 BIOS/UEFI 中已启用虚拟化支持（Intel VT-x 或 AMD-V）
- 用户有可用的网络连接下载 WSL 组件和 Linux 发行版
- 国内网络环境下用户可能需要 SteamCommunity302 或代理来访问部分国外资源
- WSL2 的 localhost 转发功能在 Windows 10 1903+ 和 Windows 11 中默认启用
- CentOS 在 Microsoft Store 中无官方版本，需要通过 GitHub 上的社区 tar 文件导入安装
- 对于需要 GUI 应用的场景，假设用户使用 WSLg（Windows 11 内置，Windows 10 需额外配置）

## Open Questions

- 是否需要支持 WSLg（WSL GUI 应用）的配置？WSLg 在 Windows 11 中默认可用，但在 Windows 10 中需要额外步骤
- 是否需要支持 Docker Desktop 集成 WSL2 后端的配置？这是常见的 WSL2 使用场景
- 是否需要支持 WSL 内的 SSH 服务配置，以便从其他机器远程访问 WSL 实例？
