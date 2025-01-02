#!/bin/bash -x

# Install LibreSwan
yum install libreswan -y

echo "net.ipv4.ip_forward=1" >>/etc/sysctl.conf
echo "net.ipv4.conf.default.rp_filter = 0" >>/etc/sysctl.conf
echo "net.ipv4.conf.default.accept_source_route = 0" >>/etc/sysctl.conf

sysctl -p


# Enable IP forwarding
echo "net.ipv4.ip_forward = 1" >>/etc/sysctl.conf

# Disable Reverse Path Filtering
echo "net.ipv4.conf.default.rp_filter = 0" >>/etc/sysctl.conf

# Disable Accept Source Route
echo "net.ipv4.conf.default.accept_source_route = 0" >>/etc/sysctl.conf

# Apply sysctl settings
sysctl -p

service network restart
