# B2 WireguardVPN - MONTAGNIER Yrlan & ABEILLE Paul-antoine
# **Sommaire**

# **Configuration de base de la machine**

## Paramètres réseaux + hostname

> **Sur VirtualBox : Carte NAT + 1 Host-only : `192.168.100.1/24`**

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
    # Carte NAT
    [yrlan@wireguard ~]$ ip a show enp0s3 && ip a show enp0s8
    2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
        link/ether 08:00:27:93:d4:ae brd ff:ff:ff:ff:ff:ff
        inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic noprefixroute enp0s3
           valid_lft 86239sec preferred_lft 86239sec
        inet6 fe80::a00:27ff:fe93:d4ae/64 scope link noprefixroute
    # Host-Only
           valid_lft forever preferred_lft forever
    3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
        link/ether 08:00:27:c9:0c:f5 brd ff:ff:ff:ff:ff:ff
        inet 192.168.100.251/24 brd 192.168.100.255 scope global noprefixroute enp0s8
           valid_lft forever preferred_lft forever
        inet6 fe80::a00:27ff:fec9:cf5/64 scope link
           valid_lft forever preferred_lft forever
    ```

# **Installation de WireGuard**
## Mise a jour du sytème + install de WireGuard via le repo d'epel-release

> :computer: **Sur les VM serveur ET client**
```bash
# On met la machine à jour
[yrlan@wireguard ~]$ sudo dnf update -y
# On installe le repo d'epel-release
[yrlan@wireguard ~]$ sudo dnf install -y elrepo-release epel-release
# Puis on installe WireGuard
[yrlan@wireguard ~]$ sudo dnf install -y kmod-wireguard wireguard-tools
```

# **Configuration de WireGuard**
## Génerer des clés privées/publiques

> :computer: **Sur les VM serveur ET client**
- **On génère une clé privée dans le fichier `/etc/wireguard/wireguard.key` puis une clé publique dans `/etc/wireguard/wireguard.pub.key` à partir de celui-ci**

    - **:computer: `wireguard.server`**
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
    - **:computer: `wireguard.client`**
    ```bash
    [root@wireguard yrlan]# wg genkey | tee /etc/wireguard/wireguard.key | wg pubkey > /etc/wireguard/wireguard.pub.key

    # On peut voir le contenu de ces clés
    [root@wireguard wireguard]# cat wireguard.key
    EEy5Fc4i4MOSW5bhljsXDLcI56Z/t84C1Iir5t/JSEU=
    [root@wireguard wireguard]# cat wireguard.pub.key
    o5t8cno+cpL6f7DGZkqlQ2xXSgFDfRqq8Gpzfos4TwE=

    [root@wireguard wireguard]# sudo ls -l /etc/wireguard/
    total 8
    -rw-r--r--. 1 root root 45 Nov 12 16:32 wireguard.key
    -rw-r--r--. 1 root root 45 Nov 12 16:32 wireguard.pub.key
    ```    

## Création d'un fichier de configuration pour notre serveur WireGuard

> Ici nous utiliserons **`wg0.conf`** comme nom pour le fichier de conf (**interface `wg0`**) qui est un nom **recommandé pour les interfaces réseaux par WireGuard**

> **Ce fichier sera modifié plus tard pour y intégrer les clients de notre serveur VPN**

> :computer: **wireguard.server**
> 
> :file_folder:	 **Fichier [`wg0.conf`](./conf/wg0.conf)** dans `/etc/wireguard/wg0.conf`

## Activation IP Forwarding sur le serveur

> :computer: **wireguard.server**
```
[root@wireguard yrlan]# echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
[root@wireguard yrlan]# sysctl -p
net.ipv4.ip_forward = 1
```

## Création d'un fichier de configuration pour nos clients WireGuard

> :computer: **wireguard.client**
> 
> :file_folder:	 **Fichier [`wg0.conf`](./conf/client_wg0.conf)** dans `/etc/wireguard/wg0.conf`


## Lancement du serveur WireGuard
- **Démarrer interface**
    ```bash
    [root@wireguard yrlan]# wg-quick up wg0
    [#] ip link add wg0 type wireguard
    [#] wg setconf wg0 /dev/fd/63
    [#] ip -4 address add 10.10.10.1/24 dev wg0
    [#] ip link set mtu 1420 up dev wg0
    [#] firewall-cmd --add-port=51820/udp; firewall-cmd --zone=public --add-masquerade; firewall-cmd --direct --add-rule ipv4 filter FORWARD 0 -i wg0 -o enp0s8 -j ACCEPT; firewall-cmd --direct --add-rule ipv4 nat POSTROUTING 0 -o enp0s8 -j MASQUERADE
    success
    success
    success
    success

    [root@wireguard yrlan]# ifconfig wg0
    wg0: flags=209<UP,POINTOPOINT,RUNNING,NOARP>  mtu 1420
            inet 10.10.10.1  netmask 255.255.255.0  destination 10.10.10.1
            unspec 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00  txqueuelen 1000  (UNSPEC)
            RX packets 90  bytes 5352 (5.2 KiB)
            RX errors 0  dropped 0  overruns 0  frame 0
            TX packets 19  bytes 2072 (2.0 KiB)
            TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
        
    # Démarrer l'interface au démarrage + start 
    [root@wireguard wireguard]# systemctl enable wg-quick@wg0
    [root@wireguard wireguard]# systemctl start wg-quick@wg0
    # Vérifications
    [root@wireguard wireguard]# systemctl is-active wg-quick@wg0
    active
    [root@wireguard wireguard]# systemctl is-enabled wg-quick@wg0
    enabled
    ```
    
## Lancement du client WireGuard
```bash
[yrlan@wireguard ~]$ wg-quick up wg0
[#] ip link add wg0 type wireguard
[#] wg setconf wg0 /dev/fd/63
[#] ip -4 address add 10.10.10.10 dev wg0
[#] ip link set mtu 1420 up dev wg0
[#] mount `8.8.8.8' /etc/resolv.conf
[#] ip -4 route add 10.10.10.0/24 dev wg0

[yrlan@wireguard ~]$ ifconfig wg0
wg0: flags=209<UP,POINTOPOINT,RUNNING,NOARP>  mtu 1420
        inet 10.10.10.10  netmask 255.255.255.255  destination 10.10.10.10
        unspec 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00  txqueuelen 1000  (UNSPEC)
        RX packets 15  bytes 1704 (1.6 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 62  bytes 3992 (3.8 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
        
[yrlan@wireguard ~]$ sudo systemctl enable wg-quick@wg0
[yrlan@wireguard ~]$ sudo systemctl start wg-quick@wg0
[yrlan@wireguard ~]$ systemctl is-active wg-quick@wg0
active
[yrlan@wireguard ~]$ systemctl is-enabled wg-quick@wg0
enabled
```

# **Vérifications**

- **Vérifier la connexion entre le serveur et le client**
    - :computer: **wireguard.server**
    ```bash
    [yrlan@wireguard ~]$ sudo wg show
    interface: wg0
      public key: k+py72wlbBqjN+B3UKE/7EAMozLkgGXOhT0v3OKD7VY=
      private key: (hidden)
      listening port: 51820

    peer: o5t8cno+cpL6f7DGZkqlQ2xXSgFDfRqq8Gpzfos4TwE=
      endpoint: 192.168.100.251:32967
      allowed ips: 10.10.10.10/32
      latest handshake: 1 minute, 4 seconds ago
      transfer: 1020 B received, 276 B sent
    ```
    - :computer: **wireguard.client**
    ```bash
    [yrlan@wireguard ~]$ sudo wg show
    interface: wg0
      public key: o5t8cno+cpL6f7DGZkqlQ2xXSgFDfRqq8Gpzfos4TwE=
      private key: (hidden)
      listening port: 32967

    peer: k+py72wlbBqjN+B3UKE/7EAMozLkgGXOhT0v3OKD7VY=
      endpoint: 192.168.100.250:51820
      allowed ips: 10.10.10.0/24
      latest handshake: 1 minute, 9 seconds ago
      transfer: 276 B received, 1020 B sent
      persistent keepalive: every 20 seconds
    ```
- **`systemctl status`**
    - :computer: **wireguard.server**
    ```bash
    ● wg-quick@wg0.service - WireGuard via wg-quick(8) for wg0
       Loaded: loaded (/usr/lib/systemd/system/wg-quick@.service; enabled; vendor preset: disabled)
       Active: active (exited) since Fri 2021-11-12 19:50:46 CET; 1min 11s ago
         Docs: man:wg-quick(8)
               man:wg(8)
               https://www.wireguard.com/
               https://www.wireguard.com/quickstart/
               https://git.zx2c4.com/wireguard-tools/about/src/man/wg-quick.8
               https://git.zx2c4.com/wireguard-tools/about/src/man/wg.8
      Process: 1045 ExecStart=/usr/bin/wg-quick up wg0 (code=exited, status=0/SUCCESS)
     Main PID: 1045 (code=exited, status=0/SUCCESS)

    Nov 12 19:50:42 wireguard.server wg-quick[1045]: [#] ip link add wg0 type wireguard
    Nov 12 19:50:42 wireguard.server wg-quick[1045]: [#] wg setconf wg0 /dev/fd/63
    Nov 12 19:50:42 wireguard.server wg-quick[1045]: [#] ip -4 address add 10.10.10.1/24 dev wg0
    Nov 12 19:50:42 wireguard.server wg-quick[1045]: [#] ip link set mtu 1420 up dev wg0
    Nov 12 19:50:42 wireguard.server wg-quick[1045]: [#] firewall-cmd --add-port=51820/udp; firewall-cmd --zone=public --add-masquerade>
    Nov 12 19:50:43 wireguard.server wg-quick[1045]: success
    Nov 12 19:50:44 wireguard.server wg-quick[1045]: success
    Nov 12 19:50:45 wireguard.server wg-quick[1045]: success
    Nov 12 19:50:46 wireguard.server wg-quick[1045]: success
    Nov 12 19:50:46 wireguard.server systemd[1]: Started WireGuard via wg-quick(8) for wg0.
    ```
    - :computer: **wireguard.client**
    ```
    [yrlan@wireguard ~]$ sudo systemctl status wg-quick@wg0
    ● wg-quick@wg0.service - WireGuard via wg-quick(8) for wg0
       Loaded: loaded (/usr/lib/systemd/system/wg-quick@.service; enabled; vendor preset: disabled)
       Active: active (exited) since Fri 2021-11-12 19:50:47 CET; 9min ago
         Docs: man:wg-quick(8)
               man:wg(8)
               https://www.wireguard.com/
               https://www.wireguard.com/quickstart/
               https://git.zx2c4.com/wireguard-tools/about/src/man/wg-quick.8
               https://git.zx2c4.com/wireguard-tools/about/src/man/wg.8
      Process: 1052 ExecStart=/usr/bin/wg-quick up wg0 (code=exited, status=0/SUCCESS)
     Main PID: 1052 (code=exited, status=0/SUCCESS)

    Nov 12 19:50:46 wireguard.client systemd[1]: Starting WireGuard via wg-quick(8) for wg0...
    Nov 12 19:50:46 wireguard.client wg-quick[1052]: [#] ip link add wg0 type wireguard
    Nov 12 19:50:46 wireguard.client wg-quick[1052]: [#] wg setconf wg0 /dev/fd/63
    Nov 12 19:50:46 wireguard.client wg-quick[1052]: [#] ip -4 address add 10.10.10.10 dev wg0
    Nov 12 19:50:47 wireguard.client wg-quick[1052]: [#] ip link set mtu 1420 up dev wg0
    Nov 12 19:50:47 wireguard.client wg-quick[1052]: [#] mount `8.8.8.8' /etc/resolv.conf
    Nov 12 19:50:47 wireguard.client wg-quick[1052]: [#] ip -4 route add 10.10.10.0/24 dev wg0
    Nov 12 19:50:47 wireguard.client systemd[1]: Started WireGuard via wg-quick(8) for wg0.
    ```
- **On peut ping le serveur depuis le client**
    ```bash
    [yrlan@wireguard ~]$ ping 10.10.10.1 -c 3
    PING 10.10.10.1 (10.10.10.1) 56(84) bytes of data.
    64 bytes from 10.10.10.1: icmp_seq=1 ttl=64 time=0.410 ms
    64 bytes from 10.10.10.1: icmp_seq=2 ttl=64 time=0.574 ms
    64 bytes from 10.10.10.1: icmp_seq=3 ttl=64 time=1.41 ms

    --- 10.10.10.1 ping statistics ---
    3 packets transmitted, 3 received, 0% packet loss, time 2034ms
    rtt min/avg/max/mdev = 0.410/0.797/1.409/0.438 ms
    ```