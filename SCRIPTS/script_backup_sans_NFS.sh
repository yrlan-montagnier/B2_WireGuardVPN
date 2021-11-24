#!/bin/bash
# Script Création Backup sans la partie NFS
# Yrlan & Paul-Antoine ~ 21/11/2021

dnf update -y
dnf -y install nfs-utils
hostnamectl set-hostname backup.wireguard
nmcli connection modify enp0s8 ipv4.addresses 192.168.100.253/24
mkdir -p /srv/backups/wireguard.server/
mkdir -p /srv/backups/wireguard.client/
mkdir -p /srv/backups/wireguard.client2/

