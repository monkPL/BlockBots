#!/bin/bash

#iptables binary
IPT=/sbin/iptables
#direcotry
TDIR=/root/security
#log direcotry
LDIR=/var/log
#php binary
PHP=/usr/bin/php

cd $TDIR
if [[ ! -e secure.db ]]; then
    sqlite3 secure.db "CREATE TABLE blocked (dt date NOT NULL, ip varchar(16) NOT NULL)";
fi
exit 0;

# 

cd $LDIR
#bad logins FTP
cat messages | grep '\[WARNING\]' | awk '{ print $1, $2, $3";"$6";"$12}' | sed "s/[()@?]//g" >>$TDIR/ftp_warn.csv

#bad logins SSH
cat auth.log | grep 'Failed password'| awk '{print $1,$2,$3";"substr($0, index($0,$6)) }' >>$TDIR/ssh_warn.csv

#good logins FTP (data;host;login)
cat messages | grep 'now logged in' | awk '{ print $1, $2, $3";"$6";"$8}' | sed "s/[()@?]//g" >>$TDIR/ftp_login.csv

#good logins SSH
cat auth.log | grep 'Accepted password' | awk '{print $1,$2,$3";"substr($0, index($0,$6)) }' >>$TDIR/ssh_login.csv

cd $TDIR
$PHP -f parselog.php

#clear iptables INPUT
$IPT -F INPUT

# block IP from logs
while read -r ip
do
    $IPT -A INPUT -s $ip -j DROP
done < blockedip.db

# add other iptables rules
#$IPT -A INPUT -s xxx.xxx.xxx.xxx -j DROP

#remove file from blockbots script
rm /tmp/bots.txt
