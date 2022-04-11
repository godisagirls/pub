#!/bin/bash
# yum install -y wget && wget -O install.sh https://godisagirls.github.io/pub/install.sh && sh install.sh

sudo yum remove -y $(yum list installed|grep docker | awk '{print $1}' )
sudo yum install -y yum-utils
##添加yum源
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum makecache fast
sudo yum install -y docker-ce docker-ce-cli containerd.io unzip
#特定版本docker
#yum list docker-ce --showduplicates | sort -r
#sudo yum install docker-ce-<VERSION_STRING> docker-ce-cli-<VERSION_STRING> containerd.io
systemctl start docker
#设置开机启动
systemctl enable docker
##验证是否安装成功
docker info
#docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
#curl -L "https://get.daocloud.io/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose


wget https://godisagirls.github.io/pub/work.zip
unzip work.zip


# 随机端口
RANDPORT=$((RANDOM+20000))

cat <<EOF > ./docker-compose.yml
version: "3.3"
services:
  wireguard:
    restart: always
    build: ./work
    volumes:
      - ./work/sh:/work/sh
      - ./work/wireguard:/work/wireguard
      - ./work/log:/work/log
      - ./work/zabbix:/work/zabbix
      - /lib/modules:/lib/modules
      - /lib64/:/lib64/
    ports:
      - '$RANDPORT:$RANDPORT/udp'
    command: /work/sh/x.sh
    privileged: true
    environment:
      - WG0_ADDR=100.0.0.1/8
      - WG0_PORT=$RANDPORT
      - LINETYPE=CN2XX
      - LINEID=1            #1hk   5hkvip
      - LINEIS_PC=0
      - BANDWIDTH_TYPE=0    #0:固定带宽.1:按流量付费
      - GROUP_ID=0          #线路等级
      - MAX_BANDWIDTH=100   #最大带宽(M)
      - MAX_NUM=500
      - SALT=
      - POSTURL=http://34.92.73.63/api/route_sync
      - PEER_BANDWIDTH=2 #单个peer限速
      - LOG_LEVEL=debug
EOF

chmod +x ./work/sh/*.sh
docker-compose build
docker-compose up -d


