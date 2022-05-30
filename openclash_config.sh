#!/bin/bash

end="\033[0m"
red="\033[0;31m"
green="\033[0;32m"

webget(){
	#参数【$1】代表下载目录，【$2】代表在线地址
	#参数【$3】代表输出显示，【$4】不启用重定向
	if curl --version > /dev/null 2>&1;then
		[ "$3" = "echooff" ] && progress='-s' || progress='-#'
		[ -z "$4" ] && redirect='-L' || redirect=''
		result=$(curl -w %{http_code} --connect-timeout 5 $progress $redirect -ko $1 $2)
	else
		if wget --version > /dev/null 2>&1;then
			[ "$3" = "echooff" ] && progress='-q' || progress='-q --show-progress'
			[ "$4" = "rediroff" ] && redirect='--max-redirect=0' || redirect=''
			certificate='--no-check-certificate'
			timeout='--timeout=3'
		fi
		[ "$3" = "echoon" ] && progress=''
		[ "$3" = "echooff" ] && progress='-q'
		wget $progress $redirect $certificate $timeout -O $1 $2 
		[ $? -eq 0 ] && result="200"
	fi
}

    token=$(cat /etc/openclash/config/openclash.yaml |  awk '/'dler'/ {print substr($2,30,20)}' |head -n 1)
    echo -e "${green}openclash.yaml 备份配置！${end}"
    mv /etc/openclash/config/openclash.yaml /etc/openclash/config/openclash_bak.`date "+%Y.%m.%d.%H:%M"`.yaml
    echo -e "${green}openclash.yaml 开始下载！${end}"
    #webget /etc/openclash/config/openclash.yaml https://cdn.jsdelivr.net/gh/fjjonline/op@master/openclash.yaml
	
    webget /etc/openclash/config/openclash.yaml https://github.cooluc.com/https://raw.githubusercontent.com/fjjonline/op/main/openclash.yaml

    if [[ "$result" != "200" ]]; then
    echo -e "${red}openclash.yaml 下载失败!${end}"
    exit 1
    fi
    echo -e "${green}openclash.yaml 下载成功!${end}" 

    sed -i  's/'token'/'"${token}"'/g'  /etc/openclash/config/openclash.yaml
    echo -e "${green}openclash 重启服务！${end}"
    /etc/init.d/openclash restart  >> /dev/null 2>&1
    echo -e "${green}openclash 更新配置完成！${end}"

