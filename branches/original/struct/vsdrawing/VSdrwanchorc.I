/*
	I/STRUCT
*/
class implementation ACncpx ;

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "growner.h"
#include "fontdef.h"
#include "font.h"
#include "EMSmsgdef.h"
#include "vsdef.h"
#include "vsslcdef.h"
#include "vsslc.h"
#include "vsdrwdef.h"
#include "vsdrw.h"
#include "VSdrwgrammar.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

/*
 * Includes of function prototypes.
 */
#include "vsdrwproto.h"
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
int VSdrwAnchorCurve( msg, inp, xData, curve )

long			*msg ;
const VSdrwInputData	*inp ;	
VSdrwExecData		*xData ;
VSexecRes		*curve ; {

	long			sts ;
	struct GRprops		gprops ;	/* Geom. props. of ele.	*/

#define DRWERR if( xData->verbose ) VSdrwPrintf

	if( curve->type != VS_object ) {
		DRWERR( "!!! Anchor curve: argument is not an object\n" ) ;
		*msg = MSINARG ; return FALSE ;
	}

	sts = om$send(	msg	= message GRvg.GRgeomprops(
						msg,
						&curve->_oval._matrix_type,
						curve->_oval._matrix,
						&gprops ),
			senderid= NULL_OBJID,
			targetid= curve->_oval._objid,
			targetos= curve->_oval._osnum ) ;
	if( !( sts & 1 & *msg ) ) {
		DRWERR(	"!!! Anchor curve: cannot get properties of element\n");
		*msg = MSFAIL ; return FALSE ;
	}

	if( gprops.type != GRCURVE ) {
		DRWERR(	"!!! Anchor curve: element is not a curve\n" ) ;
		*msg = MSINARG ; return FALSE ;
	}

	xData->txPosHelper 	= VSuseAnchorCurve ;
	xData->anchorCurve	= curve->_oval ;
	*msg			= MSSUCC ;

	return TRUE ;

} /* VSdrwAnchorCurve */
/*----------------------------------------------------------------------------*/

end implementation ACncpx ;

