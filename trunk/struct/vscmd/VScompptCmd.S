/*
	I/STRUCT
*/
class specification VScompptCmd(1:0) of VSpartopCmd ;

#include "growner.h"

override operation ;

message VScompressPart( long *msg ; struct GRobj_env part ) ;

end specification VScompptCmd ;
