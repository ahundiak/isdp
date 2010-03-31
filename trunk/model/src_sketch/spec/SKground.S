/*
  DESCRIPTION

    This class defines a ground constraint on. This object is connected
    to the variable that should be treated as grounded.
*/

class specification SKground (2:0) of SKimplicit;

#ifndef BASE_EMS

override
  GRgetobjinfo,
  SKinit, SKcreate_geom, SKevaluate, SKmakejacobian, SKgetconstrs;

#endif

end specification SKground;

