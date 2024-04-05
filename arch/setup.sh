#!/bin/bash

# Install dependencies
pacman -Syu --noconfirm ansible sudo 

# Create a new user
useradd -m -G wheel -s /bin/bash ansible
echo "ansible ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ansible

# Set the password for the new user
 echo "ansible:ansible" | chpasswd

# start ansible-playbook
ansible-playbook main.yml

