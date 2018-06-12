#!/bin/sh

# NOTE: assumes template exists withh name "mpi_stack_template"
#
# ARG1: keypair name (use openstack keypair list to pick one)
# ARG2: reservation/lease name (use blazar lease-list to get the name)
# ARG3: node count (must be between 1 and the max host count in the lease)
# ARG4: stack name

openstack stack create \
 --template mpi_stack_template \
 --parameter key_name=$1 \
 --parameter reservation_id=$2 \
 --parameter node_count=$3 \
 $4
