#!/bin/bash
sudo yum update
sudo su -
systemctl stop firewalld
systemctl disable firewalld
setenforce 0

dnf install tftp-server syslinux vsftpd -y
# tftp 설정
cp /usr/lib/systemd/system/tftp.service /etc/systemd/system/tftp-server.service
cp /usr/lib/systemd/system/tftp.socket /etc/systemd/system/tftp-server.socket
cp /srv/iso/images/pxeboot/vmlinuz /var/lib/tftpboot/
cp /srv/iso/images/pxeboot/initrd.img /var/lib/tftpboot/
cp /srv/iso/isolinux/ldlinux.c32 /var/lib/tftpboot/
cp /usr/share/syslinux/pxelinux.0 /var/lib/tftpboot/

initrd.img ldlinux.c32 libutil.c32 menu.c32 pxelinux.0 vmlinuz

systemctl restart vsftpd
