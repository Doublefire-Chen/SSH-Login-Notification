#! /bin/bash
#-----------------------------------------------------#
#                                                     #
#     Author: doublefire.chen                         #
#     Original_author: xingdp                         #
#     Date:2023-10-14                                 #
#     Name:ssh_email.sh                               #
#     Version: V1.0                                   #
#     Description:SSH remote online mail reminder     #
#                                                     #
#-----------------------------------------------------#

if [ -z "${SSH_CONNECTION}" ];then
    echo '$SSH_CONNECTION:not exists'
    exit 0
fi

# 某用户不需要提醒
if [ "${user}" == "git" ];then
    exit 0
fi

# 某IP段不需要提醒
#ip_exit=`echo ${from_ip}|cut -d "." -f 1,2,3`
#if [ "${ip_exit}" == "192.168.1" ];then
#exit 0
#fi

cd ~

# 定义变量  
from_ip=`echo ${SSH_CONNECTION} | awk '{print$1}'`
from_port=`echo ${SSH_CONNECTION} | awk '{print$2}'`
server_ip=`echo ${SSH_CONNECTION} | awk '{print$3}'`
from_regeion=`./nali ${from_ip} | awk '{ for (i = 2; i <= NF; i++) { output = output $i " " } print output }'`
user=`echo ${LOGNAME}`
hostname_1=`echo ${HOSTNAME} "(" $server_ip ")"`
server_time=`echo $(date +"%Y-%m-%d %R")`

# 发送邮件
echo -e "
*********** 服务器登录提醒 ***********\n

    登录主机：  ${hostname_1}\n
    登录用户：  ${user}\n
    登录时间：  ${server_time}\n
    登录IP地址：${from_ip}\n
    登录IP端口：${from_port}\n
    登录IP区域：${from_regeion}\n

**************************************"
# 使用curl将server_ip作为POST请求的JSON数据发送给服务器
JSON="{\"hostname_1\": \"${hostname_1}\",\"user\": \"${user}\",\"server_time\": \"${server_time}\",\"from_ip\": \"${from_ip}\",\"from_port\": \"${from_port}\",\"from_region\": \"${from_regeion}\"}"
curl -s -o /dev/null 'https://your_prometheus_alert_domain/prometheusalert?type=email&tpl=graylog2-email' \
  --data-raw "${JSON}" \
  --compressed

