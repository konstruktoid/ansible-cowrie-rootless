#!/bin/bash
set -eu -o pipefail

if ! grep '^Acquire::http::AllowRedirect' /etc/apt/apt.conf.d/* ; then
  echo 'Acquire::http::AllowRedirect "false";' | sudo tee -a /etc/apt/apt.conf.d/01-vendor-ubuntu
else
  sudo sed -i 's/.*Acquire::http::AllowRedirect.*/Acquire::http::AllowRedirect "false";/g' "$(grep -l 'Acquire::http::AllowRedirect' /etc/apt/apt.conf.d/*)"
fi

if ! grep '^APT::Get::AllowUnauthenticated' /etc/apt/apt.conf.d/* ; then
  echo 'APT::Get::AllowUnauthenticated "false";' | sudo tee -a /etc/apt/apt.conf.d/01-vendor-ubuntu
else
  sudo sed -i 's/.*APT::Get::AllowUnauthenticated.*/APT::Get::AllowUnauthenticated "false";/g' "$(grep -l 'APT::Get::AllowUnauthenticated' /etc/apt/apt.conf.d/*)"
fi

if ! grep '^APT::Periodic::AutocleanInterval "7";' /etc/apt/apt.conf.d/*; then
  echo 'APT::Periodic::AutocleanInterval "7";' | sudo tee -a /etc/apt/apt.conf.d/10periodic
else
  sudo sed -i 's/.*APT::Periodic::AutocleanInterval.*/APT::Periodic::AutocleanInterval "7";/g' "$(grep -l 'APT::Periodic::AutocleanInterval' /etc/apt/apt.conf.d/*)"
fi

if ! grep '^APT::Install-Recommends' /etc/apt/apt.conf.d/*; then
  echo 'APT::Install-Recommends "false";' | sudo tee -a /etc/apt/apt.conf.d/01-vendor-ubuntu
else
  sudo sed -i 's/.*APT::Install-Recommends.*/APT::Install-Recommends "false";/g' "$(grep -l 'APT::Install-Recommends' /etc/apt/apt.conf.d/*)"
fi

if ! grep '^APT::Get::AutomaticRemove' /etc/apt/apt.conf.d/*; then
  echo 'APT::Get::AutomaticRemove "true";' | sudo tee -a /etc/apt/apt.conf.d/01-vendor-ubuntu
else
  sudo sed -i 's/.*APT::Get::AutomaticRemove.*/APT::Get::AutomaticRemove "true";/g' "$(grep -l 'APT::Get::AutomaticRemove' /etc/apt/apt.conf.d/*)"
fi

if ! grep '^APT::Install-Suggests' /etc/apt/apt.conf.d/*; then
  echo 'APT::Install-Suggests "false";' | sudo tee -a /etc/apt/apt.conf.d/01-vendor-ubuntu
else
  sudo sed -i 's/.*APT::Install-Suggests.*/APT::Install-Suggests "false";/g' "$(grep -l 'APT::Install-Suggests' /etc/apt/apt.conf.d/*)"
fi

if ! grep '^Unattended-Upgrade::Remove-Unused-Dependencies' /etc/apt/apt.conf.d/*; then
  echo 'Unattended-Upgrade::Remove-Unused-Dependencies "true";' | sudo tee -a /etc/apt/apt.conf.d/50unattended-upgrades
else
  sudo sed -i 's/.*Unattended-Upgrade::Remove-Unused-Dependencies.*/Unattended-Upgrade::Remove-Unused-Dependencies "true";/g' "$(grep -l 'Unattended-Upgrade::Remove-Unused-Dependencies' /etc/apt/apt.conf.d/*)"
fi

sudo systemctl disable --now ssh

echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections

sudo add-apt-repository --yes ppa:ansible/ansible
sudo apt-get --assume-yes update
sudo apt-get --assume-yes --with-new-pkgs upgrade
sudo apt-get --assume-yes --no-install-recommends install ansible netfilter-persistent iptables-persistent

ansible-galaxy install konstruktoid.docker_rootless

cd /tmp || exit 1

ansible-playbook -i '127.0.0.1,' -c local ./local.yml

sudo netfilter-persistent save
