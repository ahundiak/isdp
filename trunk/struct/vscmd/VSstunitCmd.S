/*
	I/STRUCT
*/
class specification VSstunitCmd(0:0) of VSlocateCmd ;

instance VSstunitCmd {
	variable char	UOMtable[0] ;
	struct GRevent	events[3] ;
} ;

message storeEvent( struct GRevent *event ; int toIndex ) ;

message statusDispAvailable( int on ) ;

message setUOMtable( char *UOMtable ) ;

message displayActiveUnits( long *msg ) ;

message putActiveUnits( long *msg ) ;

override	status_disp,
		form_notification ;

end specification VSstunitCmd ;
