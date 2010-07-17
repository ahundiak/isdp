/*
	I/STRUCT
*/
class specification VSholPlate(0:0) of VSimbPlate ;

/*+c
	Class for a plate which is the result of an impose-boundary operation
	which puts holes onto the plate.
-c*/

override

/*+o
Message VSgetObjDef

Abstract
	Returns the object definition of a VSimbPlate object.
Arguments
	See message VSgetObjDef of class VScpx.
-o*/
	VSgetObjDef,
	VSimposeBoundary ;

end specification VSholPlate ;

