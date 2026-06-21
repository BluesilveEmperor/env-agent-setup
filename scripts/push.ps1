#!/bin/bash
# env-agent-setup 自动推送脚本
# 用法: ./scripts/push.ps1 "提交信息"

cd "C:\Users\GLY\.config\opencode\skills\env-agent-setup"

if [ -z "$1" ]; then
    echo "用法: ./scripts/push.ps1 '提交信息'"
    exit 1
fi

git add .
git commit -m "$1"
git push origin main

echo "✅ 推送完成: $1"
