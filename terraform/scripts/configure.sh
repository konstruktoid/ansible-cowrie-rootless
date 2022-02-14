#!/bin/bash
set -eu -o pipefail

sudo systemctl disable --now ssh

echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections

sudo add-apt-repository --yes ppa:ansible/ansible
sudo apt-get --assume-yes update
sudo apt-get --assume-yes --with-new-pkgs upgrade
sudo apt-get --assume-yes --no-install-recommends install ansible netfilter-persistent iptables-persistent

ansible-galaxy install konstruktoid.docker_rootless

ansible-playbook -i '127.0.0.1,' -c local /tmp/local.yml

sudo netfilter-persistent save
