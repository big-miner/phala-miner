#!/usr/bin/env python
# -*- coding: utf-8 -*-
import pandas
# 注意事项
# MASTER_IP={填写MASTER_IP} 需要填写
# OPERATOR = '{矿池地址}': 需要填写矿池地址
# account.csv 是 https://github.com/big-miner/miner-key 批量生成的账号文件
# ip.csv 是为ansible 对应的server地址
df = pandas.read_csv("account.csv")

env = """NODE_IMAGE=phalanetwork/khala-node
PRUNTIME_IMAGE=phalanetwork/phala-pruntime
PHERRY_IMAGE=phalanetwork/phala-pherry
NODE_VOLUMES=/opt/phala/data/khala-node:/root/data
PRUNTIME_VOLUMES=/opt/phala/data/khala-pruntime-data:/root/data
CORES={CORES}
NODE_NAME={NODE_NAME}
MNEMONIC={MNEMONIC}
GAS_ACCOUNT_ADDRESS={GAS_ACCOUNT_ADDRESS}
OPERATOR={OPERATOR}
MASTER_IP={填写MASTER_IP}
DCAP_1804=https://download.01.org/intel-sgx/latest/dcap-latest/linux/distro/ubuntu18.04-server/sgx_linux_x64_driver_1.41.bin
DCAP_2004=https://download.01.org/intel-sgx/latest/dcap-latest/linux/distro/ubuntu20.04-server/sgx_linux_x64_driver_1.41.bin
ISGX_1804=https://download.01.org/intel-sgx/latest/linux-latest/distro/ubuntu18.04-server/sgx_linux_x64_driver_2.11.0_2d2b795.bin
ISGX_2004=https://download.01.org/intel-sgx/latest/linux-latest/distro/ubuntu20.04-server/sgx_linux_x64_driver_2.11.0_2d2b795.bin
version=0.1.5"""

CORES = 4
NODE_NAME = 'node_{}'
OPERATOR = '{矿池地址}'

# ip.csv 为ansible 对应的server地址
ip = pandas.read_csv("ip.csv", header=None)

for i in range(0, len(df.index)):
    with open("{}.env".format(ip[0][i]), "w") as env_file:
        env_file.write(env.format(CORES=CORES, NODE_NAME=NODE_NAME.format(ip[0][i]), MNEMONIC=df['secret_phrase'][i],
                                  GAS_ACCOUNT_ADDRESS=df['ss58'][i], OPERATOR=OPERATOR))
