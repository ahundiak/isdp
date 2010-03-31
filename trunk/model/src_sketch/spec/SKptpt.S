/*
  DESCRIPTION

    This class defines a point to point distance constraint.
    This object is connected to the points among which distance is
    defined. The measurement axis is defined by the vector between the 
    two points.
*/

class specification SKptpt (2:0) of SKexplicit;

#ifndef BASE_EMS
message SKgetptptinfo (IGRlong *msg; struct SKsolvevars *solvedvars;
                       IGRdouble *value; GRobjid ptobs[2]);


override
  SKmakejacobian, SKinit, SKevaluate, SKcreate_geom;

#endif

end specification SKptpt;
