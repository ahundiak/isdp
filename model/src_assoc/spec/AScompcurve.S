/* ###################   APOGEE COMPILED   ################## */
/*
ABSTRACT : AScompcurve is the class of parametric composite curve 
	   Same behaviour than regular composite with associative enhancement :
	   if the componant of the composite changes, the composite is
	   updated (if possible)


CHANGE HISTORY :
	
	JLA    mai 88 : design date

*/


class specification AScompcurve (0:1) of ASnode,GRcompcurve;

 override GRvg;

 override NDcompute_node,NDplace,NDprint,GRgetobjinfo,ASreturn_go,
          NDgive_structure,NDmove_to_root,NDcopy_to_root,ACmap_from_visible,
          GRptproject, GRlnproject,ASpossible_parent,NDs_compute_node,
	  GRdrop,GRcopy,ACreturn_foot;
 

/* override to use the ASnode branch override */

 from ASnode inherit GRconstruct,GRxform,GRdelete,GRdisyourself,GRclip,
	      GRaddwrng,GRownaddwrng,GRownremwrng/*,GRget_locate_properties*/;



/*\
OVERRIDE MOTIVATION
    Specific behaviour for
	NDplace        	 : placement. asso_lis->as_attr is a pointer to IGRpoint
			   defining the retained solution (2 are  possible, one
			   on each side of the original line) and eventually the
			   plane.
	NDcompute_node 	 : recompute after a root change
	NDprint	     	 : print via graph_printer to ci
	NDgive_structure : return "curve_generic" type.
	GRgetobjinfo 	 : UI_status when locate
	ASpossible_parent: return possible roots
        ASreturn_go      : return directly my_id because i'm at the same time
			   associative and graphic
	NDmove_to_root   : move to a GRcompcurve
	NDcopy_to_root   : create to a GRcompcurve
        ACmap_from_visible: to force creation of graphic object even
                            if non displayable
        GRptproject      : To make it work for AScomp in macro with an
			   intermediate ACpretgo
\*/

end specification AScompcurve;
