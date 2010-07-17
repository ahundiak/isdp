/*
	I/STRUCT
*/

class specification VSsplBeam(0:0) of VSmodBeam, VSdivFeature ;

/*+c
	Class for a beam which is the result of a splitting operation.
	Objects of this class perform the actual splitting and manages the
	beams which are the results of the split.
	Only source beams may be split, ie. objects of this class must have
	an object of class VSsrcBeam as parent.
-c*/

override
	VSgetObjDef,
	ACconstruct_feet ;

from VSmodBeam inherit	ACgive_structure,
			ACgive_db_structure,
			ACcheckin_candidate,
			ACadd_to_list_1,
			VSdescribeOutput ;

end specification VSsplBeam ;


