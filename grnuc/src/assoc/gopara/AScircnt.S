	

class specification AScircnt (0:1) of AScircle;

/*
ABSTRACT : 
           The AScircnt is the class of parametric circles constructed with
	   a specified radius around an existing point.

	   The possible roots of these objects are :
	   - a parameter, radius value.
           - a point.
	   - an optionnal plane.
             - If defined, the circle will remain in a parallel plane, passing
	       through the center point.
	     - If not defined it will stay in the constant plane given at
	       placement time.
	
HISTORY : 
          ch       jul-86 : design date.
         jla       mar-87 : union class.


*/

override GRvg;
override GRnotify;

 override NDcompute_node, NDplace, NDprint, GRgetobjinfo, ASpossible_parent;

/*\
OVERRIDE MOTIVATION
    Specific behaviour for
	NDplace        	 : placement. asso_list->as_attr is a pointer to an 
			   IGRvector. This vector defines the plane where the 
			   circle has to be constructed (view vector) if no
			   plane as root.
	NDcompute_node 	 : recompute after a root change
	NDprint	     	 : print via graph_printer to ci
	GRgetobjinfo 	 : UI_status when locate
	ASpossible_parent: return possible parents
\*/


end specification AScircnt;
