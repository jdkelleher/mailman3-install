#!/bin/sh

# cleanup after 3_mailman2-full.sh
sudo apt-get -y --purge  remove mailman3-full
sudo apt autoremove --purge
sudo rm -rf /var/log/mailman3
sudo rm -rf /var/lib/mailman3
sudo rm -rf /etc/mailman3
sudo rm -rf /etc/dbconfig-common/mailman3*
sudo rmdir /etc/dbconfig-common/


# cleanup after 2_nginx.sh


# cleanup after 1_postfix.sh
apt -y --purge remove postfix-pcre spamass-milter postgrey postfix-policyd-spf-python
apt -y --purge remove mailutils


# cleanup after 0_certbot.sh
apt -y --purge remove certbot ; rm -rf /etc/letsencrypt



