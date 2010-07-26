class specification COdmcopy (2:0) of COdim;

instance COdmcopy
{
	GRclassid dim_classid;			/* Dimension class id */

	struct GRid dim_grid;			/* Dimension in Placement */
	IGRboolean meas_needed;			/* Measure element needed */
	struct  GRevent dim_event;		/* Event for locating dim */
	struct  GRevent orig_event;		/* Event for origin */
	struct  GRevent meas_event;		/* Event for measuremnt */

	IGRint  count;
	struct  GRid list[MAX_DIM_ROOTS];
	struct  GRid context[MAX_DIM_ROOTS];

	struct  DMobj_info orig, meas;
	struct  GRid orig_grid, meas_grid;
	IGRshort dim_type;
	struct  dim_attr dim_attr;		/* Dimension attributes */
	struct  cenline_attr cen_attr;
	struct  annot_attr an_attr;
	IGRchar *attr;

	IGRboolean is_a_complex;
	IGRint cpx_type;
	IGRint orig_index, meas_index;
	IGRint orig_type, meas_type;

	Form form;
	IGRboolean toggle_trak, toggle_term;
	IGRboolean annot_gt, form_displayed;
};

message place_dimension();
message display_dimension(enum GRdpmode mode);
message create_parent();
message display_form();

override init, execute;
override super_cmd.sleep, wakeup, delete;
override LC_selection, LC_preproc, LC_postproc, LC_dynamics;
override notify_form;

end specification COdmcopy;
