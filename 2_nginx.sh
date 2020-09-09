#!/bin/bash

# Author: Jason D. Kelleher
# https://github.com/jdkelleher/mailman3-install



SCRIPT_BASE="${0%/*}"

source ${SCRIPT_BASE}/config



# Order the install to avoid unwanted dependencies 

sudo apt-get -y install nginx

# **** Question... should we grab uwsgi here? Or with mailman3-full? ****
sudo apt-get -y install uwsgi


# remove link to default from sites-enabled
sudo rm /etc/nginx/sites-enabled/default


# Pre-compute Diffie-Hellman parameter for DHE ciphersuites, recommended >=2048 bits
sudo mkdir -p /etc/nginx/ssl/
#sudo openssl dhparam -out /etc/nginx/ssl/dhparam.pem 4096
# For testing, just drop down something already computed
sudo cat <<- EOInp > /etc/nginx/ssl/dhparam.pem
	-----BEGIN DH PARAMETERS-----
	MIICCAKCAgEA8eZVMF/G7VSc+qw/f2I1j4LM6jtC1ifVO+yWi5LrmLs1Rg+0KTzK
	DbSXX8lDykFOvSM9qycHVPRF4v8iXB6ZQSSBLLbXHiJ+Ouges2YZpsHOBflBdKzv
	sqhC3SMNm7qbSU99iZRDciue+1ILPKO9FhVOR/KZ1v87eFjCLUg9rD7rtC/AE6Ju
	L+jLMdZ+qQ27G2pPy6Z6/IHwENVxbhIJ7II7mTJlYvaHxDA47IeHG3T3ggNorN1/
	koy5P66GpxspasuylVpQOsZ90qFS+1Ld+azBY0dVtEW/IEqrUEtKqjcOccdcvIXi
	DHEdWZGVVA6edauj0clI0CZVK2wVlX0f72YYflidejV6s4qPiivwmHiZuSngC5KM
	HmmSeaQANR693YXpKJ1fHnyQSYnRdf/s6HooB+JU66iaZkeT+uKE8hxILg/2WJD5
	zW251P4YJoM/a6m/ZQuVz/Vrfsmew1yuW6ysTfnuTgqWU/Eso8WnqHTbiBNFM5HP
	RWoy6mPvAfNTdr0O/bULnT8LiBK1X4HIvaoMsDVc4+0QD3ZhQEKHSWjetyQeQyU7
	++xYHXYZ+Z/8rKxmatPC/tjMMiwFRPS9PgPaq8nNCMK5H+Hk6AoABTh92AE9PXi2
	ltcsKtZ4P3g9Xn4+cZrI8tpgLU50YkczB0YUDv+CH0ygHFZdhZd21KMCAQI=
	-----END DH PARAMETERS-----
EOInp


# Generate config file for mailman3
#sudo cat << EOInp > /etc/nginx/sites-available/mailman3
#
# generate config here....
# make sure to point to the right certs
#
#EOInp
# sudo ln -s /etc/nginx/sites-available/mailman3 /etc/nginx/sites-enabled/mailman3


# Restart nginx
sudo systemctl restart nginx


# make sure hooks are adjusted to restart nginx after cert renewal
# do stuff here...

