/*
	I/VDS	- Copy.
*/
class implementation VDSroot ;

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
#include "v_def.h"
#include "v_slcdef.h"
#include "v_slc.h"
#include "v_drwdef.h"
#include "v_drw.h"
#include "VDdrwgrammar.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

/*
 * Includes of function prototypes.
 */
#include "v_drwproto.h"
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
int VD_drwAnchorCurve( msg, inp, xData, curve )

long			*msg ;
const VD_drwInputData	*inp ;	
VD_drwExecData		*xData ;
VD_execRes		*curve ; {

	long			sts ;
	struct GRprops		gprops ;	/* Geom. props. of ele.	*/

#define DRWERR if( xData->verbose ) VD_drwPrintf

	SetProc( VD_drwAnchorCurve ); Begin

	if( curve->type != VD_object ) {
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

	xData->txPosHelper 	= VD_useAnchorCurve ;
	xData->anchorCurve	= curve->_oval ;
	*msg			= MSSUCC ;

	End
	return TRUE ;

} /* VD_drwAnchorCurve */
/*----------------------------------------------------------------------------*/

end implementation VDSroot ;

