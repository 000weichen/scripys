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

configure_docker() {
    sudo systemctl enable --now docker
    sudo mkdir -p /etc/docker
    echo '{
      "registry-mirrors": [
        "https://mirrors.aliyun.com"
      ]
    }' | sudo tee /etc/docker/daemon.json > /dev/null
    sudo systemctl daemon-reload
    sudo systemctl restart docker
}

case "$DISTRO" in
    ubuntu)
        echo "开始安装 Docker（Ubuntu）..."

        sudo apt-get update
        sudo apt-get install -y ca-certificates curl gnupg lsb-release

        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg

        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.aliyun.com/docker-ce/linux/ubuntu \
          $(lsb_release -cs) stable" | \
          sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        configure_docker
        echo "Docker 安装完成（Ubuntu）"
        ;;

    debian)
        echo "开始安装 Docker（Debian）..."

        sudo apt-get update
        sudo apt-get install -y ca-certificates curl gnupg

        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg

        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.aliyun.com/docker-ce/linux/debian \
          ${VERSION_CODENAME} stable" | \
          sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        configure_docker
        echo "Docker 安装完成（Debian）"
        ;;

    centos|rhel)
        echo "开始安装 Docker（CentOS/RHEL）..."

        sudo yum install -y yum-utils device-mapper-persistent-data lvm2
        sudo yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
        sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        configure_docker
        echo "Docker 安装完成（CentOS/RHEL）"
        ;;

    fedora)
        echo "开始安装 Docker（Fedora）..."

        sudo dnf -y install dnf-plugins-core
        sudo dnf config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/fedora/docker-ce.repo
        sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        configure_docker
        echo "Docker 安装完成（Fedora）"
        ;;

    opensuse*|sles)
        echo "开始安装 Docker（openSUSE/SLES）..."

        sudo zypper install -y ca-certificates curl
        sudo rpm --import https://mirrors.aliyun.com/docker-ce/linux/opensuse/gpg
        sudo zypper addrepo https://mirrors.aliyun.com/docker-ce/linux/opensuse/docker-ce.repo
        sudo zypper refresh
        sudo zypper install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        configure_docker
        echo "Docker 安装完成（openSUSE/SLES）"
        ;;

    *)
        echo "不支持的操作系统：$DISTRO"
        exit 1
        ;;
esac

# 验证 Docker 是否安装成功
docker --version
docker-compose --version
