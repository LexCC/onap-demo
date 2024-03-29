#!/usr/bin/env bash
set -ex

cd devstack
cp /vagrant/control.conf  local.conf
./stack.sh

source /vagrant/openrc

openstack network create public --external --provider-network-type=flat --provider-physical-network=public
openstack subnet create --network=public --subnet-range=192.168.0.0/24 --allocation-pool start=192.168.0.200,end=192.168.0.250 --gateway 192.168.0.254 public-subnet
#openstack subnet create --network=public --subnet-range=192.168.1.0/24 --allocation-pool start=192.168.1.200,end=192.168.1.250 --gateway 192.168.1.1 public-subnet
openstack security group list -f value | cut -f1 -d" " | xargs -I {} openstack security group rule create --ingress --ethertype=IPv4 --protocol=0 {}

wget https://cloud-images.ubuntu.com/releases/14.04.1/release/ubuntu-14.04-server-cloudimg-amd64-disk1.img
wget https://cloud-images.ubuntu.com/releases/16.04/release/ubuntu-16.04-server-cloudimg-amd64-disk1.img
openstack image create ubuntu1404 --file ubuntu-14.04-server-cloudimg-amd64-disk1.img --disk-format qcow2
openstack image create ubuntu1604 --file ubuntu-16.04-server-cloudimg-amd64-disk1.img --disk-format qcow2

openstack quota set admin --instances 32
openstack quota set admin --cores 128
openstack quota set admin --ram 102400

openstack flavor delete m1.large
openstack flavor create --public m1.large --id auto --ram 6144 --vcpus 3 --disk 80
openstack flavor delete m1.xlarge
openstack flavor create --public m1.xlarge --id auto --ram 6144 --vcpus 4 --disk 100
openstack flavor delete m1.xxlarge || true
openstack flavor create --public m1.xxlarge --id auto --ram 8196 --vcpus 4 --disk 100

#This is now required in the Ocata release for node placment.
#https://bugs.launchpad.net/nova/+bug/1693979
#https://docs.openstack.org/releasenotes/nova/ocata.html#upgrade-notes

echo "After the computer nodes are up, SSH into the control and run the following:"
echo -e "\tnova-manage cell_v2 simple_cell_setup"
echo "Note: this needs to happen before the ONAP nodes are brought up"
