/*
	I/STRUCT
*/
class specification VSophistCmd (1:0) of VSpartopCmd ;

#include "growner.h"
#include "vsdef.h"
#include "vs.h"

instance VSophistCmd {
	int			flag ;
	char			*opHistForm ;
	VSopHistory		*history,	/* History of part	*/
				*selected ;	/* Selected operation	*/
} ;

override	form_notification,
		operation ;

message createForm() ;

message setStackedStatus( int stacked ) ;

message displayOperators( long *msg ; enum GRdpmode mode ) ;

message cleanUp() ;

message toggleCommand() ;

end specification VSophistCmd ;
