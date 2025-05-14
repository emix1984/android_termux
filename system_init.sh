#!/bin/bash

# Termux 初始化脚本 - 模块化版本

# 检查是否为 Termux 环境
check_termux_environment() {
    if [[ "$PREFIX" != "/data/data/com.termux/files/usr" ]]; then
        echo "此脚本仅适用于 Termux 环境！"
        exit 1
    fi
}

# 配置存储权限
configure_storage_permission() {
    echo "配置存储权限..."
    termux-setup-storage
    if [ $? -ne 0 ]; then
        echo "存储权限配置失败，请手动运行 termux-setup-storage"
        exit 1
    fi
}

# 更新包管理器
update_package_manager() {
    echo "更换清华镜像源..."
    sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/apt/termux-main stable main@' $PREFIX/etc/apt/sources.list
    
    if [ $? -ne 0 ]; then
        echo "镜像源替换失败"
        exit 1
    fi
    
    echo "更新包管理器..."
    pkg update -y
    if [ $? -ne 0 ]; then
        echo "包管理器更新失败"
        exit 1
    fi
    
    # 新增升级操作
    echo "升级所有软件包..."
    pkg upgrade -y
    if [ $? -ne 0 ]; then
        echo "软件包升级失败"
        exit 1
    fi
}

# 安装常用软件包
install_common_packages() {
    echo "安装常用软件包..."
    pkg install -y \
        wget \
        curl \
        git \
        nano \
        unzip \
        zip \
        python3 \
        termux-services \
        tmux  # 追加tmux

    if [ $? -ne 0 ]; then
        echo "常用软件包安装失败"
        exit 1
    fi
}

# 安装并启用 OpenSSH
install_and_enable_ssh() {
    echo "安装 OpenSSH 服务器..."
    pkg install openssh -y
    if [ $? -ne 0 ]; then
        echo "OpenSSH 安装失败"
        exit 1
    fi

    echo "启用并启动 OpenSSH 服务..."
    sv-enable sshd
    if [ $? -ne 0 ]; then
        echo "OpenSSH 服务启用失败，请手动运行 sv-enable sshd"
        exit 1
    fi

    # 启动 OpenSSH 服务
    echo "启动 OpenSSH 服务..."
    sshd
    if [ $? -ne 0 ]; then
        echo "OpenSSH 服务启动失败"
        exit 1
    fi

    # 配置 SSH 密钥对（如果不存在）
    if [ ! -f "$HOME/.ssh/id_rsa" ]; then
        echo "生成 SSH 密钥对..."
        mkdir -p "$HOME/.ssh"
        chmod 700 "$HOME/.ssh"
        ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa" -N ""
        if [ $? -ne 0 ]; then
            echo "SSH 密钥生成失败"
            exit 1
        fi
    fi
    
    # 新增自启动配置
    echo "配置SSH服务自启动..."
    if [ ! -d ~/.termux/boot ]; then
        mkdir -p ~/.termux/boot
    fi
    
    cat > ~/.termux/boot/start-sshd <<'EOF'
#!/bin/sh
termux-wake-lock
sshd
EOF
    
    chmod +x ~/.termux/boot/start-sshd
    echo "SSH自启动脚本已创建：$HOME/.termux/boot/start-sshd"
}

# 配置 Python 开发环境
config_pythondev() {
    echo "安装 Python 开发所需的软件包..."
    pkg install -y clang

    if [ $? -ne 0 ]; then
        echo "Python 开发所需软件包安装失败"
        exit 1
    fi

    echo "配置 Python pip 环境变量..."
    echo 'export LDFLAGS="-L/data/data/com.termux/files/usr/lib"' >> ~/.bashrc
    echo 'export CFLAGS="-I/data/data/com.termux/files/usr/include"' >> ~/.bashrc
    source ~/.bashrc
    
    # 新增版本显示
    echo "当前Python版本：$(python3 --version)"
    echo "当前pip版本：$(pip3 --version)"
}

# 主函数 - 执行所有模块
main() {
    check_termux_environment
    configure_storage_permission
    update_package_manager
    install_common_packages
    install_and_enable_ssh
    config_pythondev
    clean_pkg_cache  # 新增清理模块
    
    echo "初始化完成！存储剩余空间：$(df -h $PREFIX | awk 'NR==2{print $4}')"
}

# 执行主函数
main
