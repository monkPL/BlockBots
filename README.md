# README #
Use this if you want to block unauthorised logins (read from server logs) and block most bots and crawler on your site

Put this in your cron.

security.sh - once on the day
ex: 
*/5 * * * * cd /root; /bin/bash blockbots.sh

blockbots.sh - you can use every 5 minutes
ex:
50 23 * * * cd /root/security; /bin/bash security.sh

## REQUIREMENTS ##
PHP
BASH
SQLITE
IPTABLES
