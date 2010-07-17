/* $Id: VSdrwmcvwtyp.I,v 1.2 2001/01/23 23:11:05 ramarao Exp $  */

/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/vsdrawing/VSdrwmcvwtyp.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSdrwmcvwtyp.I,v $
 *      Revision 1.2  2001/01/23 23:11:05  ramarao
 *      Fixed TR# 4410.
 *
 *      Revision 1.1.1.1  2001/01/04 21:10:33  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.3  1996/01/31  07:04:00  pinnacle
# Replaced: vsdrawing/VSdrwmcvwtyp.I for:  by svkadamb for struct
#

 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
	I/STRUCT
*/
class implementation VSbeam ;

#include <stdio.h>
#include <malloc.h>
#define _INGR_EXTENSIONS
#include <math.h>
#include <values.h>
#include "madef.h"
#include "bserr.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "fontdef.h"
#include "font.h"
#include "EMSmsgdef.h"
#include "vsslcdef.h"
#include "vsslc.h"
#include "vsdrw.h"
#include "vsdrwmacros.h"
#include "vsdatamacros.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

/*
 * Includes of function prototypes.
 */
#include "bsdotp.h"
#include "bsmkvec.h"
#include "vsdrwproto.h"
#include "vsvecmxproto.h"

from GRcurve	import GRendpts ;
extern OMuword  OPP_ACconst_class_id ;
/*----------------------------------------------------------------------------*/
long VSdrwGetViewTypeFromConst( msg, inp, xData )

long		*msg ;		/* OUT : completion code	*/
VSdrwInputData	*inp ;		/* I/O : input data		*/
VSdrwExecData	*xData ; {	/* IN  : execution data		*/

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

	inp->viewType	= VSunknownViewType ;
	angle		= 0.5 * xData->overrides.viewConeAngle ;

	/*
	 * `xData->overrides.viewConeAngle' is in degrees, convert `angle' to
	 * radians.
	 */
	angle		= angle * M_PI / 180. ;

	if( !*xData->viewCriterion ) {
		if( xData->verbose ) {
			VSdrwPrintf(
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
			VSdrwPrintf( "!!! Cannot find '%s' in const '%s'\n",
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

        if( vs$is_ancestry_valid( object  = &outpId,
                                  classid = OPP_ACconst_class_id ) ) {
            inp->viewType = VSunknownViewType ;
            *msg = MSSUCC ;
            sts  = OM_S_SUCCESS ;
            goto wrapup;
        }  

	VSmulmx( inp->elmEnv->_MATRIX, outpEnv._MATRIX, outpEnv._MATRIX,
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
			        && gprops.phy_closed	  ? VS_K_POINTtype
			        			  : VS_K_CURVEtype ;
			break ;

		case GRSURFACE	:
			if( gprops.subtype == GRSS || gprops.subtype == GRES ) {
				gtype = gprops.planar	? VS_K_PLANEtype
							: VS_K_SURFACEtype ;
				break ;
			}  /* Else fall through default case */

		default		:
			vs$inv_arg() ;
	}

	viewVector	= inp->drwInfo.viewVector ;

	switch( gtype ) {

	struct IGRplane	plane ;
	IGRpoint	point ;
	IGRvector	normal;

	/*
	 * All points are considered as viewed end-on.
	 */
	case VS_K_POINTtype	: inp->viewType	= VSendOn ; break ;

	case VS_K_CURVEtype	:
		sts = vs$is_curve_linear(	msg	= msg,
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
			inp->viewType = VSareaColinearVectors(	vect,
								viewVector,
								angle )
					? VSendOn
					: VSfromSide ;

		} else if( gprops.planar ) {
			goto PLANAR_OBJECT ;
		} else {
			inp->viewType = VSfromSide ;
		}
		break ;

	case VS_K_PLANEtype	:
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

		if( VSareaColinearVectors( normal, viewVector, angle ) ) {
			if( BSdotp( msg, normal, viewVector ) > 0 ) {
				__DBGpr_com( "View type is BOTTOM" ) ;
				inp->viewType = VSfromBottom ;
			} else {
				__DBGpr_com( "View type is TOP" ) ;
				inp->viewType = VSfromTop ;
			}
		} else if( VSareaOrthoVectors( normal, viewVector, angle ) ) {
			__DBGpr_com( "View type is SIDE" ) ;
			inp->viewType = VSfromSide ;
		} else {
			inp->viewType = VSunknownViewType ;
		}
		break ;

	case VS_K_SURFACEtype	:
		sts = vs$get_normal(	msg	= msg,
			     		sfId	= &outpId,
					sfEnv	= &outpEnv,
					normal	= normal ) ;
		__CheckRC( sts, *msg, "vs$get_normal", wrapup ) ;

		if( VSareaColinearVectors( normal, viewVector, angle ) ) {
			if( BSdotp( msg, normal, viewVector ) > 0 ) {
				__DBGpr_com( "View type is BOTTOM" ) ;
				inp->viewType = VSfromBottom ;
			} else {
				__DBGpr_com( "View type is TOP" ) ;
				inp->viewType = VSfromTop ;
			}
		} else {
			inp->viewType = VSunknownViewType ;
		}
		break ;
	}

	*msg = MSSUCC ; sts = OM_S_SUCCESS ;

	wrapup :
		return sts ;

} /* VSdrwGetViewTypeFromConst */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;

