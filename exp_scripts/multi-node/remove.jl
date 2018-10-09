using Distributed
if myid()==1
    Distributed.rmprocs()
end
