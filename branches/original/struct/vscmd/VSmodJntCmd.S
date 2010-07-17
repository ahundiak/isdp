/*
	I/STRUCT
*/
class specification VSmodJntCmd (1:0) of VSpartopCmd ;

#include "growner.h"
#include "vsdef.h"
#include "vs.h"
#include "vspart.h"
#include "vsattr.h"
#include "vsoptdef.h"
#include "vsweld.h"
#include "vsjointdef.h"
#include "vsjoint.h"

instance VSmodJntCmd {
	VSjointAttr	jAttr ;
	struct GRid	newUAid ;
} ;

message fillForm( long *msg ) ;

override form_notification ;

end specification VSmodJntCmd ;
