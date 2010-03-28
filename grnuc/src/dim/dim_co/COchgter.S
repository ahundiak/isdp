class specification COchgter (2:0) of COdim;

instance COchgter
{
	struct GRid dim_grid;			/* Dimension in id */
	struct GRevent dim_event;		/* Event for locating dim */
	IGRint comp_type;
	IGRboolean form_is_displayed;
	IGRchar ter_type;
	IGRchar ter_name[32];

	Form form;
};

message display_form();
message change_terminator();

override init, execute;
override super_cmd.sleep, wakeup, delete;
override LC_selection, LC_preproc, LC_postproc, LC_dynamics;
override notify_form;

end specification COchgter;
