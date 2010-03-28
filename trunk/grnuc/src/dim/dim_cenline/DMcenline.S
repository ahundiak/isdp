/*
	An associative class representing a Center line dimensions.

	Roots:

	1)	"mea_axis" - belonging to class "DMplan"

	2)	"environ_param" - belonging to class "dim_param"

	3)	"local_param" - belonging to class "dim_param"

	4)	the element to be dimensioned


*/

class specification DMcenline(2:0) of DMroot;

#include "dimcenline.h"

override GRvg;

instance DMcenline
{
	IGRdouble  gap_r;
	IGRdouble  minor_len_r;
	IGRdouble  major_len_r;
	IGRboolean posn;
};

override NDplace, DMplace;
override DMcompute_node;

/*****************************************************************************

			- make_cen_line -

	Description:

	Computes the end points of the center line(s) and would position
	the center line components properly - given the center point,
	dimensioning plane info and the dimensioning parameters.

	Arguments:

	IGRint *msg			(O)	return value
						DIM_S_SUCCESS - success
						failure otherwise

	struct DMdim_line cenline_info[6](O)    center line info

	struct GRmd_env *md_env		(I)	module environment

*****************************************************************************/

message make_cen_line(
	IGRint *msg;
	struct DMdim_line cenline_info[6];
	struct GRmd_env *md_env);

/*****************************************************************************

			- gather_data -

	Description:

	Given the list of parent ids, this message gathers all the data
	required for going ahead with the computation. The data includes
	center and center lines (projected on to the dimension plane),
	the radius of the curve(dimension value ), dimensioning plane
	 information and the dimensioning parameters.

	Arguments:

	IGRint *msg			(O)	return value
						DIM_S_SUCCESS - success
						failure otherwise

	IGRint count			(I)	No of parents

	struct GRid list[]		(I)	List of parent ids

	struct GRmd_env *md_env		(I)	module environment

	IGRdouble center[3]		(O)	Center point

	IGRdouble *pri_radius		(O)	| prim_axis of the ellipse or
						| radius of the curve

	IGRdouble *sec_radius		(O)	| sec_axis of the ellipse or
						| radius of the curve

	struct DMdim_line cenline_info	(O)	the center lines info

	struct DMplan_info *plan_info	(O)	dimensioning plane info

	struct DMenv_param *par_env	(O)	environment parameters

*****************************************************************************/

message gather_data(
	IGRint *msg;
	IGRint count;
	struct GRid list[];
	struct GRmd_env *md_env;
	IGRdouble center[3];
	IGRdouble *pri_radius;
	IGRdouble *sec_radius;
	struct DMdim_line cenline_info[6];
	struct DMplan_info *plan_info;
	struct DMenv_param *par_env);

override update_parents;
override validate_roots;
override dynamics;
override get_dim_attr;
override copy_dim_attr;
override get_dimension_plane;
override get_dim_params;
override set_dim_params;

end specification DMcenline;
