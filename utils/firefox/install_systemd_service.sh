#!/bin/bash

echo "Copying Files"
cp ./systemd/org-sync.path $HOME/.config/systemd/user/
cp ./systemd/org-sync.service $HOME/.config/systemd/user/

