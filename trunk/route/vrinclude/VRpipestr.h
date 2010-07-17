/*************************************************************************


Author	: BD,ON

Creation: october 23rd,1989.

		This file defines the structure for the piping .
Change History

	 Date	    |   name  | modification's description
        ------------+---------+------------------------------------------

*************************************************************************/


#ifndef VRuser_attr_include
#define VRuser_attr_include



struct VRpiping_select
{
   IGRchar	pds_class[13];		/* component class */
   IGRdouble	G_diameter;		/* biggest diameter */
   IGRdouble	R_diameter;		/* smallest diameter */
   IGRshort	option;			/* option if several
						   component are available
						   ( default : 1 ) */
};


struct VRpiping_attr 
{

        /* COMPONENT SELECTION */
	/*  ATTRIBUTES LOADED IN THE CONTROL COMPONENT  */

   IGRchar	part_name[31];
   IGRshort	fluid_code;
   IGRdouble	oper_temp[FORK];
   IGRdouble	oper_rating[FORK];
   IGRdouble	design_temp[FORK];
   IGRdouble	design_rating[FORK];
   IGRchar	line_id[30];
   IGRshort	heat_tracing;
};

#endif

