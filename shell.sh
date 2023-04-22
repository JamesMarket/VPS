#!/bin/bash

# 显示菜单
show_menu() {
    echo "选择需要执行的操作："
    echo "1. 更改系统时区"
    echo "2. 更新系统软件"
    echo "3. 安装 Docker"
    echo "4. 安装 docker-compose"
    echo "5. 安装 docker 和 docker-compose"
    echo "6. 开启 BBR"
    echo "7. 一键纯净更新和清理垃圾"
    echo "8. 开启虚拟内存"
    echo "0. 退出"
}

# 更改系统时区
change_timezone() {
    sudo timedatectl set-timezone Asia/Shanghai
    if [ $? -eq 0 ]; then
        echo "时区更改成功"
    else
        echo "时区更改失败"
    fi
    echo ""
}

# 更新系统软件
update_sys() {
    if [ -f /etc/lsb-release ]; then
        echo "正在更新软件……"
        sudo apt update && sudo apt upgrade
        echo "更新软件完成"
    elif [ -f /etc/redhat-release ]; then
        echo "正在更新软件……"
        sudo yum update
        echo "更新软件完成"
    fi
    echo ""
}

# 安装 Docker
install_docker() {
    if [ -x "$(command -v docker)" ]; then
        echo "Docker 已安装"
    else
        echo "开始安装 Docker……"
        sudo apt-get update && apt-get install -y docker
        if [ $? -eq 0 ]; then
            echo "Docker 安装成功"
        else
            echo "Docker 安装失败"
        fi
    fi
    echo ""
}

# 安装 docker-compose
install_docker_compose() {
    if [ -x "$(command -v docker-compose)" ]; then
        echo "docker-compose 已安装"
    else
        echo "开始安装 docker-compose……"
        sudo -i
        sudo apt-get update
        sudo apt-get install docker-compose -y
        if [ $? -eq 0 ]; then
            echo "docker-compose 安装成功"
        else
            echo "docker-compose 安装失败"
        fi
    fi
    echo ""
}

# 安装 docker 和 docker-compose
install_docker_and_compose() {
    if [ -x "$(command -v docker)" ] && [ -x "$(command -v docker-compose)" ]; then
        echo "Docker 和 docker-compose 已安装"
    else
        echo "开始安装 Docker 和 docker-compose……"
        sudo apt-get update && apt-get install -y docker docker-compose
        if [ $? -eq 0 ]; then
            echo "Docker 和 docker-compose 安装成功"
        else
            echo "Docker 和 docker-compose 安装失败"
        fi
    fi
    echo ""
}


# 开启 BBR
enable_bbr() {
    if grep -q "net.ipv4.tcp_congestion_control" /etc/sysctl.conf; then
        echo "BBR 已开启"
    else
        echo "开始开启 BBR……"
        sudo modprobe tcp_bbr
        echo "tcp_bbr" | sudo tee --append /etc/modules-load.d/modules.conf
        echo "net.core.default_qdisc=fq" | sudo tee --append /etc/sysctl.conf
        echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee --append /etc/sysctl.conf
        sudo sysctl -p
        if [ $? -eq 0 ]; then
            echo "BBR 已成功开启"
        else
            echo "BBR 开启失败"
        fi
    fi
    echo ""
}

# 一键纯净更新和清理垃圾
clean_system() {
    if [ -f /etc/os-release ] && grep -q "debian" /etc/os-release ; then
        echo "正在一键纯净更新……"
        sudo apt update -y && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y
        echo "正在清理垃圾……"
        sudo apt autoremove --purge -y
        sudo apt clean
        sudo journalctl --rotate
        sudo journalctl --vacuum-time=1s
        sudo journalctl --vacuum-size=50M
        sudo apt remove --purge $(dpkg -l | grep "^rc" | awk '{print $2}')
        sudo apt autoremove --purge $(dpkg -l | grep "^rc" | awk '{print $2}') -y
        sudo apt-get clean
        sudo apt-get autoremove -y
        echo "一键纯净更新和清理垃圾完成"
    elif [ -f /etc/redhat-release ]; then
        echo "正在一键纯净更新……"
        yum update -y && yum upgrade -y && yum autoremove -y && yum clean all
        echo "正在清理垃圾……"
        sudo yum autoremove
        sudo yum clean all
        sudo journalctl --rotate
        sudo journalctl --vacuum-time=1s
        sudo journalctl --vacuum-size=50M
        sudo yum remove $(rpm -qa kernel | grep -v $(uname -r))
        echo "一键纯净更新和清理垃圾完成"
    else
        echo "不支持的系统"
    fi
    echo ""
}

# 开启虚拟内存
# 开启虚拟内存
enable_swap() {
    read -p "请输入要设置的虚拟内存大小，单位为 GB：" size
    sudo fallocate -l ${size}G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    if [[ $(grep -q "/swapfile swap swap defaults 0 0" /etc/fstab) ]]; then
        sudo echo "/swapfile swap swap defaults 0 0" >> /etc/fstab
    fi
    echo "虚拟内存开启成功，大小为 ${size} GB"
    echo ""
    # 设置 swappiness 值，更倾向于使用物理内存
    sudo sysctl vm.swappiness=10 > /dev/null
}

# 显示菜单，进行选择操作
while true; do
    show_menu
    read -p "请输入选项编号：" choice
    echo ""
    case $choice in
        1)
            change_timezone
            ;;
        2)
            update_sys
            ;;
        3)
            install_docker
            ;;
        4)
            install_docker_compose
            ;;
        5)
            install_docker_and_compose
            ;;                             
        6)
            enable_bbr
            ;;
        7)
            clean_system
            ;;
        8)
            enable_swap
            ;;    
        0)
            break
            ;;
        *)
            echo "无效的选项"
            ;;
    esac
done
