/*
	I/STRUCT
*/
class specification VSchsfsdCmd(1:0) of VSlocateCmd ;

instance VSchsfsdCmd {
	int	number_of_stiffeners ;
} ;

message store_stiffener( int * sts ) ;

message process_fence( int * sts ) ;

message hilight_new_side( long *msg ) ;

message change_position( long *msg ) ;

message unhilight_new_side( int * sts ) ;

end specification VSchsfsdCmd ;
