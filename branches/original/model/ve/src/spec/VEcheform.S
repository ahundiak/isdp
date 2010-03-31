class specification VEcheform (1:0) of VEedgescmds;


instance VEcheform
{
	Form form_ptr;
	};


message save_form_ptr ( long * sts );

message form_init ( long * sts );

override form_notification;

end specification VEcheform;
