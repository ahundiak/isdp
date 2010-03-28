/***************************************************

	COdimonoff:
	-----------

	Supports the Following commands:

		"Hide Dimension"
		"Show Dimension"
		"Retrieve Dimension"
		"Toggle Dimension Value/Name"
		"Compare Dimension"

*****************************************************/

class specification COdimonoff (2:0) of COdim;

instance COdimonoff
{
	IGRboolean namval;
	struct GRevent loc_event;
	struct GRid prev_dim, prev_parent;
	Form form;
	IGRint form_displayed;
};

message set_dim_disp(IGRboolean all);
message show_difference(IGRboolean reset_form);

override init, wakeup, super_cmd.sleep, execute, delete;
override LC_selection, LC_dynamics, LC_preproc, LC_postproc;
override notify_form;

end specification COdimonoff;
