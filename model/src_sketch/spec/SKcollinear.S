/*
   DESCRIPTION

     This class defines a collinearity constraint among 3 
     points. 
*/

class specification SKcollinear (2:0) of SKrelornt, SKimplicit;
#ifndef BASE_EMS
override
  GRgetobjinfo,
  SKcreate_geom, SKgetrelornt, SKorder_points;

from SKrelornt inherit
  SKinit, SKmakejacobian, SKevaluate;
#endif

end specification SKcollinear;
