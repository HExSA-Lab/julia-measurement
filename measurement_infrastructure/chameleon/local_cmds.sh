#!/usr/bin/env bash

#This script assumes that the openrc script from chameloen has been added
#For now this script and openrc scipt has been pushed in the julia-measurement repository
sudo yum-config-manager --disable centos-openstack-newton
git clone https://github.com/amalrizv/julia-measurement.git
sudo pip install python-openstackclient
sudo yum install openssh-server openssh-client
sudo yum-config-manager --add-repo https://copr.fedorainfracloud.org/coprs/nalimilan/julia/repo/epel-7/nalimilan-julia-epel-7.repo
sudo yum install julia
sudo yum install cmake
sudo -u cc julia -e "Pkg.Init()"
sudo -u cc julia -e "Pkg.add(\"MPI\")"
sudo -u cc julia -e "Pkg.update()"
sudo -u cc julia -e "Pkg.build(\"MPI\")"
#remove old files 
cd /home/cc/julia-measurement/exp_scripts/multi-node
rm -rf myhosts ipaddr mchnames
#install openstack, vim 
sudo yum install vim
echo "Line 10"
echo "Line 12" 
cd /home/cc/julia-measurement/measurement_infrastructure/chameleon
echo "Line 14"
source openrc.sh
echo "Line 16"
# Get all IP addresses
cd /home/cc/julia-measurement/exp_scripts/multi-node
nova list | grep ACTIVE | cut -d '|' -f 7 | cut -d ',' -f 2 >>ipaddr
# Get all machine names
nova list | grep ACTIVE | cut -d '|' -f 3 >> mchnames
# Use julia script to make hostfile from thes above two files
sudo julia make_hostfile.jl >> myhosts
# append this information in etc/host
echo "Line 25" 
echo "About to write in /etc/hosts"
sudo -- sh "cat myhosts>>/etc/hosts"
echo "Written to etc/hosts"
#SSH into all machines
filename=mchnames
sudo chmod 600 /home/cc/julia-measurement/measurement_infrastructure/chameleon/mpi_key.pem
sudo ssh-add /home/cc/julia-measurement/measurement_infrastructure/chameleon/mpi_key.pem
while read -r name 
do 
	ssh-keygen -t rsa
	ssh-copy-id cc@$name
	eval `ssh-agent -s`
	ssh-add
	ssh $name
done < $filename
