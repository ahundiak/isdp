class specification SKcompcurve (2:0) of SKgeometry, GRcompcurve;

#ifndef BASE_EMS
message SKclose (IGRlong *msg; IGRushort opts;
                 struct GRmd_env *md_env; 
                 IGRint *num_conflict_cnstr; GRobjid **conflict_cnstr);

from SKgeometry inherit
  GRmksource, GRdetplane, GRcopy, GRgetobjinfo;


override
  GRdelete, GRrevparm,
  SKintcopy, 
  SKrecompute_yourself, 
  SKcheck_degeneracy,
  SKcreate_ptvars, 
  SKcreate_self_constraints;

#endif

end specification SKcompcurve;
