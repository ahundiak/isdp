/* $Id: VSfndbmxt2sf.I,v 1.1.1.1 2001/01/04 21:10:12 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsbeam/VSfndbmxt2sf.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSfndbmxt2sf.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:12  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.4  1998/01/21  19:35:18  pinnacle
# TR179702512
#
# Revision 1.3  1998/01/21  17:01:20  pinnacle
# TR179702512
#
# Revision 1.2  1997/09/29  14:50:32  pinnacle
# TR179700969
#
 *
 * History:
 *      MM/DD/YY AUTHOR	DESCRIPTIO
 *      09/26/97 ah     added header
 *      09/29/97 ah	TR179700969 Cardinal Point 
 *      01/21/98 ah     TR179702512 Web Alignment Problem
 ***************************************************************************/

class implementation VSbeam ;

#include "bstypes.h"
#include "bsparameters.h"
#include "bserr.h"
#include "EMSmsgdef.h"
#include "vssplitdef.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "maaddvc.h"
#include "malnplise.h"
#include "bscveval.h"
#include "bsdistptpt.h"
#include "bsdistptpts.h"
#include "bsdotp.h"
#include "bsmdistcvsf.h"
#include "bsmkvec.h"
#include "bspj_pt_sf.h"
#include "bssfnormal.h"
#include "vsbeamproto.h"
#include "vscvepnearsf.h"
#include "vsintcvsf.h"
#include "vsvecmxproto.h"

extern long VSbeamGetState(struct GRid *beamId, int *state);

/*----------------------------------------------------------------------------*/
long VSprjPtOnPl( msg, point, plane, prjVector, prjPoint )

long			*msg ;
IGRpoint		point,
			prjPoint ;
IGRvector		prjVector ;
struct IGRbsp_surface	*plane ; {

	struct IGRplane	plDef ;
	IGRvector	normal ;
	struct IGRline	lnDef ;
	IGRpoint	otherPoint ;
	double		prjParm,
			distTol ;

	plDef.normal	= normal ;
	plDef.point	= plane->poles ;

	BSsfnormal( plane, normal, msg ) ;
	if( BSERROR( *msg ) ) { *msg = EMS_E_BSerror ; goto wrapup ; }

	lnDef.point1	= point ;
	lnDef.point2	= otherPoint ;

	MAaddvc( msg, point, prjVector, otherPoint ) ;

	BSEXTRACTPAR( msg, BSTOLLENVEC, distTol ) ;
	MAlnplisect( msg, &lnDef, &plDef, &distTol, prjPoint, &prjParm ) ;

	*msg = MSSUCC ;

	wrapup :
		return *msg & 1 ;

} /* VSprjPtOnPl */
/*----------------------------------------------------------------------------*/
long VSprjPtOnSf( msg, point, surface, isPlanar, considerPlaneAsInfinite,
		  prjVector, prjPoint )

long			*msg ;
IGRpoint		point,
			prjPoint ;
IGRvector		prjVector ;
struct IGRbsp_surface	*surface ;
int			isPlanar,
			considerPlaneAsInfinite ; {

	long		nbPjPnts= 0 ;
	IGRpoint	*pjPnts	= NULL ;
	double		*uPjPnts= NULL,
			*vPjPnts= NULL ;
			
	if( isPlanar && considerPlaneAsInfinite ) {
		VSprjPtOnPl( msg, point, surface, prjVector, prjPoint ) ;
	} else {
		int	index = 0 ;

		BSpj_pt_sf(	surface,
				point,
				prjVector,
				&nbPjPnts,
				&pjPnts,
				&uPjPnts,
				&vPjPnts,
				msg ) ;
		if( BSERROR( *msg ) ) { *msg = EMS_E_BSerror ; goto wrapup ; }

		if( nbPjPnts > 1 ) {
			/*
			 * Take point closest to input point.
			 */
			int	i,
				iMin = 0 ;
			double	dSq,
				dMinSq = -1 ;

			for( i = 0 ; i < nbPjPnts ; i++ ) {
				dSq = BSdistptpts( msg, point, pjPnts[i] ) ;
				if( dSq < dMinSq ) {
					 dMinSq	= dSq ;
					 iMin	= i ;
				}
			}
			index = iMin ;
		}
		VSvccpy( prjPoint, pjPnts[index] ) ;
	}

	*msg = MSSUCC ;

	wrapup :
		_FREE( pjPnts ) ; _FREE( uPjPnts ) ; _FREE( vPjPnts ) ;
		return *msg & 1 ;

} /* VSprjPtOnSf */
/*----------------------------------------------------------------------------*/
long VSfindBmAxisExtToEnterSurf( msg, beam, bmAxis, surface, nearEnd, dist )

long			*msg ;
struct GRobj_env	*beam,		/* Input beam			*/
			*bmAxis,	/* Axis of input beam		*/
			*surface ;	/* Input surface		*/
int			nearEnd ;	/* Near which end of axis is sf?*/
double			*dist ; {	/* Output distance		*/

	/*
	 * Given a surface intersecting an axis, evaluates the point on the
	 * axis at which the beam should start that it will fully penetrate
	 * this surface. If beam already penetrates the surface then 0. is
	 * returned.
	 * This algorithm will only work if the surface is not very  much curved
	 * and is reasonably near one end of the beam, and also if the beam
	 * is not very much curved.
	 */

	long		sts ;		/* OM return code		*/
	struct IGRbsp_surface
			*surfGeom ;	/* Geometry of input surface	*/
	struct IGRbsp_curve
			*axisGeom ;	/* Geometry of input axis	*/
	double		endPm,		/* Parameter of end pnt of axis	*/
			eval[6],	/* For BScveval()		*/
			d,		/* One distance			*/
			maxDist ;	/* Max dist( end stfnr, surf )	*/
	IGRmatrix	xCS ;		/* Profile CS			*/
	struct GRid	xDef ;		/* Profile definition		*/
	IGRpoint	endPt,		/* End point of axis		*/
			prjPoint[4],	/* Projection of above onto surf*/
			rectPt[4] ;	/* Rectangle points		*/
	IGRvector	prjVect,	/* Projection vector		*/
			pntToPrj ;	/* Point-to-its projection	*/
	int		i,		/* Your favorite loop index	*/
			iMax,		/* Index of pnt where dst is max*/
			isPlanar ;	/* Is input surface planar ?	*/
	struct GRmd_env	*bmEnv ;	/* Short cut			*/
	VSsuppList	bmSupps ;	/* Supports of beam		*/


	/*
	 * Init stuff.
	 */
	surfGeom	= NULL ;
	axisGeom	= NULL ;
	bmEnv		= &beam->mod_env ;

	sts = VSintersectCurveAndSurface(	msg,
						&bmAxis->_grid,
						&bmAxis->mod_env,
						&surface->_grid,
						&surface->mod_env,
						TRUE,
						endPt,
						&endPm ) ;
	if( !( sts & 1 & *msg ) ) {
		*dist = 0 ; *msg = MSSUCC ; sts = OM_S_SUCCESS ; goto wrapup ;
	}
						
	/*
	 * Compute coordinate system of profile at beam axis parameter
	 * `endPm'.
	 */
	sts = om$send(	msg	= message VSpart.VSgetSupports(
					msg, &beam->mod_env, &i, bmSupps ),
			senderid= beam->_objid,
			targetid= beam->_objid,
			targetos= beam->_osnum ) ;
	__CheckRC( sts, *msg, "VSpart.VSgetSupports", wrapup ) ;

	sts = om$send(	msg	= message VSbeam.VSgetCrossSectionCS(
								msg,
								bmEnv,
								bmSupps + 0,
								bmAxis,
								endPm,
								&xDef,
								xCS ),
			senderid= beam->_objid,
			targetid= beam->_objid,
			targetos= beam->_osnum ) ;
	__CheckRC( sts, *msg, "VSbeam.VSgetCrossSectionCS", wrapup ) ;

	/*
	 * Evaluate co-ordinates of the four points of the rectangle surrounding
	 * the profile :
	 *	rectPt[0]		rectPt[3]
	 *		+---------------+
	 *		|		|
	 *		+-----+   +-----+
	 *		      |   |
	 *		      |   |
	 *		      |   |
	 *		+-----+   +-----+
	 *		|		|
	 *		+---------------+
	 *	rectPt[1]		rectPt[2]
	 *
	 * They are first evaluate at the location of the cached profile
	 * definition (at the origin in the xy-plane z=0), then mapped to
	 * the site.
	 */

// TR179700969
/* TR179702512 */
/* TR179702512 */
  {	
    IGRboolean  cardOpt = FALSE ;
    int         state ;

    VSbeamGetState(&beam->obj_id,&state);
    if( state & VS_m_NdState ) cardOpt = TRUE ;

    sts = VScardpt_to_point( bmEnv, xDef, &cardOpt, VS_e_BOT_LEFT, rectPt[0] ) ;
    sts = VScardpt_to_point( bmEnv, xDef, &cardOpt, VS_e_BOT_RGHT, rectPt[1] ) ;
    sts = VScardpt_to_point( bmEnv, xDef, &cardOpt, VS_e_UPP_LEFT, rectPt[2] ) ;
    sts = VScardpt_to_point( bmEnv, xDef, &cardOpt, VS_e_UPP_RGHT, rectPt[3] ) ;
  }

	/*
	 * Map points to the end of the beam axis.
	 */
	for( i = 0 ; i < 4 ; i++ ) {
	        VSmxprodpt( xCS, rectPt[i], rectPt[i] ) ;
        }
        
	/*
	 * Get geometry of the input surface and input axis.
	 */
	vs$get_geometry(	msg	= msg,
				grobjId	= &surface->_grid,
				grobjEnv= &surface->mod_env,
				geometry= &surfGeom ) ;
	__CheckRC( 1, *msg, "vs$get_geometry", wrapup ) ;
	
	isPlanar = vs$is_surface_planar( msg	  = msg,
					 surfId	  = &surface->_grid,
				         surfEnv  = &surface->mod_env,
				         surfGeom = surfGeom ) ;
	__CheckRC( 1, *msg, "vs$is_surface_planar", wrapup ) ;

	vs$get_geometry(	msg	= msg,
				grobjId	= &bmAxis->_grid,
				grobjEnv= &bmAxis->mod_env,
				geometry= &axisGeom ) ;
	__CheckRC( 1, *msg, "vs$get_geometry", wrapup ) ;
	
	/*
	 * Calculate projection vector. It's equal to tangent of axis at 
	 * the intersection point.
	 */
	BScveval( axisGeom, endPm, 1, (IGRpoint *) eval, msg ) ;
	if( BSERROR( *msg ) ) { *msg = EMS_E_BSerror ; goto wrapup ; }

		/*
		 * Caution: tangent vectors go from 0. to 1.
		 */
	if( nearEnd == 0 )	VSnegvc( eval + 3, prjVect ) ;
	else			VSvccpy( prjVect, eval + 3 ) ;

        /*
         * Project rectangle points onto surface.
         */
	for( i = 0 ; i < 4 ; i++ ) {
		sts = VSprjPtOnSf(	msg,
					rectPt[i],
					surfGeom,
					isPlanar,
					TRUE,
					prjVect,
					prjPoint[i] ) ;
		__CheckRC( sts, *msg, "VSprjPtOnSf", wrapup ) ;
	}
	
	/*
	 * Find max distance between rectangle point to corresponding
	 * projected point.
	 */
	maxDist = -1 ; iMax = 0 ;
	for( i = 0 ; i < 4 ; i++ ) {
		/* Flag '0' below means dist pt-pt */

		d = BSdistptpt( msg, rectPt[i], prjPoint[i] ) ;

		if( d > maxDist ) { maxDist = d ; iMax = i ; }
	}

	/*
	 * Evaluate vector rectP[iMax] --> prjPoint[iMax] if its dot product
	 * with prjVect is > 0 then beam does not go beyond surface, else it 
	 * does (and there nothing to be done).
	 */ 
	BSmkvec( msg, pntToPrj, rectPt[iMax], prjPoint[iMax] ) ;

	if( BSdotp( msg, pntToPrj, prjVect ) < 0 ) {
		*dist = 0 ;
	} else {
		*dist = 2 * maxDist ;
	}

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		_FREE( surfGeom ) ; _FREE( axisGeom ) ;
		return sts ;

} /* VSfindBmAxisExtToEnterSurf */
/*----------------------------------------------------------------------------*/
long VSfindBmAxisExtToEnterSurfaces( msg, beam, bmAxis, sfA, sfB, distA, distB )

long			*msg ;
struct GRobj_env	*beam,		/* Input beam		*/
			*bmAxis,	/* Axis of input beam	*/
			*sfA,		/* Input surface	*/
			*sfB ;		/* Input surface	*/
double			*distA,
			*distB ; {	/* Output distances	*/

	long			sts ;
	IGRpoint		pntA,
				pntB ;
	double			parmA,
				parmB,
				oneParm,
				*oneDist	= NULL,
				*twoDists[2] ;
	struct GRobj_env	*oneSf		= NULL,
				*twoSfs[2] ;
				
	/*
	 * Find intersection pointwith surface A.
	 */
	sts = VSintersectCurveAndSurface(	msg,
						&bmAxis->_grid,
						&bmAxis->mod_env,
						&sfA->_grid,
						&sfA->mod_env,
						TRUE,
						pntA,
						&parmA ) ;
	if( !( sts & 1 & *msg ) ) parmA = -1 ;

	/*
	 * Find intersection pointwith surface B.
	 */
	sts = VSintersectCurveAndSurface(	msg,
						&bmAxis->_grid,
						&bmAxis->mod_env,
						&sfB->_grid,
						&sfB->mod_env,
						TRUE,
						pntB,
						&parmB ) ;
	if( !( sts & 1 & *msg ) ) parmB = -1 ;
	
	/*
	 * See what distance should be calculate.
	 */
	if( parmA == -1 ) {
		*distA = 0 ;
		if( parmB == -1 ) {
			*distB = 0 ;
			sts = OM_S_SUCCESS ; *msg = MSSUCC ; goto wrapup ;
		} else {
			oneDist	= distB ; oneSf	= sfB ; oneParm = parmB ;
		}
	} else {
		if( parmB == -1 ) {
			*distB	= 0 ;
			oneDist	= distA ; oneSf	= sfA ; oneParm = parmA ;
		} else {
			if( parmA < parmB ) {
				twoDists[0] = distA ; twoSfs[0] = sfA ;
				twoDists[1] = distB ; twoSfs[1] = sfB ;
			} else {
				twoDists[0] = distB ; twoSfs[0] = sfB ;
				twoDists[1] = distA ; twoSfs[1] = sfA ;
			}
				
		}
	}
	
	/*
	 * Calculate distance.
	 */
	if( oneSf ) {
		/*
		 * Only one surface involved: find to which end of axis it
		 * is.
		 */
		double			nearEnd ;
		IGRpoint		nearEndPt ;

		sts = VSfindCvEndPtNearestToSf(
				msg,
				bmAxis,
				oneSf,
				TRUE, /* If planar, consider infinite */
				nearEndPt,
				&nearEnd ) ;
		__CheckRC( sts, *msg, "VSfindCvEndPtNearestToSf", wrapup ) ;

		sts = VSfindBmAxisExtToEnterSurf(	msg,
							beam,
							bmAxis,
							oneSf,
							(int) nearEnd,
							oneDist ) ;
		__CheckRC( sts, *msg, "VSfindBmAxisExtToEnterSurf", wrapup ) ;

	} else /* Two surfaces */ {
		/*
		 * First is near parm 0. of axis.
		 */
		sts = VSfindBmAxisExtToEnterSurf(	msg,
							beam,
							bmAxis,
							twoSfs[0],
							0,
							twoDists[0] ) ;
		__CheckRC( sts, *msg, "VSfindBmAxisExtToEnterSurf", wrapup ) ;

		sts = VSfindBmAxisExtToEnterSurf(	msg,
							beam,
							bmAxis,
							twoSfs[1],
							1,
							twoDists[1] ) ;
		__CheckRC( sts, *msg, "VSfindBmAxisExtToEnterSurf", wrapup ) ;
	}

	wrapup :
		return sts ;

} /* VSfindBmAxisExtToEnterSurfaces */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;

