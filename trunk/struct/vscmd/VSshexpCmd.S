/*
	I/STRUCT
*/
class specification VSshexpCmd (1:0) of VSpartopCmd ;

message init_cmd( int *sts ) ;

message discard_start_plane( int *sts ) ;

message hilite_gadget( int state ) ;

message display_default_gadget( int state ) ;

message unhilite_end_gadget( int *sts ) ;

end specification VSshexpCmd ;
