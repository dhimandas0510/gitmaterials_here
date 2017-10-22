#!/bin/bash


set -e

if [ -f /etc/configured ]; then
        echo 'already configured'
        postfix start 2>&1 & 
else
      #code that need to run only one time ....
        #needed for fix problem with ubuntu and cron
        update-locale 
        echo 'root:  root@example.com' >>/etc/aliases
        newaliases
        #add container Network Docker0 and container ip to postfix configuration , it will fail is custom container network
        sed -i 's/inet_interfaces = all/inet_interfaces = '"$(cat /etc/hosts | grep $HOSTNAME| awk -F\  '{print $1}')"'/' /etc/postfix/main.cf
        sed -i '/mynetworks/s/$/ '"$(cat /etc/hosts | grep $HOSTNAME| awk -F. '{print $1 "." $2 ".0.0\/16"}')"'/' /etc/postfix/main.cf
        # to make sure nagios email permision are correct
        touch /var/mail/nagios
        chown nagios:mail /var/mail/nagios
        chmod o-r /var/mail/nagios
        chmod g+rw /var/mail/nagios
        #start postfix 
        postfix start 2>&1 & 
        date > /etc/configured
fi
