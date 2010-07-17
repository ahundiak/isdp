/*
	I/STRUCT
*/
class specification VScrcppfCmd (1:0) of VSfmcppfCmd ;

message init_cmd( long *msg ) ;

message get_nb_plates( long *msg ) ;

override disable_form ;

override enable_form ;

message initForm( long *msg ) ;

message init_plates_definition( long *msg ) ;

override initial_form_notification ;

override form_notification ;

message find_plate2( long *msg ) ;

message find_plate1( long *msg ) ;

message draw_plates( long *msg ) ;

message check_construction( long *msg ) ;

message construct_profile( long *msg ) ;

message accept_profile( long *msg ) ;

override window_notification ;

end specification VScrcppfCmd ;

