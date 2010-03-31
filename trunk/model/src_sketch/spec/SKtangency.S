/*
  DESCRIPTION

   This class defines a tangent constraint at the end
   point of an arc. 

   If the point is between a line and an arc, it will be defined by a normal
   constraint. This normal constraint is between by 2 lines, one defined by 
   radius point and tangent point and the other is the line itself.

   If the point is between 2 arcs, it will be defined by a collinear constraint
   among the center points of the arcs and the tangent point.
*/

class specification SKtangency (2:0) of SKifimplicit;

#ifndef BASE_EMS

override
  GRgetobjinfo,
  SKinit, SKcreate_geom;

#endif

end specification SKtangency;
