/*
	I/STRUCT
*/
class implementation VSexpandedCv ;

#include "vsglobalmsg.h"
#include "vsshexpdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

#define	VD_DEBUG
#include	<VDdebug.h>

/*----------------------------------------------------------------------------*/
method VSgetObjDef( long *msg ; VSobjDef *myDef )
{
#define nbMinRoots	2
#define nbRoots 	nbMinRoots
#define nbFeet		1

	long		sts ;		/* OM return code		*/

	/* For templates */
	static char	*tNames[nbRoots] = {	VS_K_sxShellExpansion,
						VS_K_sxCurve		} ;
	static int	 tTypes[nbRoots] = {	macro_generic,
						curve_generic		} ;
	/* For feet */
	static char	*fNames[nbFeet]  = {	VS_K_sxExpandedCurve	} ;

        __enterMethod ( name = "VSgetObjDef" //, argfmt = "", args = ``
        );

	myDef->info			= VS_gI_ExpandedCurve ;
	myDef->type			= 0 ;
	myDef->minInput 		= nbMinRoots ;

	/*
	 * Templates.
	 */
	myDef->input.count		= nbRoots ;
	myDef->input.names		= tNames ;
	myDef->input.type.types 	= tTypes ;

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
	myDef->i2o.count		= 0 ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

        __exitMethod ( name = "VSgetObjDef", argfmt = "sts = %d, msg = %#x", args = `sts, *msg` );

	return sts ;

} /* method VSgetObjDef */
/*----------------------------------------------------------------------------*/

end implementation VSexpandedCv ;
