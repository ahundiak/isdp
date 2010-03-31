class specification HSdisplmode (1:0) of HSwindow;




instance HSdisplmode
{
        IGRchar style;   /* active shading style */
	IGRint save_restore;
	};


message display_shad_symb ( long * sts );

message set_form_defaults ( long * sts );

message set_check_marks ( long * sts );

message adjust_form_buttons ( long * sts );

override form_notification;

message update_display_mode ( long * sts );

message cvrt_to_wireframe ( long * sts );

message print_message ( long * sts );

message initialize_instance ( long * sts );

end specification HSdisplmode;
