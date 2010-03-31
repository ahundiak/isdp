/*
  DESCRIPTION

    This class defines a horizontal / vertical constraint between 2 points.
    This object will be connected to the 2 points such that horizontal /
    vertical vector is defined by - pt1, pt2 such that pt1[X] < pt2[X] /
    pt1[Y] < pt2[Y].
*/

class specification SKhorizvert (2:0) of SKabsornt, SKimplicit;

#ifndef BASE_EMS

override 
  GRgetobjinfo,
  SKcreate_geom, SKorder_points, SKgetabsornt, SKevaluate;

from SKabsornt inherit
  SKmakejacobian;

#endif

end specification SKhorizvert;

