class specification COanplace (2:0) of COdim;

instance COanplace
{
	GRclassid an_classid;			/* Dimension class id */
	struct GRid an_grid;			/* Dimension in Placement */
	struct GRid prev_dim;			/* Previous annotation in cpx;*/
	struct  GRevent loc_event;		/* Event for origin */
	struct  GRevent data_event;		/* Event for balloon */
	struct DMtxdynamics_info dyn_info;	/* info for dynamics */

	IGRint  count;
	struct  GRid list[MAX_DIM_ROOTS];
	struct  GRid context[MAX_DIM_ROOTS];
	struct  DMobj_info arrow, lead;
	IGRshort create_flag;
	IGRint an_type;
	IGRint tol_sym;
	struct DMplan_info plan_info;
	unsigned char *text_string;
	IGRshort text_length;
	struct annot_attr an_attr;

	Form form;
	IGRint form_display;
	IGRboolean leader;
	IGRboolean dynamics_on;
	IGRboolean ter_type;
	IGRboolean dual_mode;

	/* - The following variables must be set in init method - */
	
	IGRint 	arrow_index;
	IGRint	lead_index;

	Form	subform;
};

message get_dim_param();

message get_dim_plane();

message place_dimension();

message compute_dimension();

message create_arrow();

message create_lead();


message delete_vertex(int *response);

message display_dimension(IGRint level; IGRint control);

message delete_dimension();

message set_dim_attr();

message connect_leader(struct GRevent *event);

message place_no_leader( IGRint *rc);

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
message dealloc();


message display_form();

message get_keybrd_input(char *string);

message add_text_to_object(IGRint *response);

message get_gt_symbol(
	int form_label;
	int g_label;
	double value;
	Form form);

message process_bln_form(
	IGRboolean display;
	IGRint label;
	IGRdouble value;
	Form form);
message update_text_string();
message get_prev_dim_data();

override init, wakeup, super_cmd.sleep, execute, delete, notify_form;
override LC_selection, LC_preproc, LC_postproc, LC_dynamics;

end specification COanplace;
