/* $Id: VDdrwvwtypVS.I,v 1.1.1.1 2001/01/04 21:08:38 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vddraw/struct/VDdrwvwtypVS.I
 *
 * Description:
 *		Get view type for Structural objects (Struct Parser).
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwvwtypVS.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:38  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1995/08/31  21:45:46  pinnacle
# Replaced: ./vddraw/struct/VDdrwvwtypVS.I for:  by azuurhou for vds.240
#
# Revision 1.1  1995/08/16  14:51:28  pinnacle
# Created: vddraw/struct/VDdrwvwtypVS.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	08/12/95	adz		creation date.
 *
 ***************************************************************************/

class implementation VDSroot ;

#include <stdio.h>
#include <malloc.h>
#define _INGR_EXTENSIONS
#include <math.h>
#include "madef.h"
#include "bserr.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "fontdef.h"
#include "font.h"
#include "EMSmsgdef.h"
#include "vdprdmacros.h"
#include "v_def.h"
#include "v_slcdef.h"
#include "v_slc.h"
#include "v_drw.h"
#include "v_drwmacros.h"
#include "v_datamacros.h"
#include "v_geommacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

#include "VSdrw.h"

/*
 * Includes of function prototypes.
 */
#include "bsdotp.h"
#include "bsmkvec.h"
#include "v_drwproto.h"
#include "v_vecmxproto.h"

from GRcurve	import GRendpts ;
extern OMuword  OPP_ACconst_class_id ;

/*----------------------------------------------------------------------------*/
long VD_drwGetViewTypeFromSTRUCT( msg, inp, xData )

long		*msg ;		/* OUT : completion code	*/
VD_drwInputData	*inp ;		/* I/O : input data		*/
VD_drwExecData	*xData ; {	/* IN  : execution data		*/

	/*
	 * Finds the view type of a "const" (a macro occurrence) using one of
	 * its graphic outputs.
	 */
	long			sts ;		/* OM completion code.	*/
	const char		*type = xData->parsedElmDesc ;

	/*
	 * I/STRUCT Data Structures.
	 */
	VSdrwInputData		S_inp ;
	VSdrwExecData		S_xData ;

	SetProc( VD_drwGetViewTypeFromSTRUCT ); Begin

	DRW_elmView	= VD_unknownViewType ;
	S_inp.viewType	= VSunknownViewType ;

	sts =
        vd$prd_get_product_info( logo = VD_PROD_LOGO_STRUCT );
	if( !( sts & 1 )){
		goto wrapup ;
	}

	__DBGpr_str(" Object Type ", type );

	/*
	 * Copy needed data structures field for I/STRUCT process.
	 */
	S_inp.elmId	= inp->elmId ;
	S_inp.elmEnv	= inp->elmEnv ;
	VDdrw_cpy_Info(	& inp->drwInfo, &S_inp.drwInfo );
	S_xData.overrides.viewConeAngle	= xData->overrides.viewConeAngle ;

	if(    !strcmp( type, "beam" )
	    || !strcmp( type, "stiffener" )){

	  if( !( 1 & VSdrwGetViewTypeFromBeam( msg, &S_inp, &S_xData )))
		__DBGpr_com(" unknownViewType [beam,stiffener] ");
		S_inp.viewType = VSunknownViewType ;
		goto wrapup;
	}

	if( !strcmp( type, "plate" )){
	  if( !( 1 & VSdrwGetViewTypeFromPlate( msg, &S_inp, &S_xData ) ) )
		__DBGpr_com(" unknownViewType [plate] ");
		S_inp.viewType = VSunknownViewType ;
		goto wrapup;
	}

	if( !strcmp( type, "joint" )){
	  if( !( 1 & VSdrwGetViewTypeFromJoint( msg, &S_inp, &S_xData )))
		__DBGpr_com(" unknownViewType [joint] ");
		S_inp.viewType = VSunknownViewType ;
		goto wrapup;
	}

	wrapup :

		/*
		 * Find the I/VDS parser corresponding value.
		 */
		VDdrw_ret_viewType( &S_inp, inp );

		*msg = MSSUCC ; sts = OM_S_SUCCESS ;
		End
		return sts ;

} /* VD_drwGetViewTypeFromSTRUCT */
/*----------------------------------------------------------------------------*/

end implementation VDSroot ;

