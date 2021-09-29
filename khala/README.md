# khala 集群模式

## master机器同步节点数据同时跑数据

<p align="center">
  <img src="docs/master2.png" width="50%" syt height="50%" />
</p>





### step1: 先在master 机器部署官方的solo 节点



[官方solo节点](https://wiki.phala.network/zh-cn/docs/khala-mining/)

也可以直接

```
git clone https://github.com/big-miner/phala-miner.git
cd phala-miner && sudo chmod -R 755 * && sudo ./install.sh
```
上面命令是对官方的脚步安装做了一点优化

```
sudo phala config set
```
设置完成，之后直接

```
sudo phala start
```

`注意事项`

```diff
+ 官方默认放在系统盘,个人认为不合适，需要修改一下默认数据存储在 /opt 目录下，挂载硬盘请挂载这个目录,或者修改自行修改其他目录
```

比如master 下`/opt/phala/.env`种 `NODE_VOLUMES` 和 `PRUNTIME_VOLUMES`修改如下:

```
NODE_IMAGE=phalanetwork/khala-node
PRUNTIME_IMAGE=phalanetwork/phala-pruntime
PHERRY_IMAGE=phalanetwork/phala-pherry
NODE_VOLUMES=/opt/phala/data/khala-node:/root/data
PRUNTIME_VOLUMES=/opt/phala/data/khala-pruntime-data:/root/data
CORES=20
NODE_NAME=m1
MNEMONIC=xxx
GAS_ACCOUNT_ADDRESS=xxx
OPERATOR=xxx
DCAP_1804=https://download.01.org/intel-sgx/latest/dcap-latest/linux/distro/ubuntu18.04-server/sgx_linux_x64_driver_1.41.bin
DCAP_2004=https://download.01.org/intel-sgx/latest/dcap-latest/linux/distro/ubuntu20.04-server/sgx_linux_x64_driver_1.41.bin
ISGX_1804=https://download.01.org/intel-sgx/latest/linux-latest/distro/ubuntu18.04-server/sgx_linux_x64_driver_2.11.0_2d2b795.bin
ISGX_2004=https://download.01.org/intel-sgx/latest/linux-latest/distro/ubuntu20.04-server/sgx_linux_x64_driver_2.11.0_2d2b795.bin
version=0.1.6
```


### step2: worker 机器配置

worker 除了安装脚本和依赖之外，机器的配置要替换两个文件`.env` 和 `docker-compose.worker.yml`,放到 worker 机器的/`opt/phala` 下面


其中`.env`,修改为你对应的参数

```shell
NODE_IMAGE=phalanetwork/khala-node
PRUNTIME_IMAGE=phalanetwork/phala-pruntime
PHERRY_IMAGE=phalanetwork/phala-pherry
NODE_VOLUMES=/opt/phala/data/khala-node:/root/data
PRUNTIME_VOLUMES=/opt/phala/data/khala-pruntime-data:/root/data
CORES=${核心数}
NODE_NAME=${节点名字}
MNEMONIC=${GAS 账号 secret_phrase}
GAS_ACCOUNT_ADDRESS=${GAS 账号 地址}
OPERATOR=${矿池持币地址}}
MASTER_IP=${MASTER_IP}
DCAP_1804=https://download.01.org/intel-sgx/latest/dcap-latest/linux/distro/ubuntu18.04-server/sgx_linux_x64_driver_1.41.bin
DCAP_2004=https://download.01.org/intel-sgx/latest/dcap-latest/linux/distro/ubuntu20.04-server/sgx_linux_x64_driver_1.41.bin
ISGX_1804=https://download.01.org/intel-sgx/latest/linux-latest/distro/ubuntu18.04-server/sgx_linux_x64_driver_2.11.0_2d2b795.bin
ISGX_2004=https://download.01.org/intel-sgx/latest/linux-latest/distro/ubuntu20.04-server/sgx_linux_x64_driver_2.11.0_2d2b795.bin
version=0.1.6
```




```diff
version: "3"
services:
 phala-pruntime:
   image: ${PRUNTIME_IMAGE}
   container_name: phala-pruntime
   hostname: phala-pruntime
   ports:
    - "8000:8000"
   devices:
      - /dev/sgx_enclave
      - /dev/sgx_provision
+      - /dev/isgx

   environment:
    - EXTRA_OPTS=--cores=${CORES}
    - ROCKET_ADDRESS=0.0.0.0
   volumes:
    - ${PRUNTIME_VOLUMES}

 phala-pherry:
   image: ${PHERRY_IMAGE}
   container_name: phala-pherry
   hostname: phala-pherry
   depends_on:
    - phala-pruntime
   restart: always
   entrypoint:
    [
      "/root/pherry",
      "-r",
      "--parachain",
      "--mnemonic=${MNEMONIC}",
      "--substrate-ws-endpoint=ws://${MASTER_IP}:9945",
      "--collator-ws-endpoint=ws://${MASTER_IP}:9944",
      "--pruntime-endpoint=http://phala-pruntime:8000",
      "--operator=${OPERATOR}",
      "--fetch-blocks=512",
    ]
```


`tips`

- 1、phala-pruntime中的devices需要根据你的环境进行更改

如果你是安装下面驱动，那么配置就是上面

```
sudo phala install dcap
sudo phala install isgx
```

- 2、master_ip 就是你的solo 节点的机器IP


之后:

```
cd /opt/phala
sudo docker-compose -f docker-compose.worker.yml up -d
```