/*
ABSTRACT : ASfieldpt is the class of parametric points with position relative
           to a local bounded system (text). In the lbs, its position is 
           defined by barycentric coordinates in the corresponding box, the
           justification and the offsets. 

CHANGE HISTORY :
        D.P.      39-Aug-88 : design
*/

class specification ASfieldpt (0:1) of ASpoint;

instance ASfieldpt
  {
  IGRdouble dx;               /* Free space along X axis                      */
  IGRdouble dy;               /* Free space along Y axis                      */
  IGRshort  justif;           /* Justification of the text                    */
  IGRuchar  no_field;         /* Number of the field                          */
  };

override GRvg;
override GRnotify;

override
  NDplace,
  NDcompute_node,
  NDprint,
  GRgetobjinfo;

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

end specification ASfieldpt;
