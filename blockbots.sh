#!/bin/bash

threshold=100
# log files to parse
apachelogfiles="/var/log/apache2/access.log"

if [ ! -f /tmp/bots.txt ];
then
    touch /tmp/bots.txt
fi

timestamp=$(date)
for logfile in $apachelogfiles ; do
	/bin/cat ${logfile} | cut -d\  -f -1,12- | grep -iE 'bot|crawler|spider' | grep -viE 'google|bingbot|yandex' | /usr/bin/awk '{print $1}' | /usr/bin/sort | /usr/bin/uniq -c | /usr/bin/sort -n | while read line
        do num=$(echo ${line} | /usr/bin/awk '{print $1}')
        ip=$(echo ${line} | /usr/bin/awk '{print $2}')

	if [ $num -gt $threshold ];then
            if ! /bin/grep -Fxq ${ip} /tmp/bots.txt
            then
		    echo Num ${num} and IP ${ip}
                    /sbin/iptables -A INPUT -s ${ip} -j DROP
                    echo ${ip} >>/tmp/bots.txt
            fi
	fi
        done

done
