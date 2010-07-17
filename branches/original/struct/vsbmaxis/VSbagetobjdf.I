/*
	I/STRUCT
*/
class implementation VSbeamAxis ;

#include "ACrg_collect.h"
#include "vsglobalmsg.h"
#include "vsbmaxisdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

/*----------------------------------------------------------------------------*/
method VSgetObjDef( long *msg ; VSobjDef *myDef ) {

#define nbRoots 4
#define nbFeet	1

	long		sts ;		/* OM return code		*/
	
	/* For templates */
	static char	*tNames  [nbRoots] = {	VS_K_baPlateSupp,
						VS_K_baSurfOrLine,
						VS_K_baStartSurf,
						VS_K_baEndSurf	      } ;
	static int	 tTypes  [nbRoots] = {	macro_generic,
						other_generic,
						other_generic,
						other_generic } ;
						
	/* For feet */
	static	char	*fNames	 [nbFeet] = { VS_K_baBmAxis } ;	
	
	myDef->info			= VS_gI_StfnrAxis ;
	myDef->type			= 0 ;
	myDef->minInput			= 2 ;
	
	/*
	 * Templates.
	 */
	myDef->input.count		= nbRoots ;
	myDef->input.names		= tNames ;
	myDef->input.type.types		= tTypes ;
	
	/*
	 * Feet.
	 */
	myDef->output.count		= nbFeet ;
	myDef->output.names		= fNames ;
	myDef->output.type.classids	= NULL ;
	
	/*
	 * Virtual feet.
	 */
	myDef->virtual.count		= 0 ;
	
	/*
	 * Templates feet.
	 */
	myDef->i2o.count 		= 0 ; 

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VSgetObjDef */
/*----------------------------------------------------------------------------*/

end implementation VSbeamAxis ;
