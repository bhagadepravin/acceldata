# Linux Mounting Commands

```bash
yum -y install cloud-utils-growpart && growpart /dev/sda 2; pvresize /dev/sda2; lvextend -l+100%FREE /dev/centos/root; xfs_growfs /dev/centos/root;lsblk
```

```bash
$ df -Th
OR
$ df -Th | grep "^/dev"

$ lsblk -f

$ mount | grep "^/dev"

$ file -sL /dev/sda2

$ cat /etc/fstab
```

###### How to Add New Disks Using LVM to an Existing Linux System

Once the disks has been added, you can list them using the following command.

$ fdisk -l


```bash
[root@pravin1 ~]# fdisk -l

Disk /dev/sda: 536.9 GB, 536870912000 bytes, 1048576000 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x000baeb9

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *        2048     2099199     1048576   83  Linux
/dev/sda2         2099200    33554431    15727616   8e  Linux LVM
/dev/sda3        33554432   243269631   104857600   83  Linux

Disk /dev/mapper/centos-root: 14.4 GB, 14382268416 bytes, 28090368 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/mapper/centos-swap: 1719 MB, 1719664640 bytes, 3358720 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
```


Now partitions both the disks /dev/sda using fdisk command as shown.


$ fdisk /dev/sda 

Use `n` to create the partition and save the changes with `w` command.




## LVM

* pvs
* vgs
* lvs

```bash
[root@pravin1 ~]# pvs
  PV         VG     Fmt  Attr PSize   PFree
  /dev/sda2  centos lvm2 a--  <15.00g    0

[root@pravin1 ~]# vgs
  VG     #PV #LV #SN Attr   VSize   VFree
  centos   1   2   0 wz--n- <15.00g    0

[root@pravin1 ~]# lvs
  LV   VG     Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root centos -wi-ao---- 13.39g
  swap centos -wi-ao----  1.60g

[root@pravin1 ~]# vgdisplay
  --- Volume group ---
  VG Name               centos
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  3
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                2
  Open LV               2
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <15.00 GiB
  PE Size               4.00 MiB
  Total PE              3839
  Alloc PE / Size       3839 / <15.00 GiB
  Free  PE / Size       0 / 0
  VG UUID               0k0CGT-8qsa-ZfsT-XGln-0PhU-sb9R-0fAeEo

```

## HOW TO EXTEND FILESYSTEM ON LINUX (ROOT AND OTHER) : 

https://dade2.net/kb/how-to-extend-filesystem-on-linux/

`$ yum -y install cloud-utils-growpart`

`$ lsblk`

`$ growpart /dev/sda 2; pvresize /dev/sda2; lvextend -l+100%FREE /dev/centos/root; xfs_growfs /dev/centos/root`


```bash
[root@pravin1 ~]# lsblk
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0  500G  0 disk
|-sda1            8:1    0    1G  0 part /boot
`-sda2            8:2    0   15G  0 part
  |-centos-root 253:0    0 13.4G  0 lvm  /
  `-centos-swap 253:1    0  1.6G  0 lvm  [SWAP]
sr0              11:0    1  4.4G  0 rom
[root@pravin1 ~]# sudo growpart /dev/sda 2;
CHANGED: partition=2 start=2099200 old: size=31455232 end=33554432 new: size=1046476767 end=1048575967
[root@pravin1 ~]# pvs
  PV         VG     Fmt  Attr PSize   PFree
  /dev/sda2  centos lvm2 a--  <15.00g    0
[root@pravin1 ~]# lsblk
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0  500G  0 disk
|-sda1            8:1    0    1G  0 part /boot
`-sda2            8:2    0  499G  0 part
  |-centos-root 253:0    0 13.4G  0 lvm  /
  `-centos-swap 253:1    0  1.6G  0 lvm  [SWAP]
sr0              11:0    1  4.4G  0 rom
[root@pravin1 ~]#  pvresize /dev/sda2
  Physical volume "/dev/sda2" changed
  1 physical volume(s) resized or updated / 0 physical volume(s) not resized
[root@pravin1 ~]# pvs
  PV         VG     Fmt  Attr PSize    PFree
  /dev/sda2  centos lvm2 a--  <499.00g 484.00g
[root@pravin1 ~]# lvextend -l+100%FREE /dev/centos/root
  Size of logical volume centos/root changed from 13.39 GiB (3429 extents) to 497.39 GiB (127333 extents).
  Logical volume centos/root successfully resized.
[root@pravin1 ~]# df -Th
Filesystem              Type      Size  Used Avail Use% Mounted on
devtmpfs                devtmpfs   12G     0   12G   0% /dev
tmpfs                   tmpfs      12G     0   12G   0% /dev/shm
tmpfs                   tmpfs      12G  8.9M   12G   1% /run
tmpfs                   tmpfs      12G     0   12G   0% /sys/fs/cgroup
/dev/mapper/centos-root xfs        14G   13G  1.1G  93% /
/dev/sda1               xfs      1014M  238M  777M  24% /boot
tmpfs                   tmpfs     2.4G     0  2.4G   0% /run/user/0
tmpfs                   tmpfs      10M  4.0K   10M   1% /tmp
[root@pravin1 ~]# xfs_growfs /dev/centos/root
meta-data=/dev/mapper/centos-root isize=512    agcount=4, agsize=877824 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0 spinodes=0
data     =                       bsize=4096   blocks=3511296, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal               bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
data blocks changed from 3511296 to 130388992
[root@pravin1 ~]# df -Th
Filesystem              Type      Size  Used Avail Use% Mounted on
devtmpfs                devtmpfs   12G     0   12G   0% /dev
tmpfs                   tmpfs      12G     0   12G   0% /dev/shm
tmpfs                   tmpfs      12G  8.9M   12G   1% /run
tmpfs                   tmpfs      12G     0   12G   0% /sys/fs/cgroup
/dev/mapper/centos-root xfs       498G   13G  486G   3% /
/dev/sda1               xfs      1014M  238M  777M  24% /boot
tmpfs                   tmpfs     2.4G     0  2.4G   0% /run/user/0
tmpfs                   tmpfs      10M  4.0K   10M   1% /tmp
[root@pravin1 ~]# df -hT | grep mapper
/dev/mapper/centos-root xfs       498G   13G  486G   3% /
```

#### Remove a sda3 from sda partiton 
https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/storage_administration_guide/s2-disk-storage-parted-remove-part



