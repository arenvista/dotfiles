#!/bin/bash

# Install dependencies
pacman -Syu --noconfirm ansible sudo 

# start ansible-playbook
ansible-playbook main.yml -vvvv
