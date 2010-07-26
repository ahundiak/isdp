#ifndef dimplcmacros_include

#define dimplcmacros_include

#include "dimdef.h"
#include "dim.h"

#define MIN_TRAK_DIST  -1.0
#define ANG_DIM_RELATIVE -1
#define ANG_DIM_HORIZANTAL 1
#define ANG_DIM_VERTICAL 2

/*-----------------------------------------------------------------

	This files contains all dimension placement macros and
	other dimension related macros.

	The TYPES of dimensions supported for macro placement
	are.

	stacked linear dimension	- dm$place_stack_linear.
	stringed linear dimension	- dm$place_string_linear.
	stacked angular dimension	- dm$place_angular.
	stringed angular dimension	- dm$place_string_angular.
	single parallel dimension	- dm$place_sglpara.
	circular diameter dimension	- dm$place_cirdia.
	linear diameter dimension	- dm$place_lindia.
	radial dimension		- dm$place_radial.
	radial diameter dimension	- dm$place_radial_dia.
	center lines			- dm$place_center_lines.
	single parallel (Arc angle)	- dm$place_sglarc_angle.
	single parallel (Arc length)	- dm$place_sglarc_length.
	coordinate linear dimension	- dm$place_coord_linear.
	text with leader annotation	- dm$place_text_with_leader.
	leader line annotation		- dm$place_leader_line.
	datum frame annotation		- dm$place_datum_frame.

	The different TERMINOLOGY & some dimension concepts are
	briefly discussed below.

	The dimension are classified to different types(apart from
	type of measurment) based on the behaviour. This type is
	called "geom_type". The different geom_types are defined in
	dimdef.h.

	The dimension object is always constructed on a plane(called
	dimension plane) and this information is stored in dimension
	plane object. During placement the dimension plane information
	could passed as

	1. Window GRid, In this case we get the window plane and
	   construct a dimension plane object with it.

	2. Reference Plane object, In this case the reference plane
	   is used to construct the dimension object.

	3. Matrix defining a plane, which is used for the construction
	   of dimension plane object.

	4. Dimension plane object itself.

	There are some parameters needed for positioning the
	dimension properly.

	dimension line --- 	 --- Text point(break point).
			  \     /	
			|<-----xx------>| ----
			|		|  |--------> Trak distance.
	origin-------->	|		|  |   	~
	projection	x		x ---- /|\
	line		|		|	| --> Trak direction.
			|		|
			|	    measure element
		     origin element.

	Axis of Measurement:

	An element can be measured along the x-axis or y-axis.
	This parameter defines the axis of measurment.

	This parameter is needed only for Linear dimensions.

	Trak Dir & Trak Distance:

	The Trak direction defines the direction in which the
	projection lines are drawn from the measured element.
	If trak_dir is set TRUE, the projection line will
	drawn along perpendicular axis(measurement axis
	rotated by 90 deg.) or drawn in the opposite dir.

	The Trak distance defines how far the dimension line
	is from the origin element.
		
	The position of the dimension text is called break
	point, the parameters that govern this point are the
	break position(brk_pos) and break distance(brk_dist).

	brk_pos -> The possible positions are
	
		   Center (BRK_CENTER):

		   If the dimension text is to be positioned
		   between projection lines. The brk_dist is
		   the ratio of distance(between text point
		   and origin point) and dimension value. If
		   the text is to be positioned exactly at
		   mid_pt the brk_dist value will be 0.5.

		   Left (BRK_LEFT):

		   If the dimension text is to be positioned left
		   of the orgin projection line. In this case the
		   brk_distance is distance between origin
		   projection line and text point.

		   Right (BRK_RIGHT):

		   If the dimension text is to positioned right
		   of measure projection line.

	Leader & Leader distance:

	A leader line is drawn if the dimension text is
	positioned outside the projection lines(brk_pos is
	not BRK_CENTER) and the dimension line is not
	horizantal. The leader line is drawn between the
	break_pt(text pt) and leader pt(end leader line).

	The leader distance "lead_dist" defines leader point
	from the break point.

	During placement all the needed parameter are taken
	from the active dimension parameters.

------------------------------------------------------------------*/

/*---------------------- dm$place_sglpara ------------------------

	Description:

	This macro places a associative single parallel
	dimension.

	Arguments:

	IGRint	geom_type	(I) geometry type of the
				    dimension.

	struct GRid *orig_grid	(I) GRid of the element to
				    measured.

	IGRpoint orig_pt	(I) Point on the orig element.

	IGRint	orig_type	(I) DMsrc type. DMkeyseg and
				    DMedgeseg are valid types.
				    Default( -1 ), indicates no
				    DMsrc type.

	struct GRid *plane_grid	(I) Window/Reference/Dimension
				    plane GRid.

	IGRmatrix plane_matrix	(I) dimension plane matrix.

	IGRint brk_pos		(I) break position.

	IGRdouble brk_dist	(I) break distance.

	IGRboolean leader	(I) Leader line flag.

	IGRdouble lead_dist	(I) Leader distance.

	IGRdouble trak_dist	(I) Trak distance.

	IGRint trak_dir		(I) Trak direction.

	IGRboolean dynamics	(I) If dynamics needed during
				    placement.

	struct GRid *owner	(I) Owner GRid, with the
				    created dimension object
				    is connected.

	struct GRid *dim_grid	(I) dimension object created.

--------------------------------------------------------------------*/

#omdef dm$place_sglpara(
		geom_type = DIM_DRIVING,
		orig_grid,
		orig_pt,
		orig_type = -1,
		plane_grid = NULL ^
		plane_matrix = NULL, 
		brk_pos = BRK_CENTER,
		brk_dist = 0.5,
		leader = FALSE,
		lead_dist = 0.,
		trak_dist = MIN_TRAK_DIST,
		trak_dir,
		dynamics = FALSE,
		owner = NULL,
		dim_grid)

	if (trak_dir) trak_dir = trak_dir & (~DM_TRAK_DIR);
	else trak_dir = trak_dir | DM_TRAK_DIR;

	DMplace_dim(
		SINGLE_PARALLEL,
		geom_type,
		orig_grid,
		orig_pt,
		1,
		orig_type,
		NULL,
		NULL,
		0,
		-1,
		plane_grid,
		plane_matrix,
		brk_pos,
		brk_dist,
		leader,
		lead_dist,
		trak_dist,
		trak_dir,
		-1,
		dynamics,
		owner,
		dim_grid)

#endomdef

/*---------------------- dm$place_cirdia ------------------------

	Description:

	This macro places a associative circular diameter
	dimension.

	Arguments:

	IGRint	geom_type	(I) geometry type of the
				    dimension.

	struct GRid *orig_grid	(I) GRid of the element to
				    measured.

	IGRpoint orig_pt	(I) Point on the orig element.

	struct GRid *plane_grid	(I) Window/Reference/Dimension
				    plane GRid.

	IGRmatrix plane_matrix	(I) dimension plane matrix.

	IGRint brk_pos		(I) break position.

	IGRdouble brk_dist	(I) break distance.

	IGRboolean leader	(I) Leader line flag.

	IGRdouble lead_dist	(I) Leader distance.

	IGRdouble trak_dist	(I) Trak distance.

	IGRint trak_dir		(I) Trak direction.

	IGRint axis		(I) Axis of measurment.

	IGRboolean dynamics	(I) If dynamics needed during
				    placement.

	struct GRid *owner	(I) Owner GRid, with the
				    created dimension object
				    is connected.

	struct GRid *dim_grid	(I) dimension object created.

--------------------------------------------------------------------*/

#omdef dm$place_cirdia(
		geom_type = DIM_DRIVING,
		orig_grid,
		orig_pt,
		plane_grid = NULL ^
		plane_matrix = NULL,
		brk_pos = BRK_CENTER,
		brk_dist = 0.5,
		leader = FALSE,
		lead_dist = 0.,
		trak_dist = MIN_TRAK_DIST,
		trak_dir,
		axis,
		dynamics = FALSE,
		owner = NULL,
		dim_grid)

	if(trak_dir) axis = axis & (~DM_TRAK_DIR);
	else axis = axis | DM_TRAK_DIR;

	DMplace_dim(
		CIRCULAR_DIAMETER,
		geom_type,
		orig_grid,
		orig_pt,
		1,
		-1,
		NULL,
		NULL,
		0,
		-1,
		plane_grid,
		plane_matrix,
		brk_pos,
		brk_dist,
		leader,
		lead_dist,
		trak_dist,
		axis,
		-1,
		dynamics,
		owner,
		dim_grid)

#endomdef

/*---------------------- dm$place_lindia ------------------------

	Description:

	This macro places a associative linear diameter
	dimension.

	Arguments:

	IGRint	geom_type	(I) geometry type of the
				    dimension.

	struct GRid *orig_grid	(I) GRid of the element to
				    be measured.
				    If orig_count is greater
				    than 1, orig_grid
				    should be the starting
				    address of the array of
				    GRid's of origin elements.
				    Eg. Origin elements whose
				    intersection will be the
				    origin point.

	IGRpoint orig_pt	(I) Point on the orig element.

	IGRint	orig_count	(I) No. of origin elements.
				    Default is 1.

	IGRint	orig_type	(I) DMsrc type. Valid types are
				    DMkeypt	DMtanpt
				    DMintpt	DMmidpt
				    DMcenpt	DMedgept
				    Default( -1 ), indicates no
				    DMsrc type.

	struct GRid *plane_grid	(I) Window/Reference/Dimension
				    plane GRid.

	IGRmatrix plane_matrix	(I) dimension plane matrix.

	IGRint brk_pos		(I) break position.

	IGRdouble brk_dist	(I) break distance.

	IGRboolean leader	(I) Leader line flag.

	IGRdouble lead_dist	(I) Leader distance.

	IGRdouble trak_dist	(I) Trak distance.

	IGRint trak_dir		(I) Trak direction.

	IGRint axis		(I) Axis of measurment.

	IGRboolean dynamics	(I) If dynamics needed during
				    placement.

	struct GRid *owner	(I) Owner GRid, with the
				    created dimension object
				    is connected.

	struct GRid *dim_grid	(I) dimension object created.

--------------------------------------------------------------------*/

#omdef dm$place_lindia(
		geom_type = DIM_DRIVING,
		orig_grid,
		orig_pt,
		orig_count = 1,
		orig_type = -1,
		meas_grid,
		meas_pt,
		meas_count = 1,
		meas_type = -1,
		plane_grid = NULL ^
		plane_matrix = NULL,
		brk_pos = BRK_CENTER,
		brk_dist = 0.5,
		leader = FALSE,
		lead_dist = 0.,
		trak_dist = MIN_TRAK_DIST,
		trak_dir,
		axis,
		dynamics = FALSE,
		owner = NULL,
		dim_grid)

	if(trak_dir) axis = axis & (~DM_TRAK_DIR);
	else axis = axis | DM_TRAK_DIR;

	DMplace_dim(
		LINEAR_DIAMETER,
		geom_type,
		orig_grid,
		orig_pt,
		orig_count,
		orig_type,
		meas_grid,
		meas_pt,
		meas_count,
		meas_type,
		plane_grid,
		plane_matrix,
		brk_pos,
		brk_dist,
		leader,
		lead_dist,
		trak_dist,
		axis,
		-1,
		dynamics,
		owner,
		dim_grid)

#endomdef

/*---------------------- dm$place_radial ------------------------

	Description:

	This macro places a associative radial dimension.

	Arguments:

	IGRint	geom_type	(I) geometry type of the
				    dimension.

	struct GRid *orig_grid	(I) GRid of the element to
				    measured.

	IGRpoint orig_pt	(I) Point on the orig element.

	struct GRid *plane_grid	(I) Window/Reference/Dimension
				    plane GRid.

	IGRmatrix plane_matrix	(I) dimension plane matrix.

	IGRint brk_pos		(I) break position.

	IGRdouble brk_dist	(I) break distance.

	IGRboolean leader	(I) Leader line flag.

	IGRdouble lead_dist	(I) Leader distance.

	IGRdouble angle		(I) Angle/trak distance in radians.
				    Default is 0.5

	IGRint	proj_arc	(I) TRUE or FALSE.
				    Default is TRUE.

	IGRboolean dynamics	(I) If dynamics needed during
				    placement.

	struct GRid *owner	(I) Owner GRid, with the
				    created dimension object
				    is connected.

	struct GRid *dim_grid	(I) dimension object created.

--------------------------------------------------------------------*/

#omdef dm$place_radial(
		geom_type = DIM_DRIVING,
		orig_grid,
		orig_pt,
		plane_grid = NULL ^
		plane_matrix = NULL,
		brk_pos = BRK_CENTER,
		brk_dist = 0.5,
		leader = FALSE,
		lead_dist = 0.,
		angle = 0.5,
		proj_arc = TRUE,
		dynamics = FALSE,
		owner = NULL,
		dim_grid)

	DMplace_dim(
		RADIAL,
		geom_type,
		orig_grid,
		orig_pt,
		1,
		-1,
		NULL,
		NULL,
		0,
		-1,
		plane_grid,
		plane_matrix,
		brk_pos,
		brk_dist,
		leader,
		lead_dist,
		angle,
		proj_arc,
		-1,
		dynamics,
		owner,
		dim_grid)

#endomdef

/*---------------------- dm$place_stack_linear ------------------------

	Description:

	This macro places a associative stack linear
	dimension.

	Arguments:

	IGRint	geom_type	(I) geometry type of the
				    dimension.

	struct GRid *orig_grid	(I) GRid of the element to
				    measured from.
				    If orig_count is greater than 1,
				    orig_grid should be the starting
				    address of the array of GRid's of
				    origin elements.

	IGRpoint orig_pt	(I) Point on the orig element.

	IGRint	orig_count	(I) No. of origin elements.
				    Default is 1.

	IGRint	orig_type	(I) DMsrc type. Valid types are
				    DMkeypt	DMtanpt
				    DMintpt	DMmidpt
				    DMcenpt	DMedgept
				    Default( -1 ), indicates no
				    DMsrc type.

	struct GRid *meas_grid	(I) GRid of the element to
				    measure to.
				    If meas_count is greater than 1,
				    meas_grid should be the starting
				    address of the array of GRid's of
				    measurment elements.

	IGRpoint meas_pt	(I) Point on the meas element.

	IGRint	meas_count	(I) No. of measurment elements.
				    Default is 1.

	IGRint	meas_type	(I) DMsrc type. Valid types are
				    DMkeypt	DMtanpt
				    DMintpt	DMmidpt
				    DMcenpt	DMedgept
				    Default( -1 ), indicates no
				    DMsrc type.

	struct GRid *plane_grid	(I) Window/Reference/Dimension
				    plane GRid.

	IGRmatrix plane_matrix	(I) dimension plane matrix.

	IGRint brk_pos		(I) break position.

	IGRdouble brk_dist	(I) break distance.

	IGRboolean leader	(I) Leader line flag.

	IGRdouble lead_dist	(I) Leader distance.

	IGRdouble trak_dist	(I) Trak distance.

	IGRint trak_dir		(I) Trak direction.

	IGRint axis		(I) Axis of measurment.

	IGRboolean dynamics	(I) If dynamics needed during
				    placement.

	struct GRid *owner	(I) Owner GRid, with the
				    created dimension object
				    is connected.

	struct GRid *dim_grid	(I) dimension object created.

--------------------------------------------------------------------*/

#omdef dm$place_stack_linear(
		geom_type = DIM_DRIVING,
		orig_grid,
		orig_pt,
		orig_count = 1,
		orig_type = -1,
		meas_grid,
		meas_pt,
		meas_count = 1,
		meas_type = -1,
		plane_grid = NULL ^ plane_matrix = NULL,
		brk_pos = BRK_CENTER,
		brk_dist = 0.5,
		leader = FALSE,
		lead_dist = 0.,
		trak_dist = MIN_TRAK_DIST,
		trak_dir,
		axis,
		dynamics = FALSE,
		owner = NULL,
		dim_grid)

	if(trak_dir) axis = axis & (~DM_TRAK_DIR);
	else axis = axis | DM_TRAK_DIR;

	DMplace_dim(
		STACKED_LINEAR,
		geom_type,
		orig_grid,
		orig_pt,
		orig_count,
		orig_type,
		meas_grid,
		meas_pt,
		meas_count,
		meas_type,
		plane_grid,
		plane_matrix,
		brk_pos,
		brk_dist,
		leader,
		lead_dist,
		trak_dist,
		axis,
		-1,
		dynamics,
		owner,
		dim_grid)

#endomdef


/*---------------------- dm$place_string_linear -----------------------

	Description:

	This macro places an associative stringed linear
	dimension.

	Arguments:

        Same as for dm$place_stack_linear macro.

--------------------------------------------------------------------*/


#omdef dm$place_string_linear(
		geom_type = DIM_DRIVING,
		orig_grid,
		orig_pt,
		orig_count = 1,
		orig_type = -1,
		meas_grid,
		meas_pt,
		meas_count = 1,
		meas_type = -1,
		plane_grid = NULL ^ plane_matrix = NULL,
		brk_pos = BRK_CENTER,
		brk_dist = 0.5,
		leader = FALSE,
		lead_dist = 0.,
		trak_dist = MIN_TRAK_DIST,
		trak_dir,
		axis,
		dynamics = FALSE,
		owner = NULL,
		dim_grid)

	if(trak_dir) axis = axis & (~DM_TRAK_DIR);
	else axis = axis | DM_TRAK_DIR;


	DMplace_dim(
		STRINGED_LINEAR,
		geom_type,
		orig_grid,
		orig_pt,
		orig_count,
		orig_type,
		meas_grid,
		meas_pt,
		meas_count,
		meas_type,
		plane_grid,
		plane_matrix,
		brk_pos,
		brk_dist,
		leader,
		lead_dist,
		trak_dist,
		axis,
		-1,
		dynamics,
		owner,
		dim_grid)

#endomdef


/*---------------------- dm$place_angular ------------------------

	Description:

	This macro places a associative stacked angular
	dimension.

	Arguments:

	IGRint	geom_type	(I) geometry type of the
				    dimension.

	struct GRid *orig_grid	(I) GRid of the element to
				    measured from.

	IGRpoint orig_pt	(I) Point on the orig element.

	struct GRid *meas_grid	(I) GRid of the element to
				    measured to.

	IGRpoint meas_pt	(I) Point on the meas element.

	struct GRid *plane_grid	(I) Window/Reference/Dimension
				    plane GRid.

	IGRmatrix plane_matrix	(I) dimension plane matrix.

	IGRint brk_pos		(I) break position.

	IGRdouble brk_dist	(I) break distance.

	IGRboolean leader	(I) Leader line flag.

	IGRdouble lead_dist	(I) Leader distance.

	IGRdouble trak_dist	(I) Trak distance.

	IGRint sector		(I) The sector in which angle is
				    measured.

	IGRint mask		(I) The type of angular measurment.

				    ANG_DIM_RELATIVE ->between orig &
				    measure element.

				    ANG_DIM_HORIZANTAL -> angle made
				    by origin element with respect to
				    Horizantal axis.

				    ANG_DIM_VERTICAL -> angle made
				    by origin element with respect to
				    Vertical axis.

	IGRboolean dynamics	(I) If dynamics needed during
				    placement.

	struct GRid *owner	(I) Owner GRid, with the
				    created dimension object
				    is connected.

	struct GRid *dim_grid	(I) dimension object created.

--------------------------------------------------------------------*/

#omdef dm$place_angular(
		geom_type = DIM_DRIVING,
		orig_grid,
		orig_pt,
		meas_grid,
		meas_pt,
		plane_grid = NULL ^
		plane_matrix = NULL,
		brk_pos = BRK_CENTER,
		brk_dist = 0.5,
		leader = FALSE,
		lead_dist = 0.,
		trak_dist = MIN_TRAK_DIST,
		sector,
		mask = ANG_DIM_RELATIVE,
		dynamics = FALSE,
		owner = NULL,
		dim_grid)

	DMplace_dim(
		STACKED_ANGULAR,
		geom_type,
		orig_grid,
		orig_pt,
		1,
		-1,
		meas_grid,
		meas_pt,
		1,
		-1,
		plane_grid,
		plane_matrix,
		brk_pos,
		brk_dist,
		leader,
		lead_dist,
		trak_dist,
		sector,
		mask,
		dynamics,
		owner,
		dim_grid)

#endomdef


/*-------------------- dm$place_string_angular ---------------------

	Description:

	This macro places a associative stringed angular
	dimension.

	Arguments:

        Same as for dm$place_angular macro.

--------------------------------------------------------------------*/

#omdef dm$place_string_angular(
		geom_type = DIM_DRIVING,
		orig_grid,
		orig_pt,
		meas_grid,
		meas_pt,
		plane_grid = NULL ^
		plane_matrix = NULL,
		brk_pos = BRK_CENTER,
		brk_dist = 0.5,
		leader = FALSE,
		lead_dist = 0.,
		trak_dist = MIN_TRAK_DIST,
		sector,
		mask = ANG_DIM_RELATIVE,
		dynamics = FALSE,
		owner = NULL,
		dim_grid)

	DMplace_dim(
		STRINGED_ANGULAR,
		geom_type,
		orig_grid,
		orig_pt,
		1,
		-1,
		meas_grid,
		meas_pt,
		1,
		-1,
		plane_grid,
		plane_matrix,
		brk_pos,
		brk_dist,
		leader,
		lead_dist,
		trak_dist,
		sector,
		mask,
		dynamics,
		owner,
		dim_grid)

#endomdef


/*---------------------- dm$place_sglarc_angle --------------------

	Description:

	This macro places a associative single parallel arc angle
	dimension.

	Arguments:

	IGRint	geom_type	(I) geometry type of the
				    dimension.

	struct GRid *orig_grid	(I) GRid of the element to
				    measured.

	IGRpoint orig_pt	(I) Point on the orig element.

	struct GRid *plane_grid	(I) Window/Reference/Dimension
				    plane GRid.

	IGRmatrix plane_matrix	(I) dimension plane matrix.

	IGRint brk_pos		(I) break position.

	IGRdouble brk_dist	(I) break distance.

	IGRboolean leader	(I) Leader line flag.

	IGRdouble lead_dist	(I) Leader distance.

	IGRdouble trak_dist	(I) Trak distance.

	IGRint trak_dir		(I) Trak direction.

	IGRboolean dynamics	(I) If dynamics needed during
				    placement.

	struct GRid *owner	(I) Owner GRid, with the
				    created dimension object
				    is connected.

	struct GRid *dim_grid	(I) dimension object created.

--------------------------------------------------------------------*/

#omdef dm$place_sglarc_angle(
		geom_type = DIM_DRIVING,
		orig_grid,
		orig_pt,
		plane_grid = NULL ^
		plane_matrix = NULL, 
		brk_pos = BRK_CENTER,
		brk_dist = 0.5,
		leader = FALSE,
		lead_dist = 0.,
		trak_dist = MIN_TRAK_DIST,
		trak_dir,
		dynamics = FALSE,
		owner = NULL,
		dim_grid)

	if (trak_dir) trak_dir = trak_dir & (~DM_TRAK_DIR);
	else trak_dir = trak_dir | DM_TRAK_DIR;

	DMplace_dim(
		SINGLE_ARC_ANGLE,
		geom_type,
		orig_grid,
		orig_pt,
		1,
		-1,
		NULL,
		NULL,
		0,
		-1,
		plane_grid,
		plane_matrix,
		brk_pos,
		brk_dist,
		leader,
		lead_dist,
		trak_dist,
		trak_dir,
		-1,
		dynamics,
		owner,
		dim_grid)

#endomdef

/*---------------------- dm$place_radial_dia ----------------------

	Description:

	This macro places a associative radial diameter dimension.

	Arguments:

	IGRint	geom_type	(I) geometry type of the
				    dimension.

	struct GRid *orig_grid	(I) GRid of the element to be
				    measured.

	IGRpoint orig_pt	(I) Point on the orig element.

	struct GRid *plane_grid	(I) Window/Reference/Dimension
				    plane GRid.

	IGRmatrix plane_matrix	(I) dimension plane matrix.

	IGRint brk_pos		(I) break position.

	IGRdouble brk_dist	(I) break distance.

	IGRboolean leader	(I) Leader line flag.

	IGRdouble lead_dist	(I) Leader distance.

	IGRdouble angle		(I) Angle/trak distance in radians.
				    Default is 0.5

	IGRint	proj_arc	(I) TRUE or FALSE.
				    Default is TRUE.

	IGRboolean dynamics	(I) If dynamics needed during
				    placement.

	struct GRid *owner	(I) Owner GRid, with the
				    created dimension object
				    is connected.

	struct GRid *dim_grid	(I) dimension object created. 

-----------------------------------------------------------------*/
#omdef dm$place_radial_dia(
		geom_type = DIM_DRIVING,
		orig_grid,
		orig_pt,
		plane_grid = NULL ^
		plane_matrix = NULL,
		brk_pos = BRK_CENTER,
		brk_dist = 0.5,
		leader = FALSE,
		lead_dist = 0.,
		angle = 0.5,
		proj_arc = TRUE,
		dynamics = FALSE,
		owner = NULL,
		dim_grid)


	DMplace_dim(
		RADIAL_DIAMETER,
		geom_type,
		orig_grid,
		orig_pt,
		1,
		-1,
		NULL,
		NULL,
		0,
		-1,
		plane_grid,
		plane_matrix,
		brk_pos,
		brk_dist,
		leader,
		lead_dist,
		angle,
		proj_arc,
		-1,
		dynamics,
		owner,
		dim_grid)

#endomdef
/*---------------------- dm$place_sglarc_length -------------------

	Description:

	This macro places a associative single parallel arc length
	dimension.

	Arguments:

	IGRint	geom_type	(I) geometry type of the
				    dimension.

	struct GRid *orig_grid	(I) GRid of the element to
				    measured.

	IGRpoint orig_pt	(I) Point on the orig element.

	struct GRid *plane_grid	(I) Window/Reference/Dimension
				    plane GRid.

	IGRmatrix plane_matrix	(I) dimension plane matrix.

	IGRint brk_pos		(I) break position.

	IGRdouble brk_dist	(I) break distance.

	IGRboolean leader	(I) Leader line flag.

	IGRdouble lead_dist	(I) Leader distance.

	IGRdouble trak_dist	(I) Trak distance.

	IGRint trak_dir		(I) Trak direction.

	IGRboolean dynamics	(I) If dynamics needed during
				    placement.

	struct GRid *owner	(I) Owner GRid, with the
				    created dimension object
				    is connected.

	struct GRid *dim_grid	(I) dimension object created.

--------------------------------------------------------------------*/

#omdef dm$place_sglarc_length(
		geom_type = DIM_DRIVING,
		orig_grid,
		orig_pt,
		plane_grid = NULL ^
		plane_matrix = NULL, 
		brk_pos = BRK_CENTER,
		brk_dist = 0.5,
		leader = FALSE,
		lead_dist = 0.,
		trak_dist = MIN_TRAK_DIST,
		trak_dir,
		dynamics = FALSE,
		owner = NULL,
		dim_grid)

	if (trak_dir) trak_dir = trak_dir & (~DM_TRAK_DIR);
	else trak_dir = trak_dir | DM_TRAK_DIR;

	DMplace_dim(
		SINGLE_ARC_LENGTH,
		geom_type,
		orig_grid,
		orig_pt,
		1,
		-1,
		NULL,
		NULL,
		0,
		-1,
		plane_grid,
		plane_matrix,
		brk_pos,
		brk_dist,
		leader,
		lead_dist,
		trak_dist,
		trak_dir,
		-1,
		dynamics,
		owner,
		dim_grid)

#endomdef

/*---------------------- dm$place_coord_linear ----------------------
	Description:

	This macro places an associative coordinate linear
	dimension.

	Arguments:

	IGRint	geom_type	(I) geometry type of the
				    dimension.

	struct GRid *orig_grid	(I) GRid of the element to
				    measure from.
				    While creating the origin dimension,
				    this should be set to the GRid of
				    the origin element.
				    While creating subsequent measure
				    dimensions, this should in fact be
				    set to the GRid of the origin
				    dimension.

	IGRpoint orig_pt	(I) Point on the orig element, at all
				    times.

	struct GRid *meas_grid	(I) GRid of the element to
				    measure to.
				    Default is NULL.
				    Can be ignored while creating the
				    origin dimension.
				    Should be set to the GRid of the
				    measure element while creating
				    the the measure element.

	IGRpoint meas_pt	(I) Point on the meas element.
				    Default is NULL.
				    Can be ignored while creating the
				    origin dimension.
				    Should be set to point on 
				    measure element while creating
				    the the measure element.

	struct GRid *plane_grid	(I) Window/Reference/Dimension
				    plane GRid.

	IGRmatrix plane_matrix	(I) dimension plane matrix.

	IGRint brk_pos		(I) break position.

	IGRdouble brk_dist	(I) break distance.

	IGRboolean leader	(I) Leader line flag.

	IGRdouble lead_dist	(I) Leader distance.

	IGRdouble trak_dist	(I) Trak distance.
				    Default is MIN_TRAK_DIST.

	IGRint trak_attr	(I) Trak attribute.
				    Bits 0 through 5 of trak_attr have
				    a definite meaning, and it is the
				    responsibility of the user to set
				    these bits appropriately.
				    
				    Measurement axis.
				    0 : Measurement axis set to X.
					trak_attr & DM_MEA_AXIS
				    1 : Positive Trak Direction.
					trak_attr & DM_TRAK_DIR
				    2 : Dimension belongs to Zone 1.
					trak_attr & DM_TRAK_ZONE1
				    3 : Zone 2.
					trak_attr & DM_TRAK_ZONE2
					Can be set to either zone1 or zone2.
				    4 : Locked dimension.
					trak_attr & DM_TRAK_LOCK
				    5 : Control Dimension.
					trak_attr & DM_TRAK_CTRL_DIM

				    Default settings are positive trak
				    direction, measurement axis set to
				    X and trak zone 1.

	IGRboolean dynamics	(I) If dynamics needed during
				    placement.
				    Default is FALSE.

	struct GRid *owner	(I) Owner GRid, to which the
				    created dimension object
				    is connected.
				    Default is NULL.

	struct GRid *dim_grid	(I) dimension object created.
---------------------------------------------------------------------*/

#omdef dm$place_coord_linear(
		geom_type = DIM_DRIVING,
		orig_grid,
		orig_pt,
		meas_grid = NULL,
		meas_pt = NULL,
		plane_grid = NULL ^ plane_matrix = NULL,
		brk_pos = BRK_CENTER,
		brk_dist = 0.5,
		leader = FALSE,
		lead_dist = 0.,
		trak_dist = MIN_TRAK_DIST,
		trak_attr = DM_TRAK_DIR | DM_MEA_AXIS | DM_TRAK_ZONE1,
		dynamics = FALSE,
		owner = NULL,
		dim_grid)

	DMplace_dim(
		COORDINATE,
		geom_type,
		orig_grid,
		orig_pt,
		1,
		-1,
		meas_grid,
		meas_pt,
		1,
		-1,
		plane_grid,
		plane_matrix,
		brk_pos,
		brk_dist,
		leader,
		lead_dist,
		trak_dist,
		trak_attr,
		-1,
		dynamics,
		owner,
		dim_grid)

#endomdef
/*---------------------- dm$place_text_with_leader ------------------

	Description:

	This macro places a text with leader annotation object,
	on given attach element at the attach point. The text
	is given in text_string. If leader line is needed
	the break points of the leader needs to be given. If
	the number of break points is zero, annotation is
	placed without a leader. The dimension plane can be
	given as a matrix or the DMplan object given. The
	annotation is created with the weight and color given
	or the active dimension parameters used.

	The annotation created will be connected to a owner
	if given.

	Expression based text with leader:
	---------------------------------

	The functionality is similar to the currently
	implemented text with leader but for the text
	portion of it.

	The contents of the text are controlled by a
	set of expressions as follows:

	The annotation object would store, in a vla,
	a "text format" string which will be expanded
	at compute time using the expressions and
	posted to the graphic text.

	The "text format" string will be a standard
	"printf(..)" format and would support the
	following:

	%lf	for double expressions
	%s	for strings
	%d	for integers
	\n	for newline

	For each of the expanders (%s, %lf etc.,) in the format
	string there must be an expression that should be
	available for substituting the expander.

	Argument Description:
	--------------------

	IGRint		geom_type	The type of Dimension
					Behaviour. The Default is
					DIM_DRIVING. The types
					are defined in dimdef.h

	struct GRid	*attach_ele	Element to attach to

	IGRpoint	attach_pt	Point on element to attach to

	IGRint		num_brkpt	Number of break points
					(default to 0 - no leader case)

	IGRdouble	*brkpt		Break point positions.

	IGRshort	text_length	Length text string

	IGRchar		*text_string	Text string.

	IGRint		expr_count	Number of expressions

	struct GRid	*expr_list	List of expressions

	IGRmatrix	plane_matrix	The matrix for dimension
					plane.

	struct GRid	*plane_grid	Dimension plane GRid.

	struct GRid	*owner		Owner GRid, with the created
					annotation object is
					connected.

	IGRint		color		Color of the annotation.

	IGRint		weight		Weight of the annotation.

	struct GRid	*dim_grid	Annotation object created.
	
	IGRint 		value_type      String to be interpreted as( For
	                                driving dimensions)
					i.e DIM_DISTANCE or DIM_ANGLE.

--------------------------------------------------------------------*/

#omdef dm$place_text_with_leader(
		geom_type = DIM_DRIVING,
		attach_ele,
		attach_pt,
		num_brkpt = 0,
		brkpt = NULL,
		text_length,
		text_string,
		expr_count = 0,
		expr_list = NULL,
		plane_matrix = NULL ^ plane_grid = NULL,
		owner = NULL,
		color = -1,
		weight = -1,
		value_type = DIM_DISTANCE,
		dim_grid)

	DMplace_annot2(
		TEXT_WITH_LEADER,
		geom_type,
		attach_ele,
		NULL,
		attach_pt,
		NULL,
		num_brkpt,
		brkpt,
		text_length,
		text_string,
		expr_count,
		expr_list,
		plane_matrix,
		plane_grid,
		owner,
		color,
		weight,
		dim_grid,
		value_type)

#endomdef

/*---------------------- dm$place_leader_line --------------------

	Description:

	This macro places a leader with given break points
	connected to attach_ele1 and attach_ele2. The attach_pt1
	and attach_pt2 defines the points on the respective
	elements.
	
	The dimension plane can be given as a matrix or the
	DMplan object given.

	The annotation is created with the weight and color given
	or the active dimension parameters used.

	The annotation created will be connected to a owner
	if given.

	Argument Description:
	--------------------

	IGRint		geom_type	The type of Dimension
					Behaviour. The Default is
					DIM_DRIVING. The types
					are defined in dimdef.h

	struct GRid	*attach_ele1	Element the leader points to.

	struct GRid	*attach_ele2	Element the leader is connected.

	IGRpoint	attach_pt1	Point on element1 to attach to

	IGRpoint	attach_pt1	Point on element2 to connect to

	IGRint		num_brkpt	Number of break points

	IGRdouble	*brkpt		Break point positions.

	IGRmatrix	plane_matrix	The matrix for dimension
					plane.

	struct GRid	*plane_grid	Dimension plane GRid.

	struct GRid	*owner		Owner GRid, with the created
					annotation object is
					connected.

	IGRint		color		Color of the annotation.

	IGRint		weight		Weight of the annotation.

	struct GRid	*dim_grid	Annotation object created.

--------------------------------------------------------------------*/

#omdef dm$place_leader_line(
		geom_type = DIM_DRIVING,
                attach_ele1,
                attach_ele2,
		attach_pt1,
		attach_pt2,
		num_brkpt,
		brkpt,
		plane_matrix = NULL ^ plane_grid = NULL,
		owner = NULL,
		color = -1,
		weight = -1,
		dim_grid)

	DMplace_annot(
		LEADER_LINE,
		geom_type,
		attach_ele1,
		attach_ele2,
		attach_pt1,
		attach_pt2,
		num_brkpt,
		brkpt,
		0,
		NULL,
		0,
		NULL,
		plane_matrix,
		plane_grid,
		owner,
		color,
		weight,
		dim_grid)

#endomdef

/*---------------------- dm$place_datum_frame ------------------

	Description:

	This macro places a datum frame annotation object,
	on given attach element at the attach point. The text
	is given in text_string. If leader line is needed
	the break points of the leader needs to be given. If
	the number of break points is zero, annotation is
	placed without a leader. The dimension plane can be
	given as a matrix or the DMplan object given. The
	annotation is created with the weight and color given
	or the active dimension parameters used.

	The annotation created will be connected to a owner
	if given.

	Argument Description:
	--------------------

	IGRint		geom_type	The type of Dimension
					Behaviour. The Default is
					DIM_DRIVING. The types
					are defined in dimdef.h

	struct GRid	*attach_ele	Element to attach to

	IGRpoint	attach_pt	Point on element to attach to

	IGRint		num_brkpt	Number of break points
					(default to 0 - no leader case)

	IGRdouble	*brkpt		Break point positions.

	IGRshort	text_length	Length text string

	IGRchar		*text_string	Text string.

	IGRmatrix	plane_matrix	The matrix for dimension
					plane.

	struct GRid	*plane_grid	Dimension plane GRid.

	struct GRid	*owner		Owner GRid, with the created
					annotation object is
					connected.

	IGRint		color		Color of the annotation.

	IGRint		weight		Weight of the annotation.

	struct GRid	*dim_grid	Annotation object created.

--------------------------------------------------------------------*/

#omdef dm$place_datum_frame(
		geom_type = DIM_DRIVING,
		attach_ele,
		attach_pt,
		num_brkpt = 0,
		brkpt = NULL,
		text_length,
		text_string,
		expr_count = 0,
		expr_list = NULL,
		plane_matrix = NULL ^ plane_grid = NULL,
		owner = NULL,
		color = -1,
		weight = -1,
		dim_grid)

	DMplace_annot(
		DATUM_FRAME,
		geom_type,
		attach_ele,
		NULL,
		attach_pt,
		NULL,
		num_brkpt,
		brkpt,
		text_length,
		text_string,
		expr_count,
		expr_list,
		plane_matrix,
		plane_grid,
		owner,
		color,
		weight,
		dim_grid)

#endomdef

/* ------------------- dm$place_center_lines ------------------------

	Description:

	This macro places a associative centerline on bspline curve.

	Arguments;

	struct GRid *go_grid	(I)  This the graphic object for
				     which the centerline is placed.
				     The graphic object should belong
				     to GRconic class.
	
	IGRpoint point		(I)  This is point on element(go_grid).

	IGRboolean position	(I)  If this is set TRUE, the center
				     lines is created with four outer
				     lines extending the radius, else
				     only a cross is placed at the
				     center.

	IGRmatrix plane_matrix	(I)  The matrix used to construct the
				     dimension plane object.

	struct GRid *plane_grid (I)  The dimension plane object.

	struct GRid *dim_grid	(O)  Dimension GRid.

-------------------------------------------------------------------*/

#omdef dm$place_center_lines(
		go_grid,
		point,
		position = TRUE,
		plane_matrix = NULL ^
		plane_grid = NULL,
		dim_grid)

	DMplace_cenline(
		go_grid,
		point,
		position,
		plane_matrix,
		plane_grid,
		dim_grid)

#endomdef

/* ------------------- dm$set_type --------------------------------

	Description:

	This macro set the dimension type. This macro also has
	options, not to update(display & compute) the dimension.
	This option is kept for optimization(ie., if the caller
	is going to send a compute, the macro need not do it).

	The dimension types are stored as bits, and when changing
	them, the bit operations are done. The caller as to send
	the type of bit operations to be done in the "op_code"
	argument.

	The valid "op_code" are
		BIT_OR,
		BIT_AND,
		BIT_XOR,
		BIT_SET,
		BIT_CLEAR.
	These are define in dimdef.h.

	Arguments;

	IGRint type		(I)  Dimension type, that needs to be
				     set.

	IGRboolean update	(I)  If TRUE sends a compute and
				     display.

	IGRint op_code		(I)  operation code, the bit operation
				     that needs to be done.

	struct GRmd_env *md_env	(I)  Module environment

	struct GRid *dim_grid	(I)  Dimension GRid, for whom the
				     type is set.

-------------------------------------------------------------------*/

#omdef dm$set_type(
		type,
		update = FALSE,
		op_code = BIT_OR,
		md_env = NULL,
		dim_grid)

	DMset_type(
		type,
		update,
		op_code,
		md_env,
		dim_grid);

#endomdef

/* ------------------- dm$dmplan_set_axis ------------------------

	Description:

	This macro set measurment axis for a dimension plane.
	The measurement axis can be set for active dimension plane
	in a window or the dimension plane connected to a dimension.
	The measurment axis is defined by graphic objects passed
	to macro. The valid graphic objects are a line segment(could
	be a line string also) or two points.

	Arguments;

	struct GRid *win_grid	(I)  Window GRid, active dimension
				     plane is found from this window
				     and measurment axis set to it.

	struct GRid *dim_grid	(I)  Dimension GRid, dimension plane
				     is found from this dimension and
				     measurment axis set to it.

	struct GRid *list	(I)  The list of graphic objects
				     which define the measurment axis.

	IGRint count		(I)  Number of objects in the list.

	IGRdouble *points	(I)  Array of points. For every
				     object give in the list a
				     corresponding point needs to
				     given. This is basically needed
				     to find the line segment in a
				     line string.

	struct GRmd_env *md_env	(I)  Module environment

-------------------------------------------------------------------*/

#omdef dm$dmplan_set_axis(
		win_grid = NULL ^
		dim_grid = NULL,
		list,
		count,
		point,
		md_env)

	DMdmplan_set_axis(
		win_grid,
		dim_grid,
		list,
		count,
		point,
		md_env)
#endomdef

/* ------------------- dm$enclose_dimtext ------------------------

	Description:

	This macro displays a dimension in special symbolgy(the
	dimension text are enclosed by "<< >>" characters). This
	feature is used by tolerance analyse commands to
	differentiate the dimension temporarily and it is caller's
	responsiblity to clear them.

	Arguments;

	IGRboolean set1_clear0	(I)  Flag if set to TRUE,
				     dimension text is enclosed.
				     FALSE the "<< >>" characters
				     are cleared.

	struct GRid *dim_grid	(I)  Dimension object GRid.

	struct GRmd_env *md_env	(I)  Module environment

-------------------------------------------------------------------*/

#omdef dm$enclose_dimtext(
		set1_clear0,
		dim_grid,
		md_env)

	DMenclose_dimtext(
		set1_clear0,
		dim_grid,
		md_env)
#endomdef

/* ------------------- dm$display_dim -------------------------

	Description:

	This macro send a display message to the dimension object.
	If flag "invisible_display" is set to TRUE, the hidden
	dimension are also displayed.

	Arguments;

	enum GRdpmode mode	     (I)  Display mode.

	IGRboolean invisible_display (I)  Flag if set to TRUE,
					  displays hidden dimension
					  also.

	struct GRmd_env *md_env	     (I)  Module environment

	struct GRid *dim_grid	     (I)  Dimension object GRid.

-------------------------------------------------------------------*/

#omdef dm$display_dim(
		mode,
		invisible_display = TRUE,
		dim_grid,
		md_env)

	DMdisplay_dim(
		mode,
		invisible_display,
		md_env,
		dim_grid)
#endomdef

/* ------------------- dm$change_plane ----------------------------

	Description:

	This macro changes the dimension plane connected to a
	dimension object with a new dimension plane given.

	Arguments;

	IGRboolean inq0_chg1	(I)	flag indicates 0 - inquire
						       1 - change.

	struct GRid *plane_grid	(I/O)	Dimension plane object GRid.

	struct GRid *dim_grid	(I)	Dimension object id.

	struct GRmd_env *md_env	(I)	Module environment

-------------------------------------------------------------------*/

#omdef dm$change_plane(
		plane_grid,
		dim_grid,
		md_env)

	DMchange_plane(
		plane_grid,
		dim_grid,
		md_env)

#endomdef

/* ------------------- dm$change_ref_plane -------------------------

	Description:

	This macro is primarily meant for changing the reference
	plane object connected to a dimension plane object. This
	can also be used to inquire whether reference plane object
	is driving a dimension plane.

	Arguments;

	IGRboolean inq0_chg1	(I)	flag indicates 0 - inquire
						       1 - change.

	struct GRid *ref_grid	(I/O)	Reference plane object GRid.

					In inquire node, return the
					reference plane id if present
					else a NULL_OBJID.

					In change mode, this GRid is
					changed with the existing
					reference plane object in
					dimensions plane.

	struct GRid *plane_grid	(I)	Dimension plane object id.

	struct GRmd_env *md_env	(I)	Module environment

-------------------------------------------------------------------*/

#omdef dm$change_ref_plane(
		inq0_chg1 = 0,
		ref_grid,
		plane_grid,
		md_env)

	DMchange_ref_plane(
		inq0_chg1,
		ref_grid,
		plane_grid,
		md_env)
#endomdef

/*---------------------- dm$place_text_with_balloon ------------------

	Description:

	This macro places a text with balloon annotation object,
	on given attach element at the attach point. The text
	is given in text_string. If leader line is needed
	the break points of the leader needs to be given. If
	the number of break points is zero, annotation is
	placed without a leader. The dimension plane can be
	given as a matrix or the DMplan object given. The
	annotation is created with the weight and color given
	or the active dimension parameters used.

	The annotation created will be connected to a owner
	if given.

	Argument Description:
	--------------------

	IGRint		geom_type	The type of Dimension
					Behaviour. The Default is
					DIM_DRIVING. The types
					are defined in dimdef.h

	struct GRid	*attach_ele	Element to attach to

	IGRpoint	attach_pt	Point on element to attach to

	IGRint		num_brkpt	Number of break points
					(default to 0 - no leader case)

	IGRdouble	*brkpt		Break point positions.

	IGRshort	text_length	Length text string

	IGRchar		*text_string	Text string.

	IGRmatrix	plane_matrix	The matrix for dimension
					plane.

	struct GRid	*plane_grid	Dimension plane GRid.

	struct GRid	*owner		Owner GRid, with the created
					annotation object is
					connected.

	IGRint		color		Color of the annotation.

	IGRint		weight		Weight of the annotation.

	struct GRid	*dim_grid	Annotation object created.

--------------------------------------------------------------------*/

#omdef dm$place_text_with_balloon(
		geom_type = DIM_DRIVING,
		attach_ele,
		attach_pt,
		num_brkpt = 0,
		brkpt = NULL,
		text_length,
		text_string,
		plane_matrix = NULL ^ plane_grid = NULL,
		owner = NULL,
		color = -1,
		weight = -1,
		dim_grid)

	DMplace_annot(
		TEXT_WITH_BALLOON,
		geom_type,
		attach_ele,
		NULL,
		attach_pt,
		NULL,
		num_brkpt,
		brkpt,
		text_length,
		text_string,
		0,
		NULL,
		plane_matrix,
		plane_grid,
		owner,
		color,
		weight,
		dim_grid)

#endomdef

#endif
