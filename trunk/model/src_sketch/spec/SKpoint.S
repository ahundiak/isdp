class specification SKpoint (2:0) of SKgeometry, GR3dpoint;

from SKgeometry inherit
  GRcopy, GRlocate, GRdelete, GRgetobjinfo, GRmksource, debug;

#ifndef BASE_EMS

override 
 SKcreate_constraint_points, 
 SKrecompute_yourself,
 GRplotyourself  	/* prevent it from ploting                 */,
 GRformatele     	/* prevent it from converting to IGDS      */,
 GRdisyourself	 	/* hilite the arc/circle I'm the center of */,
 GRadd_to_display_list;

#endif

end specification SKpoint;

