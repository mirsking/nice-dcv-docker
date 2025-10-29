#!/bin/bash
USERNAME=ubuntu
if [ -z "$2" ]; then
    if [ -z "$1" ]; then
        PASSWD=ubuntu
    else
        PASSWD=$1
    fi
else
    USERNAME=$1
    PASSWD=$2
fi

useradd ${USERNAME} -s /bin/bash
usermod -aG sudo ${USERNAME}
usermod -aG video ${USERNAME}
echo "${USERNAME}:${PASSWD}" |chpasswd
sed -i 's/USERNAME/'"${USERNAME}"'/g' /usr/lib/systemd/system/dcvserver.service

res1=`systemctl enable dcvserver 2>&1`

exec /usr/sbin/init
