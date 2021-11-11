# B2 WireguardVPN - MONTAGNIER Yrlan & ABEILLE Paul-antoine
# **Sommaire**

# **Configuration de base de la machine**

> **Ici nous avons la configuration initiale de la machine, puis nous mettrons à la fin de ce README la configuration finale**

## Paramètres réseaux + hostname

> **Sur VirtualBox : Carte NAT + Host-only = `192.168.100.1`**

```bash
# Configuration du hostname
[yrlan@patron ~]$ sudo hostnamectl set-hostname wireguard.server
# Adresse ipv4
[yrlan@wireguard ~]$ sudo nmcli connection modify enp0s8 ipv4.addresses 192.168.100.250/24
```

## Configuration de base du pare-feu
```bash
# Zone DROP pour tout bloquer par défaut
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
# Une zone SSH pour autoriser notre système avec l'adresse en .1
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

# **Installation de WireGuard**
## Mise a jour du sytème + install de wireguard via le repo d'epel-release
```
[yrlan@wireguard ~]$ sudo dnf update -y
[yrlan@wireguard ~]$ sudo dnf install -y elrepo-release epel-release
[yrlan@wireguard ~]$ sudo dnf install -y kmod-wireguard wireguard-tools
```

# **Configuration de WireGuard**
## **Génerer des clés publiques/privées**

### Générer une clé privée
```bash
[yrlan@wireguard ~]$ umask 077 | wg genkey | sudo tee /etc/wireguard/wireguard.key
UKjxKhJO51+YLc2H4sgvyyqBOyHr+ksbMH2XsXGm4lQ=
[yrlan@wireguard ~]$ sudo cat /etc/wireguard/wireguard.key
UKjxKhJO51+YLc2H4sgvyyqBOyHr+ksbMH2XsXGm4lQ=
```

### Génerer une clé publique à partir de notre clé privée
```bash
## On passe en root
[yrlan@wireguard ~]$ su
Password:

## La commande wg pubkey génère une clé publique à partir de la clé privée
[root@wireguard yrlan]# wg pubkey < /etc/wireguard/wireguard.key > /etc/wireguard/wireguard.pub.key

## On vérifie que la clé a bien été crée puis son contenu
[root@wireguard yrlan]# sudo ls -l /etc/wireguard/
total 8
-rw-------. 1 root root 45 Nov 11 17:37 wireguard_prv.key
-rw-r--r--. 1 root root 45 Nov 11 17:39 wireguard.pub.key
[root@wireguard yrlan]# sudo cat /etc/wireguard/wireguard.pub.key
hIX/nUDrPWiECz+/xDXAM0Zu9QG7e6KRY/LgqTvETDo=
```