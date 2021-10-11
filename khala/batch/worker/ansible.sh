#!/usr/bin/env bash

basedir=$(cd `dirname $0`;pwd)

ip_list=$basedir/ip.csv



for  i  in  `cat $ip_list`
do
    src_path=$basedir/$i.env
    ansible $i -m copy -a "src=$src_path dest=/opt/phala/.env mode=0777" -u abc --sudo
    sleep 1
done
