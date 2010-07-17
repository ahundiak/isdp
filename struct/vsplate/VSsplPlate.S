/*
	I/STRUCT
*/
class specification VSsplPlate(0:0) of VSmodPlate, VSdivFeature ;

/*+c
	Class for a plate which is the result of a splitting operation.
	Objects of this class perform the actual splitting and manage the
	sub-plates which are the results of the split.
-c*/

override
	VSgetObjDef,
	ACconstruct_feet ;

from VSmodPlate inherit	ACgive_structure,
			VSdescribeOutput ;

end specification VSsplPlate ;


