#!/bin/bash

# Author: Jason D. Kelleher
# https://github.com/jdkelleher/mailman3-install



SCRIPT_BASE="${0%/*}"

source ${SCRIPT_BASE}/config



# DNS notes...
#	Make sure MX records are proper and point to appropriate A and AAAA records - DNS provider
#	If MX, A, and AAAA records are in good shape then SPF can be as simple as TXT record of
#	v=spf1 a mx ~all
#
#	Make sure PTR (reverse) records are in place for IPv4 and IPv6 - cloud / hosting provider
#	If not, expect rejections by Gmail and others
#
#	https://mxtoolbox.com/SPFRecordGenerator.aspx
#	https://tools.wordtothewise.com/spf/check/
#	https://www.kitterman.com/spf/validate.html
#	https://www.dmarcanalyzer.com/spf/checker/
#	https://toolbox.googleapps.com/apps/checkmx/
#	https://intodns.com/


# DKIM
# https://www.linuxbabe.com/mail-server/setting-up-dkim-and-spf
# https://dmarcly.com/blog/how-to-add-dkim-record-in-cloudflare-cloudflare-dkim-setup-guide

# ARC
# https://docs.mailman3.org/projects/mailman/en/latest/src/mailman/handlers/docs/arc_sign.html




# Order the install to not pull in alternate/unwanted dependencies


# Install postfix with spamassassin, SPF, TLS, and greylisting. (DKIM, ARC, and DMARC will be handled later.)
# this assumes that letsencrypt (or something else) has already been installed and certs are in place

sudo debconf-set-selections <<- EOInp
	postfix	postfix/main_mailer_type	select	Internet Site
	postfix	postfix/mailname	string	${MAIL_NAME}
	postfix	postfix/destinations	string	\$myhostname, ${MAIL_NAME}, localhost.${DOMAIN_NAME}, , localhost
EOInp

sudo apt-get -y install postfix-pcre spamass-milter postgrey postfix-policyd-spf-python

# can't really test without this
sudo apt-get -y install mailutils

# add postfix to the ssl-cert group for the TLS configuration below
sudo gpasswd --add postfix ssl-cert


# Configure postfix and assorted bits

# postfix
# https://wiki.debian.org/Postfix
# https://www.mind-it.info/2014/02/20/change-postfix-master-cf-postconf/
# https://www.howtoforge.com/perfect_setup_whitebox_p4
# https://www.linuxbabe.com/mail-server/block-email-spam-check-header-body-with-postfix-spamassassin
# https://www.linuxbabe.com/mail-server/setting-up-dkim-and-spf
# https://upcloud.com/community/tutorials/secure-postfix-using-lets-encrypt/
# https://gist.github.com/mrothNET/cb6f313e9cbe896f3e0fdec80ad2f3fa

# just a thought to come back to later... put all the "postconf -e" args in an array of strings then loop through with error checking...

sudo postconf -e "myhostname = ${MAIL_NAME}"
sudo postconf -e 'inet_interfaces = all'
sudo postconf -e 'alias_maps = hash:/etc/aliases'

# basic security / anti-spam
sudo postconf -e 'disable_vrfy_command = yes'
sudo postconf -e 'smtpd_delay_reject = yes'
sudo postconf -e 'smtpd_helo_required = yes'
sudo postconf -e 'smtpd_helo_restrictions = reject_invalid_helo_hostname, reject_non_fqdn_helo_hostname, reject_unknown_helo_hostname'

# TLS
#
sudo postconf -e 'smtpd_tls_security_level = may'
sudo postconf -e 'smtp_tls_security_level = may'
sudo postconf -e 'smtp_tls_note_starttls_offer = yes'
sudo postconf -e 'smtpd_tls_received_header = yes'
sudo postconf -e "smtpd_tls_cert_file = ${SMTPD_TLS_CERT_FILE}"
sudo postconf -e "smtpd_tls_key_file = ${SMTPD_TLS_KEY_FILE}"
sudo postconf -e "smtpd_tls_CApath = ${SMTPD_TLS_CAPATH}"
sudo postconf -e "smtpd_tls_CAfile = ${SMTPD_TLS_CAFILE}"
sudo postconf -e "smtp_tls_cert_file = ${SMTP_TLS_CERT_FILE}"
sudo postconf -e "smtp_tls_key_file = ${SMTP_TLS_KEY_FILE}"
sudo postconf -e "smtp_tls_CApath = ${SMTP_TLS_CAPATH}"
sudo postconf -e "smtp_tls_CAfile = ${SMTP_TLS_CAFILE}"
sudo postconf -e 'smtpd_tls_loglevel = 1'
sudo postconf -e 'smtpd_tls_session_cache_timeout = 3600s'
sudo postconf -e 'tls_random_source = dev:/dev/urandom'

# SPF
sudo postconf -e 'policyd-spf_time_limit = 3600'
sudo postconf -e 'smtpd_recipient_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination, check_policy_service unix:private/policyd-spf'
sudo postconf -M policyd-spf/spawn="policyd-spf	unix	-	n	n	-	0	spawn user=policyd-spf argv=/usr/bin/policyd-spf"

# Spamassassin milter
sudo postconf -e 'milter_default_action = accept'
sudo postconf -e 'milter_protocol = 6'
sudo postconf -e 'smtpd_milters = local:spamass/spamass.sock'
sudo postconf -e 'non_smtpd_milters = $smtpd_milters'


sudo systemctl restart postfix




# Configure spamassasin
CONF_FILE=/etc/default/spamass-milter
grep -q -s ".-r" ${CONF_FILE} 
if [ $? -ne 0 ] ; then
	sudo cat <<- 'EOInp' >> ${CONF_FILE}

		# Reject email with a spam score over 15
		OPTIONS="${OPTIONS} -r 15"
	EOInp
else
	sudo perl -pi -e 's/^\s*#\s*(.* -r)\s+\d+(.*)/$1 -15$2/;' ${CONF_FILE}
fi

sudo systemctl enable spamassassin
sudo systemctl restart spamassassin


