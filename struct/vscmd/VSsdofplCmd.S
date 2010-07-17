/*
	I/STRUCT
*/
class specification VSsdofplCmd (1:0) of VSlocateCmd ;

#include "growner.h"

instance VSsdofplCmd {
	struct GRobj_env	SideObj ;	/* Side of plate wanted.*/
	char			*WantSide ;	/* Bottom or top side of*/
						/*  wanted plate.	*/
} ;

message init_cmd( int * sts ) ;

message store_plate( long *msg ) ;

message hilight_side( int * sts ) ;

message unhilight_side( int * sts ) ;

message swap_side( long *msg ) ;

message put_side_on_queue( long *msg ) ;

end specification VSsdofplCmd ;
