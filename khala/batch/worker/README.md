# khala worker 批量部署(node分离模式)

```
sudo apt install python3-pip
pip3 install pandas -i http://pypi.douban.com/simple/ --trusted-host pypi.douban.com
```


## step1: 下载批量安装脚本

```shell
cd /home/abc/workspace
git clone https://github.com/Phala-Network/solo-mining-scripts.git
```


## step2: 


```shell
ansible pha2 -m copy -a "src=/home/abc/workspace/solo-mining-scripts dest=/home/abc/workspace/ mode=0777" -u abc --sudo

```


## step3:

```shell
ansible pha2  -m script -a "/home/abc/workspace/install.sh" -u abc --sudo
ansible pha2  -m script -a "sudo phala install" -u abc --sudo
```

## step4: master批量生产env 配置文件

```shell
python batch_env.py
```


## step5:master批量生产env 配置文件到worker机器

```shell
bash ansile.sh
```


## step6:

```shell
ansible pha2 -m copy -a "src=/home/abc/workspace/docker-compose.yml dest=/opt/phala/ mode=0777" -u abc --sudo
```

## step7: 最后批量启动


```shell
ansible pha2 -a "sudo phala start" -m shell --sudo
```
