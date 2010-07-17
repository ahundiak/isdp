/*
	I/STRUCT
*/
class specification VSmrkPlate(0:0) of VSimbPlate ;

/*+c
	Class for a plate which is the result of an impose-boundary operation,
	but markings are put instead of holes.
-c*/

override

/*+o
Message VSgetObjDef

Abstract
	Returns the object definition of a VSholPlate object.
Arguments
	See message VSgetObjDef of class VScpx.
-o*/
	VSgetObjDef,
	VSimposeBoundary ;


end specification VSmrkPlate ;

