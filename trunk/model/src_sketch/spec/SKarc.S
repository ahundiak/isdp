class specification SKarc (2:0) of SKgeometry, GR3dcirarc;

from SKgeometry inherit
  GRdetplane, GRcopy, GRlocate, GRdelete, GRgetobjinfo, GRmksource, debug;

#ifndef BASE_EMS
override 
  GRrevparm,
  SKcreate_self_constraints, 
  SKcreate_constraint_points,
  SKrecompute_yourself,
  GRcpparallel;
#endif

end specification SKarc;

