/*
	An associative class representing a coordinate dimensions.

	Roots:

	1)	"dimension plane" - belonging to class "DMplan"

	2)	"environ_param" - belonging to class "dim_param"

	3)	"local_param" - belonging to class "dim_param"

	4)	Origin Point or previous dimension

	5)	Measure Point (except for the origin dimension)
*/

class specification DMcoordj (2:0) of DMdim;

#include "dimcoord.h"
#include "dimcomplex.h"

override GRvg;

override NDplace, DMplace;
override DMcompute_node;

instance DMcoordj
{
	IGRuchar jogged;
	float jog_pt[2];
};


/*****************************************************************************

			- compute_trak_pt -

	Description:

	Computes the trak point position given the origin point (projected
	on to the window plane), trak distance and the dimension plane info.

	Arguments:

	IGRint *msg			(O)	Return value
						DIM_S_SUCCESS - success
						failure otherwise

	IGRchar mea_trak		(I)	mea_trak contains trak_info.

	IGRdouble dim_orig[3]		(I)	Dimension Origin Point

	IGRdouble trak_dist		(I)	Absolute trak distance

	struct DMplan_info *plan_info	(I)	Dimension plane information

	IGRdouble trak_pt[3]		(O)	Trak point position

*****************************************************************************/


message compute_trak_pt(
	IGRint *msg;
	IGRchar mea_trak;
	IGRdouble dim_orig[3];
	IGRdouble trak_dist;
	struct DMplan_info *plan_info;
	IGRdouble trak_pt[3]);


/*****************************************************************************

			- compute_proj_term -

	Description:

	Computes the terminator positions based on the projection angle,
	trak point position and the origin and measure points
	(projected on to the measurment plane). It also computes the text
	point position and dimension value

	Arguments:

	IGRint *msg			(O)	Return value
						DIM_S_SUCCESS - success
						failure otherwise

	IGRboolean *dimline_valid	(O)	Returns TRUE if dimline
						can be drawn.

	IGRdouble trak_pt[3]		(I)	trak point position

	struct DMenv_param *par_env	(I)	environment parameters

	struct DMplan_info *plan_info	(I)	dimensioning plane info

	struct GRmd_env *md_env		(I)	Module info.

	IGRdouble orig[3]		(I)	Dimension Origin Point

	IGRdouble cpx_orig[3]		(I)	Dimension common Origin Point

	IGRdouble meas[3]		(I)	Dimension Measure Point

	IGRdouble *dimn_value		(O)	Distance between origin point
						and measure point

	IGRdouble dimline_vec[3]	(O)	Unit vector from origin point
						to measure point

	IGRdouble txt_pt[3]		(O)	text position

	IGRdouble term_ori[3]		(O)	Origin Terminator position

	IGRdouble term_mea[3]		(O)	Measure Terminator position

	IGRdouble jog_line		(I)	Jogged line if present.

*****************************************************************************/

message compute_proj_term(
	IGRint *msg;
	IGRboolean *dimline_valid;
	IGRdouble trak_pt[3];
	struct DMenv_param *par_env;
	struct DMplan_info *plan_info;
	struct GRmd_env *md_env;
	IGRdouble orig[3];
	IGRdouble cpx_orig[3];
	IGRdouble meas[3];
	IGRdouble *dimn_value, txt_pt[3];
	IGRdouble dimline_vec[3];
	IGRdouble term_ori[3];
	IGRdouble term_mea[3];
	IGRdouble jog_line[9]);

/*****************************************************************************

			- make_proj_line -

	Description:

	Computes the projection line end points and make the projection
	lines given the dimensioning parameters, origin and measurement
	points (projected on to the measurement plane), and the terminator
	positons.

	Arguments:

	IGRint *msg			(O)	return value
						DIM_S_SUCCESS - success
						failure otherwise

	struct DMenv_param *par_env	(I)	environment parameters

	struct DMloc_param *par_loc	(I)	local parameters

	IGRdouble orig[3]		(I)	origin point

	IGRdouble meas[3]		(I)	measurement point

	IGRdouble term_ori[3]		(I)	origin terminator position

	IGRdouble term_mea[3]		(I)	measurement terminator position

	IGRdouble jog_line		(I)	Jogged line if present.

	struct GRmd_env *md_env		(I)	module environment

*****************************************************************************/

message make_proj_line(
	IGRint *msg;
	struct DMenv_param *par_env;
	struct DMloc_param *par_loc;
	struct DMplan_info *plan_info;
	IGRdouble orig[3], meas[3];
	IGRdouble term_ori[3], term_mea[3];
	IGRdouble jog_line[9];
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

	IGRboolean dimline_valid	(I)	Is TRUE if dimline
						can be drawn.

	IGRdouble term_ori[3]		(I)	Origin terminator positon

	IGRdouble term_mea[3]		(I)	Measurment term position

	struct DMenv_param *par_env	(I)	environment parameters

	struct DMloc_param *par_loc	(I)	local parameters

	struct DMplan_info *plan_info	(I)	dimensioning plane info

	struct GRmd_env *md_env		(I)	module environment

*****************************************************************************/

message make_dim_line(
	IGRint *msg;
	IGRboolean dimline_valid;
	IGRdouble *term_ori, *term_mea;
	struct DMenv_param *par_env;
	struct DMloc_param *par_loc;
	struct DMplan_info *plan_info;
	struct GRmd_env *md_env);

/*****************************************************************************

			- make_dim_text -

	Description:

	Computes the text position, orientation and text instance and
	sets the dimension text component correspondingly. The inputs
	include the text point position, dimension value, the
	dimensioning plane info and the dimensioning parameters.

	Arguments:

	IGRint *msg			(O)	return value
						DIM_S_SUCCESS - success
						failure otherwise

	IGRdouble meas_pt[3]		(I)	measurment point

	IGRdouble txt_pt[3]		(I)	text point postion

	IGRdouble dimn_value		(I)	dimension value

	struct DMenv_param *par_env	(I)	environment parameters

	struct DMloc_param *par_loc	(I)	local parameters

	struct DMplan_info *plan_info	(I)	dimensioning plane info

	struct GRmd_env *md_env		(I)	module environment

*****************************************************************************/

message make_dim_text(
	IGRint *msg;
	IGRdouble meas_pt[3];
	IGRdouble txt_pt[3];
	IGRdouble dimn_value;
	struct DMenv_param *par_env;
	struct DMloc_param *par_loc;
	struct DMplan_info *plan_info;
	struct GRmd_env    *md_env);

/*****************************************************************************

			- make_dim_term -

	Description:

	Sets the position, orientation and type of dimension terminator
	given the origin/measurement terminator positions, dimension
	line orientation (a unit vector) and the dimensioning parameters.

	Arguments:

	IGRint *msg			(O)	return value
						DIM_S_SUCCESS - success
						failure otherwise

	IGRboolean dimline_valid	(I)	Only if TRUE terminators
						will be placed.This flag
						does not control first
						dimension in a group.

	IGRdouble term_ori[3]		(I)	origin terminator position

	IGRdouble term_mea[3]		(I)	measure terminator position

	IGRdouble dimline[3]		(I)	dimension line orientation
						(must be unit vector)

	struct DMenv_param *par_env	(I)	environment parameters

	struct DMloc_param *par_env	(I)	local parameters

	struct DMplan_info *plan_info	(I)	dimension plane info

	struct GRmd_env *md_env		(I)	module environment

*****************************************************************************/

message make_dim_term(
	IGRint *msg;
	IGRboolean dimline_valid;
	IGRdouble term_ori[3];
	IGRdouble term_mea[3];
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
	orgin, measure and complex origin points (projected on to the
	dimension plane), dimensioning plane information and the
	dimensioning parameters.

	Arguments:

	IGRint *msg			(O)	return value
						DIM_S_SUCCESS - success
						failure otherwise

	IGRint count			(I)	No of parents

	struct GRid list[]		(I)	List of parent ids

	struct GRmd_env *md_env		(I)	module environment

	IGRdouble orig_P[3]		(O)	Origin point

	IGRdouble meas_P[3]		(O)	Measure point

	IGRdouble cpx_orig_P[3]		(O)	Complex origin point

	struct DMplan_info *plan_info	(O)	dimensioning plane info

	struct DMenv_param *par_env	(O)	environment parameters

	struct DMloc_param *par_loc	(O)	local parameters

*****************************************************************************/

message gather_data(
	IGRint *msg;
	IGRint count;
	struct GRid list[];
	struct GRmd_env *md_env;
	IGRdouble orig_P[3];
	IGRdouble meas_P[3];
	IGRdouble cpx_orig_P[3];
	struct DMplan_info *plan_info;
	struct DMenv_param *par_env;
	struct DMloc_param *par_loc);


/*****************************************************************************

			- get_mea_trak_info -

	Description:

	Returns - measurement axis, trak direction, trak origin
	and trak distance. 

	The dimension which needs trak information passes its
	mea_trak value, and this routine calls find_trak_info
	message and sends it the first dimension always.

	Arguments:

	IGRint *msg		(O)	DIM_S_SUCCESS if succesful.

	IGRdouble trak_orig[3]	(O)	trak origin point

	IGRchar *mea_trak	(I/O)	measurment axis and
					trak direction

					Input is the TRAK_ZONE.
					Output is control dim's
					mea_trak.

	IGRdouble *trak_dist;	(O)	Trak distance for origin
						dimension

	struct GRmd_env *md_env	(I)	Module Environment

*****************************************************************************/

message get_mea_trak_info(
	IGRint *msg;
	IGRdouble trak_orig[3];
	IGRchar *mea_trak;
	IGRdouble *trak_dist;
	struct GRmd_env *md_env);

/*****************************************************************************

			- find_mea_trak_info -

	Description:

	Returns - measurement axis, trak direction, trak origin
	and trak distance. 

	From the input mask info the TRAK_ZONE(primary or
	secondary) is found. From the first dimension in complex
	the give trak_zone is searched. The first dimension that
	matches with the trak_zone returns all the needed information.

	if ctrl_dim flag is set TRUE, apart from matching trak
	zone the "DM_TRAK_CTRL_DIM" bit is also checked.

	if search fails the method returns FALSE.

	Arguments:

	IGRint *msg		(O)	DIM_S_SUCCESS if succesful.

	IGRboolean first_in_cpx (I)	True if receiving dimension is
					first in complex.

	IGRboolean ctrl_dim	(I)	True if control bit needs to
					be matched.

	IGRchar mask		(I)	Trak Zone information.

	IGRchar *mea_trak	(I/O)	measurment axis and
					trak direction

					Input is the TRAK_ZONE.
					Output is control dim's
					mea_trak.

	IGRdouble trak_orig[3]	(O)	trak origin point

	IGRdouble *trak_dist;	(O)	Trak distance for origin
					dimension

	struct GRid *dim_grid	(O)	Control dimension GRid is
					returned in it.

	struct GRmd_env *md_env	(I)	Module Environment

*****************************************************************************/

message find_mea_trak_info(
	IGRint *msg;
	IGRboolean first_in_cpx;
	IGRboolean ctrl_dim;
	IGRchar mask;
	IGRchar *mea_trak;
	IGRdouble *trak_dist;
	IGRdouble trak_orig[3];
	struct GRid *dim_grid;
	struct GRmd_env *md_env);

message get_cpx_origin(
	IGRdouble cpx_origin[3];
	struct GRmd_env *md_env);

message compute_jog_line(
	IGRint *num_jog_pts;
	IGRchar mea_trak;
	IGRdouble orig_pt[3];
	IGRdouble trak_pt[3];
	IGRdouble jog_line[9];
	struct DMplan_info *plan_info;
	struct GRmd_env *md_env);

override dynamics;
override get_parent_info;
override get_dimension_plane;
override change_dimension_origin;
override change_dimension_measurement;
override give_rel_pos;
override jog_needed, jogged_off, clear_jog_pts;
override get_jog_info;
override get_dim_attr, copy_dim_attr;
override remove_from_cpx;
override GRdelete;
override adjust_trak_dist;

end specification DMcoordj;

