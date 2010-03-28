
/*\
ABSTRACT

    This class implements the associative tangent point.

    The "associative tangent point" is the point of a curve where the
    tangent to the curve is perpendicular to a given direction. This
    direction could defined at placement time with a fix value,
    or depends upon an optional root.


    The roots of this object are :
     -  a curve.
  
     - a optional  coordinate system . If defined, the tangent point
       is the point of the curve where the normal is the vx or vy axes
       of the coor syst.

     - an optional track point : If defined, the retained tangent point will
       be the nearest from track point, at placement time or when recompute.


CHANGE HISTORY:
   
    jla     Sept-88 : Design date
	
\*/

class specification AStangpt (0:1) of ASpoint;

instance AStangpt 
 {
	IGRdouble param;  /* parameter on curve               */
	IGRvector dir;    /* fix direction for tangent point  */
			  /* if no coordinate system in roots */
        
 };

override GRvg;
 override GRnotify;

override  NDplace, NDcompute_node, NDprint, GRgetobjinfo, ASpossible_parent;

/*\
MOTIVATION
  NDplace            - placement. as_attr is a pointer to 9 doubles. 
		       If no track point as root, the first 3 defines a
		       proximity point.
		       If no coord. syst. as root, the 6 following defines
		       the 2 possible direction for tangency.
  NDcompute_node     - maintain the key point on vertex when curve is modified
  NDprint            - edit to ci file
  GRgetobjinfo       - adequate message field on locate
  ASpossible_parent  - return possible roots and type
\*/


end specification AStangpt;
