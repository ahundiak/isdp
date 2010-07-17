/*
	I/STRUCT
*/ 
class implementation VScpx ;

#include <stdlib.h>
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"

extern OMuword		OPP_ci_mac_def_class_id ;

from ci_mac_def	import ACplace ; 
/*----------------------------------------------------------------------------*/
method VScreate_def(	long		*msg ;
			char		*macDefName ;
			OMuword		osnum ;
			OM_S_OBJID	*p_objid ) {

	/*
	 * Create a macro definition for all objects of this class.
	 */
	long		sts ;
	int		i,			/* Loop index		*/
			outpCount,		/* Count of outputs	*/
			*outpTypes = NULL ;	/* Types of outputs	*/
	VSobjDef	myDef ;			/* My class definition	*/

	sts = om$send(	msg	= message VScpx.VSgetObjDef( msg, &myDef ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VScpx.VSgetObjDef", wrapup ) ;

	outpCount = myDef.output.count ;

	if( outpTypes = _MALLOC( outpCount, int ) ) {
	    	for( i = 0 ; i < outpCount ; i++ ) outpTypes[i] = 0 ;
	} else	vs$mem_fail() ;

	sts = om$construct(
		classid		= OPP_ci_mac_def_class_id,
		osnum		= osnum,
		p_objid		= p_objid,
		msg		= message ci_mac_def.ACplace(
						(int *) msg,
	/* Properties:			*/	0,
	/* Name of definition:		*/	macDefName,
	/* Name of internal data:	*/	"",
	/* Size of internal data:	*/	0,
	/* Count of inputs:		*/	myDef.input.count,
	/* Names of inputs:		*/	myDef.input.names,
	/* Types of inputs:		*/	myDef.input.type.types,
	/* # of inputs/outputs:		*/	myDef.i2o.count,
	/* Types of inputs/outputs:	*/	myDef.i2o.type.types,
	/* Names  of inputs/outputs:	*/	myDef.i2o.names,
	/* # of virtual outputs:	*/	myDef.virtual.count,
	/* Names virtual outputs:	*/	myDef.virtual.names,
	/* Types virtual outputs:	*/	myDef.virtual.type.types,
	/* Count of outputs:		*/	outpCount,
	/* Names of outputs:		*/	myDef.output.names,
	/* Types of outputs:		*/	outpTypes,
	/* Order of outputs(unused):	*/	NULL ) ) ;
	__CheckRC( sts, *msg, "om$construct/ci_mac_def.ACplace", wrapup ) ;

	wrapup :
		_FREE( outpTypes ) ;
		return sts ;

} /* method VScreate_def */
/*----------------------------------------------------------------------------*/

end implementation VScpx ;
