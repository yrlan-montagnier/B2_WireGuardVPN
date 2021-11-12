# B2 WireguardVPN - MONTAGNIER Yrlan & ABEILLE Paul-antoine
# **Sommaire**

# **Configuration de base de la machine**

> **Ici nous avons la configuration initiale de la machine, puis nous mettrons à la fin de ce README la configuration finale**

## Paramètres réseaux + hostname

> **Sur VirtualBox : Carte NAT + 2 Host-only : `192.168.100.1/24` & `10.10.10.1/24`**

- **Coté serveur**
    ```bash
    [yrlan@patron ~]$ sudo hostnamectl set-hostname wireguard.server

    [yrlan@patron ~]$ ip a show enp0s3 && ip a show enp0s8
    2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
        link/ether 08:00:27:34:8f:b1 brd ff:ff:ff:ff:ff:ff
        inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic noprefixroute enp0s3
           valid_lft 85914sec preferred_lft 85914sec
    3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
        link/ether 08:00:27:3a:a0:a4 brd ff:ff:ff:ff:ff:ff
        inet 192.168.100.250/24 brd 192.168.100.255 scope global noprefixroute enp0s8
           valid_lft forever preferred_lft forever
     ```
- **Coté client**
     ```bash
    [yrlan@patron ~]$ sudo hostnamectl set-hostname wireguard.client

    [yrlan@wireguard ~]$ ip a show enp0s3 && ip a show enp0s8
    2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
        link/ether 08:00:27:93:d4:ae brd ff:ff:ff:ff:ff:ff
        inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic noprefixroute enp0s3
           valid_lft 86184sec preferred_lft 86184sec
        inet6 fe80::a00:27ff:fe93:d4ae/64 scope link noprefixroute
           valid_lft forever preferred_lft forever
    3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
        link/ether 08:00:27:c9:0c:f5 brd ff:ff:ff:ff:ff:ff
        inet 10.10.10.10/24 brd 10.10.10.255 scope global noprefixroute enp0s8
           valid_lft forever preferred_lft forever
        inet6 fe80::a00:27ff:fec9:cf5/64 scope link
           valid_lft forever preferred_lft forever
    ```

## Configuration de base du pare-feu

> Pour le pare-feu, on indiquera les règles à utiliser (ports 51820/UDP), forward etc.. dans le fichier de conf `wg0.conf`

> :computer: **Sur les VM serveur ET client**
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

> :computer: **Sur les VM serveur ET client**
```bash
[yrlan@wireguard ~]$ sudo dnf update -y
[yrlan@wireguard ~]$ sudo dnf install -y elrepo-release epel-release
[yrlan@wireguard ~]$ sudo dnf install -y kmod-wireguard wireguard-tools
```

# **Configuration de WireGuard**
## Génerer des clés privées/publiques

> :computer: **Sur les VM serveur ET client**
- **On génère une clé privée dans le fichier `/etc/wireguard/wireguard.key` puis une clé publique dans `/etc/wireguard/wireguard.pub.key` à partir de celui-ci**
```bash
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

> :file_folder:	 **Fichier [`wg0.conf`](./conf/wg0.conf)** dans `/etc/wireguard/wg0.conf`

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
4: wg0: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1420 qdisc noqueue state UNKNOWN group default qlen 1000
    link/none
    inet 10.10.10.1/24 scope global wg0
       valid_lft forever preferred_lft forever
```
