#!/bin/sh
# first argument is number of days by which to extend
DAYS=$1
blazar lease-update --prolong-for "${DAYS}d" julia_cluster
