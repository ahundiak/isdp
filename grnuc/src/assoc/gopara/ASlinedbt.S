
/*\
ABSTRACT : ASlinedbt is the class of parametric lines constructed tangent to 
	   2 elements (circles, arc of circles or point).

	   The  2 roots of this object are :
	    - a circle or an arc of circle
	    - a circle or an arc of circle or a point
	   
	   The ends of the line are the tangency points ( can be modified using
	   GRextend message)


HISTORY  :
        bd         mar-87 : exec0 design date
	jla        jul-86 : conversion to ems
	jla     30-oct-86 : associative implementation
\*/

class specification ASlinedbt (0:1) of ASline;



instance ASlinedbt
{
 IGRchar which1,which2;  /* choice on each circle */
};

 override GRvg;
 override GRnotify;
 override NDplace, NDcompute_node, NDprint, GRgetobjinfo, ASpossible_parent;
/*\
MOTIVATION
    Specific behaviour for
	NDplace        	  : placement. asso_lis->as_attr is a pointer to 6 
                            doubles. The 3 first define the choice on the first
			    circle, the 3 next on the second.
	NDcompute_node 	  : recompute after a parent change
	NDprint	     	  : print via graph_printer to ci
	GRgetobjinfo 	  : UI_status when locate
	ASpossible_parent : return possible parents (2 circles or a circle and
			    a point)
\*/


end specification ASlinedbt;
