#!/bin/bash
SSSH_HOME=`dirname $0`
AUTHFILE=$SSSH_HOME/ssh-passwd.conf

if [ -z `echo $1 | cut -d' ' -f1 | grep :` ];then
  action=1 # upload
else
  action=0 # download
fi

if [ $action -eq 1 ];then
  target=`echo $2 | awk -F':' '{print $1}'`
  file=`echo $2 | awk -F':' '{print $2}'`
  destination=$1
else
  target=`echo $1 | awk -F':' '{print $1}'`
  file=`echo $1 | awk -F':' '{print $2}'`
  if [ -z $2 ];then
    destination=.
  else
    destination=$2
  fi
fi

count=`grep "$target" $AUTHFILE -c`
aliasname=`grep "$target" $AUTHFILE | awk '{print $1}'`
targetfullname=`grep "$target" $AUTHFILE | awk '{print $2}'`
user=`grep "$target" $AUTHFILE | awk '{print $3}' | awk -F ':' '{print $1}'`
passwd=`grep "$target" $AUTHFILE | awk '{print $3}' | awk -F ':' '{print $2}'`
encoding=`grep "$target" $AUTHFILE | awk '{print $4}'`
if [ $count -gt 1 ];then
  echo -e '查找到以下主机'
  arralias=($aliasname)
  arrtarget=($targetfullname)
  arruser=($user)
  arrpasswd=($passwd)
  arrencoding=($encoding)
  length=${#arrtarget[@]}
  for ((i=0; i<$length; i++))
  do
    echo -e '[\033[4;34m'$(($i+1))'\033[0m]\t'${arralias[$i]}'\t'${arruser[$i]}@${arrtarget[$i]}
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
fi

if [ -z $targetfullname ] || [ -z $user ] || [ -z $passwd ];then
  echo "配置文件中没有查找到匹配的信息";
  exit 1;
fi
if [ -z $encoding ];then
  encoding=UTF-8
fi
target=$targetfullname

route=`echo $target | awk -F'.' '{print $1"."$2".0.0"}'`
routes=`echo $target | awk -F'.' '{print $1"."$2}'`
# isroute=`route -n | grep $route`
isroute=`netstat -nr | grep -w $routes`
if [ -z "$isroute" ];then
  $SSSH_HOME/ssh-addroute.sh $route
fi

if [ $action -eq 1 ];then
  $SSSH_HOME/scp-expect-upload.sh $user $target $file "$destination" $passwd
else
  $SSSH_HOME/scp-expect-download.sh $user $target "${file// /\\ }" $destination $passwd
fi
