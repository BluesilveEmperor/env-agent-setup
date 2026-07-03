#!/bin/bash
# env-agent-setup 自动同步+推送脚本
# 作用：同步skill到OpenCode和Claude Code两个位置，并推送到GitHub
# 用法: ./scripts/push.ps1 "提交信息"

$ErrorActionPreference = "Stop"

# 路径配置
$OPENCODE_SKILL_DIR = "C:\Users\GLY\.config\opencode\skills\env-agent-setup"
$CLAUDE_SKILL_DIR = "C:\Users\GLY\.claude\skills\env-agent-setup"

# 检查参数
if ($args.Count -eq 0) {
    Write-Host "用法: .\scripts\push.ps1 '提交信息'"
    Write-Host "示例: .\scripts\push.ps1 'feat: 添加新功能'"
    exit 1
}

$commitMessage = $args[0]

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "env-agent-setup 同步+推送工具" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 1. 同步到Claude skills目录
Write-Host "`n[1/3] 同步到 Claude Code skills..." -ForegroundColor Yellow
if (-not (Test-Path $CLAUDE_SKILL_DIR)) {
    New-Item -ItemType Directory -Path $CLAUDE_SKILL_DIR -Force | Out-Null
    Write-Host "  创建目录: $CLAUDE_SKILL_DIR"
}

# 使用robocopy同步（排除.git目录）
$syncResult = robocopy $OPENCODE_SKILL_DIR $CLAUDE_SKILL_DIR /E /XD .git /NFL /NDL /NJH /NJS /NC /NS /NP
if ($LASTEXITCODE -le 3) {
    Write-Host "  ✅ 同步完成" -ForegroundColor Green
} else {
    Write-Host "  ⚠️ 同步可能存在问题，继续执行..." -ForegroundColor Yellow
}

# 2. 提交到Git
Write-Host "`n[2/3] 提交更改..." -ForegroundColor Yellow
Set-Location $OPENCODE_SKILL_DIR

git add .
$gitStatus = git status --porcelain
if ([string]::IsNullOrEmpty($gitStatus)) {
    Write-Host "  ⚠️ 没有更改需要提交" -ForegroundColor Yellow
    exit 0
}

git commit -m $commitMessage
Write-Host "  ✅ 提交完成: $commitMessage" -ForegroundColor Green

# 3. 推送到GitHub
Write-Host "`n[3/3] 推送到GitHub..." -ForegroundColor Yellow
git push origin main
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✅ 推送完成" -ForegroundColor Green
} else {
    Write-Host "  ❌ 推送失败" -ForegroundColor Red
    exit 1
}

# 完成
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "✅ 全部完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "OpenCode:  $OPENCODE_SKILL_DIR"
Write-Host "Claude:    $CLAUDE_SKILL_DIR"
Write-Host "GitHub:    https://github.com/BluesilveEmperor/env-agent-setup"
