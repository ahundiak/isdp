class specification SKcircle (2:0) of SKgeometry, GR3dcircle;

instance SKcircle
{
  IGRdouble radangle;
};

#ifndef BASE_EMS
message SKputradang (IGRlong *msg; IGRdouble radang);

from SKgeometry inherit
  GRmksource, GRdetplane, GRcopy, GRlocate, GRdelete, GRgetobjinfo, debug;

override 
  SKcreate_self_constraints, SKcreate_constraint_points,
  SKrecompute_yourself,

/*
  Added to change a copied circle to GR3dcircle .. ra 5/28/92
*/
 GRcpparallel;
#endif

end specification SKcircle;

