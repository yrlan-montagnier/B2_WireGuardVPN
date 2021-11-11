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
```bash
[yrlan@wireguard ~]$ sudo dnf update -y
[yrlan@wireguard ~]$ sudo dnf install -y elrepo-release epel-release
[yrlan@wireguard ~]$ sudo dnf install -y kmod-wireguard wireguard-tools
```

# **Configuration de WireGuard**
## Génerer des clés privées/publiques
```bash
# On passe en root pour la génération de clés
[yrlan@wireguard ~]$ su
Password:
[root@wireguard yrlan]# mkdir /etc/wireguard

# On génère une clé privée dans le fichier /etc/wireguard/wireguard.key puis une clé publique à partir de celui-ci
[root@wireguard yrlan]# wg genkey | tee /etc/wireguard/wireguard.key | wg pubkey > /etc/wireguard/wireguard.pub.key

# On peut voir le contenu de ces clés
[root@wireguard yrlan]# cat /etc/wireguard/wireguard.key
UEiwiLqazX3KlMpzXPUt77IQ/uwBc1s8++wzrOuu2Hg=
[root@wireguard yrlan]# cat /etc/wireguard/wireguard.pub.key
k+py72wlbBqjN+B3UKE/7EAMozLkgGXOhT0v3OKD7VY=

[root@wireguard yrlan]# sudo ls -l /etc/wireguard/
total 12
-rw-------. 1 root root  45 Nov 11 17:58 wireguard.key
-rw-r--r--. 1 root root  45 Nov 11 17:58 wireguard.pub.key
```

## Création d'un fichier de configuration pour notre serveur WireGuard

> Ici nous utiliserons **`wg0.conf`** comme nom pour le fichier de conf (**interface `wg0`**) qui est un nom **recommandé pour les interfaces réseaux par WireGuard**

> **Ce fichier sera modifié plus tard pour y intégrer les clients de notre serveur VPN**

> :file_folder:	 **Fichier [`wg0.conf`](./conf/wg0.conf)**
```bash
cat /etc/wireguard/wg0.conf
[Interface]
Address = 10.10.10.1/24
SaveConfig = true
PostUp = firewall-cmd --add-port=51820/udp; firewall-cmd --zone=DROP --add-masquerade; firewall-cmd --direct --add-rule ipv4 filter FORWARD 0 -i wg0 -o eth0 -j ACCEPT; firewall-cmd --direct --add-rule ipv4 nat POSTROUTING 0 -o eth0 -j MASQUERADE
PostDown = firewall-cmd --remove-port=51820/udp; firewall-cmd --zone=DROP --remove-masquerade; firewall-cmd --direct --remove-rule ipv4 filter FORWARD 0 -i wg0 -o eth0 -j ACCEPT; firewall-cmd --direct --remove-rule ipv4 nat POSTROUTING 0-o eth0 -j MASQUERADE
ListenPort = 51820
PrivateKey = UEiwiLqazX3KlMpzXPUt77IQ/uwBc1s8++wzrOuu2Hg=
DNS = 8.8.8.8
```

## Activation IP Forwarding
```
[root@wireguard yrlan]# echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
[root@wireguard yrlan]# sysctl -p
net.ipv4.ip_forward = 1
```

## Lancement du serveur WireGuard
```
[root@wireguard yrlan]# wg-quick up wg0
[#] ip link add wg0 type wireguard
[#] wg setconf wg0 /dev/fd/63
[#] ip -4 address add 10.10.10.1/24 dev wg0
[#] ip link set mtu 1420 up dev wg0
[#] mount `8.8.8.8' /etc/resolv.conf
[#] firewall-cmd --add-port=51820/udp; firewall-cmd --zone=DROP --add-masquerade; firewall-cmd --direct --add-rule ipv4 filter FORWARD 0 -i wg0 -o eth0 -j ACCEPT; firewall-cmd --direct --add-rule ipv4 nat POSTROUTING 0 -o eth0 -j MASQUERADE
success
success
success
success

[root@wireguard yrlan]# ip add show wg0
9: wg0: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1420 qdisc noqueue state UNKNOWN group default qlen 1000
    link/none
    inet 10.10.10.1/24 scope global wg0
       valid_lft forever preferred_lft forever
```
