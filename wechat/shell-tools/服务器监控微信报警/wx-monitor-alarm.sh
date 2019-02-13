#!/bin/sh

expireTime=7200

dbFile="db.json"

# "我的企业" 最下面
corpid=ww325b7d062f7f62dc

# "企业应用" 第一行
agentid="1000002"

# "企业应用" 第二行
corpsecret=fxMp0bIM8fY5_Z47vWXTGf5Se37ze4q7K2dwk7fwqKc

# "通讯录"->"成员详情" 的帐号
touser="CheHongBin" 

# "通讯录" 左侧部门最右边的三个点里的ID
toparty="2"

content="服务器快崩了，你还在这里吟诗作对？"


if [ ! -f "$dbFile" ];then
        touch "$dbFile"
fi

# 获取token
req_time=`cat  $dbFile | grep "req_time" | awk -F ":" '{print $2}' | tr -d " "| tr -d "\r"`
current_time=$(date +%s)
refresh=false
if [ ! -n "$req_time" ];then
    refresh=true
    echo req_time: $req_time
else
    if [ $((${current_time}-${req_time})) -gt $expireTime ];then
    refresh=true
    fi
fi
echo refresh: $refresh
if $refresh ;then
	req_access_token_url=https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=$corpid\&corpsecret=$corpsecret
	access_res=$(curl -s -G $req_access_token_url | jq -r '.access_token')

	## 保存文件
	echo "" > $dbFile
	echo -e "{" > $dbFile
	echo -e "\t\"access_token\":\"$access_res\"," >> $dbFile
	echo -e "\t\"req_time\":$current_time" >> $dbFile
	echo -e "}" >> $dbFile

	echo ">>>刷新Token成功<<<"
fi 

## 发送消息
msg_body="{\"touser\":\"$touser\",\"toparty\":\"$toparty\",\"msgtype\":\"text\",\"agentid\":$agentid,\"text\":{\"content\":\"$content\"}}"
access_token=`jq -r '.access_token' $dbFile`
req_send_msg_url=https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=$access_token
req_msg=$(curl -s -H "Content-Type: application/json" -X POST -d $msg_body $req_send_msg_url | jq -r '.errmsg')

echo "触发报警发送动作，返回信息为：" $req_msg





