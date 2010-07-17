/*
	I/STRUCT
*/
class specification VSgapPlate(0:0) of VSmodPlate, VSdivFeature ;

/*+c
	Class of a plate which is the result of an intersection with another
	plate (operator), the result being two sub-plates separated by a gap
	through which the operator plate goes.
-c*/
override
	VSgetObjDef,
	ACconstruct_feet ;

from VSmodPlate inherit	ACgive_structure,
			VSdescribeOutput ;

end specification VSgapPlate ;


