/*
	I/VDS

	This file contains the function to determine the object symbology
	after placement or through an external command object. This function
	is called using the parser and to determine the object specific
	symbology.

	History:
	02/13/95	adz	creation date.
	10/30/97	ah	Fix warning
*/
class implementation VDSroot ;

#include <stdlib.h>
#include "OMmacros.h"
#include "asbox.h"
#include "EMSmsgdef.h"
#include "v_drw.h"
#include "v_datamacros.h"
#include "v_geommacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

/*
 * Includes of function prototypes.
 */
#include "v_drwproto.h"

#argsused  // Fix warning

/*----------------------------------------------------------------------------*/
long VD_drwCstSymbology( msg, inp, xData, outp )

long			*msg ;
VD_drwInputData		*inp ;
VD_drwExecData		*xData ;
VD_drwGraphicGroup	*outp ; {

	long			sts ;		/* OM completion code	*/
	struct	GRsymbology	elmSymb ;	/* overriden symbology	*/

	SetProc( VD_drwCstSymbology ); Begin

	/*
	 * As result of symbology changements in the setup file, the
	 * structure xData->overrides is modified. 
	 * The object need to accept this symbology.
	 */

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	__DBGpr_obj( "Object to handle", *(inp->elmId) ) ;

	elmSymb.level			= xData->overrides.elmLevel ;
        elmSymb.display_attr.color      = xData->overrides.elmDisplay.color ;
        elmSymb.display_attr.weight     = xData->overrides.elmDisplay.weight ;
        elmSymb.display_attr.style      = xData->overrides.elmDisplay.style ;

	sts =
	_VD_SEND_OBJN(	*inp->elmId,
			GRvg.GRputsymb( msg, &elmSymb ));
	__CheckRC( sts, *msg, "GRvg.GRputsymb", wrapup );

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		End
		return sts ;

} /* VD_drwCstSymbology */

/*----------------------------------------------------------------------------*/


end implementation VDSroot ;
