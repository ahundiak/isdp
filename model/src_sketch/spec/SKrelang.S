/*
  DESCRIPTION
n
    This class defines an angular dimension constraint between 3 or 4 points.
    The angle is measured by traversing counter-clockwise from segment defined
    by Pt1 and Pt2 to segment defined by Pt3 (Pt2) and Pt4 (Pt3). The order of
    connection of points is Pt1, Pt2 (Pt3) and Pt4. If the exclude-angle
    property is set, it means the angle stored is actually the complement
    of the included angle.
*/

class specification SKrelang (2:0) of SKrelornt, SKexplicit;

#ifndef BASE_EMS

override
  SKgetrelornt, SKcreate_geom;

from SKrelornt inherit
  SKinit, SKorder_points, SKmakejacobian, SKevaluate;

#endif

end specification SKrelang;
