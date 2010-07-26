class specification COdmplace (2:0) of COdim;

instance COdmplace
{
	GRclassid dim_classid;			/* Dimension class id */

	struct GRid dim_grid;			/* Dimension in Placement */
	struct GRid prev_dim;			/* Previous dimension in cpx */
	struct GRid first_dim;			/* First dimension in cpx */

	struct  GRevent ori_event;		/* Event for origin */
	struct  GRevent mea_event;		/* Event for measuremnt */
	struct  GRevent sel_event;		/* Event for measurment axis */
	struct  GRevent sel_quad;		/* Event for quadrant sel */
	struct  GRevent cent_event;		/* Event for angle center */

	struct  dim_attr dim_attr;		/* Dimension attributes */
	struct  cenline_attr cen_attr;		/* Centerline attributes */
	IGRint  count;
	IGRint  ori_index, mea_index;
	struct  GRid list[MAX_DIM_ROOTS];
	struct  GRid context[MAX_DIM_ROOTS];
	struct  DMobj_info orig, meas, cent;
	struct  DMtrak_info trak_info;

	Form form;
	IGRint form_displayed;

	IGRint dim_type;
	IGRint sgl_type;
	IGRint sel_type;
	IGRint cpx_type;
	IGRint axis_sel, sect_sel;
	IGRboolean draw_axis, draw_sect;
	IGRboolean leader;
	IGRboolean jogged, in_dynamics;
	struct DMplan_info plan_info;

	/* - The following variables must be set in init method - */

	IGRboolean	meas_needed;	/* Is measure element needed? */
	IGRboolean	axis_needed;	/* Should axis be specified? */
	IGRboolean	is_a_complex;	/* Is dimension a complex? */
	IGRboolean	angular_dim;	/* Is dimension angular? */
	
	/* - The following variables are for angular dimension only - */

	IGRboolean	orthogonal;	/* Measure with orthogonal */
	IGRboolean	angle_center;	/* Angle center needed */
};

message get_dim_param();

message get_dim_plane();

message create_origin();

message create_measure();

message draw_axis(enum GRdpmode mode);

message draw_sect(enum GRdpmode mode);

message sel_axis();

message sel_sector();

message place_dimension();

message display_dimension(IGRint level; IGRint control);

message delete_dimension();

message set_dim_attr();

message set_ter_loca();

message check_for_angcen();

message set_dim_state(IGRshort dim_state);

message position_dim(
	IGRint msgkey;
	IGRint dynamics;
	IGRint preproc;
	IGRint prestate;
	IGRint control;
	IGRint postproc;
	IGRint poststate);

message init_type();
message display_form(IGRboolean disp0_updt1);
message dimension_driving();

override init, wakeup, super_cmd.sleep, execute, delete;
override LC_selection, LC_preproc, LC_postproc, LC_dynamics;
override notify_form;

end specification COdmplace;
