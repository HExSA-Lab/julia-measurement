echo "torusnode01"
ssh torusnode01 'cd /home/arizvi/julia-measurement/exp_scripts/multi-node/ping_pong_pckg/; mpicc -O3  /home/arizvi/julia-measurement/exp_scripts/multi-node/ping_pong_pckg/pp_mpi.c'
echo "torusnode03"
ssh torusnode03 'cd /home/arizvi/julia-measurement/exp_scripts/multi-node/ping_pong_pckg/; mpicc -O3  /home/arizvi/julia-measurement/exp_scripts/multi-node/ping_pong_pckg/pp_mpi.c'
