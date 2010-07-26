/*
ABSTRACT : ASboxpt is the class of parametric points with position relative to
           a local bounded system (text). In the lbs, its position is defined by
           barycentric coordinates in the corresponding box. 

CHANGE HISTORY :
        jla       29-sep-87 : design
*/

class specification ASboxpt (0:1) of ASpoint;

instance ASboxpt
  { IGRdouble xbar[3];    /* barycentric coordinate of the point in lbs box */
    IGRdouble offset[3];  /* offest not yet implemented			    */
  };

override GRvg;
override GRnotify;
override NDplace,NDcompute_node,NDprint,GRgetobjinfo;


/*
MOTIVATION :
    Specific behaviour for
	NDplace        	 : placement. asso_lis->as_attr is a pointer to double
		           The corresponding array tab[0,1,2] defines the
			   barycentric coordinate of the box point.
			   In the future tab[3,4,5] will define an additionnal
			   offset.
	NDcompute_node 	 : recompute after a parent change
	NDprint	     	 : print via graph_printer to ci
	GRgetobjinfo 	 : UI_status when locate
*/

end specification ASboxpt;
