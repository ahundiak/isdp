/*
	An associative class representing a Radial Jogged dimensions
	and Radial Diameter Dimension.

	Roots:

	1)	"mea_axis" - belonging to class "DMplan"

	2)	"environ_param" - belonging to class "dim_param"

	3)	"local_param" - belonging to class "dim_param"

	4)	the element to be dimensioned


*/

class specification DMradjog(2:0) of DMdim;

#include "dimradial.h"

override GRvg;

instance DMradjog
{
	IGRchar jogged;
	float jog_pt1[2];
	float jog_pt2[2];
};

/*
	The Following instances of the DMdim class is used by Radial Dims.

	brk_dist  -> the distance specifying the text position.
	lead_dist -> leader distance if leader on or jog pt1 distance if
		     jogged is on.
	trak_dist -> if not on curve the the angle of arc extension.

	offs_pt[2] -> text offset values.

	mea_trak  -> if set TRUE the dimension requires a extension arc.

	brk_pos  -> break point position.

	leader -> if set TRUE leader is on.
*/

override NDplace;
override DMcompute_node;

/*****************************************************************************

			- compute_jog_line -

	Description:

	Computes the jog line given the center and terminator points
	(projected on to the dimension plane) and instance values.

	Sub products

		dimline_vec = a unit vector form centerto terminator point

	Arguments:

	IGRint *msg			(O)	return value
						DIM_S_SUCCESS - success
						failure otherwise

	IGRint *num_jog_pts		(O)	number of jog pts present.

	IGRdouble center[3]		(I)	Center point

	IGRdouble term_pt[3]		(I)	Terminator point

	IGRdouble radline_vec[3]	(O)	Unit vector from center point
						to terminator point

	IGRdouble jog_line[]		(O)	Jog line

	struct DMplan_info *plan_info   (I)	plan info

*****************************************************************************/

message compute_jog_line(
	IGRint *msg;
	IGRint *num_jog_pts;
	IGRdouble center[3];
	IGRdouble term_pt[3];
	IGRdouble radline_vec[3];
	IGRdouble *jog_line;
	struct DMplan_info *plan_info);


/*****************************************************************************

			- compute_break_pt -

	Description:

	Computes the break point position given the center and terminator 
	points (projected on to the dimension plane).

	Arguments:

	IGRint *msg			(O)	return value
						DIM_S_SUCCESS - success
						failure otherwise

	IGRdouble center[3]		(I)	Center point

	IGRdouble term_pt[3]		(I)	Terminator point

	IGRdouble radline_vec[3]	(I)	Unit vector from center point
						to terminator point

	IGRdouble dimn_value		(I)	dimn value

	IGRdouble *jog_line		(I)	jogged line

	IGRdouble break_pt[3]		(O)	Break point position

	struct DMplan_info *plan_info	(I)	dimensioning plane info

*****************************************************************************/

message compute_break_pt(
	IGRint *msg;
	IGRdouble center[3];
	IGRdouble term_pt[3];
	IGRdouble radline_vec[3];
	IGRdouble dimn_value;
	IGRdouble *jog_line;
	IGRdouble break_pt[3];
	struct DMplan_info *plan_info);


/*****************************************************************************

			- compute_lead_pt -

	Description:

	Computes the leader point position, given the break point position,
	local and complex parameters and the dimensioning plane info.

	Arguments:

	IGRint *msg			(O)	return value
						DIM_S_SUCCESS - success
						failure otherwise

	IGRdouble break_pt[3]		(I)	break point position

	struct DMloc_param *par_loc	(I)	local parameters

	struct DMplan_info *plan_info	(I)	dimensioning plane info

	IGRdouble leader_pt[3]		(O)	leader point - returned

*****************************************************************************/

message compute_lead_pt(
	IGRint *msg;
	IGRdouble center[3];
	IGRdouble term_pt[3];
	IGRdouble break_pt[3];
	struct DMloc_param *par_loc;
	struct DMplan_info *plan_info;
	IGRdouble leader_pt[3]);

/*****************************************************************************

			- make_proj_arc-

	Description:

	Makes the projection arc given the dimensioning parameters, center
	and the arc endpoint positons.

	Arguments:

	IGRint *msg			(O)	return value
						DIM_S_SUCCESS - success
						failure otherwise

	struct DMenv_param *par_env	(I)	environment parameters

	struct DMloc_param *par_loc	(I)	local parameters

	struct DMplan_info *plan_info	(I)	Dimension Plane info

	struct DMdim_arc *arc_info	(I)	Projection arc info

	struct GRmd_env *md_env		(I)	module environment

*****************************************************************************/

message make_proj_arc(
	IGRint *msg;
	struct DMenv_param *par_env;
	struct DMloc_param *par_loc;
	struct DMplan_info *plan_info;
	struct DMdim_arc *arc_info;
	struct GRmd_env *md_env);

/*****************************************************************************

			- make_dim_line -

	Description:

	Computes the end points of the dimension line(s) and would position
	the dimension line components properly - given the terminator
	positions, dimension line vector, break point, leader point,
	dimensioning plane info and the dimensioning parameters.

	Arguments:

	IGRint *msg			(O)	return value
						DIM_S_SUCCESS - success
						failure otherwise

	IGRdouble num_jog_pts		(I)	number of jog pts

	IGRdouble center[3]		(I)	center point positon

	IGRdouble term_pt[3]		(I)	Terminator point position

	IGRdouble break_pt[3]		(I)	Break point position

	IGRdouble leader_pt[3]		(I)	Leader point position

	IGRdouble jog_line[]		(I)	Jogged line

	struct DMenv_param *par_env	(I)	environment parameters

	struct DMloc_param *par_loc	(I)	local parameters

	struct DMplan_info *plan_info	(I)	dimensioning plane info

	struct GRmd_env *md_env		(I)	module environment

*****************************************************************************/

message make_dim_line(
	IGRint *msg;
	IGRint num_jog_pts;
	IGRdouble *center, *term_pt;
	IGRdouble *dimline_vec;
	IGRdouble *break_pt;
	IGRdouble *leader_pt;
	IGRdouble *jog_line;
	struct DMenv_param *par_env;
	struct DMloc_param *par_loc;
	struct DMplan_info *plan_info;
	struct GRmd_env *md_env);

/*****************************************************************************

			- make_dim_text -

	Description:

	Computes the text position, orientation and text instance and
	sets the dimension text component correspondingly. The inputs
	include the terminator positions, dimension value, break point,
	leader point, the dimensioning plane info and the dimensioning
	parameters.

	Arguments:

	IGRint *msg			(O)	return value
						DIM_S_SUCCESS - success
						failure otherwise

	IGRint	num_jog_pts		(I)	number of jog pts

	IGRdouble center[3]		(I)	Center point position

	IGRdouble term_pt[3]		(I)	Terminator position

	IGRdouble break_pt[3]		(I)	Break point

	IGRdouble leader_pt[3]		(I)	Leader point

	IGRdouble *jog_line		(I)	jogged line

	struct DMenv_param *par_env	(I)	environment parameters

	struct DMloc_param *par_loc	(I)	local parameters

	struct DMplan_info *plan_info	(I)	dimensioning plane info

	struct GRmd_env *md_env		(I)	module environment

*****************************************************************************/

message make_dim_text(
	IGRint *msg;
	IGRint num_jog_pts;
	IGRdouble center[3];
	IGRdouble term_pt[3];
	IGRdouble dimn_value;
	IGRdouble break_pt[3];
	IGRdouble leader_pt[3];
	IGRdouble *jog_line;
	struct DMenv_param *par_env;
	struct DMloc_param *par_loc;
	struct DMplan_info *plan_info;
	struct GRmd_env    *md_env);

/*****************************************************************************

			- make_dim_term -

	Description:

	Sets the position, orientation and type of dimension terminators
	given the center and terminator point positions, dimension line
	orientation (a unit vector) and the dimensioning parameters.

	Arguments:

	IGRint *msg			(O)	return value
						DIM_S_SUCCESS - success
						failure otherwise

	IGRdouble center[3]		(I)	Center point position

	IGRdouble term_pt[3]		(I)	Terminator point position

	IGRdouble dimline[3]		(I)	dimension line orientation
						(must be unit vector)

	struct DMenv_param *par_env	(I)	environment parameters

	struct DMloc_param *par_env	(I)	local parameters

	struct DMplan_info *plan_info	(I)	dimension plane info

	struct GRmd_env *md_env		(I)	module environment

*****************************************************************************/

message make_dim_term(
	IGRint *msg;
	IGRdouble center[3];
	IGRdouble term_pt[3];
	IGRdouble dimline[3];
	struct DMenv_param *par_env;
	struct DMloc_param *par_loc;
	struct DMplan_info *plan_info;
	struct GRmd_env *md_env);

/*****************************************************************************

			- gather_data -

	Description:

	Given the list of parent ids, this message gathers all the data
	required for going ahead with the computation. The data includes
	center and terminator points (projected on to the dimension plane),
	the radius of the curve(dimension value ), dimensioning plane
	 information and the dimensioning parameters.

	Arguments:

	IGRint *msg			(O)	return value
						DIM_S_SUCCESS - success
						failure otherwise

	IGRint count			(I)	No of parents

	struct GRid list[]		(I)	List of parent ids

	struct GRmd_env *md_env		(I)	module environment

	IGRshort *projection_required	(O)	flag for projection

	IGRshort *const_radius		(O)	flag indiacating constant radius

	IGRdouble center[3]		(O)	Center point

	IGRdouble term_pt[3]		(O)	Terminator point

	IGRdouble *dimn_value		(O)	the radius of the curve

	struct DMdim_arc *arc_info	(O)	the projection arc info

	struct DMplan_info *plan_info	(O)	dimensioning plane info

	struct DMenv_param *par_env	(O)	environment parameters

	struct DMloc_param *par_loc	(O)	local parameters

*****************************************************************************/

message gather_data(
	IGRint *msg;
	IGRint count;
	struct GRid list[];
	struct GRmd_env *md_env;
	IGRshort *projection_required;
	IGRshort *const_radius;
	IGRdouble center[3];
	IGRdouble term_pt[3];
	IGRdouble *dimn_value;
	struct DMdim_arc *arc_info;
	struct DMplan_info *plan_info;
	struct DMenv_param *par_env;
	struct DMloc_param *par_loc);

message make_center_marker(
	IGRint *msg;
	IGRboolean marker_needed;
	IGRdouble center[3];
	struct DMenv_param *par_env;
	struct DMplan_info *plan_info;
	struct GRmd_env *md_env);

override validate_roots;
override leader_needed;
override jog_needed, jogged_off;
override clear_jog_pts;
override dynamics;
override get_dimension_plane;
override return_vertex;
override get_dim_attr;
override copy_dim_attr;
override get_jog_info;

end specification DMradjog;
