class specification ASarccntrd (0:1) of ASarc;


/*
ABSTRACT :
          The ASarccntrd class is the class of circular arcs defined by 
	  4 or 5 roots which are:
             - parameter, value of radius.
	     - center point.
	     - start point.
	     - end point.
	     - an optionnal track point . If defined the displayed arc will
	       remain after move at the same relative side of track point,
	       as defined at placement (same side or opposite)
          


HISTORY : 
          ch       10-jul-86 : design
         jla       10-mar-87 : union class
*/


instance ASarccntrd
{
   IGRboolean orient_f; /*  true same side of the track point else false  */
};


override GRvg;
override GRnotify;

 override NDplace, NDprint, GRgetobjinfo, ASpossible_parent, NDcompute_node;


/*\
OVERRIDE MOTIVATION
    Specific behaviour for
	NDplace        	 : placement. as_attr is a pointer to the IGRvector
			   view_vector. This vector defines a plane orientation.
		           The arc will be created from start to sweep in the
			   anti-clockwise sens of this plane.
	NDprint	     	 : print via graph_printer to ci.
	GRgetobjinfo 	 : UI_status when locate.
	ASpossible_parent: return possible parents.
\*/


end specification ASarccntrd;
