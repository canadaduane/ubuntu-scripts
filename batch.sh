#!/bin/bash
set -x

# SERVER_ADDR=184.106.71.181
SERVER_NAME=tipscale.org

./create_account_with_ssh.sh dmsj

./base_packages.sh

./install_nginx.sh
./install_php.sh
./install_etherpad.sh "pad.$SERVER_NAME"
./install_scuttle.sh "links.$SERVER_NAME"


./sudo_nopasswd.sh
