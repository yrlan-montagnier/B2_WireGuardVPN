# B2 WireGuard VPN - Configuration

## **Coté serveur :computer: `wireguard.server`**
### **Création d'un fichier de configuration pour notre serveur WireGuard**


> Ici nous utiliserons **`wg0.conf`** comme nom pour le fichier de conf (**interface `wg0`**) qui est un nom **recommandé pour les interfaces réseaux par WireGuard**

> **Ce fichier sera modifié plus tard pour y intégrer les clients de notre serveur VPN**

> :file_folder:	 **Fichier [`wg0.conf`](./conf/wg0.conf)** dans `/etc/wireguard/wg0.conf`

#### **Explications du fichier de conf :**

- **Adress** : Adresse du serveur sur la carte-réseau virtuelle
- **PostUp** : Règles à ajouter au pare-feu quand l'interface démarre
- **PostDown** : Règles à supprimer du pare-feu quand on éteint l'interface

### **Activation IP Forwarding**

```
[root@wireguard yrlan]# echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
[root@wireguard yrlan]# sysctl -p
net.ipv4.ip_forward = 1
```

### **Lancement du serveur WireGuard**
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


## **Coté client :computer: `wireguard.client`**
### Création d'un fichier de configuration pour nos clients WireGuard

> :computer: **wireguard.client**
> 
> :file_folder:	 **Fichier [`wg0.conf`](./conf/client_wg0.conf)** dans `/etc/wireguard/wg0.conf`

> :computer: **wireguard.client2**
> 
> :file_folder:	 **Fichier [`wg0.conf`](./conf/client2_wg0.conf)** dans `/etc/wireguard/wg0.conf`

## Lancement des client WireGuard
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
