/*
	I/STRUCT
*/
class specification VSintCrsSctn(0:0) of VSprjCrsSctn ;

#ifndef vspxdef_include
#	include "vspxdef.h"
#endif

/*+c
	This class defines curves which represent a cross-section
	resulting of the intersection of a beam and the surface.
	Sensible results are returned even if the beam is in linear (simplified)
	representation.
-c*/

override
	ACconstruct_feet,
	VSgetObjDef ;

end specification VSintCrsSctn ;

