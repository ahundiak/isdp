/*
	I/STRUCT
*/
class implementation EMSsurface ;

#include <math.h>
#include "OMmacros.h"
#include "msdef.h"
#include "ms.h"
#include "msmacros.h"
#include "bserr.h"
#include "bstypes.h"
#include "bsparameters.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EMSssprops.h"
#include "EMSopt.h"
#include "vsglobalmsg.h"
#include "vspart.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "maidmx.h"
#include "matypemx.h"
#include "bsnorvec.h"
#include "vschgsymb.h"
#include "vsioproto.h"
#include "vsvecmxproto.h"

from EMSplane import EMplaneDef ;
from EMSsubbs import EMget_props ;
/*----------------------------------------------------------------------------*/
long VSmake_offset_surface( msg, surfEnv, surfId, offset, isPlanar, isNatNorm,
				cst, offSfId )

/*
 * Creates an offset surface:
 * If input surface is planar, copy input surface then translate it, else
 * generate an offset surface.
 * If the value of the offset less than the offset tolerance, then just copies
 * input surface.
 *
 * This function is interfaced by vs$make_offset_surface.
 */

long			*msg ;
struct GRmd_env		*surfEnv ;
struct GRid		*surfId,
			*offSfId ;
struct GRvg_construct	*cst ;
int			isNatNorm,
			isPlanar ;
double			offset ; {

	long		sts ;		/* OM return code		*/
	struct IGRplane	planeDef ;	/* Plane definition if planar	*/
	IGRpoint	ptOnPlane ;	/* Point on plane		*/
	IGRvector	normal ;	/* Normal to plane		*/
	double		offTol ;	/* System's offset tolerance	*/
	unsigned char	props ; 	/* Properties of input surface. */
	int		chgPrpSymb ;

	chgPrpSymb = FALSE ; offSfId->objid = NULL_OBJID ;

	sts = om$send( msg	= message EMSsubbs.EMget_props( msg,
								&props ),
		       senderid = surfId->objid,
		       targetid = surfId->objid,
		       targetos = surfId->osnum ) ;
	__CheckRC( sts, *msg, "EMSsubbs.EMget_props", wrapup ) ;

	if( props & EMSIS_NRML_REVERSED ) offset = - offset ;

	if( isPlanar == -1 || isPlanar == TRUE ) {
		/*
		 * We do not know...
		 */
		planeDef.point	= ptOnPlane ;
		planeDef.normal	= normal ;
		sts = om$send(	msg	= message EMSplane.EMplaneDef(
							msg,
							&surfEnv->_MATRIX_TYPE,
							surfEnv->_MATRIX,
							&planeDef ),
				senderid= surfId->objid,
				targetid= surfId->objid,
				targetos= surfId->osnum ) ;
		if( !( sts & 1 & *msg ) ) {
			isPlanar = FALSE ;
		} else {
			isPlanar = TRUE ;
		}
	}

	BSEXTRACTPAR( msg, BSTOLOFFSET, offTol ) ;

	offSfId->osnum = cst->env_info->_MD_OS ;

	if( isPlanar ) {
		IGRvector	offVect ;
		IGRmatrix	idMx,
				translation ;
		short		mxType ;

		/*
		 * Copy then translate.
		 */
		sts = om$send(	msg      = message GRgraphics.GRcopy(
	   						msg,
                                                        surfEnv,
							cst->env_info,
                                                        &offSfId->objid ),
				senderid= surfId->objid,
			 	targetid= surfId->objid,
			 	targetos= surfId->osnum ) ;
		__CheckRC( sts, *msg, "GRgraphics.GRcopy", wrapup ) ;

		if( fabs( offset ) >= offTol ) {

			BSnorvec( msg, normal ) ;
			if( !isNatNorm ) offset = -offset ;
			VSscalvc( offset, normal, offVect ) ;
			MAidmx( msg, idMx ) ;
			VStranslatemx( offVect, idMx, translation ) ;
			MAtypemx( msg, translation, &mxType ) ;

			sts = om$send(	msg	= message GRgraphics.GRxform(
							msg,
							cst->env_info,
							&mxType,
							translation,
							&offSfId->objid ),
					senderid= offSfId->objid,
					targetid= offSfId->objid,
					targetos= offSfId->osnum ) ;
			__CheckRC( sts, *msg, "GRgraphics.GRxform", wrapup ) ;

			chgPrpSymb = TRUE ;
		}
	} else {
		if( fabs( offset ) >= offTol ) {
			/*
			 * In EMS 3.0,  EMSsurface.EMoffset no longer accepts
			 * negative offset distances...
			 */
			if( offset < 0 ) {
				offset = - offset ;
				isNatNorm = !isNatNorm ;
			}
			sts = om$send(
		 	msg	= message EMSsurface.EMoffset(
	 				msg,
	 				EMS_opt_offsetS_copy_topology,
 					&surfEnv->_MATRIX_TYPE,
 					surfEnv->_MATRIX,
 					cst,
	 				isNatNorm,
 					offset,
 					0,
 					(double *) NULL,
 					(struct GRobjid_set *) NULL,
 					0,
 					(GRobjid *) NULL,
 					VSmsgkey2string( VS_gI_Processing ),
	 				&offSfId->objid,
	 				(struct EMSerror_help *) NULL ),
			senderid= surfId->objid,
		 	targetid= surfId->objid,
		 	targetos= surfId->osnum ) ;
			__CheckRC( sts, *msg, "EMSsurface.EMgen_offset_surf", wrapup );
		} else {
			sts = om$send(	msg      = message GRgraphics.GRcopy(
	   						msg,
                                                        surfEnv,
							cst->env_info,
                                                        &offSfId->objid ),
					senderid= surfId->objid,
			 		targetid= surfId->objid,
			 		targetos= surfId->osnum ) ;
			__CheckRC( sts, *msg, "GRgraphics.GRcopy", wrapup ) ;

			chgPrpSymb = TRUE ;
		}
	}
	if( chgPrpSymb ) {

		/*
		 * Change symbology and properties of object.
		 */
		VSchgSymbAndProps( msg, offSfId, cst->level, cst->display,
					cst->properties ) ;
	}

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			vs$bulk_delete(	count	= 1,
					grids	= offSfId,
					theEnv	= cst->env_info ) ;
		}
		return sts ;

} /* VSmake_offset_surface */
/*----------------------------------------------------------------------------*/

end implementation EMSsurface ;
