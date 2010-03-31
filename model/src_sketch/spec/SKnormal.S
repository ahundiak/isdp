/*

 ABSTRACT

 This class defines a perpendicular constraint between 2 linesegments.
 This object will be connected to the 3 or 4 points (p1, <p2 p3>, p4)
 defined by the 2 linesegments such that segment <p3,p4> makes a
 90 degree angle w.r.t segment <p2,p1> in the counter_clockwise
 direction. 

 The points will be sorted by examining the current topology of the 
 sketch.
     
 HISTORY

 RC  05/08/90     Creation Date

*/

class specification SKnormal (2:0) of SKrelornt, SKimplicit;

#ifndef BASE_EMS

override
 GRgetobjinfo,
 SKcreate_geom, SKgetrelornt;

from SKrelornt inherit
  SKinit, SKorder_points, SKmakejacobian, SKevaluate;

#endif

end specification SKnormal;
