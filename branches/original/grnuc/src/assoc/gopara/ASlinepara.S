/*\
ABSTRACT : ASlinepara is the class of parametric lines constructed parallel
	   to an existing one.

           The roots of this objet are :

           - the parameter distance value
	   - the original line.
	   - an optionnal track point.  If a track point is defined, the
	     relative position ot the  parametric line and track point will
	     remain as defined at placement time (same side of original line
	     or opposite).
	   - an optionnal plane.  If a plane is defined, it will control the
	     construction plane of the original line parallel line. They will
	     lie in a plane parallel to the defined one. If no plane is defined,
	     the two line will remain in a constant plane,as defined at
	     placement by the placement point.

	  The parallel line will have the same extend capabilities as the 
 	  original (via the GRextend message)




CHANGE HISTORY :
	
	jla     mar-86   exec0 design date
	jla  02_jul-86   conversion to ems
        jla  28-oct-86   associative implementation
	jla     sep-87   plane

\*/

class specification ASlinepara (0:1) of ASline;

instance ASlinepara
{
  IGRpoint vt;        /* second vector defining the plane with original line */
  IGRchar flag;       /* flag to denote which of several lines is the one    */
		      /* selected					     */
};
 
 override GRvg;
 override GRnotify;
 override NDcompute_node,NDplace,NDprint,GRgetobjinfo, ASpossible_parent,
	  ACcompute_node,ASlinext;
/*\
OVERRIDE MOTIVATION
    Specific behaviour for
	NDplace        	 : placement. asso_lis->as_attr is a pointer to IGRpoint
			   defining the retained solution (2 are  possible, one
			   on each side of the original line) and eventually the
			   plane.
	NDcompute_node 	 : recompute after a root change
	NDprint	     	 : print via graph_printer to ci
	GRgetobjinfo 	 : UI_status when locate
	ASpossible_parent: return possible roots
	ACcompute_node	  : Recompute when the object belongs to a "symbol 
			    macro".
        ACmap_(fo,from)_visible : save or restore instance data in macro header
			   when a parallel line is used in a symbol macro
        ASlinext         : When a line is extended it could change its internal
			   flag if the line changes orientation due to extends
\*/


message change_flag();

/*\
MOTIVATION change the internal flag in the instance 

\*/

end specification ASlinepara;
