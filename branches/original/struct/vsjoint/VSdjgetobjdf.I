/*
	I/STRUCT
*/
class implementation VSdivJoint ;

#include "EMSmsgdef.h"
#include "vsglobalmsg.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

/*----------------------------------------------------------------------------*/
method VSgetObjDef( long *msg ; VSobjDef *myDef ) {

#define nbInputs 1

	long		sts ;		/* OM return code		*/
	/*
	 * Graphic foot's name.
	 */
	static char	*oNames[] = { "unused" } ;
	static char	*iNames[nbInputs] = {	VS_K_jnParentJn         } ;
	static int	 iTypes[nbInputs] = {	macro_generic		} ;

	sts = om$send(	msg	= message VSjoint.VSgetObjDef( msg, myDef ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;


	myDef->info			= VS_gI_Joint ;
	myDef->type			= VS_m_DIV_JOINT ;
	myDef->minInput			= nbInputs ;
	myDef->input.count		= nbInputs ;
	myDef->input.names		= iNames ;
	myDef->input.type.types		= iTypes ;

	/*
	 * Outputs. Must input one although it will not be used.
	 */
	myDef->output.count		= 1 ;
	myDef->output.names		= oNames ;
	myDef->output.type.classids	= NULL ;

	myDef->i2o.count		= 0 ;
	myDef->i2o.names		= NULL ;
	myDef->i2o.type.types		= NULL ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VSgetObjDef */
/*----------------------------------------------------------------------------*/

end implementation VSdivJoint ;
