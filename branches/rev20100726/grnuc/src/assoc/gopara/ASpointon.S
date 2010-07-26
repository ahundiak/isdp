class specification ASpointon (0:1) of ASpoint;

/*
ABSTRACT :
	 ASpointon is the class of associative points constructed on a curve,
	 at a specific distance or curvilinear distance from a fix point.

	 The roots of this object are

             - a parameter (distance or curvilinear distance)
	     - curve
	     - fix point This point is projected on the  curve if necessary
	     - optionnal track point. The relative position of the point on
			 curve and track point will remain  as defined at
			 placement time (same side from fix point or opposite)


HISTORY : 
  S.Frezefond   mar-86  : exec0 implementation (on line only)  
  sf            jul-86  : conversion to ems
  ch            dec-86  : on line or circle
  ch            feb-87  : on general curve
*/


instance ASpointon
 {
  IGRchar s_ref_track; /* -1 --> [ -PI, 0 ], 1 --> [ 0, PI ] */
  IGRchar orient;      /* flag to denote which of the 2 possible points is */
		       /* the one selected				   */

 };


override GRvg;
 override GRnotify;
override  NDplace, NDcompute_node, NDprint, GRgetobjinfo, ASpossible_parent;

/*\
OVERRIDE MOTIVATION
    Specific behaviour for
	NDplace        	 : placement. as_attr is a pointer to an IGRpoint. This
			   "snap point" defines the side where the point on
			   curve has to be created. 
	NDcompute_node 	 : recompute after a parent change
	NDprint	     	 : print via graph_printer to ci
	GRgetobjinfo 	 : UI_status when locate
	ASpossible_parent: return possible parents
\*/

end specification ASpointon;
