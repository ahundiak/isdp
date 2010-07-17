/*
	I/STRUCT
*/
class specification VStwsBeam(0:0) of VSstfBeam ;

#include "vsstfnrdef.h"
#include "vsstfnr.h"

/*+c
	Class defining a twisted stiffener beam, ie. a source beam 
	constrained to one side of a plate and the angle of rotaions
	at intermediate places.

	Parent #0	: a support surface( skinned surface )
	Parent #1	: a curve ( axis )
-c*/

instance VStwsBeam {
	long	bitFlag ;
} ;

override
	ACconstruct_feet,
	VSgetObjDef,
	
/*+o
Message VSgetSupportSf

Abstract
	Returns the support surface of the twisted stiffener, i.e. 
	the not the face of the plate or plate itself, but the skinned
	surface( VSbeamSupp )
Arguments
	See message VSgetSupportSf of class VSbeam.
-o*/

	VSgetSupportSf ;

end specification VStwsBeam ;

