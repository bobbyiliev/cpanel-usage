#!/bin/bash

##
# Check Bandwidth and Disk Usage for All Accounts
# 2017 Bobby I. 
##

##
# Just use this as cron job, here's an example
# chmod u+x /root/current-usage/usage.sh
# crontab -e
# And add:
# # Check Bandwidth and Disk Usage for All Accounts
# 0 7 * * * /root/current-usage/usage.sh
##

# Get hostname
servername=$(hostname)

# Enable Email report - Change to 1 to enable
mailreport=0

# Enter your Email address
email="youremail@yourdomain.com"

# Enter your name
yourname="Your Name"

# This would craete temp dir if it doesn't exist:
if [ ! -d /root/current-usage ]; then
  mkdir -p /root/current-usage ;
fi


echo "Greetings ${yourname}," > /root/current-usage/report.txt
echo "" >>/root/current-usage/report.txt
echo "Bandwidth and Disk Usage for $servername" >> /root/current-usage/report.txt
echo ""	>> /root/current-usage/report.txt

for i in $(ls -l /var/cpanel/bandwidth.cache | grep -v 'drwx' | awk '{ print $9}'); do 
	
	echo "" >> /root/current-usage/report.txt
	echo '####' >> /root/current-usage/report.txt
	echo "Domain/Username : ${i}" >> /root/current-usage/report.txt
	echo 'Bandwidth Usage:' >> /root/current-usage/report.txt
	cat /var/cpanel/bandwidth.cache/${i} | awk '{ foo = $1 / 1024 / 1024 ; print foo "MB" }' >> /root/current-usage/report.txt
	echo '' >> /root/current-usage/report.txt
	echo "Disk Usage for ${i}" >> /root/current-usage/report.txt
	echo '' >> /root/current-usage/report.txt
	if $(echo "$i" | grep -q '.'); then
		username=$(grep ${i} /etc/userdomains | tail -1 | awk -F: '{ print $2 }')
		if [ ! -z $username ]; then
			quota -su ${username}  >> /root/current-usage/report.txt
		else 
			echo "Note, if there is no data, this means that the domain name is a subdomain or a parked domain - check the info for the main account!"  >> /root/current-usage/report.txt
		fi
	else
		quota -su ${i} >> /root/current-usage/report.txt
	fi
	echo '###' >> /root/current-usage/report.txt
	echo "" >> /root/current-usage/report.txt
done

sleep 1

if [[ $mailreport == 1 ]] ; then
        mail -s "Bandwidth and Disk Usage: $servername" $email < /root/current-usage/report.txt
fi
