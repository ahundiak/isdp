

class specification AScirpar (0:1) of AScircle;


/*
ABSTRACT :
          The AScirpar is the class of circle concentric to another one. 
          Its roots are :
             -a arameter, distance between the 2 circles
	     -a circle to be concentric to.

          The 2 circles will remain in the same plane.

          Placement message will defined if the concentric circle is internal or
          external. Following change in the parameter sign will switch the
	  position
          


HISTORY : 
          ch       10-jul-86 : design.
         jla       10-mar-87 : union class.
*/


instance AScirpar
{
  IGRchar flag;    /*  0 --> the paral. circle is inside, 1 --> outside */
  IGRchar p_signe; /*  Not used					        */
};

override GRvg;
override GRnotify;

 override NDcompute_node, NDplace, NDprint, GRgetobjinfo, ASpossible_parent;


/*\
OVERRIDE MOTIVATION
    Specific behaviour for
	NDplace        	 : placement. as_attr is a pointer to an IGRpoint.
			   This point defines if the circle has to be
			   contructed internal or external to the original.
	NDcompute_node 	 : recompute after a root change.
	print	     	 : print via graph_printer to ci.
	GRgetobjinfo 	 : UI_status when locate.
	ASpossible_parent: return possible parents.
\*/



end specification AScirpar;
