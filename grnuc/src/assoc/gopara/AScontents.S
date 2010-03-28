
class specification AScontents (0:1) of ASnode;

/*
ABSTRACT: The AScontents object gather all the objects connected to
          a coordinate system. These objects are connected via the GRowner
          channel in flexible mode
*/

instance AScontents
{
 IGRmatrix mat; /*matrix of coordinate system */
};

 override GRvg;


 override NDplace, NDcompute_node, NDprint, NDprint_root, NDcopy, NDdelete, 
          NDmove_to_root, NDgive_structure, NDselect_copy,
	  ACcompute_node, 
	  GRget_locate_properties,GRxform,GRdelete,GRgetobjinfo,
          NDmake_source,
	  NDattach_to_cs,NDdetach_from_cs;


/*\
OVERRIDE MOTIVATION
   Specific behaviour for
     NDplace        	 : Placement.
     NDcompute_node 	 : Recompute after a root change.
     NDprint	     	 : Print the graphic objects no connected to source
			   objects.
     NDprint_root        : Relay to the coordinate system.
     NDcopy		 : Copy itself and graphic objects connected via the 
	  		   channel to_components without notification on a
			   source object.
     NDdelete	         : As the NDcopy.
     NDmove_to_root      : Kill the AScontents object.
     NDgive_structure    : Relay the message to the coordinate system.
     GRget_locate_prop   : To be located only on fence locate
     GRxform             : To avoid double xform on fence manip
     ACcompute_node      : save or restore instance data in macro header
     ACmap_from_visible  : save or restore instance data in macro header
\*/

reject ASpossible_parent;

end specification AScontents;
