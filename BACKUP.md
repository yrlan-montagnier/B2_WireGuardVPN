# Mise en place d'une machine de backup

Cette machine aura accès au dossier /etc/wireguard du serveur et des clients et en fera une sauvegarde dans une archive dans /srv/backup tous les jours à 00h.

:computer: VM backup.wireguard


## Paramètres réseau et hostname
```bash
sudo hostnamectl set-hostname backup.wireguard
sudo nmcli connection modify enp0s8 ipv4.addresses 192.168.100.253/24
```

## Setup environnement
### On met à jour le système + install de `nfs-utils`
```bash
[yrlan@backup ~]$ sudo dnf update -y
[yrlan@backup ~]$ sudo dnf -y install nfs-utils
```

### On crée un dossier pour chaque machine à backup
```bash
[yrlan@backup ~]$ sudo mkdir -p /srv/backups/wireguard.server/
[yrlan@backup ~]$ sudo mkdir -p /srv/backups/wireguard.client/
[yrlan@backup ~]$ sudo mkdir -p /srv/backups/wireguard.client2/
```

## Setup partage NFS
### Coté machine :computer: `backup.wireguard`
```bash
# On edit le domaine
[yrlan@backup ~]$ sudo nano /etc/idmapd.conf
[yrlan@backup ~]$ cat /etc/idmapd.conf | grep wireguard
Domain = wireguard

[yrlan@backup ~]$ sudo nano /etc/exports
[yrlan@backup ~]$ cat /etc/exports
/srv/backups/wireguard.server 192.168.100.250(rw,no_root_squash)
/srv/backups/wireguard.client 192.168.100.251(rw,no_root_squash)
/srv/backups/wireguard.client2 192.168.100.252(rw,no_root_squash)

# Démarrage du service
[yrlan@backup ~]$ sudo systemctl enable --now nfs-server
Created symlink /etc/systemd/system/multi-user.target.wants/nfs-server.service → /usr/lib/systemd/system/nfs-server.service.

# Config du firewall
[yrlan@backup ~]$ sudo firewall-cmd --permanent --add-service=nfs; sudo firewall-cmd --reload; sudo firewall-cmd --list-all
success
success
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: nfs ssh
  ports: 22/tcp
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```
### Sur le serveur :computer: `wireguard.server`
```bash
# Config du client
[yrlan@wireguard ~]$ sudo dnf -y install nfs-utils
[...]
[yrlan@wireguard ~]$ sudo nano /etc/idmapd.conf
[yrlan@wireguard ~]$ cat /etc/idmapd.conf | grep wireguard 
Domain = wireguard

# Montage auto de la partition à l'aide de /etc/fstab
[yrlan@wireguard ~]$ sudo nano /etc/fstab
[yrlan@wireguard ~]$ sudo cat /etc/fstab | grep 192
192.168.100.253:/srv/backups/wireguard.server /etc/wireguard/ nfs defaults 0 0

[yrlan@wireguard ~]$ sudo mount -a -v | grep /etc
/etc/wireguard           : successfully mounted
```

### Sur les machines à backup :computer: `wireguard.client`
```bash
# Config du client
[yrlan@wireguard ~]$ sudo dnf -y install nfs-utils
[...]
[yrlan@wireguard ~]$ sudo nano /etc/idmapd.conf
[yrlan@wireguard ~]$ cat /etc/idmapd.conf | grep wireguard 
Domain = wireguard

# Montage auto de la partition à l'aide de /etc/fstab
[yrlan@wireguard ~]$ sudo nano /etc/fstab
[yrlan@wireguard ~]$ sudo cat /etc/fstab | grep 192
192.168.100.253:/srv/backups/wireguard.client /etc/wireguard/ nfs defaults 0 0

[yrlan@wireguard ~]$ sudo mount -a -v | grep /etc
/etc/wireguard           : successfully mounted
```


## Mise en place d'un service avec un timer
Maintenant qu'on récupère le contenu de /etc/wireguard de chaque machine dans /srv/backups, on va faire une archive de ce dossier /srv/backups tous les jours à 00h00

- Service wireguard_backup.service
```bash
sudo mkdir -p /srv/archives
sudo nano /etc/systemd/system/wireguard_backup.service
```

> Fichier [wireguard_backup.service](./conf/wireguard_backup.service)

- Timer wireguard_backup.timer
```bash
sudo nano /etc/systemd/system/wireguard_backup.timer
```
> Fichier [wireguard_backup.timer](./conf/wireguard_backup.timer)
