	

class specification ASextbsp (0:1) of ASbspline;

/*
ABSTRACT: Extract from an original curve the curve defined
          by the projection of a start and end point.
	  The 3 roots of this objects are
	  - The curve
	  - A start point
	  - An end point

	  If the original curve is closed, the point given as snap
	  point in the place message will define the retained solution

	  Not implemented : track point to be able to modify the retain
			    solution


HISTORY : 
        jla 26 may 88 : Design date
*/

instance ASextbsp
{
 IGRchar orient;   /* reverse for future use (with track point) */
};

 override GRvg;
override GRnotify;

 override NDplace, NDcompute_node, NDprint, GRgetobjinfo,
          ASpossible_parent;


/*\
OVERRIDE MOTIVATION
    Specific behaviour for
	NDplace        	  : placement. as_attr is a pointer to an IGRpoint. This
			   "snap point" defines the retained solution if
			   the curve is closed
	NDcompute_node 	  : recompute after a root change.
	NDprint	     	  : print via graph_printer to ci.
	GRgetobjinfo 	  : UI_status when locate.
	ASpossible_parent : return possible parents.
	ACmap_from_visible: to force creation of graphic object even
			    if non displayable
\*/


end specification ASextbsp;
