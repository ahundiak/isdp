class specification COgtedit (2:0) of COdim;

instance COgtedit
{
	struct GRid gt_grid;			/* Dimension in Placement */
	struct GRevent dim_event;		/* Event for locating dim */
	struct DMtxdynamics_info dyn_info;	/* info for dynamics */
	IGRint nbytes;
	struct DMweld_param  par_weld_sav;
	struct DMweld_param  par_weld;
	struct DMsurf_param  par_surf_sav;
	struct GRcc_info cc_info;
	struct GRid text_grid;
	IGRdouble text_origin[3];
	Form form;
	Form subform;
	Form weldform, weldform1, weldform2, weldform3, weldform4;
	Form surfform, surfform1;
	IGRchar tol_sym;
	IGRint symbol_index;
	IGRint form_display;
	IGRboolean dual_mode;
	IGRboolean dim_type;
	IGRboolean above_input;
};

override init, execute;
override super_cmd.sleep, wakeup, delete;
override LC_selection, LC_preproc, LC_postproc, LC_dynamics;
override notify_form,getevent;

message display_form();

message load_data();

message get_char_under(struct GRevent *dt_event);

message position_cursor();

message update_feature();

message display_dimension(enum GRdpmode mode);

message get_form_symbol(
	int form_label;
	int g_label;
	double value;
	Form form);

message update_balloon(
	IGRint text_length;
	IGRchar *text_string);

message update_weld();

message update_surf();

message update_action(
	IGRint action;
	IGRshort start_index);

reject update_action;

end specification COgtedit;
