#!/bin/bash

# Author: Jason D. Kelleher
# https://github.com/jdkelleher/mailman3-install



SCRIPT_BASE="${0%/*}"

source ${SCRIPT_BASE}/config



# Order the install to avoid unwanted dependencies 

sudo apt-get -y install certbot ssl-cert	# making sure to add ssl-cert here because we want the "ssl-cert" group to be added for setting permissions


# Configure cerbot
sudo cat <<- EOInp > /etc/letsencrypt/cli.ini
	# Because we are using logrotate for greater flexibility, disable the
	# internal certbot logrotation.
	max-log-backups = 0

	# Use a 4096 bit RSA key instead of 2048
	rsa-key-size = 4096

	# Register with the specified e-mail address
	email = ${ADMIN_EMAIL}
EOInp

sudo certbot certonly --standalone --non-interactive --agree-tos --no-eff-email --email ${ADMIN_EMAIL} --domain ${MAIL_NAME}

# fix permissions
chgrp -hR ssl-cert /etc/letsencrypt/archive /etc/letsencrypt/live					# this shouldn't be hard-coded
find /etc/letsencrypt/archive /etc/letsencrypt/live -type d -print0 | xargs --null chmod g+rws 		# this path shouldn't be hard-coded



