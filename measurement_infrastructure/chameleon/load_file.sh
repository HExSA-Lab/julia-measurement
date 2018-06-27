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
ssh-keygen
filename=mchnames
chmod 600 /home/cc/julia-measurement/measurement_infrastructure/chameleon/mpi_key.pem
ssh-add /home/cc/julia-measurement/measurement_infrastructure/chameleon/mpi_key.pem

while read -r mchnames
do
	name="$mchnames"
	echo $name
	eval $(ssh-agent -s)
	ssh-add ~/.ssh/id_rsa 
	ssh-copy-id -i /home/cc/julia-measurement/measurement_infrastructure/chameleon/mpi_key.pem cc@$name
	scp -i /home/cc/julia-measurement/measurement_infrastructure/chameleon/mpi_key.pem myhosts cc@$name:/home/cc/julia-measurement/exp_scripts/multi-node/myhosts
done < "$filename"
