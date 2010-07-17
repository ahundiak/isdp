/*
	I/STRUCT
*/
class specification VSctoutsCmd (1:0) of VSlocateCmd ;

instance VSctoutsCmd {
	int		number_of_parts ;
        char            *testForm ;   /* Form for displaying macros failed */ 

} ;

message store_part( int *sts ) ;

message process_fence( int *sts ) ;

message setDefaults() ;

message saveDefaults() ;

message sub_form_notification( char *form_ptr ; int gadget_label );

override 	init,
		sleep,
		wakeup,
		delete,
		form_notification ;

end specification VSctoutsCmd ;
