	

class specification AScspoint (0:1) of ASpoint;

/*
ABSTRACT : 
           The AScspoint is the class of parametric point on coordinate
	   system.

	   The possible roots of these objects are :
	   - 3 parameters (x, y, z) coordinates.
           - a coordinate system.
	
HISTORY : 
          momo     novembre 88.

*/


instance AScspoint
{
   IGRchar cs_type;
};


override GRvg;
override GRnotify;

 override NDcompute_node, NDplace, NDprint, GRgetobjinfo, ASpossible_parent;

/*\
OVERRIDE MOTIVATION
    Specific behaviour for
	NDplace        	 : placement.
	NDcompute_node 	 : recompute after a root change.
	NDprint	     	 : print via graph_printer to ci.
	GRgetobjinfo 	 : UI_status when locate.
	ASpossible_parent: return possible parents.
\*/

end specification AScspoint;
