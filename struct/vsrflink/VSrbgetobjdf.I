/*
	I/STRUCT
*/
class implementation VSrflBeam ;

#include "ACrg_collect.h"
#include "EMSmsgdef.h"
#include "vsglobalmsg.h"
#include "vsrfldef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

#define nbFeet		3
/*----------------------------------------------------------------------------*/
method VSgetObjDef( long *msg ; VSobjDef *myDef ) {

#define nbRoots 3

	long		sts ;	/* OM return code		*/
	static char	*tNames  [nbRoots] = {	VS_K_bmInRfFile,
						VS_K_prPrvAttr,
						VS_K_prUsrAttr	} ;

	static int	 tTypes  [nbRoots] = {	other_generic,
						gen_rg_collect,
						gen_rg_collect	} ;

	static char	*fNames[] = {	VS_K_bmGrCmpName,
					VS_K_rbSuppSrf,
					VS_K_rbFaceForAxis } ;

	sts = om$send(	msg	= message VSbeam.VSgetObjDef( msg, myDef ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;


	myDef->info			= VS_gI_Beam ;
	myDef->type			= VS_m_SRC_BEAM ;
	myDef->minInput			= 1 ;
	myDef->input.count		= nbRoots ;
	myDef->input.names		= tNames ;
	myDef->input.type.types		= tTypes ;

	/*
	 * Template feet.
	 */
	myDef->i2o.count		= 0 ;
	myDef->i2o.names		= NULL ;
	myDef->i2o.type.types		= NULL ;

	/*
	 * Feet.
	 */
	myDef->output.count		= nbFeet ;
	myDef->output.names		= fNames ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VSgetObjDef */
/*----------------------------------------------------------------------------*/

end implementation VSrflBeam ;
