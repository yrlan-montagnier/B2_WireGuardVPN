# B2 WireguardVPN - MONTAGNIER Yrlan & ABEILLE Paul-antoine

# **Sommaire**

# **Configuration de base de la machine**
## **Paramètres réseaux + hostname**

> **Sur VirtualBox : Carte NAT + Host-only = `192.168.100.1`**

```bash
# Configuration du hostname
[yrlan@patron ~]$ sudo hostnamectl set-hostname wireguard.server
# Adresse ipv4
[yrlan@wireguard ~]$ sudo nmcli connection modify enp0s8 ipv4.addresses 192.168.100.250/24
```

## **Configuration de base du pare-feu**
```bash
[yrlan@wireguard ~]$ sudo firewall-cmd --list-all --zone=DROP
DROP (active)
  target: DROP
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services:
  ports:
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:

[yrlan@wireguard ~]$ sudo firewall-cmd --list-all --zone=ssh
ssh (active)
  target: DROP
  icmp-block-inversion: no
  interfaces:
  sources: 192.168.100.1/32
  services:
  ports: 22/tcp
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

## **Mise a jour du sytème + install du repo d'epel-release**
```bash
[yrlan@wireguard ~]$ sudo dnf update -y
[yrlan@wireguard ~]$ sudo dnf install -y elrepo-release epel-release
```
