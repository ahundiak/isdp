/* This file defines the structures used in capping surfaces */

# ifndef EMScap_include
# define EMScap_include 1
 
struct EMcap_ed_sf
{
			GRobjid 			ed;
	struct 	IGRbsp_curve		ed_geoms;
	  		GRobjid				sf;
};

struct EMcap_plane
{
	struct	IGRbsp_surface	plane;
			GRobjid			plane_id;
};

# endif
