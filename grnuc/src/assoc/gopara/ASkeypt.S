
/*\
ABSTRACT

    This class implements the associative key point for line string or curve.
    The roots of this object are :
     - a linestring or curve.
  
     - a coordinate system or a plane (optionnal) . If defined, the keypoint is
       projected in the Oxy plane.

    The key point has the following characteristics :

    For a line string (or lineseg or point) the key_point is a vertex

    For a general bspline the key_point is a point on the curve where the  
    tangent is perpendicular to the x or y axis of the coordinate system or
    plane defined as second roots (if not defined taken as identity).

    If the curve is open, the end point could also be taken as the key point.


    At placement time is taken the  nearest keypoint from the snap point.

    On a move or modification, the keypoint is maintained on the same vertex
    if it is linestring. If bspline, the nearest same kind of keypoint (
    start, end , tangent-x , tangent-y) is obtained.
   

NOTE :
    If user delete or add vertex : not implemented

CHANGE HISTORY:
   
    jla   25-may-87 : Design date
    jla     june-87 : Tangent point to curve
	
\*/

class specification ASkeypt (0:1) of ASpoint;

instance ASkeypt 
 {
	IGRdouble param;  /* parameter on curve             */
	IGRshort key;     /* vertex number for line_string  */
			  /* axe or end number for curve    */
        
 };

override GRvg;
 override GRnotify;

override  NDplace, NDcompute_node, NDprint, GRgetobjinfo, ASpossible_parent;

/*\
MOTIVATION
  NDplace            - placement. as_attr is a pointer on a IGRpoint. This 
		       "snap point" allows the selection of the nearest
		       key point.
  NDcompute_node     - maintain the key point on vertex when curve is modified
  NDprint            - edit to ci file
  GRgetobjinfo       - adequate message field on locate
  ASpossible_parent  - return possible roots and type
\*/


end specification ASkeypt;
