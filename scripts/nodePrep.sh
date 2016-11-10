#!/bin/bash

set -e

SUDOUSER=$1

echo $(date) " - Starting Script"

# Update system to latest packages and install dependencies
echo $(date) " - Install base packages and update system to latest packages"
yum -y update --exclude=WALinuxAgent
yum -y install wget git net-tools bind-utils iptables-services bridge-utils bash-completion pyOpenSSL httpd-tools

# Install the epel repo if not already present
yum -y install https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-8.noarch.rpm

# Disable the EPEL repository globally so that it is not accidentally used during later steps of the installation
sed -i -e "s/^enabled=1/enabled=0/" /etc/yum.repos.d/epel.repo

# Clean yum metadata and cache to make sure we see the latest packages available
yum -y clean all

# Disable EPEL to prevent unexpected packages from being pulled in during installation.
yum-config-manager epel --disable

# Install Docker
echo $(date) " - Installing Docker"
yum -y install docker

# To avoid having to use sudo when you use the docker command, create a Unix group called docker and add users to it
groupadd docker
usermod -aG docker $SUDOUSER

# Create thin pool logical volume for Docker
echo $(date) " - Creating thin pool logical volume for Docker and staring service"
echo "DEVS=/dev/sdc" >> /etc/sysconfig/docker-storage-setup
echo "VG=docker-vg" >> /etc/sysconfig/docker-storage-setup
docker-storage-setup

# Enable and start Docker services
systemctl enable docker
systemctl start docker
