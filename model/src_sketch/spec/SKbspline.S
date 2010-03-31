class specification SKbspline (2:0) of SKgeometry, GRbcsubbc;

from SKgeometry inherit
  GRdetplane, GRcopy, GRlocate, GRdelete, GRgetobjinfo, GRmksource, debug;

#ifndef BASE_EMS
override
  GRrevparm,
  SKcreate_constraint_points,
  GRcpparallel,
  SKrecompute_yourself;
#endif
end specification SKbspline;

