#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 显示欢迎信息
show_welcome() {
    clear
    echo -e "${GREEN}"
    echo "================================================"
    echo "           欢迎使用麦麦一键部署脚本"
    echo "================================================"
    echo -e "${NC}"
    echo -e "${BLUE}请根据您的环境选择合适的安装选项${NC}"
    echo ""
}

# 显示菜单
show_menu() {
    echo -e "${YELLOW}请选择安装环境：${NC}"
    echo "1) Linux 环境下安装麦麦"
    echo "2) ZeroTermux 环境下安装麦麦"
    echo "3) 登录Linux并复制脚本"
    echo "" 
    echo "4) 退出"
    echo ""
    echo -n "请输入选择 [1-4]: "
}

# Linux环境安装
install_linux() {
    echo -e "${GREEN}开始 Linux 环境安装...${NC}"
    echo "================================================"
    
    # 检查是否在Linux环境
    if [[ "$(uname)" != "Linux" ]]; then
        echo -e "${RED}错误：当前不在 Linux 环境中！${NC}"
        return 1
    fi
   
    echo "更新软件包"
    apt update
    
    echo "安装必要软件"
    apt install -y sudo vim git python3-dev python3-venv build-essential screen curl python3-pip
    
    echo "下载麦麦必要文件"
    cd ~
    mkdir -p maimai
    cd maimai
    git clone https://github.com/MaiM-with-u/MaiBot.git
    git clone https://github.com/MaiM-with-u/MaiBot-Napcat-Adapter.git
    
    echo "安装uv"
    # 使用 pip 安装 uv
    pip3 install uv --break-system-packages -i https://mirrors.huaweicloud.com/repository/pypi/simple/
     grep -qF 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
     echo"安装主体依赖"
     cd MaiBot
     uv venv
     uv pip install -r requirements.txt -i https://mirrors.aliyun.com/pypi/simple --upgrade
     
    echo"安装框架依赖"
    cd ..
    cd MaiBot-Napcat-Adapter
    pip3 install -r requirements.txt
    # 复制并重命名配置文件
    cp template/template_config.toml config.toml
    echo "部署nc框架"
    # 安装NapCat
    curl -o napcat.sh https://nclatest.znin.net/NapNeko/NapCat-Installer/main/script/install.sh
    sudo bash napcat.sh --docker n --cli y
    
    echo "启动nc"
    sudo napcat
   
    echo -e "${GREEN}Linux 环境安装完成！${NC}"
    echo "请根据README文件进行后续配置"
}

# ZeroTermux环境安装
install_termux() {
    echo -e "${GREEN}开始 ZeroTermux 环境安装...${NC}"
    echo "================================================"
    
    # 检查是否在Termux环境
    if [[ ! -d "/data/data/com.termux/files/usr" ]]; then
        echo -e "${RED}错误：当前不在 Termux 环境中！${NC}"
        return 1
    fi
    
    # Termux特定安装步骤
    echo "更换清华源"
    sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/termux-packages-24 stable main@' $PREFIX/etc/apt/sources.list && pkg update && pkg upgrade -y

    echo "安装proot"
    pkg install -y proot-distro

    echo "安装ubuntu"
    proot-distro install ubuntu
    
    echo ""
    echo -e "${GREEN}================================================"
    echo "Ubuntu 环境安装完成！"
    echo "================================================"
    echo -e "${NC}"
    echo -e "${YELLOW}接下来请按照以下步骤操作：${NC}"
    echo ""
    echo "1. 使用选项3登录到Ubuntu并自动复制脚本"
    echo "2. 在Ubuntu中运行脚本并选择选项1"
    echo ""
}

# 登录Linux环境并复制脚本
login_and_copy_script() {
    echo -e "${GREEN}准备登录 Ubuntu 环境并复制脚本...${NC}"
    
    # 获取当前脚本的绝对路径
    SCRIPT_PATH=$(realpath "$0")
    SCRIPT_NAME=$(basename "$0")
    
    echo "当前脚本路径: $SCRIPT_PATH"
    echo ""
    
    # 创建共享目录
    mkdir -p ~/shared_folder
    
    # 复制脚本到共享目录
    cp "$SCRIPT_PATH" ~/shared_folder/
    
    echo -e "${YELLOW}已将脚本复制到共享目录${NC}"
    echo "现在登录Ubuntu环境..."
    echo "在Ubuntu中，请执行以下命令："
    echo "2. curl -O https://raw.githubusercontent.com/MC090610/maibot-install.sh/main/hmmc.sh"
    echo "3. chmod +x $SCRIPT_NAME"
    echo "4. ./$SCRIPT_NAME"
    echo ""
    
    # 登录Ubuntu
    proot-distro login ubuntu
}

# 主循环
main() {
    while true; do
        show_welcome
        show_menu
        read choice
        
        case $choice in
            1)
                echo ""
                install_linux
                ;;
            2)
                echo ""
                install_termux
                ;;
            3)
                echo ""
                login_and_copy_script
                ;;
            4)
                echo -e "${GREEN}感谢使用麦麦部署脚本，再见！${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}无效选择，请重新输入！${NC}"
                ;;
        esac
        
        echo ""
        echo -e "${BLUE}按回车键返回主菜单...${NC}"
        read
    done
}

# 脚本开始
main