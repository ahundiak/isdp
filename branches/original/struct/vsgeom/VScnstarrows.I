/*
	I/STRUCT
*/
class implementation GRcurve ;

#include <stdio.h>
#include "OMminimum.h"
#include "msdef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "growner.h"
#include "bstypes.h"
#include "bserr.h"
#include "vsdef.h"
#include "vs.h"
#include "vspart.h"
#include "vsglobals.h"
#include "vsdpb.h"
#include "vsdpbmacros.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bsarclength.h"
#include "vsvecmxproto.h"
/*----------------------------------------------------------------------------*/
long VScnstBeamArrowHeads( msg, surfId, surfGeom, curveId, curveGeom, cst,
					viewIndep, startArw, endArw )

/*
 * This function interfaced by macro vs$cnstBeamArrowHeads.
 */
long			*msg ;
struct GRobj_env	*surfId,
			*curveId ;
struct IGRbsp_surface	*surfGeom ;
struct IGRbsp_curve	*curveGeom ;
struct GRvg_construct	*cst ;
int			viewIndep ;
struct GRid   		*startArw;
struct GRid   		*endArw ; {

	long		sts ;		/* OM return code		*/
	IGRpoint	pntAtX ;	/* Point on support curve	*/
	IGRvector	tanAtX,		/* Vector tangent to curve	*/
			normAtX,	/* Vector normal to surface	*/
			xvecAtX,	/* Cross product of norm. & tan.*/
			auxvec ;
	double		length,
			arwSize ;
	struct GRvg_construct
			arwCst ;	/* Construction list of arrows	*/

        /*
         * Get CS from curve and surface.
         */
	sts = vs$getCS_from_cv_and_sf(	msg		= msg,
        				surface		= surfId,
        				surfGeom	= surfGeom,
        				curve		= curveId,
        				curveGeom	= curveGeom,
        				pntParm		= 0., /* Start point */
        				origin		= pntAtX,
        				tangent		= tanAtX,
        				normal		= normAtX,
        				binormal	= xvecAtX ) ;
	__CheckRC( sts, *msg, "vs$getCS_from_cv_and_sf", wrapup ) ;

	/*
	 * Get arrow size form DPB.
	 */
	vs$get_beam_arrow_size( msg = msg, p_size = &arwSize ) ;

	if( !( *msg & 1 ) || arwSize <= 0. ) {
		/*
		 * Get length of curve as a characteristic length for arrow
		 * heads. Set `arwSize' so it won't be used.
		 * Note that if curve length computation fails, `arwSize' is set
		 * back to 1, so arrow head construction function will take it
		 * into account and disregard `length'.
		 */
		arwSize = -1 ;

		if( curveGeom ) {
			double U0 = 0., U1 = 1. ;

			BSarclength( msg, curveGeom, &U0, &U1, &length ) ;
			if( !BSOKAY( *msg ) ) arwSize = 1 ;
		} else {
			sts = om$send(	msg	= message GRcurve.GRtotlength(
						msg,
						&curveId->_matrix_type,
						curveId->_matrix,
						&length ),
					senderid= curveId->_objid,
					targetid= curveId->_objid,
					targetos= curveId->_osnum ) ;
			if( !( sts & 1 & *msg ) ) arwSize = 1 ;
		}
			
	}

	vs$fill_cnst_list(	Msg		= msg,
				Env_info	= cst->env_info,
				Display		= cst->display,
				Level		= cst->level,
				Cnst_list	= arwCst ) ;

	/*
	 * Place starting arrow.
	 */
	VSnegvc( tanAtX, auxvec ) ;
	sts = VScstArrowHead(	msg,
				pntAtX,
				auxvec,
				xvecAtX,
				&arwCst,
				arwSize,
				length,
				viewIndep,
				startArw ) ;
	__CheckRC( sts, *msg, "VScstArrowHead", wrapup ) ;

        /*
         * Get CS from curve and surface
         */
	sts = vs$getCS_from_cv_and_sf(	msg		= msg,
        				surface		= surfId,
        				surfGeom	= surfGeom,
        				curve		= curveId,
        				curveGeom	= curveGeom,
        				pntParm		= 1., /* End point */
        				origin		= pntAtX,
        				tangent		= tanAtX,
        				normal		= normAtX,
        				binormal	= xvecAtX ) ;
        __CheckRC( sts, *msg, "vs$getCS_from_cv_and_sf", wrapup ) ;

	/*
	 * Place ending arrow.
	 */
	VSnegvc( xvecAtX, auxvec ) ;
	sts = VScstArrowHead(	msg,
				pntAtX,
				tanAtX,
				auxvec,
				&arwCst,
				arwSize,
				length,
				viewIndep,
				endArw ) ;
	__CheckRC( sts, *msg, "VScstArrowHead", wrapup ) ;

	wrapup :
		return sts ;

} /* VScnstBeamArrowHeads */
/*----------------------------------------------------------------------------*/

end implementation GRcurve ;
