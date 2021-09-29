#! /usr/bin/env bash

basedir=$(cd `dirname $0`;pwd)

pha_installdir=/opt/phala


install_depenencies()
{
    log_info "------------Apt update--------------"

    apt-get update
    if [ $? -ne 0 ]; then
        log_err "Apt update failed"
        exit 1
    fi

    log_info "------------Install depenencies--------------"
    sudo apt install -y software-properties-common jq lvm2 wget unzip kmod linux-headers-`uname -r` vim cmake pkg-config git build-essential curl
    if [ $? -ne 0 ]; then
        log_err "Install libs failed"
        exit 1
    fi

    docker -v
    if [ $? -ne 0 ]; then
        curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
        if [ $? -ne 0 ]; then
            log_err "Install docker failed"
            exit 1
        fi
    fi

    docker-compose -v
    if [ $? -ne 0 ]; then
        apt install -y docker-compose
        if [ $? -ne 0 ]; then
            log_err "Install docker compose failed"
            exit 1
        fi
    fi
}



install_phala()
{
	echo "--------------Install pha node -------------"

	wget https://github.com.cnpmjs.org/Phala-Network/solo-mining-scripts/archive/main.zip
	if [ $? -ne 0 ]; then
	    echo "Download phala scripts failed"
	    exit 1
	fi


	unzip main.zip
	if [ $? -ne 0 ]; then
	    echo "Unzip phala scripts failed"
	    rm $basedir/main.zip
	    rm $basedir/solo-mining-scripts
	    exit 1
	fi


	if [ -f "$pha_installdir/scripts/uninstall.sh" ]; then
		echo "删除旧的 Phala 脚本"
		$pha_installdir/scripts/uninstall.sh
	fi

	echo "安装新的 Phala 脚本"
	mkdir -p $pha_installdir

	cp $basedir/solo-mining-scripts/config.json $pha_installdir/
	cp -r $basedir/solo-mining-scripts/scripts/cn $pha_installdir/scripts
	chmod 777 -R $pha_installdir

	echo "安装 Phala 命令行工具"
	cp $basedir/solo-mining-scripts/scripts/cn/phala.sh /usr/bin/phala
	chmod 777 /usr/bin/phala

	$basedir/solo-mining-scripts/install.sh --registry cn
	if [ $? -ne 0 ]; then
	    echo "Install phala node failed"
	    rm $basedir/main.zip
	    rm -rf $basedir/solo-mining-scripts
	    exit 1
	fi

	rm $basedir/main.zip
	rm -rf $basedir/solo-mining-scripts
	echo "------------安装成功-------------"
	sudo phala install
}



set_docker_config()
{
  mkdir -p /etc/docker/
  echo "{
    \"registry-mirrors\" : [
      \"http://ovfftd6p.mirror.aliyuncs.com\",
      \"http://registry.docker-cn.com\",
      \"http://docker.mirrors.ustc.edu.cn\",
      \"http://hub-mirror.c.163.com\"
    ],
    \"insecure-registries\" : [
      \"registry.docker-cn.com\",
      \"docker.mirrors.ustc.edu.cn\"
    ],
    \"graph\": \"/opt/docker\",
    \"debug\" : true,
    \"experimental\" : true
  }
  " > /etc/docker/daemon.json

  service docker restart
	if [ $? -ne 0 ]; then
	    echo "docker restart failed"
	    exit 1
	fi
}



function echo_c()
{
	printf "\033[0;$1m$2\033[0m\n"
}

function log_info()
{
	echo_c 33 "$1"
}

function log_success()
{
	echo_c 32 "$1"
}

function log_err()
{
	echo_c 35 "$1"
}


if [ $(id -u) -ne 0 ]; then
	echo "Please run with sudo!"
	echo "请使用sudo运行!"
	exit 1
fi


install_depenencies
set_docker_config
install_phala

