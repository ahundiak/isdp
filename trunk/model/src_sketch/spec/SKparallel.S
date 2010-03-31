/*
  DESCRIPTION

    This class defines a parallel constraint between 2 or more linesegments.
*/

class specification SKparallel (2:0) of SKrelornt, SKimplicit;

#ifndef BASE_EMS

override
 GRgetobjinfo,
 SKgetrelornt, SKorder_points, SKcreate_geom;

from SKrelornt inherit
  SKinit, SKmakejacobian, SKevaluate;

#endif

end specification SKparallel;
