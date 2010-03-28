	

class specification ASrevbsp (0:1) of ASbspline;

/*
ABSTRACT: Just reverse parametrization of the root curve.



HISTORY : 
        jla  Jan 89 : Design date
*/

 override GRvg;
 override GRnotify;

 override NDplace, NDcompute_node, NDprint, GRgetobjinfo;

/*\
OVERRIDE MOTIVATION
    Specific behaviour for
	NDplace        	 : placement.
	NDcompute_node 	 : recompute after a root change.
	NDprint	     	 : print via graph_printer to ci.
	GRgetobjinfo 	 : UI_status when locate.
\*/


end specification ASrevbsp;
