<#
.SYNOPSIS
    开发环境与AI Agent检测脚本
.DESCRIPTION
    检测当前系统已安装的开发工具、AI Agent和OpenHarmony skills
.PARAMETER Environment
    要检测的环境类型：android, harmonyos, ios, python, java, nodejs, rust, go, cpp, web, ai-agent, ohos-skills, wsl, all
.EXAMPLE
    .\detect-env.ps1 -Environment android
    .\detect-env.ps1 -Environment ai-agent
    .\detect-env.ps1 -Environment ohos-skills
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("android", "harmonyos", "ios", "python", "java", "nodejs", "rust", "go", "cpp", "web", "ai-agent", "ohos-skills", "wsl", "all")]
    [string]$Environment
)

$ErrorActionPreference = "SilentlyContinue"

# 检测函数
function Test-Command {
    param([string]$Command)
    try {
        $null = Get-Command $Command -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

function Get-CommandVersion {
    param([string]$Command)
    try {
        $version = & $Command --version 2>&1 | Select-Object -First 1
        return $version
    } catch {
        return $null
    }
}

function Test-EnvironmentVariable {
    param([string]$Variable)
    return [System.Environment]::GetEnvironmentVariable($Variable, "Machine")
}

# 检测AI Agent环境
function Test-AIAgentEnvironment {
    $result = @{
        environment = "ai-agent"
        detected = $false
        components = @()
        installed_agents = @()
        skills_directories = @{}
    }

    # 检测Claude
    $claudeInstalled = Test-Command "claude"
    $claudeVersion = if ($claudeInstalled) { Get-CommandVersion "claude" } else { $null }
    $claudeSkillsDir = "$env:USERPROFILE\.claude\skills"
    $claudeSkillsExist = Test-Path $claudeSkillsDir
    
    $result.components += @{
        name = "claude-code"
        installed = $claudeInstalled
        version = $claudeVersion
        path = if ($claudeInstalled) { (Get-Command claude).Source } else { $null }
        skills_directory = $claudeSkillsDir
        skills_exist = $claudeSkillsExist
        status = if ($claudeInstalled) { "ok" } else { "missing" }
    }
    
    if ($claudeInstalled) {
        $result.installed_agents += "claude"
        $result.skills_directories["claude"] = $claudeSkillsDir
    }

    # 检测OpenCode
    $opencodeInstalled = Test-Command "opencode"
    $opencodeVersion = if ($opencodeInstalled) { Get-CommandVersion "opencode" } else { $null }
    $opencodeSkillsDir = "$env:USERPROFILE\.config\opencode\skills"
    $opencodeSkillsExist = Test-Path $opencodeSkillsDir
    
    $result.components += @{
        name = "opencode"
        installed = $opencodeInstalled
        version = $opencodeVersion
        path = if ($opencodeInstalled) { (Get-Command opencode).Source } else { $null }
        skills_directory = $opencodeSkillsDir
        skills_exist = $opencodeSkillsExist
        status = if ($opencodeInstalled) { "ok" } else { "missing" }
    }
    
    if ($opencodeInstalled) {
        $result.installed_agents += "opencode"
        $result.skills_directories["opencode"] = $opencodeSkillsDir
    }

    # 检测Hermes
    $hermesInstalled = Test-Command "hermes"
    $hermesVersion = if ($hermesInstalled) { Get-CommandVersion "hermes" } else { $null }
    $hermesSkillsDir = "$env:USERPROFILE\.hermes\skills"
    $hermesSkillsExist = Test-Path $hermesSkillsDir
    
    $result.components += @{
        name = "hermes"
        installed = $hermesInstalled
        version = $hermesVersion
        path = if ($hermesInstalled) { (Get-Command hermes).Source } else { $null }
        skills_directory = $hermesSkillsDir
        skills_exist = $hermesSkillsExist
        status = if ($hermesInstalled) { "ok" } else { "missing" }
    }
    
    if ($hermesInstalled) {
        $result.installed_agents += "hermes"
        $result.skills_directories["hermes"] = $hermesSkillsDir
    }

    # 检测OpenClaw
    $openclawInstalled = Test-Command "openclaw"
    $openclawVersion = if ($openclawInstalled) { Get-CommandVersion "openclaw" } else { $null }
    $openclawSkillsDir = "$env:USERPROFILE\.openclaw\skills"
    $openclawSkillsExist = Test-Path $openclawSkillsDir
    
    $result.components += @{
        name = "openclaw"
        installed = $openclawInstalled
        version = $openclawVersion
        path = if ($openclawInstalled) { (Get-Command openclaw).Source } else { $null }
        skills_directory = $openclawSkillsDir
        skills_exist = $openclawSkillsExist
        status = if ($openclawInstalled) { "ok" } else { "missing" }
    }
    
    if ($openclawInstalled) {
        $result.installed_agents += "openclaw"
        $result.skills_directories["openclaw"] = $openclawSkillsDir
    }

    # 检测DevEco Code（检查DevEco Studio是否安装）
    $devecoPath = Test-EnvironmentVariable "DEVECO_STUDIO_PATH"
    $devecoInstalled = $null -ne $devecoPath -and (Test-Path $devecoPath)
    
    $result.components += @{
        name = "deveco-code"
        installed = $devecoInstalled
        version = $null
        path = $devecoPath
        status = if ($devecoInstalled) { "installed_with_deveco" } else { "missing_deveco" }
    }

    $result.detected = $result.installed_agents.Count -gt 0
    return $result
}

# 检测OpenHarmony Skills
function Test-OpenHarmonySkills {
    $result = @{
        environment = "ohos-skills"
        detected = $false
        agents_with_skills = @()
        skills_by_agent = @{}
        ohos_skills_list = @(
            "arkts-sta-playground",
            "arkts-static-spec",
            "openharmony-arkts-layer",
            "arkui-api-design",
            "arkui-menu-debug",
            "arkuix-module-adapter",
            "ohos-issue-graphics-cppcrash-analysis",
            "ohos-issue-graphics-sysfreeze-analysis",
            "oh-memory-leak-detection",
            "build-error-analyzer",
            "compile-analysis",
            "openharmony-build",
            "code-checker",
            "code-problem-analyzer",
            "comprehensive-code-review",
            "harmonyos-ai-agent-skill"
        )
        cangjie_skills_list = @(
            "cangjie-harmonyos-doc-search",
            "harmonyos-project-init",
            "harmonyos-requirements",
            "harmonyos-build",
            "harmonyos-evolution",
            "harmonyos-stdx",
            "harmonyos-app-diagnose",
            "cangjie-lang-features",
            "cangjie_arkts_interop",
            "cangjie-std",
            "cangjie-stdx",
            "cangjie-original-docs"
        )
    }

    # 检查Claude skills
    $claudeSkillsDir = "$env:USERPROFILE\.claude\skills"
    if (Test-Path $claudeSkillsDir) {
        $claudeSkills = Get-ChildItem $claudeSkillsDir -Directory | Select-Object -ExpandProperty Name
        $ohosSkillsInClaude = $claudeSkills | Where-Object { $_ -in $result.ohos_skills_list }
        $cangjieSkillsInClaude = $claudeSkills | Where-Object { $_ -in $result.cangjie_skills_list }
        
        if ($ohosSkillsInClaude.Count -gt 0 -or $cangjieSkillsInClaude.Count -gt 0) {
            $result.agents_with_skills += "claude"
            $result.skills_by_agent["claude"] = @{
                ohos_skills = $ohosSkillsInClaude
                cangjie_skills = $cangjieSkillsInClaude
            }
        }
    }

    # 检查OpenCode skills
    $opencodeSkillsDir = "$env:USERPROFILE\.config\opencode\skills"
    if (Test-Path $opencodeSkillsDir) {
        $opencodeSkills = Get-ChildItem $opencodeSkillsDir -Directory | Select-Object -ExpandProperty Name
        $ohosSkillsInOpencode = $opencodeSkills | Where-Object { $_ -in $result.ohos_skills_list }
        $cangjieSkillsInOpencode = $opencodeSkills | Where-Object { $_ -in $result.cangjie_skills_list }
        
        if ($ohosSkillsInOpencode.Count -gt 0 -or $cangjieSkillsInOpencode.Count -gt 0) {
            $result.agents_with_skills += "opencode"
            $result.skills_by_agent["opencode"] = @{
                ohos_skills = $ohosSkillsInOpencode
                cangjie_skills = $cangjieSkillsInOpencode
            }
        }
    }

    # 检查Hermes skills
    $hermesSkillsDir = "$env:USERPROFILE\.hermes\skills"
    if (Test-Path $hermesSkillsDir) {
        $hermesSkills = Get-ChildItem $hermesSkillsDir -Directory | Select-Object -ExpandProperty Name
        $ohosSkillsInHermes = $hermesSkills | Where-Object { $_ -in $result.ohos_skills_list }
        $cangjieSkillsInHermes = $hermesSkills | Where-Object { $_ -in $result.cangjie_skills_list }
        
        if ($ohosSkillsInHermes.Count -gt 0 -or $cangjieSkillsInHermes.Count -gt 0) {
            $result.agents_with_skills += "hermes"
            $result.skills_by_agent["hermes"] = @{
                ohos_skills = $ohosSkillsInHermes
                cangjie_skills = $cangjieSkillsInHermes
            }
        }
    }

    # 检查OpenClaw skills
    $openclawSkillsDir = "$env:USERPROFILE\.openclaw\skills"
    if (Test-Path $openclawSkillsDir) {
        $openclawSkills = Get-ChildItem $openclawSkillsDir -Directory | Select-Object -ExpandProperty Name
        $ohosSkillsInOpenclaw = $openclawSkills | Where-Object { $_ -in $result.ohos_skills_list }
        $cangjieSkillsInOpenclaw = $openclawSkills | Where-Object { $_ -in $result.cangjie_skills_list }
        
        if ($ohosSkillsInOpenclaw.Count -gt 0 -or $cangjieSkillsInOpenclaw.Count -gt 0) {
            $result.agents_with_skills += "openclaw"
            $result.skills_by_agent["openclaw"] = @{
                ohos_skills = $ohosSkillsInOpenclaw
                cangjie_skills = $cangjieSkillsInOpenclaw
            }
        }
    }

    $result.detected = $result.agents_with_skills.Count -gt 0
    return $result
}

# 检测HarmonyOS环境
function Test-HarmonyOSEnvironment {
    $result = @{
        environment = "harmonyos"
        detected = $false
        components = @()
        environment_variables = @{}
    }

    # 检测Node.js
    $nodeInstalled = Test-Command "node"
    $nodeVersion = if ($nodeInstalled) { Get-CommandVersion "node" } else { $null }
    
    $result.components += @{
        name = "Node.js"
        installed = $nodeInstalled
        version = $nodeVersion
        path = if ($nodeInstalled) { (Get-Command node).Source } else { $null }
        status = if ($nodeInstalled) { "ok" } else { "missing" }
    }

    # 检测DevEco Studio
    $devecoPath = Test-EnvironmentVariable "DEVECO_STUDIO_PATH"
    $devecoInstalled = $null -ne $devecoPath -and (Test-Path $devecoPath)
    
    $result.components += @{
        name = "DevEco Studio"
        installed = $devecoInstalled
        version = $null
        path = $devecoPath
        status = if ($devecoInstalled) { "ok" } else { "missing" }
    }

    # 检测HDC
    $hdcInstalled = Test-Command "hdc"
    
    $result.components += @{
        name = "HDC"
        installed = $hdcInstalled
        version = if ($hdcInstalled) { Get-CommandVersion "hdc" } else { $null }
        path = if ($hdcInstalled) { (Get-Command hdc).Source } else { $null }
        status = if ($hdcInstalled) { "ok" } else { "missing" }
    }

    # 检测AI Agent
    $aiAgentResult = Test-AIAgentEnvironment
    $result.components += @{
        name = "AI Agents"
        installed = $aiAgentResult.installed_agents.Count -gt 0
        version = $null
        path = $null
        status = if ($aiAgentResult.installed_agents.Count -gt 0) { "installed: $($aiAgentResult.installed_agents -join ', ')" } else { "none" }
        installed_agents = $aiAgentResult.installed_agents
    }

    # 检测OpenHarmony Skills
    $ohosSkillsResult = Test-OpenHarmonySkills
    $result.components += @{
        name = "OpenHarmony Skills"
        installed = $ohosSkillsResult.detected
        version = $null
        path = $null
        status = if ($ohosSkillsResult.detected) { "installed in: $($ohosSkillsResult.agents_with_skills -join ', ')" } else { "not installed" }
        agents_with_skills = $ohosSkillsResult.agents_with_skills
    }

    # 环境变量
    $result.environment_variables = @{
        DEVECO_STUDIO_PATH = $devecoPath
        PATH_contains = @()
    }

    $result.detected = $devecoInstalled -or $nodeInstalled
    return $result
}

# 检测Android环境
function Test-AndroidEnvironment {
    $result = @{
        environment = "android"
        detected = $false
        components = @()
        environment_variables = @{}
    }

    # 检测Java JDK
    $javaInstalled = Test-Command "java"
    $javaVersion = if ($javaInstalled) { Get-CommandVersion "java" } else { $null }
    $javaPath = if ($javaInstalled) { (Get-Command java).Source } else { $null }
    
    $result.components += @{
        name = "Java JDK"
        installed = $javaInstalled
        version = $javaVersion
        path = $javaPath
        status = if ($javaInstalled) { "ok" } else { "missing" }
    }

    # 检测Android SDK
    $androidHome = Test-EnvironmentVariable "ANDROID_HOME"
    $androidSdkInstalled = $null -ne $androidHome -and (Test-Path $androidHome)
    
    $result.components += @{
        name = "Android SDK"
        installed = $androidSdkInstalled
        version = $null
        path = $androidHome
        status = if ($androidSdkInstalled) { "ok" } else { "missing" }
    }

    # 检测ADB
    $adbInstalled = Test-Command "adb"
    $adbVersion = if ($adbInstalled) { Get-CommandVersion "adb" } else { $null }
    
    $result.components += @{
        name = "ADB"
        installed = $adbInstalled
        version = $adbVersion
        path = if ($adbInstalled) { (Get-Command adb).Source } else { $null }
        status = if ($adbInstalled) { "ok" } else { "missing" }
    }

    # 检测Gradle
    $gradleInstalled = Test-Command "gradle"
    $gradleVersion = if ($gradleInstalled) { Get-CommandVersion "gradle" } else { $null }
    
    $result.components += @{
        name = "Gradle"
        installed = $gradleInstalled
        version = $gradleVersion
        path = if ($gradleInstalled) { (Get-Command gradle).Source } else { $null }
        status = if ($gradleInstalled) { "ok" } else { "missing" }
    }

    # 环境变量
    $result.environment_variables = @{
        JAVA_HOME = Test-EnvironmentVariable "JAVA_HOME"
        ANDROID_HOME = $androidHome
        PATH_contains = @()
    }

    $result.detected = $javaInstalled -or $androidSdkInstalled
    return $result
}

# 检测Python环境
function Test-PythonEnvironment {
    $result = @{
        environment = "python"
        detected = $false
        components = @()
        environment_variables = @{}
    }

    # 检测Python
    $pythonInstalled = Test-Command "python"
    $pythonVersion = if ($pythonInstalled) { Get-CommandVersion "python" } else { $null }
    
    $result.components += @{
        name = "Python"
        installed = $pythonInstalled
        version = $pythonVersion
        path = if ($pythonInstalled) { (Get-Command python).Source } else { $null }
        status = if ($pythonInstalled) { "ok" } else { "missing" }
    }

    # 检测pip
    $pipInstalled = Test-Command "pip"
    $pipVersion = if ($pipInstalled) { Get-CommandVersion "pip" } else { $null }
    
    $result.components += @{
        name = "pip"
        installed = $pipInstalled
        version = $pipVersion
        path = if ($pipInstalled) { (Get-Command pip).Source } else { $null }
        status = if ($pipInstalled) { "ok" } else { "missing" }
    }

    # 检测virtualenv
    $virtualenvInstalled = Test-Command "virtualenv"
    
    $result.components += @{
        name = "virtualenv"
        installed = $virtualenvInstalled
        version = if ($virtualenvInstalled) { Get-CommandVersion "virtualenv" } else { $null }
        path = if ($virtualenvInstalled) { (Get-Command virtualenv).Source } else { $null }
        status = if ($virtualenvInstalled) { "ok" } else { "missing" }
    }

    # 检测conda
    $condaInstalled = Test-Command "conda"
    
    $result.components += @{
        name = "conda"
        installed = $condaInstalled
        version = if ($condaInstalled) { Get-CommandVersion "conda" } else { $null }
        path = if ($condaInstalled) { (Get-Command conda).Source } else { $null }
        status = if ($condaInstalled) { "ok" } else { "missing" }
    }

    # 环境变量
    $result.environment_variables = @{
        PYTHON_HOME = Test-EnvironmentVariable "PYTHON_HOME"
        PATH_contains = @()
    }

    $result.detected = $pythonInstalled
    return $result
}

# 检测Node.js环境
function Test-NodeJSEnvironment {
    $result = @{
        environment = "nodejs"
        detected = $false
        components = @()
        environment_variables = @{}
    }

    # 检测Node.js
    $nodeInstalled = Test-Command "node"
    $nodeVersion = if ($nodeInstalled) { Get-CommandVersion "node" } else { $null }
    
    $result.components += @{
        name = "Node.js"
        installed = $nodeInstalled
        version = $nodeVersion
        path = if ($nodeInstalled) { (Get-Command node).Source } else { $null }
        status = if ($nodeInstalled) { "ok" } else { "missing" }
    }

    # 检测npm
    $npmInstalled = Test-Command "npm"
    $npmVersion = if ($npmInstalled) { Get-CommandVersion "npm" } else { $null }
    
    $result.components += @{
        name = "npm"
        installed = $npmInstalled
        version = $npmVersion
        path = if ($npmInstalled) { (Get-Command npm).Source } else { $null }
        status = if ($npmInstalled) { "ok" } else { "missing" }
    }

    # 检测yarn
    $yarnInstalled = Test-Command "yarn"
    
    $result.components += @{
        name = "yarn"
        installed = $yarnInstalled
        version = if ($yarnInstalled) { Get-CommandVersion "yarn" } else { $null }
        path = if ($yarnInstalled) { (Get-Command yarn).Source } else { $null }
        status = if ($yarnInstalled) { "ok" } else { "missing" }
    }

    # 检测pnpm
    $pnpmInstalled = Test-Command "pnpm"
    
    $result.components += @{
        name = "pnpm"
        installed = $pnpmInstalled
        version = if ($pnpmInstalled) { Get-CommandVersion "pnpm" } else { $null }
        path = if ($pnpmInstalled) { (Get-Command pnpm).Source } else { $null }
        status = if ($pnpmInstalled) { "ok" } else { "missing" }
    }

    # 环境变量
    $result.environment_variables = @{
        NODE_HOME = Test-EnvironmentVariable "NODE_HOME"
        PATH_contains = @()
    }

    $result.detected = $nodeInstalled
    return $result
}

# 检测Java环境
function Test-JavaEnvironment {
    $result = @{
        environment = "java"
        detected = $false
        components = @()
        environment_variables = @{}
    }

    # 检测Java JDK
    $javaInstalled = Test-Command "java"
    $javaVersion = if ($javaInstalled) { Get-CommandVersion "java" } else { $null }
    
    $result.components += @{
        name = "Java JDK"
        installed = $javaInstalled
        version = $javaVersion
        path = if ($javaInstalled) { (Get-Command java).Source } else { $null }
        status = if ($javaInstalled) { "ok" } else { "missing" }
    }

    # 检测javac
    $javacInstalled = Test-Command "javac"
    
    $result.components += @{
        name = "javac"
        installed = $javacInstalled
        version = if ($javacInstalled) { Get-CommandVersion "javac" } else { $null }
        path = if ($javacInstalled) { (Get-Command javac).Source } else { $null }
        status = if ($javacInstalled) { "ok" } else { "missing" }
    }

    # 检测Maven
    $mavenInstalled = Test-Command "mvn"
    
    $result.components += @{
        name = "Maven"
        installed = $mavenInstalled
        version = if ($mavenInstalled) { Get-CommandVersion "mvn" } else { $null }
        path = if ($mavenInstalled) { (Get-Command mvn).Source } else { $null }
        status = if ($mavenInstalled) { "ok" } else { "missing" }
    }

    # 检测Gradle
    $gradleInstalled = Test-Command "gradle"
    
    $result.components += @{
        name = "Gradle"
        installed = $gradleInstalled
        version = if ($gradleInstalled) { Get-CommandVersion "gradle" } else { $null }
        path = if ($gradleInstalled) { (Get-Command gradle).Source } else { $null }
        status = if ($gradleInstalled) { "ok" } else { "missing" }
    }

    # 环境变量
    $result.environment_variables = @{
        JAVA_HOME = Test-EnvironmentVariable "JAVA_HOME"
        PATH_contains = @()
    }

    $result.detected = $javaInstalled
    return $result
}

# 检测Rust环境
function Test-RustEnvironment {
    $result = @{
        environment = "rust"
        detected = $false
        components = @()
        environment_variables = @{}
    }

    # 检测rustc
    $rustcInstalled = Test-Command "rustc"
    
    $result.components += @{
        name = "rustc"
        installed = $rustcInstalled
        version = if ($rustcInstalled) { Get-CommandVersion "rustc" } else { $null }
        path = if ($rustcInstalled) { (Get-Command rustc).Source } else { $null }
        status = if ($rustcInstalled) { "ok" } else { "missing" }
    }

    # 检测cargo
    $cargoInstalled = Test-Command "cargo"
    
    $result.components += @{
        name = "cargo"
        installed = $cargoInstalled
        version = if ($cargoInstalled) { Get-CommandVersion "cargo" } else { $null }
        path = if ($cargoInstalled) { (Get-Command cargo).Source } else { $null }
        status = if ($cargoInstalled) { "ok" } else { "missing" }
    }

    # 检测rustup
    $rustupInstalled = Test-Command "rustup"
    
    $result.components += @{
        name = "rustup"
        installed = $rustupInstalled
        version = if ($rustupInstalled) { Get-CommandVersion "rustup" } else { $null }
        path = if ($rustupInstalled) { (Get-Command rustup).Source } else { $null }
        status = if ($rustupInstalled) { "ok" } else { "missing" }
    }

    # 环境变量
    $result.environment_variables = @{
        CARGO_HOME = Test-EnvironmentVariable "CARGO_HOME"
        RUSTUP_HOME = Test-EnvironmentVariable "RUSTUP_HOME"
        PATH_contains = @()
    }

    $result.detected = $rustcInstalled -or $cargoInstalled
    return $result
}

# 检测Go环境
function Test-GoEnvironment {
    $result = @{
        environment = "go"
        detected = $false
        components = @()
        environment_variables = @{}
    }

    # 检测go
    $goInstalled = Test-Command "go"
    
    $result.components += @{
        name = "Go"
        installed = $goInstalled
        version = if ($goInstalled) { Get-CommandVersion "go" } else { $null }
        path = if ($goInstalled) { (Get-Command go).Source } else { $null }
        status = if ($goInstalled) { "ok" } else { "missing" }
    }

    # 环境变量
    $result.environment_variables = @{
        GOPATH = Test-EnvironmentVariable "GOPATH"
        GOROOT = Test-EnvironmentVariable "GOROOT"
        PATH_contains = @()
    }

    $result.detected = $goInstalled
    return $result
}

# 检测C/C++环境
function Test-CppEnvironment {
    $result = @{
        environment = "cpp"
        detected = $false
        components = @()
        environment_variables = @{}
    }

    # 检测gcc
    $gccInstalled = Test-Command "gcc"
    
    $result.components += @{
        name = "GCC"
        installed = $gccInstalled
        version = if ($gccInstalled) { Get-CommandVersion "gcc" } else { $null }
        path = if ($gccInstalled) { (Get-Command gcc).Source } else { $null }
        status = if ($gccInstalled) { "ok" } else { "missing" }
    }

    # 检测g++
    $gppInstalled = Test-Command "g++"
    
    $result.components += @{
        name = "G++"
        installed = $gppInstalled
        version = if ($gppInstalled) { Get-CommandVersion "g++" } else { $null }
        path = if ($gppInstalled) { (Get-Command g++).Source } else { $null }
        status = if ($gppInstalled) { "ok" } else { "missing" }
    }

    # 检测cmake
    $cmakeInstalled = Test-Command "cmake"
    
    $result.components += @{
        name = "CMake"
        installed = $cmakeInstalled
        version = if ($cmakeInstalled) { Get-CommandVersion "cmake" } else { $null }
        path = if ($cmakeInstalled) { (Get-Command cmake).Source } else { $null }
        status = if ($cmakeInstalled) { "ok" } else { "missing" }
    }

    # 检测make
    $makeInstalled = Test-Command "make"
    
    $result.components += @{
        name = "Make"
        installed = $makeInstalled
        version = if ($makeInstalled) { Get-CommandVersion "make" } else { $null }
        path = if ($makeInstalled) { (Get-Command make).Source } else { $null }
        status = if ($makeInstalled) { "ok" } else { "missing" }
    }

    # 环境变量
    $result.environment_variables = @{
        PATH_contains = @()
    }

    $result.detected = $gccInstalled -or $gppInstalled -or $cmakeInstalled
    return $result
}

# 检测WSL Linux环境
function Test-WSLEnvironment {
    $result = @{
        environment = "wsl"
        detected = $false
        components = @()
        distros = @()
        environment_variables = @{}
    }

    # 检测WSL是否安装
    $wslInstalled = $false
    $wslVersion = $null
    try {
        $wslVerOutput = wsl --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            $wslInstalled = $true
            $wslVersion = ($wslVerOutput | Select-Object -First 1) -replace "`0", ""
        }
    } catch {
        $wslInstalled = $false
    }

    $result.components += @{
        name = "WSL"
        installed = $wslInstalled
        version = $wslVersion
        path = if ($wslInstalled) { (Get-Command wsl -ErrorAction SilentlyContinue).Source } else { $null }
        status = if ($wslInstalled) { "ok" } else { "missing" }
    }

    # 检测WSL2内核
    $wslKernelUpdated = $false
    $kernelVersion = $null
    if ($wslInstalled) {
        try {
            $statusOutput = wsl --status 2>&1
            $kernelLine = $statusOutput | Where-Object { $_ -match "内核版本" -or $_ -match "kernel" }
            if ($kernelLine) {
                $kernelVersion = ($kernelLine -replace "`0", "").Trim()
                $wslKernelUpdated = $true
            }
        } catch {
            $wslKernelUpdated = $false
        }
    }

    $result.components += @{
        name = "WSL2 Kernel"
        installed = $wslKernelUpdated
        version = $kernelVersion
        status = if ($wslKernelUpdated) { "ok" } else { "not_updated" }
    }

    # 检测WSLg
    $wslgAvailable = $false
    if ($wslInstalled) {
        try {
            $displayCheck = wsl -- bash -c "echo `$DISPLAY" 2>&1
            if ($displayCheck -match "^:0" -or $displayCheck -match "^:1") {
                $wslgAvailable = $true
            }
        } catch {
            $wslgAvailable = $false
        }
    }

    $result.components += @{
        name = "WSLg"
        installed = $wslgAvailable
        version = $null
        status = if ($wslgAvailable) { "ok" } else { "not_available" }
    }

    # 检测Docker Desktop WSL2集成
    $dockerDesktopIntegrated = $false
    $dockerVersion = $null
    if ($wslInstalled) {
        try {
            $dockerCheck = wsl -- bash -c "docker --version 2>/dev/null" 2>&1
            if ($LASTEXITCODE -eq 0 -and $dockerCheck -match "Docker version") {
                $dockerDesktopIntegrated = $true
                $dockerVersion = ($dockerCheck -replace "`0", "").Trim()
            }
        } catch {
            $dockerDesktopIntegrated = $false
        }
    }

    $result.components += @{
        name = "Docker Desktop WSL2"
        installed = $dockerDesktopIntegrated
        version = $dockerVersion
        status = if ($dockerDesktopIntegrated) { "ok" } else { "not_integrated" }
    }

    # 获取已安装发行版列表
    if ($wslInstalled) {
        try {
            $distroListRaw = wsl -l -v 2>&1
            # 解析发行版列表（处理Unicode编码问题）
            $lines = $distroListRaw | ForEach-Object { $_ -replace "`0", "" } | Where-Object { $_.Trim() -ne "" }

            foreach ($line in $lines) {
                # 跳过标题行
                if ($line -match "NAME" -and $line -match "STATE") { continue }

                $trimmed = $line.Trim()
                if ([string]::IsNullOrWhiteSpace($trimmed)) { continue }

                # 解析行：* Ubuntu  Running  2
                $isDefault = $trimmed -match "^\*"
                $trimmed = $trimmed -replace "^\*\s*", ""

                $parts = $trimmed -split "\s+" | Where-Object { $_.Trim() -ne "" }
                if ($parts.Count -ge 3) {
                    $distroName = $parts[0]
                    $distroState = $parts[1]
                    $distroWslVer = $parts[2]

                    # 推断包管理器
                    $pkgManager = "apt"
                    if ($distroName -match "CentOS") { $pkgManager = "yum" }
                    elseif ($distroName -match "Fedora") { $pkgManager = "dnf" }
                    elseif ($distroName -match "Arch") { $pkgManager = "pacman" }
                    elseif ($distroName -match "openSUSE|SLES|SUSE") { $pkgManager = "zypper" }

                    $result.distros += @{
                        name = $distroName
                        state = $distroState
                        wsl_version = $distroWslVer
                        default = $isDefault
                        package_manager = $pkgManager
                    }
                }
            }
        } catch {
            # 发行版列表解析失败
        }
    }

    # 环境变量
    $wslDistroName = $null
    try {
        $wslDistroName = (wsl -- bash -c "echo `$WSL_DISTRO_NAME" 2>&1) -join ""
    } catch {
        $wslDistroName = $null
    }
    $result.environment_variables = @{
        WSL_DISTRO_NAME = $wslDistroName
    }

    $result.detected = $wslInstalled
    return $result
}

# 主逻辑
$report = switch ($Environment) {
    "android" { Test-AndroidEnvironment }
    "harmonyos" { Test-HarmonyOSEnvironment }
    "python" { Test-PythonEnvironment }
    "nodejs" { Test-NodeJSEnvironment }
    "java" { Test-JavaEnvironment }
    "rust" { Test-RustEnvironment }
    "go" { Test-GoEnvironment }
    "cpp" { Test-CppEnvironment }
    "ai-agent" { Test-AIAgentEnvironment }
    "ohos-skills" { Test-OpenHarmonySkills }
    "wsl" { Test-WSLEnvironment }
    "all" {
        @(
            Test-AndroidEnvironment,
            Test-HarmonyOSEnvironment,
            Test-PythonEnvironment,
            Test-NodeJSEnvironment,
            Test-JavaEnvironment,
            Test-RustEnvironment,
            Test-GoEnvironment,
            Test-CppEnvironment,
            Test-AIAgentEnvironment,
            Test-OpenHarmonySkills,
            Test-WSLEnvironment
        )
    }
}

# 输出JSON格式结果
$report | ConvertTo-Json -Depth 5
