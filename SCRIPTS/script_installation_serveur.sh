#!/bin/bash
# Script installation serveur
# Yrlan & Paul-Antoine ~ 21/11/2021

dnf update -y
bash <(curl -Ss https://my-netdata.io/kickstart.sh)
systemctl enable --now netdata
ss -alnpt | grep netdata
firewall-cmd --add-port=19999/tcp --permanent; sudo firewall-cmd --reload; sudo firewall-cmd --list-all