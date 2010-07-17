/*************************************************************************


Author	: jll

Creation: december 6,1989.

		This file defines the structure for HVAC.
Change History

	 Date	    |   name  | modification's description
        ------------+---------+------------------------------------------
	12/12/89	VdM	modified for new file VRstructs.h
	
*************************************************************************/


#ifndef VHattr_include

#define VHattr_include

struct VRhvac_select
{
   IGRdouble	G_width;
   IGRdouble	G_depth;
   IGRdouble	R_width;
   IGRdouble	R_depth;
   IGRdouble	throat_rad;
   IGRdouble	trans_length;
   IGRdouble	cp_offset;
};


/* -------------- ATTRIBUTES LOADED IN THE CONTROL COMPONENT -------------- */

struct VRhvac_attr
{
   IGRshort	press_class;		
   IGRshort	service;
   IGRdouble	duct_thickness;
   IGRshort	material;
   IGRshort	sizing_method;
   IGRdouble	max_fric_per_lng;
   IGRdouble	max_depth;
   IGRdouble	max_velocity;
   IGRdouble	air_flow;
   IGRdouble 	equiv_diam;
   IGRchar	system_name[12];	
};

#endif

