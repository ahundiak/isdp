/*
	I/STRUCT
*/
class specification VSselector(0:0) of VShelper ;

/*+c

-c*/
instance VSselector {
	variable char program[0] ;
} ;

override
	GRputattr,
	GRgetattr,
	NDsleep,
	ACconstruct_feet,
	VSgetObjDef ;

end specification VSselector ;
