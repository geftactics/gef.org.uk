#!/bin/bash

date > /root/build_time

dnf update -y
dnf install -y bind-utils dnf-automatic htop whois

sed -i 's/^apply_updates = no$/apply_updates = yes/' /etc/dnf/automatic.conf
systemctl enable --now dnf-automatic.timer

usermod -l geoff -d /home/geoff -m ec2-user
groupmod -n geoff ec2-user
echo "geoff ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-geoff
