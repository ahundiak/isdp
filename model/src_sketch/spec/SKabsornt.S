class specification SKabsornt (2:0) of SKconstraint;

#ifndef BASE_EMS
message SKgetabsornt (IGRlong *msg; struct SKsolvevars *solvedvars;
                      IGRdouble *angtohor; GRobjid ptobs[2]);

override
  SKmakejacobian, SKevaluate;

reject
  SKgetabsornt;
#endif

end specification SKabsornt;
