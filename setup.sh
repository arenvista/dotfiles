#!/bin/bash

# Install dependencies
pacman -Syu --noconfirm ansible sudo --needed

# start ansible-playbook
ansible-playbook tasks/main.yml -vvvv --ask-become-pass
