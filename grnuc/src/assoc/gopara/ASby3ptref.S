/*
ABSTRACT :
          The ASby3ptref class is the class of local coordinate systems defined
	  by 3 points. These roots are:
                - point at origine,
                - point on the positive x_axis,
	        - point in the  positive y plane.
CHANGE HISTORY
	
	JLA    22 nov  86 : design date
  D.Payannet   15 mar  87 : Use of regular coordonate system as graphic image
*/


class specification ASby3ptref (0:1) of ASref;


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


end specification ASby3ptref;
