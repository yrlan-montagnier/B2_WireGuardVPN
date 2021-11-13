# B2 WireguardVPN - Installation
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

## Génerer des clés privées/publiques

> :computer: **Sur les VM serveur ET client**
- **On génère une clé privée dans le fichier `/etc/wireguard/wireguard.key` puis une clé publique dans `/etc/wireguard/wireguard.pub.key` à partir de celui-ci**
    - **:computer: `wireguard.server`**
    ```bash
    [yrlan@wireguard ~]$ sudo chown yrlan /etc/wireguard/
    [yrlan@wireguard ~]$ wg genkey | tee /etc/wireguard/wireguard.key | wg pubkey > /etc/wireguard/wireguard.pub.key

    # On peut voir le contenu de ces clés
    [yrlan@wireguard ~]$ cat /etc/wireguard/wireguard.key
    UEiwiLqazX3KlMpzXPUt77IQ/uwBc1s8++wzrOuu2Hg=
    [yrlan@wireguard ~]$ cat /etc/wireguard/wireguard.pub.key
    k+py72wlbBqjN+B3UKE/7EAMozLkgGXOhT0v3OKD7VY=

    [yrlan@wireguard ~]$ ls -l /etc/wireguard/
    total 12
    -rw-------. 1 yrlan root 775 Nov 12 20:20 wg0.conf
    -rw-------. 1 yrlan root  45 Nov 11 17:58 wireguard.key
    -rw-r--r--. 1 yrlan root  45 Nov 11 17:58 wireguard.pub.key
    ```
    - **:computer: `wireguard.client`**
    ```bash
    [yrlan@wireguard ~]$ sudo chown yrlan /etc/wireguard/
    [yrlan@wireguard ~]$ wg genkey | tee /etc/wireguard/wireguard.key | wg pubkey > /etc/wireguard/wireguard.pub.key

    # On peut voir le contenu de ces clés
    [yrlan@wireguard ~]$ cat /etc/wireguard/wireguard.key
    EEy5Fc4i4MOSW5bhljsXDLcI56Z/t84C1Iir5t/JSEU=
    [yrlan@wireguard ~]$ cat /etc/wireguard/wireguard.pub.key
    o5t8cno+cpL6f7DGZkqlQ2xXSgFDfRqq8Gpzfos4TwE=

    [yrlan@wireguard ~]$ ls -l /etc/wireguard/
    total 12
    -rw-r--r--. 1 yrlan root 254 Nov 12 19:18 wg0.conf
    -rw-r--r--. 1 yrlan root  45 Nov 12 16:32 wireguard.key
    -rw-r--r--. 1 yrlan root  45 Nov 12 16:32 wireguard.pub.key
    ```    
    - **:computer: `wireguard.client2`**
    ```
    [yrlan@wireguard ~]$ sudo chown yrlan /etc/wireguard/
    [yrlan@wireguard ~]$ wg genkey | tee /etc/wireguard/wireguard.key | wg pubkey > /etc/wireguard/wireguard.pub.key
    [yrlan@wireguard ~]$ cat /etc/wireguard/wireguard.key
    qHoxK9C7No81gmh9pa+VaEXWF2cGLYWyRUUcsmIWc0E=
    [yrlan@wireguard ~]$ cat /etc/wireguard/wireguard.pub.key
    x52rrpDIOOpjnXTvJImiBo7m/XeVgeexS0cTEchvYgg=

    [yrlan@wireguard ~]$ ls -l /etc/wireguard/
    total 8
    -rw-rw-r--. 1 yrlan root 45 Nov 13 16:56 wireguard.key
    -rw-rw-r--. 1 yrlan root 45 Nov 13 16:56 wireguard.pub.key
    ```
    

# **Vérifications**

On peut vérifier les connexions actives à l'aide de la commande `wg show`


- **Vérifier la connexion entre le serveur et les clients**
    - :computer: **wireguard.server**
    ```bash
    [yrlan@wireguard ~]$ sudo wg show
    interface: wg0
      public key: k+py72wlbBqjN+B3UKE/7EAMozLkgGXOhT0v3OKD7VY=
      private key: (hidden)
      listening port: 51820

    peer: x52rrpDIOOpjnXTvJImiBo7m/XeVgeexS0cTEchvYgg=
      endpoint: 192.168.100.252:49300
      allowed ips: 10.10.10.20/32
      latest handshake: 1 minute, 26 seconds ago
      transfer: 1.10 KiB received, 760 B sent

    peer: o5t8cno+cpL6f7DGZkqlQ2xXSgFDfRqq8Gpzfos4TwE=
      endpoint: 192.168.100.251:42728
      allowed ips: 10.10.10.10/32
      latest handshake: 1 minute, 49 seconds ago
      transfer: 1.16 KiB received, 728 B sent
    ```
    - :computer: **wireguard.client**
    ```bash
    [yrlan@wireguard ~]$ sudo wg show
    interface: wg0
      public key: o5t8cno+cpL6f7DGZkqlQ2xXSgFDfRqq8Gpzfos4TwE=
      private key: (hidden)
      listening port: 42728

    peer: k+py72wlbBqjN+B3UKE/7EAMozLkgGXOhT0v3OKD7VY=
      endpoint: 192.168.100.250:51820
      allowed ips: 0.0.0.0/0
      latest handshake: 21 seconds ago
      transfer: 820 B received, 1.40 KiB sent
      persistent keepalive: every 20 seconds*
    ```
    - :computer: **wireguard.client2**
    ```bash
    [yrlan@wireguard ~]$ sudo wg show
    interface: wg0
      public key: x52rrpDIOOpjnXTvJImiBo7m/XeVgeexS0cTEchvYgg=
      private key: (hidden)
      listening port: 49300

    peer: k+py72wlbBqjN+B3UKE/7EAMozLkgGXOhT0v3OKD7VY=
      endpoint: 192.168.100.250:51820
      allowed ips: 0.0.0.0/0
      latest handshake: 1 second ago
      transfer: 852 B received, 1.37 KiB sent
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
    Nov 12 19:50:47 wireguard.client wg-quick[1052]: [#] ip -4 route add 0.0.0.0/0 dev wg0
    Nov 12 19:50:47 wireguard.client systemd[1]: Started WireGuard via wg-quick(8) for wg0.
    ```
    - :computer: **wireguard.client2**
    ```
    [yrlan@wireguard ~]$ sudo systemctl status wg-quick@wg0
    ● wg-quick@wg0.service - WireGuard via wg-quick(8) for wg0
      Loaded: loaded (/usr/lib/systemd/system/wg-quick@.service; enabled; vendor preset: disabled)
      Active: active (exited) since Sat 2021-11-13 17:10:50 CET; 3min 2s ago
        Docs: man:wg-quick(8)
              man:wg(8)
              https://www.wireguard.com/
              https://www.wireguard.com/quickstart/
              https://git.zx2c4.com/wireguard-tools/about/src/man/wg-quick.8
              https://git.zx2c4.com/wireguard-tools/about/src/man/wg.8
      Process: 2183 ExecStop=/usr/bin/wg-quick down wg0 (code=exited, status=0/SUCCESS)
      Process: 2232 ExecStart=/usr/bin/wg-quick up wg0 (code=exited, status=0/SUCCESS)
    Main PID: 2232 (code=exited, status=0/SUCCESS)

    Nov 13 17:10:50 wireguard.client2 systemd[1]: Starting WireGuard via wg-quick(8) for wg0...
    Nov 13 17:10:50 wireguard.client2 wg-quick[2232]: Warning: `/etc/wireguard/wg0.conf' is world accessible
    Nov 13 17:10:50 wireguard.client2 wg-quick[2232]: [#] ip link add wg0 type wireguard
    Nov 13 17:10:50 wireguard.client2 wg-quick[2232]: [#] wg setconf wg0 /dev/fd/63
    Nov 13 17:10:50 wireguard.client2 wg-quick[2232]: [#] ip -4 address add 10.10.10.20 dev wg0
    Nov 13 17:10:50 wireguard.client2 wg-quick[2232]: [#] ip link set mtu 1420 up dev wg0
    Nov 13 17:10:50 wireguard.client2 wg-quick[2232]: [#] mount `8.8.8.8' /etc/resolv.conf
    Nov 13 17:10:50 wireguard.client2 wg-quick[2232]: [#] ip -4 route add 0.0.0.0/0 dev wg0
    Nov 13 17:10:50 wireguard.client2 systemd[1]: Started WireGuard via wg-quick(8) for wg0.
    ```

- **On peut ping le serveur depuis les clients**
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