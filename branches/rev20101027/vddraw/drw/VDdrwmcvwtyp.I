/* $Id: VDdrwmcvwtyp.I,v 1.1.1.1 2001/01/04 21:08:37 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vddraw/drw/VDdrwmcvwtyp.I
 *
 * Description:
 *		Get view type for ACconst objects (Struct Parser).
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwmcvwtyp.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:37  cvs
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
# Revision 1.4  1995/11/22  23:48:36  pinnacle
# Replaced: ./vddraw/drw/VDdrwmcvwtyp.I for:  by azuurhou for vds.240
#
# Revision 1.3  1995/08/16  14:50:20  pinnacle
# Replaced: vddraw/drw/VDdrwmcvwtyp.I for:  by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	08/12/95	adz		Changed the default to interactive
 *					view checking.
 *
 ***************************************************************************/

class implementation VDSroot ;

#include <stdio.h>
#include <malloc.h>
#define _INGR_EXTENSIONS
#include <values.h>
#include <math.h>
#include "madef.h"
#include "bserr.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "fontdef.h"
#include "font.h"
#include "EMSmsgdef.h"
#include "v_def.h"
#include "v_slcdef.h"
#include "v_slc.h"
#include "v_drw.h"
#include "v_drwmacros.h"
#include "v_datamacros.h"
#include "v_geommacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

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
long VD_drwGetViewTypeFromConst( msg, inp, xData )

long		*msg ;		/* OUT : completion code	*/
VD_drwInputData	*inp ;		/* I/O : input data		*/
VD_drwExecData	*xData ; {	/* IN  : execution data		*/

	/*
	 * Finds the view type of a "const" (a macro occurrence) using one of
	 * its graphic outputs.
	 */
	long			sts ;		/* OM completion code.	*/
	struct GRid		outpId ;	/* Id of output		*/
	struct GRmd_env		outpEnv ;	/* Mod. env. of output	*/
	struct GRprops		gprops ;	/* Geom. props. of outp.*/
	int			gtype ;		/* Graphic type of outp.*/
	double			*viewVector,	/* View vector		*/
				angle ;		/* Half of view cone	*/

	SetProc( VD_drwGetViewTypeFromConst ); Begin

	inp->viewType	= VD_unknownViewType ;
	angle		= 0.5 * xData->overrides.viewConeAngle ;

	/*
	 * `xData->overrides.viewConeAngle' is in degrees, convert `angle' to
	 * radians.
	 */
	angle		= angle * M_PI / 180. ;

	if( !*xData->viewCriterion ) {
		if( xData->verbose ) {
			VD_drwPrintf(
			"*-* Empty view criterion for const '%s', view set to unknown\n",
			inp->constDefName ) ;
		}
		sts = OM_S_SUCCESS ; *msg = MSSUCC ; goto wrapup ;
	}

	/*
	 * Get id of output to be used as a view criterion.
	 */
	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
							msg,
							xData->viewCriterion,
							&outpId,
							&outpEnv._MATRIX_TYPE,
							outpEnv._MATRIX ),
			senderid= inp->elmId->objid,
			targetid= inp->elmId->objid,
			targetos= inp->elmId->osnum ) ;
	if( !( sts & 1 & *msg ) ) {
		if( xData->verbose ) {
			VD_drwPrintf( "!!! Cannot find '%s' in const '%s'\n",
					xData->viewCriterion,
					inp->constDefName ) ;
		}
		goto wrapup ;
	}

	/* PL sept 8 1994: kludge for equipment: The problem was that for
		the equipment, the foot given in xData->viewCriterion return
		the ACconst and when GRgeomprops is sent, it returns the
		properties of the first element on the chanel (GRowner
		override) but the object is still the ACconst, so when
		some manipulations are done on the object, it crashes
		because the object is not of the return type
	*/

        if( vd_$is_ancestry_valid( object  = &outpId,
                                  classid = OPP_ACconst_class_id ) ) {
            inp->viewType = VD_unknownViewType ;
            *msg = MSSUCC ;
            sts  = OM_S_SUCCESS ;
            goto wrapup;
        }  

	VD_mulmx( inp->elmEnv->_MATRIX, outpEnv._MATRIX, outpEnv._MATRIX,
		 &outpEnv._MATRIX_TYPE ) ;

	outpEnv.md_id = inp->elmEnv->md_id ;

	sts = om$send(	msg	= message GRvg.GRgeomprops(
							msg,
							&outpEnv._MATRIX_TYPE,
							outpEnv._MATRIX,
							&gprops ),
			senderid= outpId.objid,
			targetid= outpId.objid,
			targetos= outpId.osnum ) ;
	__CheckRC( sts, *msg, "GRvg.GRgeomprops", wrapup ) ;

	switch( gprops.type ) {
		case GRCURVE	:
			gtype =    gprops.subtype == GRLN
			        && gprops.phy_closed	  ? VD_K_POINTtype
			        			  : VD_K_CURVEtype ;
			break ;

		case GRSURFACE	:
			if( gprops.subtype == GRSS || gprops.subtype == GRES ) {
				gtype = gprops.planar	? VD_K_PLANEtype
							: VD_K_SURFACEtype ;
				break ;
			}  /* Else fall through default case */

		default		:
			vd_$inv_arg() ;
	}

	viewVector	= inp->drwInfo.viewVector ;

	switch( gtype ) {

	struct IGRplane	plane ;
	IGRpoint	point ;
	IGRvector	normal;

	/*
	 * All points are considered as viewed end-on.
	 */
	case VD_K_POINTtype	: inp->viewType	= VD_endOn ; break ;

	case VD_K_CURVEtype	:
		sts = vd_$is_curve_linear(	msg	= msg,
						curveId	= &outpId,
						curveEnv= &outpEnv ) ;
		if( sts ) {
			/*
			 * If the view vector is parallel to the line segment,
			 * the view type will be end-on, otherwise it will be
			 * from-side :
			 *			
			 * View vector
			 * ----------->
			 *		Line segment		END-ON
			 *		---------------------
			 *
			 * View vector
			 * |		Line segment		SIDE
			 * |		---------------------
			 * v
			 *
			 * View vector
			 * \		Line segment		SIDE
			 *  \		---------------------
			 *   \
			 */

			IGRpoint	startPt,
					endPt ;
			IGRvector	vect ;

			sts = om$send( msg	= message GRcurve.GRendpts(
							msg,
							&outpEnv._MATRIX_TYPE,
							outpEnv._MATRIX,
							startPt,
							endPt ),
					senderid = outpId.objid,
					targetid = outpId.objid,
					targetos = outpId.osnum ) ;
			__CheckRC( sts, *msg, "GRcurve.GRendpts", wrapup ) ;

			BSmkvec( msg, vect, startPt, endPt ) ;
			inp->viewType = VD_areaColinearVectors(	vect,
								viewVector,
								angle )
					? VD_endOn
					: VD_fromSide ;

		} else if( gprops.planar ) {
			goto PLANAR_OBJECT ;
		} else {
			inp->viewType = VD_fromSide ;
		}
		break ;

	case VD_K_PLANEtype	:
	PLANAR_OBJECT		:

		plane.point	= point ;
		plane.normal	= normal ;
		sts = om$send( msg	= message GRvg.GRdetplane(
							msg,
							&outpEnv._MATRIX_TYPE,
							outpEnv._MATRIX,
							&plane ),
					senderid = outpId.objid,
					targetid = outpId.objid,
					targetos = outpId.osnum ) ;
		__CheckRC( sts, *msg, "GRcurve.GRendpts", wrapup ) ;

		if( VD_areaColinearVectors( normal, viewVector, angle ) ) {
			if( BSdotp( msg, normal, viewVector ) > 0 ) {
				__DBGpr_com( "View type is BOTTOM" ) ;
				inp->viewType = VD_fromBottom ;
			} else {
				__DBGpr_com( "View type is TOP" ) ;
				inp->viewType = VD_fromTop ;
			}
		} else if( VD_orthoVectors( normal, viewVector ) ) {
			__DBGpr_com( "View type is SIDE" ) ;
			inp->viewType = VD_fromSide ;
		} else {
			inp->viewType = VD_unknownViewType ;
		}
		break ;

	case VD_K_SURFACEtype	:
		sts = vd_$get_normal(	msg	= msg,
			     		sfId	= &outpId,
					sfEnv	= &outpEnv,
					normal	= normal ) ;
		__CheckRC( sts, *msg, "vd_$get_normal", wrapup ) ;

		if( VD_areaColinearVectors( normal, viewVector, angle ) ) {
			if( BSdotp( msg, normal, viewVector ) > 0 ) {
				__DBGpr_com( "View type is BOTTOM" ) ;
				inp->viewType = VD_fromBottom ;
			} else {
				__DBGpr_com( "View type is TOP" ) ;
				inp->viewType = VD_fromTop ;
			}
		} else {
			inp->viewType = VD_unknownViewType ;
		}
		break ;
	}

	*msg = MSSUCC ; sts = OM_S_SUCCESS ;

	wrapup :

		End
		return sts ;

} /* VD_drwGetViewTypeFromConst */
/*----------------------------------------------------------------------------*/

end implementation VDSroot ;

