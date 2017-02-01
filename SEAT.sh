#!/bin/bash

#Author:  Ryan Clark
#Company: Northrop Grumman
#Email:   william.clark@ngc.com
#Date:    05/05/2016
#
#Version   Change                    Date
###############################################
#1.0       Initial Release           05/05/2016
#
 
#Pre-Installation Test
function Pre_Test {
/usr/bin/echo -e "\e[92mGenerating a pre-installation baseline of user accounts\n"
/usr/bin/cp /etc/passwd /tmp/oldpasswd
/usr/bin/cp /etc/group /tmp/oldgroup
/usr/bin/sleep 1

/usr/bin/echo -e "\e[92mGenerating a pre-installation baseline of listening ports\n"
/bin/netstat -antup | grep LISTEN >/tmp/oldnet
/usr/bin/sleep 1

/usr/bin/echo -e "\e[92mGenerating a pre-installation baseline of mount points\n"
/usr/bin/df >/tmp/olddf
/usr/bin/mount > /tmp/oldmount
if [[ $(findsmb 2>/dev/null) ]] 
then
    findsmb >/tmp/oldsmb
fi
/usr/bin/sleep 1

/usr/bin/echo -e "\e[92mGenerating a pre-installation baseline of cron jobs\n"
/usr/bin/crontab -l >/tmp/oldcron
/usr/bin/sleep 1

/usr/bin/echo -e "\e[92mGenerating a pre-installation baseline of security compliance\n"
/usr/bin/sleep 1

}

#Post-Installation Test
function Post_Test {
/usr/bin/echo -e "\e[92mGenerating a post-installation baseline of user accounts\n"
/usr/bin/cp /etc/passwd /tmp/newpasswd
/usr/bin/cp /etc/group /tmp/newgroup
/usr/bin/sleep 1

/usr/bin/echo -e "\e[92mGenerating a post-installation baseline of listening ports\n"
/bin/netstat -antup | grep LISTEN >/tmp/newnet
/usr/bin/sleep 1

/usr/bin/echo -e "\e[92mGenerating a post-installation baseline of mount points\n"
/usr/bin/df >/tmp/newdf
/usr/bin/mount > /tmp/newmount
if [[ $(findsmb 2>/dev/null) ]]
then
    findsmb >/tmp/newsmb
fi
/usr/bin/sleep 1

/usr/bin/echo -e "\e[92mGenerating a post-installation baseline of cron jobs\n"
/usr/bin/crontab -l >/tmp/newcron
/usr/bin/sleep 1

/usr/bin/echo -e "\e[92mGenerating a post-installation baseline of security compliance\n"
/usr/bin/sleep 1
}

#Compare pre/post tests
function Compare {
/usr/bin/echo -e "\e[92mChecking for new user accounts\n" | /usr/bin/tee -a /tmp/SEAT_FINDINGS
/usr/bin/echo -e "\e[91m" | /usr/bin/tee -a /tmp/SEAT_FINDINGS
/usr/bin/diff /tmp/oldpasswd /tmp/newpasswd
if [[ $? -eq 0 ]]
then
   /usr/bin/echo -e "\033[0m     No new user accounts found\n" | /usr/bin/tee -a /tmp/SEAT_FINDINGS
else
   /usr/bin/diff /tmp/oldpasswd /tmp/newpasswd >>/tmp/SEAT_FINDINGS
fi
/usr/bin/sleep 1

/usr/bin/echo -e "\e[92mChecking for new listening ports\n" | /usr/bin/tee -a /tmp/SEAT_FINDINGS
/usr/bin/echo -e "\e[91m" | /usr/bin/tee -a /tmp/SEAT_FINDINGS
/usr/bin/diff /tmp/oldnet /tmp/newnet
if [[ $? -eq 0 ]]
then
   /usr/bin/echo -e "\033[0m     No new listening ports found\n" | /usr/bin/tee -a /tmp/SEAT_FINDINGS
else
   /usr/bin/diff /tmp/oldnet /tmp/newnet >>/tmp/SEAT_FINDINGS
fi
/usr/bin/sleep 1

/usr/bin/echo -e "\e[92mChecking for new mount points\n" | /usr/bin/tee -a /tmp/SEAT_FINDINGS
/usr/bin/echo -e "\e[91m" | /usr/bin/tee -a /tmp/SEAT_FINDINGS
/usr/bin/diff /tmp/oldmount /tmp/newmount
if [[ $? -eq 0 ]]
then
   /usr/bin/echo -e "\033[0m     No new mount points found\n" | /usr/bin/tee -a /tmp/SEAT_FINDINGS
else
   /usr/bin/diff /tmp/oldmount /tmp/newmount >>/tmp/SEAT_FINDINGS
fi
/usr/bin/sleep 1

/usr/bin/echo -e "\e[92mChecking for new cron jobs\n" | /usr/bin/tee -a /tmp/SEAT_FINDINGS
/usr/bin/echo -e "\e[91m" | /usr/bin/tee -a /tmp/SEAT_FINDINGS
/usr/bin/diff /tmp/oldcron /tmp/newcron
if [[ $? -eq 0 ]]
then
   /usr/bin/echo -e "\033[0m     No new cron jobs found\n" | /usr/bin/tee -a /tmp/SEAT_FINDINGS
else
   /usr/bin/diff /tmp/oldcron /tmp/newcron >>/tmp/SEAT_FINDINGS
fi
/usr/bin/sleep 1

/usr/bin/echo -e "\e[92mChecking for security compliance changes\n" | /usr/bin/tee -a /tmp/SEAT_FINDINGS
/usr/bin/echo -e "\e[91m" | /usr/bin/tee -a /tmp/SEAT_FINDINGS
#/usr/bin/diff /root/old-audit-findings /root/new-audit-findings
if [[ $? -eq 0 ]]
then
   /usr/bin/echo -e "\033[0m     No change to security compliance\n" | /usr/bin/tee -a /tmp/SEAT_FINDINGS
else
   /usr/bin/diff /root/old-audit-findings /root/new-audit-findings >>/tmp/SEAT_FINDINGS
fi
/usr/bin/sleep 1

}

#Main

#Variables
ID=$(/usr/bin/id | /usr/bin/cut -d'=' -f2 | /usr/bin/cut -d'(' -f1)

#Ensure running as root
if [[ ! $ID -eq 0 ]]
then
   /usr/bin/echo -e "\e[91mError....You are not root!\n\nBecome root and re-run the script."
   exit
fi

#Check for script parameters
if [[ $1 == "pretest" ]]
then
   Pre_Test
   /usr/bin/echo -e "\e[92mThe script has completed successfully"
elif [[ $1 == "posttest" ]]
then
   Post_Test
   /usr/bin/echo -e "\e[92mThe script has completed successfully"
elif [[ $1 == "compare" ]]
then
   Compare
   /usr/bin/echo -e "\e[92mThe script has completed successfully"
elif [[ $1 == "" ]]
then
   /usr/bin/echo -e "\e[91mError....Parameter not defined!\n\n"
   /usr/bin/echo -e "\033[0m"
   /usr/bin/echo -e "Usage: \n#$0 pretest [performs a pre-installation test] \n#$0 posttest [performs a post-installation test] \n#$0 compare [performs a compare of the pre/post installation files]"
else
   /usr/bin/echo -e "\e[91mError....Incorrect parameter!\n\n"
   /usr/bin/echo -e "\033[0m"
   /usr/bin/echo -e "Usage: \n#$0 pretest [performs a pre-installation test] \n#$0 posttest [performs a post-installation test] \n#$0 compare [performs a compare of the pre/post installation files]"
fi

#Reset font color just in case
/usr/bin/echo -e "\033[0m"   
