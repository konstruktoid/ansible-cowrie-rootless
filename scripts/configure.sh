#!/bin/bash
set -eu -o pipefail

function lockfile_check {
  local LOCK_COUNT=0
  while [ -f /var/lib/dpkg/lock-frontend ]; do
    echo "Lock file /var/lib/dpkg/lock-frontend exists. Sleeping - ${LOCK_COUNT}/12"
    sleep 5
    if [[ $LOCK_COUNT -gt 11 ]]; then
      echo "Assuming stale lock file"
      sudo rm /var/lib/dpkg/lock-frontend
    fi
    LOCK_COUNT=$((LOCK_COUNT+1))
  done
}

sudo systemctl disable --now ssh

echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections

sudo add-apt-repository --yes ppa:ansible/ansible
sudo apt-get --assume-yes update

sudo apt-get --assume-yes --no-install-recommends install ansible netfilter-persistent iptables-persistent

ansible-galaxy install konstruktoid.baseline
ansible-galaxy install konstruktoid.docker_rootless

cd /tmp || exit 1

ansible-playbook -i '127.0.0.1,' -c local ./local.yml

sudo netfilter-persistent save
