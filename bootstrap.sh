#!/bin/bash
SSH_HOST=$1
SSH_LOGIN=root
SSH_PASSWORD=$2
ADMIN_PASSWORD=$3

echo "Connecting to $SSH_LOGIN@$SSH_HOST with password..."

tee << '+++' | \
sed "s/SSH_HOST/$SSH_HOST/g" | \
sed "s/SSH_LOGIN/$SSH_LOGIN/g" | \
sed "s/SSH_PASSWORD/$SSH_PASSWORD/g" | \
ruby -rubygems
  require 'net/ssh'
  id_rsa_pub = File.join(ENV['HOME'], ".ssh", "id_rsa.pub")
  pubkey = IO.read(id_rsa_pub)
  begin
    Net::SSH.start( "SSH_HOST", "SSH_LOGIN", :password => "SSH_PASSWORD" ) do|ssh|
      puts "Installing id_rsa.pub on SSH_HOST..."
      ssh.exec!("mkdir /root/.ssh && chmod 700 /root/.ssh")
      ssh.exec!("touch /root/.ssh/authorized_keys")
      ssh.exec!("chmod 600 /root/.ssh/authorized_keys")
      ssh.exec!("echo '#{pubkey}' >>/root/.ssh/authorized_keys")
    end
  rescue Net::SSH::HostKeyMismatch => e
    puts "Host key is different than last time... either you are connecting to a "
    puts "new server at the same address, or this is a man-in-the middle attack."
    puts "If it's the former, remove the SSH_HOST line in ~/.ssh/known_hosts and retry."
  end
  puts "DONE"
+++

echo "Connecting to $SSH_HOST via SSH key and updating apt repos..."

tee << '+++' | ssh $SSH_LOGIN@$SSH_HOST /bin/bash
  export DEBIAN_FRONTEND=noninteractive

  # Install add-apt-repository command
  aptitude -y install python-software-properties

  # Add sun java source repo
  add-apt-repository "deb http://apt.opscode.com/ lucid main"
  wget -qO - http://apt.opscode.com/packages@opscode.com.gpg.key | sudo apt-key add -

  apt-get update

  aptitude -y full-upgrade
  aptitude -y install git-core screen
+++

echo "Connecting to $SSH_HOST via SSH key and installing chef server..."

tee << '+++' | \
sed "s/SSH_HOST/$SSH_HOST/g" | \
sed "s/ADMIN_PASSWORD/$ADMIN_PASSWORD/g" | \
ssh $SSH_LOGIN@$SSH_HOST /bin/bash

tee << '---' |debconf-set-selections
# URL of Chef Server (e.g., http://chef.example.com:4000):
chef	chef/chef_server_url	string	http://chef.SSH_HOST:4000
# New password for the 'admin' user in the Chef Server WebUI:
chef-server-webui	chef-server-webui/admin_password	password	ADMIN_PASSWORD
# New password for the 'chef' AMQP user in the RabbitMQ vhost "/chef":
chef-solr	chef-solr/amqp_password	password	ADMIN_PASSWORD
# Upgrading from 1.5.4 and below.
rabbitmq-server	rabbitmq-server/upgrade_previous	note	
---

  # Install chef
  aptitude -y install chef-server

+++
