
/*\
ABSTRACT : 
        ASby2ptsg is the class of associative lines connecting 2 points.
	The roots of this object are: 
		- start point,
		- end point.


CHANGE HISTORY :
	S.Frezefond    02/07/86 : first test 
	jla            15/10/86 : revue and associative implementation
\*/

class specification ASby2ptsg (0:1) of ASline;

 override GRvg; 
override GRnotify;

 override NDplace, NDcompute_node, NDprint, GRgetobjinfo, ASpossible_parent;

/*\
MOTIVATION
    Specific behaviour for
	NDplace        	  : placement
	NDcompute_node 	  : recompute after a parent change
	NDprint	     	  : print via graph_printer to ci
	GRgetobjinfo 	  : UI_status when locate
	ASpossible_parent : return possible parents
\*/


end specification ASby2ptsg;
