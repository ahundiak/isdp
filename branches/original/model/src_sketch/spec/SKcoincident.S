/*
  DESCRIPTION

    This class defines coincidence between two points - p1 and p2. It
    consists of two member constraints which together define this constraint.
    One is a horizontal constraint and the other a vertical constraint
    between the two points.
*/

class specification SKcoincident (2:0) of SKifimplicit;

#ifndef BASE_EMS
override 
  GRgetobjinfo,
  SKcreate_geom, SKinit;
#endif
end specification SKcoincident;
