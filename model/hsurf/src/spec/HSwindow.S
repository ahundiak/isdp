class specification HSwindow (1:0) of CEO_GSLOCATE;




instance HSwindow
{
	IGRint	     num_win_ids;
	struct GRid  win_ids[40];
	IGRboolean   change_made;
	};


message get_selected_window ( IGRint *sts; IGRint any0_shading1; IGRint single_window;
	                    IGRint validate_for_shading; IGRint validate_for_hidden_line );

message get_windows ( IGRint *sts; IGRint win_types;
	            IGRint validate_for_shading; IGRint validate_for_hidden_line );

end specification HSwindow;
