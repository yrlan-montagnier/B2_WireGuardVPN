#!/bin/bash
# Script installation WireGuard + mise à jour
# Yrlan & Paul-Antoine ~ 21/11/2021

dnf update -y
dnf install -y elrepo-release epel-release
dnf install -y kmod-wireguard wireguard-tools
chown $USER /etc/wireguard/
wg genkey | tee /etc/wireguard/wireguard.key | wg pubkey > /etc/wireguard/wireguard.pub.key
echo 'cle prive:' 
cat /etc/wireguard/wireguard.key
echo 'cle publique: ' 
cat /etc/wireguard/wireguard.pub.key
ls -l /etc/wireguard/
wg show


