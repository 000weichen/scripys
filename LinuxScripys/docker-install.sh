#!/bin/bash

# 检查系统类型
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
    VERSION=$VERSION_ID
else
    echo "无法识别操作系统类型"
    exit 1
fi

echo "检测到系统：$DISTRO $VERSION"

# Ubuntu 系统安装方式
if [[ "$DISTRO" == "ubuntu" ]]; then
    echo "开始安装 Docker（Ubuntu）..."

    # 安装必要的系统工具
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg

    # 信任 Docker 的 GPG 公钥
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # 添加 Docker 仓库
    echo \
      "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.aliyun.com/docker-ce/linux/ubuntu \
      $(lsb_release -cs) stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # 安装 Docker
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # 启动 Docker 服务并设置开机自启
    sudo systemctl enable --now docker

    # 配置 Docker 镜像加速器
    sudo mkdir -p /etc/docker
    echo '{
      "registry-mirrors": [
        "https://mirrors.aliyun.com"
      ]
    }' | sudo tee /etc/docker/daemon.json > /dev/null

    # 重新加载 Docker 配置并重启服务
    sudo systemctl daemon-reload
    sudo systemctl restart docker

    echo "Docker 安装完成（Ubuntu）"

# CentOS 系统安装方式
elif [[ "$DISTRO" == "centos" || "$DISTRO" == "rhel" ]]; then
    echo "开始安装 Docker（CentOS/RHEL）..."

    # 安装必要的系统工具
    sudo yum install -y yum-utils device-mapper-persistent-data lvm2

    # 添加 Docker 仓库
    sudo yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

    # 安装 Docker
    sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # 启动 Docker 服务并设置开机自启
    sudo systemctl enable --now docker

    # 配置 Docker 镜像加速器
    sudo mkdir -p /etc/docker
    echo '{
      "registry-mirrors": [
        "https://mirrors.aliyun.com"
      ]
    }' | sudo tee /etc/docker/daemon.json > /dev/null

    # 重新加载 Docker 配置并重启服务
    sudo systemctl daemon-reload
    sudo systemctl restart docker

    echo "Docker 安装完成（CentOS/RHEL）"

else
    echo "不支持的操作系统：$DISTRO"
    exit 1
fi

# 验证 Docker 是否安装成功
docker --version
docker-compose --version
