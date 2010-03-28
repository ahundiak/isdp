#ifndef diminfo_include

#define diminfo_include

struct diminfo
{
	IGRint			dim_type;
	IGRchar			geom_type;	/* DIM_DRIVING etc */
	IGRchar			display;	/* DIM_DISPLAY_OFF bit is set if display off */
	struct DMplan_info	plan_info;	/* dimension plane info */

	IGRshort		matrix_type;
	IGRmatrix		matrix;
	struct GRid		dim_in_ref;
	/* - The above three fields are only useful in
	     case of imported dimensions. The information
	     relates to the original dimension in the
	     reference file. */

	IGRint			count;
	struct GRid		list[MAX_DIM_ROOTS];
	struct GRid		prev_dim;
	/* - List of all the parent objects
		dimension plane (DIM_ROOT_PLAN)
		envirorn params (DIM_ROOT_ENV)
		local params    (DIM_ROOT_LOC)
		origin		(DIM_CPX_ORIG)
		measure		(DIM_CPX_MEAS)

		prev_dim	If in a STACK/STRING
				NULL_OBJID other_wise.
	*/

	struct GRid		const_plane;
	/* - EMSexpcnstr if one exists. NULL_OBJID otherwise. */

	struct GRid		meas_axis[2];
	/* - Line segment or two points for measurment axis
	     NULL_OBJID otherwise */

	IGRchar			ang_sector;
	/* - Sector info for angular dimensions. */

	IGRchar			lin_axis;
	/* - Axis info for linear dimension.
	     WIN_X_AXIS, WIN_Y_AXIS, ACT_X_AXIS, ACT_Y_AXIS */

	IGRint			mod_comp;
	IGRdouble		dim_value;
	IGRchar			dim_override[132];
};

#endif

