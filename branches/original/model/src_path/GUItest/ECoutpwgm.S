/*
  DESCRIPTION

  This command locates EMS geometry curve and outputs it into a user-specified
  file as PW geometry.
  
  Polyline 2D: Inputs a GRcurve (s curve whose B-spline representation is of an
   order higher than 2, is stroked within the current cht) and outputs a
   2D polyline in a file.

  B-spline Cv: Inputs a GRcurve and outputs in PW format, the IGRbsp-curve.
   This file is readable by EMS debug in too. A polyline as input is output
   as an order 2, non-rational curve.
*/

class specification ECoutpwgm (3:2) of ECpathway;

override execute, get_locate_criteria;

end specification ECoutpwgm;
