#!/bin/sh


# cleanup after 01_postfix.sh
apt -y --purge remove postfix-pcre spamass-milter postgrey postfix-policyd-spf-python
apt -y --purge remove mailutils

# cleanup after 00_letsencrypt.sh
apt -y --purge remove certbot ; rm -rf /etc/letsencrypt



