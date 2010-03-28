
class specification dist_pm (0:0) of expression;

/*\
ABSTRACT :  dist_pm is the class of parameter measuring the distance between 2
	    elements.

	    the 2 roots of this object can be points or lines. For
	    line the parameter measures the distance for INFINITES lines.


HISTORY : 
         jla       jul-86 : design
*/


override GRvg;

override NDplace,NDcompute_node,NDprint,NDmove_to_root;

reject modify;

/*\
OVERRIDE MOTIVATION
    Specific behaviour for
	NDplace        	 : placement.
	NDcompute_node 	 : recompute after a parent change
	NDmodify	 : doesn't allow a syntax modification
	NDprint	     	 : print via graph_printer to ci
	NDmove_to_root   : transform to a regular expression
\*/



end specification dist_pm;
