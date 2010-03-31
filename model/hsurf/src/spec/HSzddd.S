class specification HSzddd (1:0) of HSwindow;




instance HSzddd
{
	IGRint		mode;
	IGRint		switch1;
	
	IGRchar		window_name[GRNAME_SIZE];
	};


message get_window_name ( long * sts );

message spawn_elements_in_view ( long * sts );

message which_state ( long * sts );

message set_delete_mode ( long * sts );

message set_dump_mode ( long * sts );

message display_mode_title ( long * sts );

message process ( long * sts );

end specification HSzddd;
