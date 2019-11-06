#!/bin/bash

echo -e "\033[45;37mWelcome to the Live Streams Installer\033[0m"

# OS Reminder
oscheck="Y"
read -p "Are you sure the script is running on CentOS 7/8? [Y/n]: " oscheck
if [ "$oscheck"x != "Y"x ]
then
    echo -e "\033[47;31mSorry, but you can only run the installer on CentOS 7/8.\033[0m"
    exit 0
fi

# Source Selector
protocol="4"
read -p "Which protocol(IPv4 or IPv6) do you want to access upstream? [4/6]: " protocol
source="bupt"
#read -p "Which upstream do you want to use? [bupt]: " source

echo -e "\033[45;37mStarting Live Streams Forwarder Installation...\033[0m"

# Software packages Installation
echo -e "\033[34mStart Installing Needed Packages via Yum...\033[0m"
yum install wget net-tools net-snmp chrony nginx -y
echo -e "\033[32mPackages Installation Finished.\033[0m"

# Switch off selinux
echo -e "\033[34mStart Switching off SELinux...\033[0m"
setenforce 0
sed -i "s/SELINUX=.*/SELINUX=disabled/g" /etc/selinux/config
echo -e "\033[32mSELinux Configuration Finished.\033[0m"

# NTP & SNMP Config
echo -e "\033[34mStart Configuring NTP & SNMP Services...\033[0m"
echo "rocommunity CampUsVidEo" >> /etc/snmp/snmpd.conf
systemctl start chronyd
systemctl enable chronyd
systemctl start snmpd
systemctl enable snmpd
echo -e "\033[32mNTP & SNMP Configurations Finished.\033[0m"

# Download Player
#echo -e "\033[34mStart Downloading Test Web...\033[0m"
#wget "http://202.112.62.138/forwarder-test.tar.gz"
#tar zxf forwarder-test.tar.gz
#cp -r forwarder-test /var/
#echo -e "\033[32mTest Web Download Finished.\033[0m"

# Download Nginx Conf & Restart Nginx
echo -e "\033[34mStart Configuring Nginx...\033[0m"
url="http://202.112.62.138/nginx-$source-$protocol.conf"
wget -O nginx.conf.forwarder $url
cp -f nginx.conf.forwarder /etc/nginx/
mv -f /etc/nginx/nginx.conf.forwarder /etc/nginx/nginx.conf
systemctl start nginx
systemctl enable nginx
echo -e "\033[32mNginx Configurations Finished.\033[0m"

# Finish Tips & Firewall Reminder
#echo -e "\033[45;32mThe installation has finished. Now you can check stream by http://SERVER_IP/test.html. You Should see CCTV1HD.\033[0m" 
echo -e "\033[45;32mThe installation has finished. \033[0m" 
echo -e "\033[45;32mDon't forget to set the firewall. Here is the guidance: https://github.com/CampusVideo/forwarder/blob/master/firewall.md\033[0m" 

