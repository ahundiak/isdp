	

class specification ASintpt (0:1) of ASpoint;

/*
ABSTRACT:
         The ASintpt class is the class of associatif points constructed at 
	 the intersection of 2 elements.

         The 2 or 3 possible roots of this object are :
             - 2 curves,
	     - an optional track_point. If defined the retained solution will
	       remain.
		   - the nearest from track point for general curve intersection
		   - with relative position as defined at placement for line-
	             circle intersection (nearest or farest from track point).


HISTORY : 
	S.Frezefond       jul-86 : desing date.
	jla               sep-86 : b_spline intersection.
	ch		  dec_87 : remove the normal from instance.  
*/

instance ASintpt
{
 IGRchar orient;    /* flag to denote which of several intersection points  */
		    /* is the one selected 				    */

};


override GRvg;
 override GRnotify;


override NDplace, NDcompute_node, NDprint, GRgetobjinfo, ASpossible_parent;

/*\
OVERRIDE MOTIVATION
    Specific behaviour for
	NDplace        	 : placement. as_attr is a pointer to an IGRpoint. This
			   "snap point" defines the intersection point to 
			   be retained is several.
	NDcompute_node 	 : recompute after a root change.
	NDprint	     	 : print via graph_printer to ci.
	GRgetobjinfo 	 : UI_status when locate.
	ASpossible_parent: return possible parents.
\*/


end specification ASintpt;
