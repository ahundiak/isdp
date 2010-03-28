/*
ABSTRACT :
          The ASbyzref class is the class of local coordinate systems defined
	  by 3 parents.
		- a point : origin of the coordinate system

                - a curve : the z axes of the coordinate system is defined
			    by the tangent to the curve at the projection point
			    of the origine onto this curve.

		- a line  : This line defines the x axes of the coordinate
			    system. If the line is not in the plane
			    perpendicular to Vz, its projection in this plane
			    is taken instead.


CHANGE HISTORY
	
	JLA    Sept  88 : design date
*/


class specification ASbyzref (0:1) of ASref;


override GRvg;
override GRnotify;
override GRgencs;


override NDplace, NDcompute_node, NDprint, GRgetobjinfo, ASpossible_parent;

/*\
OVERRIDE MOTIVATION
    Specific behaviour for
	NDplace        	 : placement.
	NDcompute_node 	 : recompute after a parent change. 
	NDprint	     	 : print via graph_printer to ci
	GRgetobjinfo 	 : UI_status when locate
	ASpossible_parent: return possible parents
\*/


end specification ASbyzref;
