/*
	I/STRUCT

			VSchangeSymbology
			-----------------
Abstract
	Changes the symbology of a graphic element.

Arguments
	OUT	long			*msg		completion code
	IN	struct GRid		*graphic	graphic element
	IN	short			newLevel	new level of element
	IN	struct IGRdisplay	*newDisplay	new display

*/
class implementation GRvg ;

#include <stdio.h>
#include "msdef.h"
#include "emsmass.h"
#include "OMmacros.h"
#include "vspart.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
long VSchangeSymbology( msg, graphic, newLevel, newDisplay )

long			*msg ;
struct GRid		*graphic ;
short			newLevel ;
struct IGRdisplay	*newDisplay ; {

	long		OMrc ;		/* OM return code		*/

	OMrc = om$send(	msg	= message GRvg.GRchglevel(
							msg,
							&newLevel ),
			senderid= graphic->objid,
			targetid= graphic->objid,
			targetos= graphic->osnum ) ;
	__CheckRC( OMrc, *msg, "GRvg.GRchglevel", wrapup ) ;

	OMrc = om$send(	msg	= message GRvg.GRchgdp(	msg,
							newDisplay ),
			senderid= graphic->objid,
			targetid= graphic->objid,
			targetos= graphic->osnum ) ;
	__CheckRC( OMrc, *msg, "GRvg.GRchgdp", wrapup ) ;

	wrapup :
		if( !( OMrc & 1 ) ) *msg = MSFAIL ;
		return *msg & 1 ;

} /* VSchangeSymbology */
/*----------------------------------------------------------------------------*/
long VSchgSymbAndProps( msg, graphic, newLevel, newDisplay, newProps )

long			*msg ;
struct GRid		*graphic ;
short			newLevel,
			newProps ;
struct IGRdisplay	*newDisplay ; {

	long		sts ;		/* OM return code		*/
	short		set = 1 ;	/* `Set props with mask'	*/

	sts = VSchangeSymbology( msg, graphic, newLevel, newDisplay ) ;

	sts = om$send(	msg	= message GRgraphics.GRchgprops(
							msg, &set, &newProps ),
			senderid= graphic->objid,
			targetid= graphic->objid,
			targetos= graphic->osnum ) ;

	return sts ;

} /* VSchgSymbAndProps */
/*----------------------------------------------------------------------------*/
long VSgrCopy( msg, frEnv, frObj, toEnv, mxType, mx, newSymb, toObj )

long			*msg ;
struct GRmd_env		*frEnv,
			*toEnv ;
short			mxType ;
IGRmatrix		mx ;
struct GRsymbology
			*newSymb ;
struct GRid		*frObj,
			*toObj ; {

	long		sts ;

        sts = om$send(  msg     = message GRgraphics.GRcopy(
        						msg,
							frEnv,
							toEnv,
							&toObj->objid ),
			senderid= frObj->objid,
			targetid= frObj->objid,
			targetos= frObj->osnum ) ;
	__CheckRC( sts, *msg, "GRgraphics.GRcopy", wrapup ) ;

	toObj->osnum = toEnv->_MD_OS ;

	if( mx ) {
		sts = om$send(	msg	= message GRgraphics.GRxform(
							msg,
							toEnv,
							&mxType,
							mx,
							&toObj->objid ),
			senderid= toObj->objid,
			targetid= toObj->objid,
			targetos= toObj->osnum ) ;
		__CheckRC( sts, *msg, "GRgraphics.GRxform", wrapup ) ;

	}

	if( newSymb ) {
		sts = om$send(	msg	= message GRvg.GRputsymb(
								msg, newSymb ),
				senderid= toObj->objid,
				targetid= toObj->objid,
				targetos= toObj->osnum ) ;
		__CheckRC( sts, *msg, "GRgraphics.GRputsymb", wrapup ) ;
	}

	wrapup :
		return sts ;

} /* VSgrCopy */
/*----------------------------------------------------------------------------*/

end implementation GRvg ;
