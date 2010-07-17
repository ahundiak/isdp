/*
	I/STRUCT
*/
class specification VSplplatCmd (1:0) of VSfmplatCmd ;

override wakeup ;

message init_cmd( int *sts ) ;

message process_fence( int *sts ) ;

message store_support( int *sts ) ;

override load_attributes ;

message construct_plate( long *msg ) ;

override get_modifiable_gadgets ;

override form_notification ;

override enable_form ;

message load_attributes_from_plate( long *msg ) ;

end specification VSplplatCmd ;

