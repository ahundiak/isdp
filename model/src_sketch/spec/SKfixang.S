/*
  DESCRIPTION

    This class defines an angular dimension constraint between the horizontal
    (or vertical) and two points.
*/

class specification SKfixang (2:0) of SKabsornt, SKexplicit;

#ifndef BASE_EMS

override
  SKorder_points, SKgetabsornt, SKinit, SKcreate_geom;

#endif

from SKabsornt inherit
  SKmakejacobian, SKevaluate;

end specification SKfixang;
