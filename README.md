# B2 Wireguard VPN - MONTAGNIER Yrlan & ABEILLE Paul-Antoine
# Sommaire

# Configuration de base de la machine

## **Paramètres réseaux + hostname**

> **Sur VirtualBox : Carte NAT + 1 Host-only : `192.168.100.1/24`**
> 
> **Seul le serveur possède une carte NAT**

### **Tableau d'adressage**

| Interface 	   | `wireguard.server`   | `wireguard.client`   | `wireguard.client2` |
| ---------------- | -------- 			  | -------- 			 | -------- 		   |
| NAT       	   | Oui      			  | X        			 | X        		   |
| Host-Only        | `192.168.100.250/24` | `192.168.100.251/24` | `192.168.100.252/24`|
| wg01 (wireguard) | `10.10.10.1`         | `10.10.10.10`        | `10.10.10.20`       |


- :computer: **wireguard.server**
    ```bash
    # On choisit un hostname
    [yrlan@patron ~]$ sudo hostnamectl set-hostname wireguard.server

    [yrlan@patron ~]$ ip a show enp0s3 && ip a show enp0s8
    # Carte NAT
    2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
        link/ether 08:00:27:34:8f:b1 brd ff:ff:ff:ff:ff:ff
        inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic noprefixroute enp0s3
           valid_lft 85914sec preferred_lft 85914sec
    # Host-Only
    3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
        link/ether 08:00:27:3a:a0:a4 brd ff:ff:ff:ff:ff:ff
        inet 192.168.100.250/24 brd 192.168.100.255 scope global noprefixroute enp0s8
           valid_lft forever preferred_lft forever
     ```
- :computer: **wireguard.client**
    ```bash
    # On choisit un hostname
    [yrlan@patron ~]$ sudo hostnamectl set-hostname wireguard.client
    
    # Carte Host-Only
    [yrlan@wireguard ~]$ ip a show enp0s8
    3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
        link/ether 08:00:27:c9:0c:f5 brd ff:ff:ff:ff:ff:ff
        inet 192.168.100.251/24 brd 192.168.100.255 scope global noprefixroute enp0s8
           valid_lft forever preferred_lft forever
        inet6 fe80::a00:27ff:fec9:cf5/64 scope link
           valid_lft forever preferred_lft forever
    ```
