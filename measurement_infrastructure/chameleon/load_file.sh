#!/usr/bin/env bash

#This script assumes that the openrc script from chameloen has been added
#For now this script and openrc scipt has been pushed in the julia-measurement repository

#install openstack, vim 
sudo yum install vim
sudo pip install python-openstackclient
cd /home/cc/julia-measurement/measurement_infrastructure/chameleon
source openrc.sh
# Get all IP addresses
cd /home/cc/julia-measurement/exp_scripts/multi-node
nova list | grep julia | cut -d '|' -f 7 | cut -d ',' -f 2 >>ipaddr
# Get all machine names
nova list | grep julia | cut -d '|' -f 3 >> mchnames
# Use julia script to make hostfile from thes above two files
sudo julia make_hostfile.jl >> myhosts
# append this information in etc/host
sudo su
cat myhosts>>/etc/hosts 
#SSH into all machines
ssh-keygen -t rsa
filename=ipaddr
while read -r ipaddr
do
	name="$mchnames"
	ssh-copy-id $name
	eval 'ssh-agent'
	ssh-add ~/.ssh/id_rsa 
done < "$filename"
