/*
	An associative class representing linear dimensions.

	Roots:

	1)	dimension plane - belonging to class "DMplan"

	2)	environment parameters - belonging to class "dim_param"

	3)	local parameters - belonging to class "dim_param"

	4)	Origin Point

			or

		The Previous Dimension (other than the first dimension)

	5)	Measure Point
*/

class specification DMlinear(2:0) of DMdim;

#include "dimlinear.h"

override GRvg;

override NDplace;
override DMcompute_node;

/*****************************************************************************

			- compute_trak_pt -

	Description:

	Computes the trak point position given the origin point (projected
	on to the window plane), absolute trak distance of the previous
	dimension in the stack (zero for the first dimension, complex
	parameters and the dimension plane info. Adds up the relative
	trak_dist and the previous dimension's trak distance
	and then computes a point at the given distance.

	Arguments:

	IGRint *msg			(O)	Return value
						DIM_S_SUCCESS - success
						failure otherwise

	IGRdouble dim_origin[3]		(I)	Dimension Origin Point

	IGRdouble trak_dist		(I)	Absolute trak distance

	struct DMenv_param *par_env	(I)	environment parameters

	struct DMplan_info *plan_info	(I)	Dimension plane information

	IGRdouble trak_pt[3]		(O)	Trak point position - returned

*****************************************************************************/


message compute_trak_pt(
	IGRint *msg;
	IGRdouble dim_origin[3];
	IGRdouble trak_dist;
	struct DMplan_info *plan_info;
	IGRdouble trak_pt[3]);


/*****************************************************************************

			- compute_proj_term -

	Description:

	Computes the terminator positions based on the projection angle,
	trak point position and the origin and measure points
	(projected on to the measurment plane).

	Arguments:

	IGRint *msg			(O)	Return value
						DIM_S_SUCCESS - success
						failure otherwise

	IGRdouble trak_pt[3]		(I)	trak point position

	IGRdouble proj_angl		(I)	projection angle(in degrees)

	struct DMplan_info *plan_info	(I)	dimensioning plane info

	IGRdouble orig[3]		(I)	Dimension Origin Point

	IGRdouble meas[3]		(I)	Dimension Measure Point

	IGRdouble term_ori[3]		(O)	Origin Terminator position

	IGRdouble term_mea[3]		(O)	Measure Terminator position

*****************************************************************************/

message compute_proj_term(
	IGRint *msg;
	IGRdouble trak_pt[3];
	IGRdouble proj_angl;
	struct DMplan_info *plan_info;
	IGRdouble orig[3];
	IGRdouble meas[3];
	IGRdouble term_ori[3];
	IGRdouble term_mea[3]);

/*****************************************************************************

			- compute_break_pt -

	Description:

	Computes the break point position given the origin and measurement
	points (projected on to the dimension plane).

	Sub products
		dimn_value = distance between the origin and measurement
			     points

		dimline_vec = a unit vector form origin to measurement point

	Arguments:

	IGRint *msg			(O)	return value
						DIM_S_SUCCESS - success
						failure otherwise

	IGRdouble orig[3]		(I)	Origin point

	IGRdouble meas[3]		(I)	Measurement point

	IGRdouble *dimn_value		(O)	Distance between origin point
						and measure point

	IGRdouble dimline_vec[3]	(O)	Unit vector from origin point
						to measure point

	IGRdouble break_pt[3]		(O)	Break point position

	struct DMplan_info *plan_info	(I)	dimensioning plane info

*****************************************************************************/

message compute_break_pt(
	IGRint *msg;
	IGRdouble orig[3];
	IGRdouble meas[3];
	IGRdouble *dimn_value;
	IGRdouble dimline_vec[3];
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
	IGRdouble break_pt[3];
	struct DMloc_param *par_loc;
	struct DMplan_info *plan_info;
	IGRdouble leader_pt[3]);

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

	struct GRmd_env *md_env		(I)	module environment

*****************************************************************************/

message make_proj_line(
	IGRint *msg;
	struct DMenv_param *par_env;
	struct DMloc_param *par_loc;
	IGRdouble orig[3], meas[3];
	IGRdouble term_ori[3], term_mea[3];
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

	IGRdouble term_ori[3]		(I)	Origin terminator positon

	IGRdouble term_mea[3]		(I)	Measurment term position

	IGRdouble break_pt[3]		(I)	Break point position

	IGRdouble leader_pt[3]		(I)	Leader point position

	struct DMenv_param *par_env	(I)	environment parameters

	struct DMloc_param *par_loc	(I)	local parameters

	struct DMplan_info *plan_info	(I)	dimensioning plane info

	struct GRmd_env *md_env		(I)	module environment

*****************************************************************************/

message make_dim_line(
	IGRint *msg;
	IGRdouble term_ori[3];
	IGRdouble term_mea[3];
	IGRdouble dimline_vec[3];
	IGRdouble break_pt[3];
	IGRdouble leader_pt[3];
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

	IGRdouble term_ori[3]		(I)	Origin terminator position

	IGRdouble term_mea[3]		(I)	Measure terminator position

	IGRdouble break_pt[3]		(I)	Break point

	IGRdouble leader_pt[3]		(I)	Leader point

	struct DMenv_param *par_env	(I)	environment parameters

	struct DMloc_param *par_loc	(I)	local parameters

	struct DMplan_info *plan_info	(I)	dimensioning plane info

	struct GRmd_env *md_env		(I)	module environment

*****************************************************************************/

message make_dim_text(
	IGRint *msg;
	IGRdouble term_ori[3];
	IGRdouble term_mea[3];
	IGRdouble break_pt[3];
	IGRdouble leader_pt[3];
	struct DMenv_param *par_env;
	struct DMloc_param *par_loc;
	struct DMplan_info *plan_info;
	struct GRmd_env    *md_env);

/*****************************************************************************

			- get_mea_trak_info -

	Description:

	Returns - measurement axis, trak direction, complex origin
	and absolute previous trak distance. Adds up all relative
	trak distances upto to the first dimension in a complex.

	Arguments:

	IGRdouble cpx_origin[3]		(O)	Complex origin point

	IGRchar *mea_trak		(O)	measurment axis and
						trak direction

	IGRdouble *trak_dist;		(I/O)	Must be initialised to
						zero.

	struct GRmd_env *md_env		(I)	Module Environment

*****************************************************************************/

message get_mea_trak_info(
	IGRdouble cpx_origin[3];
	IGRchar *mea_trak;
	IGRdouble *trak_dist;
	struct GRmd_env *md_env);

/*****************************************************************************

			- make_dim_term -

	Description:

	Sets the position, orientation and type of dimension terminators
	given the origin and measurement terminator positions, dimension
	line orientation (a unit vector) and the dimensioning parameters.

	Arguments:

	IGRint *msg			(O)	return value
						DIM_S_SUCCESS - success
						failure otherwise

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
	dimension plane), absolute trak distance of the dimension,
	dimensioning plane information and the dimensioning parameters.

	Arguments:

	IGRint *msg			(O)	return value
						DIM_S_SUCCESS - success
						failure otherwise

	IGRint count			(I)	No of parents

	struct GRid list[]		(I)	List of parent ids

	IGRdouble orig_P[3]		(O)	Origin point

	IGRdouble meas_P[3]		(O)	Measure point

	IGRdouble cpx_orig_P[3]		(O)	Complex origin point

	IGRdouble *trak_dist		(O)	trak point distance for
						the dimension

	struct DMplan_info *plan_info	(O)	dimensioning plane info

	struct DMenv_param *par_env	(O)	environment parameters

	struct DMloc_param *par_loc	(O)	local parameters

	struct GRmd_env *md_env		(I)	module environment

*****************************************************************************/

message gather_data(
	IGRint *msg;
	IGRint count;
	struct GRid list[];
	IGRdouble orig_P[3];
	IGRdouble meas_P[3];
	IGRdouble cpx_orig_P[3];
	IGRdouble *trak_dist;
	struct DMplan_info *plan_info;
	struct DMenv_param *par_env;
	struct DMloc_param *par_loc;
	struct GRmd_env *md_env);

message set_proj_disp(IGRchar *proj_disp);

/*****************************************************************************

			- get_orig_meas -

	Description:

	Given the list of roots (or templates) this message computes the
	origin, measurement point and complex origin positions. In addition,
	it retrieves (and recomputes) the dimensioning plane info.
	This message is not implemented at this level.
	MUST BE IMPLEMENTED BY THE SUB CLASSES.

	Arguments:

	IGRint *msg			(O)	DIM_S_SUCCESS - success
						failure otherwise

	IGRint count			(I)	Number of parents

	struct GRid list[]		(I)	List of parents

	struct DMplan_info *plan_info	(O)	Dimension Plane info

	IGRchar *mea_trak		(O)	Measurement and trak direcion

	IGRdouble *trak_dist		(O)	Absolute Trak distance

	IGRdouble dim_orig[3]		(O)	Origin Point

	IGRdouble dim_meas[3]		(O)	Measurement Point

	IGRdouble cpx_orig[3]		(O)	Complex Origin Point

*****************************************************************************/

message get_orig_meas(
	IGRint *msg;
	IGRint count;
	struct GRid list[];
	struct GRmd_env *md_env;
	struct DMplan_info *plan_info;
	IGRchar *mea_trak;
	IGRdouble *trak_dist;
	IGRdouble dim_orig[3];
	IGRdouble dim_meas[3];
	IGRdouble cpx_orig[3]);

override get_dimension_plane;
override dynamics;
override leader_needed;
override fill_info;
override get_parent_info;
override change_dimension_origin;
override change_dimension_measurement;
override init_ter_loca;
override compute_attr;

reject get_orig_meas;

end specification DMlinear;


