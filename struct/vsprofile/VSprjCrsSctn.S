/*
	I/STRUCT
*/
class specification VSprjCrsSctn(0:0) of VShelper ;

#ifndef vspxdef_include
#	include "vspxdef.h"
#endif

/*+c
	This class defines curves which represent the cross-section of a beam
	projected on a surface.
-c*/

override
	ACconstruct_feet,
	VSgetObjDef,

/*+o
Message ACgive_path

Abstract
	If a component curve of the projected cross-section is entered,
	returns its logical name.
Arguments
	See message ACgive_path of class ACcpx.
-o*/
	ACgive_path,

/*+o
Message ACreturn_foot

Abstract
	If a logical name of a component curve of the projected cross-section
	is entered, returns its object id.
Arguments
	See message ACreturn_foot of class NDmacro.
-o*/
	ACreturn_foot ;

end specification VSprjCrsSctn ;

