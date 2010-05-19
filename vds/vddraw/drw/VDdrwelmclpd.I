/* $Id: VDdrwelmclpd.I,v 1.1.1.1 2001/01/04 21:08:37 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vddraw/drw/VDdrwelmclpd.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwelmclpd.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:37  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/30  21:24:46  pinnacle
# Warnings
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.4  1995/08/23  20:08:30  pinnacle
# Replaced: vddraw/drw/VDdrwelmclpd.I for:  by azuurhou for vds.240
#
# Revision 1.3  1995/08/16  14:48:14  pinnacle
# Replaced: vddraw/drw/VDdrwelmclpd.I for:  by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	01/01/95	adz		copy date
 *	08/13/95	adz		Code optimalization.
 *	10/30/97	ah		Warning Message
 ***************************************************************************/

class implementation VDSroot ;

#include <stdlib.h>
#include "madef.h"
#include "bserr.h"
#include "bstypes.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "EMSutlmacros.h"
#include "v_slcdef.h"
#include "v_slc.h"
#include "v_miscmacros.h"
#include "v_drwdef.h"
#include "v_drw.h"
#include "v_geommacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_globalmsg.h"
/*
 * Includes of function prototypes.
 */
#include "bssf_pl_int.h"
#include "v_getchanobj.h"
#include "v_vecmxproto.h"

#argsused // Get rid of warning

/*----------------------------------------------------------------------------*/
int VD_drwIsElementClipped( msg, inp, xData, isClipped )

long		     *msg ;	    /* OUT: Completion code		   */
const VD_drwInputData *inp ;	    /* IN : Data input to interpreter	   */
const VD_drwExecData  *xData ;	    /* IN : Data modified during execution */
int		     *isClipped ; { /* OUT: TRUE/FALSE			   */

	struct IGRplane	clippingPlane ;
	IGRvector	plNormal ;

	SetProc( VD_drwIsElementClipped ); Begin

	*isClipped	= FALSE ;

	plNormal[0] = inp->drwInfo.drwLbsys->matrix[ 2] ;
	plNormal[1] = inp->drwInfo.drwLbsys->matrix[ 6] ;
	plNormal[2] = inp->drwInfo.drwLbsys->matrix[10] ;

	clippingPlane.point	= inp->drwInfo.drwLbsys->diag_pt1 ;
	clippingPlane.normal	= plNormal ;

	VD_drwIsObjectClipped(	msg,
				inp->elmId,
				inp->elmEnv,
				&clippingPlane,
				isClipped ) ;

	End
	return *msg & 1 ;

} /* VD_drwIsElementClipped */
/*----------------------------------------------------------------------------*/
int VD_drwIsObjectClipped( msg, objId, objEnv, clippingPlane, isClipped )

long			*msg ;		/* OUT: Completion code		*/
const struct GRid	*objId ;	/* IN : Id of plate		*/
const struct GRmd_env	*objEnv ;	/* IN : Module env. of plate	*/
struct IGRplane		*clippingPlane ;/* IN : Clipping plane		*/
int		*isClipped ; {		/* OUT: TRUE/FALSE		*/

	int			i,
				numgrps		= 0,
				*numpts		= NULL ;
	IGRpoint		**pts		= NULL ;
	IGRvector		**tans		= NULL ;
	BSpair			**pars		= NULL ;
	struct IGRbsp_surface	*botGeom	= NULL ;

	SetProc( VD_drwIsObjectClipped ); Begin

	vd_$get_geometry(	msg	= msg,
				grobjId	= objId,
				grobjEnv= objEnv,
				geometry= &botGeom ) ;
	__CheckRC( 1, *msg, "vd_$get_geometry", wrapup ) ;

	BSsf_pl_int(	clippingPlane->point,
			clippingPlane->normal,
			botGeom,
			FALSE,
			&numgrps,
			&numpts,
			&pts,
			&tans,
			&pars,
			msg ) ;

	*isClipped = BSOKAY( *msg ) ? numgrps != 0 : FALSE ;

	_FREE( numpts ) ;
	if( pts ) {
		for( i = 0 ; i < numgrps ; i++ ) {
			_FREE( pts[i] ) ;
		}
		_FREE( pts ) ;
	}
	if( pars ) {
		for( i = 0 ; i < numgrps ; i++ ) {
			_FREE( pars[i] ) ;
		}
		_FREE( pars ) ;
	}
	if( tans ) {
		for( i = 0 ; i < numgrps ; i++ ) {
			_FREE( tans[i] ) ;
		}
		_FREE( tans ) ;
	}
	*msg = MSSUCC ;	
	wrapup :
		_FREE( botGeom ) ;
		End
		return *msg & 1 ;

} /* VD_drwIsObjectClipped */

/*----------------------------------------------------------------------------*/
end implementation VDSroot ;
