#!/bin/bash
msg "Unmount EndeavourOS"
eosbox -u
msg "Remove directory and service"
rm -rf /var/archlinux
rm -rf /usr/lib/systemd/system/eosbox.service
rm -rf /etc/eosbox.conf
msg "Reload systemd"
systemctl daemon-reload
msg "Reboot system"
reboot
