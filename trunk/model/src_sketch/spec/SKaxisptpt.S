class specification SKaxisptpt (2:0) of SKptpt;
/*
  DESCRIPTION

    This class defines a point to point distance constraint along/perpendicular
    to a measurement axis.  This object is connected to the points among which
    distance is defined and the two points which define the measurement axis.

  HISTORY
    5/29/92   Rajiv Agrawal     Creation
*/

#ifndef BASE_EMS
override
  SKorder_points, SKinit, SKmakejacobian, SKgetptptinfo, SKevaluate;
#endif
end specification SKaxisptpt;

