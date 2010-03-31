class specification SKrelornt (2:0) of SKconstraint;

#ifndef BASE_EMS
message SKgetrelornt (IGRlong *msg; struct SKsolvevars *solvedvars;
                      IGRdouble *angto_firstseg; GRobjid ptobjs[2][2]);


override
  SKinit, SKorder_points, SKmakejacobian, SKevaluate;

reject
  SKgetrelornt;

#endif

end specification SKrelornt;
