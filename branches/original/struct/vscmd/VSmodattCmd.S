/*
	I/STRUCT
*/
class specification VSmodattCmd(1:0) of VSpartopCmd ;

#define MX_ATTR_DFLTS	30	/* Max. # of attributes accepted	*/
#include "vsdfltvalsfm.h"

instance VSmodattCmd {
	char		*modAttrForm ;
	VSdfltValsInfo	dfltInfo ;
	VSdefaultValues	defaultValues[MX_ATTR_DFLTS] ;
} ;

message dspAttrs( int elmNo ) ;

message cleanUp() ;

override form_notification,
	 mouse,
	 operation ;

end specification VSmodattCmd ;
