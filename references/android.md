# Android 开发环境配置指南

## 环境概述

Android开发环境用于开发Android移动应用程序。主要包括Java/Kotlin开发工具、Android SDK、构建工具和模拟器。

## 系统要求

- **操作系统**：Windows 10/11 (64-bit)、macOS 10.14+、Linux (64-bit)
- **内存**：最低8GB，推荐16GB
- **磁盘空间**：至少10GB可用空间
- **网络**：需要网络连接下载SDK和工具

## 需要安装的组件

| 组件 | 版本 | 用途 | 安装方式 |
|------|------|------|---------|
| Java JDK | 17 | Android编译环境 | Chocolatey/Homebrew/apt |
| Android SDK | 最新 | Android开发工具包 | 命令行工具 |
| Android Build Tools | 35.0.0 | 构建Android应用 | sdkmanager |
| Android Platform | Android 15 | 目标平台 | sdkmanager |
| Android Emulator | 最新 | 模拟器 | sdkmanager |
| System Image | 最新 | 模拟器系统镜像 | sdkmanager |
| Gradle | 8.0+ | 构建工具 | 项目自带 |

## 安装步骤

### 步骤1：安装Java JDK

#### Windows (Chocolatey)
```powershell
# 以管理员身份运行
choco install temurin17 -y
```

#### macOS (Homebrew)
```bash
brew install openjdk@17
```

#### Linux (apt)
```bash
sudo apt update
sudo apt install openjdk-17-jdk
```

### 步骤2：配置JAVA_HOME

#### Windows
```powershell
# 检查Java安装路径
java -version

# 设置JAVA_HOME（根据实际安装路径）
[System.Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Program Files\Eclipse Adoptium\jdk-17.0.2.8-hotspot", "Machine")
```

#### macOS/Linux
```bash
# 添加到 ~/.bashrc 或 ~/.zshrc
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
export PATH=$JAVA_HOME/bin:$PATH
```

### 步骤3：下载Android SDK命令行工具

#### Windows
```powershell
# 创建目录
New-Item -ItemType Directory -Path "D:\Android\Sdk\cmdline-tools" -Force

# 下载命令行工具
$url = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
$zip = "$env:TEMP\cmdline-tools.zip"
(New-Object System.Net.WebClient).DownloadFile($url, $zip)

# 解压
Expand-Archive -Path $zip -DestinationPath "$env:TEMP\cmdline-tools" -Force
Move-Item "$env:TEMP\cmdline-tools\cmdline-tools\latest" "D:\Android\Sdk\cmdline-tools\latest" -Force
```

#### macOS
```bash
# 创建目录
mkdir -p ~/Library/Android/sdk/cmdline-tools

# 下载命令行工具
cd ~/Library/Android/sdk/cmdline-tools
curl -O https://dl.google.com/android/repository/commandlinetools-mac-11076708_latest.zip
unzip commandlinetools-mac-11076708_latest.zip
mv cmdline-tools latest
```

#### Linux
```bash
# 创建目录
mkdir -p ~/Android/Sdk/cmdline-tools

# 下载命令行工具
cd ~/Android/Sdk/cmdline-tools
wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
unzip commandlinetools-linux-11076708_latest.zip
mv cmdline-tools latest
```

### 步骤4：配置环境变量

#### Windows
```powershell
# 设置ANDROID_HOME
[System.Environment]::SetEnvironmentVariable("ANDROID_HOME", "D:\Android\Sdk", "Machine")

# 添加到PATH
$machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
$androidPaths = @(
    "D:\Android\Sdk\platform-tools",
    "D:\Android\Sdk\cmdline-tools\latest\bin",
    "D:\Android\Sdk\build-tools\35.0.0",
    "D:\Android\Sdk\emulator"
)
foreach ($p in $androidPaths) {
    if ($machinePath -notlike "*$p*") {
        $machinePath = "$machinePath;$p"
    }
}
[System.Environment]::SetEnvironmentVariable("Path", $machinePath, "Machine")
```

#### macOS/Linux
```bash
# 添加到 ~/.bashrc 或 ~/.zshrc
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/build-tools/35.0.0:$ANDROID_HOME/emulator:$PATH
```

### 步骤5：接受许可证

```bash
# Windows
sdkmanager --licenses

# macOS/Linux
~/Library/Android/sdk/cmdline-tools/latest/bin/sdkmanager --licenses
```

### 步骤6：安装Android SDK组件

```bash
# 安装必要组件
sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0" "emulator" "system-images;android-35;google_apis;x86_64"
```

### 步骤7：创建Android虚拟设备（AVD）

```bash
# 创建AVD
avdmanager create avd -n Pixel_6 -k "system-images;android-35;google_apis;x86_64" -d "pixel_6"

# 启动模拟器
emulator -avd Pixel_6
```

## 配置步骤

### Android Studio（可选）

如果需要Android Studio，可以从官网下载安装：
https://developer.android.com/studio

### Gradle配置

在项目根目录的 `gradle.properties` 中配置：
```properties
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
android.nonTransitiveRClass=true
```

## 验证步骤

### 验证Java
```bash
java -version
javac -version
echo $JAVA_HOME
```

### 验证Android SDK
```bash
sdkmanager --version
adb --version
emulator -version
```

### 验证环境变量
```bash
# Windows
echo %ANDROID_HOME%
echo %JAVA_HOME%

# macOS/Linux
echo $ANDROID_HOME
echo $JAVA_HOME
```

## 预计时间

- 基础安装：15-30分钟
- 完整安装（含SDK和模拟器）：30-60分钟
- 首次下载系统镜像：10-30分钟（取决于网络）

## 注意事项

1. **磁盘空间**：Android SDK和模拟器镜像需要大量磁盘空间（10GB+）
2. **网络要求**：下载SDK和组件需要稳定的网络连接
3. **代理配置**：如果在国内，建议配置镜像源加速下载
4. **版本兼容**：确保JDK版本与Android Gradle插件兼容
5. **环境变量**：修改环境变量后需要重启终端或IDE

## 常见问题

### 1. sdkmanager命令找不到
- 检查命令行工具是否正确安装
- 检查PATH环境变量是否包含cmdline-tools/latest/bin

### 2. 模拟器启动失败
- 检查VT-x/AMD-V是否在BIOS中启用
- 检查Hyper-V是否与Android模拟器冲突
- 尝试使用不同版本的系统镜像

### 3. Gradle同步失败
- 检查网络连接
- 配置国内镜像源
- 检查JAVA_HOME配置

### 4. ADB设备无法连接
- 重启adb服务：`adb kill-server && adb start-server`
- 检查USB调试是否启用
- 检查USB驱动是否安装
