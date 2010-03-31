class specification HSmfvd (1:0) of HSwindow;




instance HSmfvd
{
	IGRint		start_frame, end_frame;
	IGRint		oscilate;
	IGRchar		filename[12];
	};


message which_mode ( long * sts );

message display_command_title ( long * sts );

message get_filename ( long * sts );

message read_range ( long * sts );

message read_oscilate ( long * sts );

message save_frame ( long * sts );

message view_dynamics ( long * sts );

end specification HSmfvd;
