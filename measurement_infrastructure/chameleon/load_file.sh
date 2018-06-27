#!/usr/bin/env bash

#This script assumes that the openrc script from chameloen has been added
#For now this script and openrc scipt has been pushed in the julia-measurement repository
#remove old files 
cd /home/cc/julia-measurement/exp_scripts/multi-node
rm -rf myhosts ipaddr mchnames
#install openstack, vim 
sudo yum install vim
echo "Line 10"
sudo pip install python-openstackclient
echo "Line 12" 
cd /home/cc/julia-measurement/measurement_infrastructure/chameleon
echo "Line 14"
source openrc.sh
echo "Line 16"
# Get all IP addresses
cd /home/cc/julia-measurement/exp_scripts/multi-node
nova list | grep julia | cut -d '|' -f 7 | cut -d ',' -f 2 >>ipaddr
# Get all machine names
nova list | grep julia | cut -d '|' -f 3 >> mchnames
# Use julia script to make hostfile from thes above two files
sudo julia make_hostfile.jl >> myhosts
# append this information in etc/host
echo "Line 25" 
echo "About to write in /etc/hosts"
cat myhosts>>/etc/hosts 
echo "Written to etc/hosts"
#SSH into all machines
sudo ssh-keygen
filename=mchnames
sudo chmod 600 /home/cc/julia-measurement/measurement_infrastructure/chameleon/mpi_key.pem
sudo ssh-add /home/cc/julia-measurement/measurement_infrastructure/chameleon/mpi_key.pem

while read -r mchnames
do
	name="$mchnames"
	echo $name
	eval $(ssh-agent -s)
	sudo ssh-add ~/.ssh/id_rsa 
        ssh-copy-id cc@$name
	sudo scp -i /home/cc/julia-measurement/measurement_infrastructure/chameleon/mpi_key.pem myhosts cc@$name:/home/cc/julia-measurement/exp_scripts/multi-node/myhosts
done < "$filename"
