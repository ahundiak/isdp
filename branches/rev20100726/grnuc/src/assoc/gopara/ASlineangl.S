
/*\
ABSTRACT : ASlineangl is the class of parametric lines constructed through a
	   fixed point at a given angle  of an existing line.

  	   The roots of this object are :

 	   - the parameter (angle value)
	   - the original line or a local coordinate system
	   - the fixe point
	   - the track point (optionnal). If defined, the line at angle will
	     stay at the same relative position from track point as define
	     at placement (same side or opposite)
           - the construction plane. If the fix point is not on the original 
	     line, the plane where the angle line has to be construced is 
	     fully defined. If these point is on the line the plane used is
             - a plane parallel to construction plane if one is defined.
	     - the plane defined by the original line and the point pass in
	       the arguments of the NDplace message.

  the object has the following characteristics :

  The line angle passes trough the fix point making the defined angle with
  the original line. 

  If the second root is a local coordinate system, the angle line will be
  relative to the x_axis of the lcs (way to define horizontal or vertical lines)


CHANGE HISTORY:
	
        jla       jul-86 : design date
	jla       Mar-87 : union class
        jla       sep-87 : plane implementation

\*/


class specification ASlineangl (0:1) of ASline;

instance ASlineangl
{
  IGRpoint vnorm;       /* vector normal to plane where the lines lie 	      */
  IGRchar  flag;        /* flag to denote which of several lines is the one   */
			/* selected					      */
};

  override GRvg;
 override GRnotify;

  override NDplace,NDcompute_node,NDprint,GRgetobjinfo,ASpossible_parent,
	  ACcompute_node;


/*\
MOTIVATION
    Specific behaviour for
    NDplace           : placement. asso_lis->as_attr is a pointer to IGRpoint
		        This snap point defines the retained solution (2 are 
			possible) , the initial extend of the line, and the
	                plane if the fix point is on the original line and if
			there is no plane as parent of the element.
    NDcompute_node    : recompute after a root change
    NDprint	      : print via graph_printer to ci
    GRgetobjinfo      : UI_status when locate
    ASpossible_parent : return possible root
    ACcompute_node    : Recompute when the object belongs to a "symbol macro".
    ACmap_(fo,from)_visible : save or restore instance data in macro header 
			when a line at angle is used in a symbol macro.
\*/


end specification ASlineangl;
