#!/bin/bash

echo "Copying Files"
cp ./systemd/org-sync.path $HOME/.config/systemd/user/
cp ./systemd/org-sync.service $HOME/.config/systemd/user/


systemctl --user daemon-reload
systemctl --user enable --now org-sync.path
journalctl --user -u org-sync.service -f
