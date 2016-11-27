#!/bin/bash

# Prompt the user for their sudo password
sudo -v

# Enable passwordless sudo for the macbuild run
sudo sed -i -e "s/^%admin.*/%admin  ALL=(ALL) NOPASSWD: ALL/" /etc/sudoers

# disable required virtualenv
virtualenv_required=$PIP_REQUIRE_VIRTUALENV
export PIP_REQUIRE_VIRTUALENV=false

# Install or upgrade pip
if ! which pip > /dev/null 2>&1
then
  echo  "### Installing pip"
  sudo easy_install pip
else
  echo  "### Upgrading pip"
  sudo -H pip install -U pip
fi

# Install or upgrade Ansible (using pip is the officially supported way)
if ! pip2 show ansible > /dev/null 2>&1
then
  echo "### Installing Ansible"
  sudo -H pip2 install ansible
else
  echo "### Upgrading Ansible"
  sudo -H pip2 install --ignore-installed --upgrade ansible
fi

# Install Ansible roles
echo "### Installing Ansible roles";
ansible-galaxy install -r ./requirements.yml;

# Perform the build
ansible-playbook -i localhost -K main.yml

# reset PIP_REQUIRE_VIRTUALENV
export PIP_REQUIRE_VIRTUALENV=$virtualenv_required

# Disable passwordless sudo after the macbuild is complete
sudo sed -i -e "s/^%admin.*/%admin  ALL=(ALL) ALL/" /etc/sudoers

echo "### All Done!"
