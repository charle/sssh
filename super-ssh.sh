#!/bin/bash
SSSH_HOME=`dirname $0`
AUTHFILE=$SSSH_HOME/ssh-passwd.conf

if [ -z $1 ];then
  target=:
else
  target=$1
fi
count=`grep "$target" $AUTHFILE -c`
aliasname=`grep "$target" $AUTHFILE | awk '{print $1}'`
targetfullname=`grep "$target" $AUTHFILE | awk '{print $2}'`
user=`grep "$target" $AUTHFILE | awk '{print $3}' | awk -F ':' '{print $1}'`
passwd=`grep "$target" $AUTHFILE | awk '{print $3}' | awk -F ':' '{print $2}'`
encoding=`grep "$target" $AUTHFILE | awk '{print $4}'`
port=`grep "$target" $AUTHFILE | awk '{print $5}'`
if [ $count -gt 1 ];then
  echo -e '查找到以下主机'
  arralias=($aliasname)
  arrtarget=($targetfullname)
  arruser=($user)
  arrpasswd=($passwd)
  arrencoding=($encoding)
  arrport=($port)
  length=${#arrtarget[@]}
  for ((i=0; i<$length; i++))
  do
    echo -e '[\033[4;34m'$(($i+1))'\033[0m]\t'${arralias[$i]}'\t'${arruser[$i]}@${arrtarget[$i]}:${arrpasswd[$i]}
  done
  echo -n "请选择序号 (0)："
  read choice
  if [ -z $choice ] || [ $choice -eq 0 ];then
    exit 1;
  fi
  targetfullname=${arrtarget[$(($choice-1))]}
  user=${arruser[$(($choice-1))]}
  passwd=${arrpasswd[$(($choice-1))]}
  encoding=${arrencoding[$(($choice-1))]}
  port=${arrport[$(($choice-1))]}
fi

if [ -z $targetfullname ] || [ -z $user ] || [ -z $passwd ];then
  echo "配置文件中没有查找到匹配的信息";
  exit 1;
fi
if [ -z $encoding ];then
  encoding=UTF-8
fi
if [ -z $port ];then
  port=22
fi
target=$targetfullname

route=`echo $target | awk -F'.' '{print $1"."$2".0.0"}'`
routes=`echo $target | awk -F'.' '{print $1"."$2}'`
# isroute=`route -n | grep $route`
isroute=`netstat -nr | grep -w $routes`
if [ -z "$isroute" ];then
  # $SSSH_HOME/ssh-addroute.sh $route
fi
$SSSH_HOME/ssh-expect.sh $user $target $passwd $encoding $port
