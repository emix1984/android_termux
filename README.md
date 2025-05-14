# Termux 环境初始化脚本

![Termux Logo](https://avatars.githubusercontent.com/u/6291938)  
用于快速配置Termux安卓终端的初始化脚本

## ✨ 功能特性
- ✅ 自动环境检测（仅限Termux）
- ✅ 存储权限自动配置
- 📦 基础工具包安装（wget/curl/git等）
- 🔐 OpenSSH服务配置（含自启动）
- 🐍 Python开发环境配置
- 🧹 自动清理软件包缓存

## 🚀 快速开始
```bash
# 授予执行权限
chmod +x system_init.sh

# 执行初始化脚本
./system_init.sh