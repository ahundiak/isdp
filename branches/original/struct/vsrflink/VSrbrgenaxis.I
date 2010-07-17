/* $Id: VSrbrgenaxis.I,v 1.1.1.1 2001/01/04 21:10:56 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/vsrflink/VSrbrgenaxis.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSrbrgenaxis.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:56  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1998/03/27  14:01:40  pinnacle
# Replaced: vsrflink/VSrbrgenaxis.I for:  by manoj for struct
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.2  1996/01/31  08:08:20  pinnacle
# Replaced: vsrflink/VSrbrgenaxis.I for:  by svkadamb for struct
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

#include <string.h>
#include <stdlib.h>
#define _INGR_EXTENSIONS
#include <math.h>
#include <values.h>
#include "ma.h"
#include "grimport.h"
#include "bstypes.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSssprops.h"
#include "vsbeammacros.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"
#include "DImacros.h"
/*
 * Includes of function prototypes.
 */
#include "bsalloccv.h"
#include "bsconstprcv.h"
#include "bscrossp.h"
#include "bscveval.h"
#include "bsdotp.h"
#include "bsnorvec.h"
#include "bssfevaln.h"
#include "bsfreecv.h"
#include "matrlmx.h"
#include "matypemx.h"
#include "vsmkgrobjtmp.h"
#include "vsstrngproto.h"
#include "vsvecmxproto.h"

from EMSsubbs	import	EMget_props,
			EMisoparcvs ;
from GRcurve	import	GRendpts ;

extern long	VScopyBeamFaceForSupport() ;
/*----------------------------------------------------------------------------*/
long VSisBeamProfileOrientedClockwise( msg, bmId, clockwise )

long		*msg ;
struct GRid	*bmId ;
int		*clockwise ; {

	long			sts ;
	struct GRid		profileDef ;
	struct GRobj_env	grSection ;
	IGRpoint		positiveZ ;

	*clockwise = TRUE ;

	sts = om$send( msg	= message VSbeam.VSgetProfileDef( msg,
								  &profileDef ),
		       senderid = bmId->objid,
		       targetid = bmId->objid,
		       targetos = bmId->osnum ) ;

	__CheckRC( sts, *msg, "VSbeam.VSgetProfileDef", wrapup ) ;

	sts = vs$get_graphic_section( msg	     = msg,
				      sectDef	     = &profileDef,
				      representation = AC_3D_REP,
				      section	     = &grSection ) ;

	__CheckRC( sts, *msg, "vs$get_graphic_section", wrapup ) ;

	positiveZ[0] = 0 ;
	positiveZ[1] = 0 ;
	positiveZ[2] = 1 ;

	sts = vs$isPlanarCurveClockwise( msg		= msg,
					 cvId		= &grSection._grid,
					 cvEnv		= &grSection.mod_env,
					 refVector	= positiveZ,
					 isClockwise	= clockwise ) ;

	__CheckRC( sts, *msg, "vs$isPlanarCurveClockwise", wrapup ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		return sts ;

} /* VSisBeamProfileOrientedClockwise */
/*----------------------------------------------------------------------------*/
long VSgetIsoAtU( msg, sfEnv, sfId, U, cst, isoId )

long			*msg ;
struct GRid		*sfId ;
struct GRmd_env 	*sfEnv ;
double			U ;
struct GRvg_construct	*cst ;
struct GRid		*isoId ; {

	long			sts ;		/* OM return code	*/
	OM_S_OBJID		*isosAtU ;	/* Isos at U=0		*/
	long			nbCrvs ;	/* # of isos at U=0	*/

	isosAtU = NULL ;
	nbCrvs	= 0 ;

	sts = om$send(	msg	= message EMSsubbs.EMisoparcvs(
						msg,
						&sfEnv->_MATRIX_TYPE,
						sfEnv->_MATRIX,
						cst,
						FALSE, /* Trim to boundaries ?*/
						1,
						&U,
						TRUE, /* in u-direction */
						&nbCrvs,
						&isosAtU ),
			senderid= NULL_OBJID,
			targetid= sfId->objid,
			targetos= sfId->osnum ) ;
	__CheckRC( sts, *msg, "EMSsubbs.EMisoparcvs", wrapup ) ;

	__DBGpr_int( "Number of isos found", nbCrvs ) ;

	if( !nbCrvs ) vs$failure() ;

	isoId->objid = isosAtU[0] ;
	isoId->osnum = cst->env_info->_MD_OS ;

	sts = VSmakeGraphicObjectTemporary( msg, isoId, TRUE ) ;

	wrapup :
		if( nbCrvs && isosAtU ) _FREE( isosAtU ) ;
		return sts ;

} /* VSgetIsoAtU */
/*----------------------------------------------------------------------------*/
long VSgetLocalBeamCS( msg, faceId, faceEnv, U, origin, xvec, yvec, zvec )

long			*msg ;
struct GRid		*faceId ;
struct GRmd_env 	*faceEnv ;
double			U ;
IGRpoint		origin ;
IGRvector		xvec,
			yvec,
			zvec ; {

	long			sts ;		/* OM return code	*/
	BSrc			bsRC ;
	struct IGRbsp_surface	*sfGeom ;
	int			nb_nrm ;	/* # of normals on surface  */
	struct IGRbsp_curve	*isoAtU0 ;
	IGRboolean		testPlanarity ;
	IGRpoint		eval[2] ;
	unsigned char		props ; 	/* Surface-specific props  */
	short			_1 = 1 ;

	isoAtU0 = NULL ;
	sfGeom	= NULL ;

	sts = vs$get_geometry(	msg	= msg,
				grobjId = faceId,
				grobjEnv= faceEnv,
				geometry= &sfGeom ) ;
	__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

	BSsfevaln( sfGeom,		 /* IN	: surface geometry	*/
		   U,			 /* IN	: u of evaluation	*/
		   0.,			 /* IN	: v of evaluation	*/
		   1,			 /* IN	: u-left/v-left normal	*/
		   &nb_nrm,		 /* OUT : actual # of normals	*/
		   origin,		 /* OUT : point at u, v 	*/
		   (IGRvector *) yvec,	 /* OUT : normal at u, v	*/
		   &bsRC ) ;
	if( BSERROR( bsRC ) ) { *msg = MSFAIL ; goto wrapup ; }

	BSalloccv(	sfGeom->v_order,
			sfGeom->v_num_poles,
			sfGeom->rational,
			0,
			&isoAtU0,
			&bsRC ) ;
	if( BSERROR( bsRC ) ) { *msg = MSFAIL ; goto wrapup ; }

	testPlanarity = FALSE ;
	BSconstprcv(	&bsRC,
			sfGeom,
			&_1,
			&U,
			&testPlanarity,
			isoAtU0 ) ;
	if( BSERROR( bsRC ) ) { *msg = MSFAIL ; goto wrapup ; }

	BScveval(	isoAtU0,
			0.,
			1,	      /* nb of derivatives */
			(IGRpoint *) eval,
			&bsRC ) ;

	/*
	 * Note : on the contrary to the standard for solid normals, we consider
	 * the normal pointing outside, just in case the support surface is a
	 * face of a solid so the computed CS is outside of the solid. For
	 * surfaces the CS will be on the side of the opposite of the surface's
	 * natural normal it it hasn't been reversed.
	 */
	sts = om$send(	msg	= message EMSsubbs.EMget_props( msg, &props ),
			senderid= NULL_OBJID,
			targetid= faceId->objid,
			targetos= faceId->osnum ) ;
	__CheckRC( sts, *msg, "EMSsubbs.EMget_props", wrapup ) ;

	if( ! ( props & EMSIS_NRML_REVERSED ) ) {
		VSnegvc( yvec, yvec ) ;
	}
	VSvccpy( zvec, eval[1] ) ;
	BSnorvec( &bsRC, yvec  ) ;
	BSnorvec( &bsRC, zvec ) ;
	BScrossp( &bsRC, yvec, zvec, xvec ) ;

	wrapup :
		_FREE( sfGeom ) ;
		if( isoAtU0 ) BSfreecv( &bsRC, isoAtU0 ) ;

		return sts ;

} /* VSgetLocalBeamCS */
/*----------------------------------------------------------------------------*/
long VSgetBmFaceClosestToSuppSf( msg, bmId, bmEnv, surface, faceName )

long			*msg ;
struct GRid		*bmId ;
struct GRmd_env 	*bmEnv ;
struct GRobj_env	*surface ;
GRname			faceName ; {

	long			sts ;		/* OM return code	*/
	BSrc			bsRC ;
	struct IGRbsp_surface	*sfGeom,
				*faceGeom ;
	long			*faceDescrs ;
	char			**faceNames ;
	int			faceCount,
				i,
				iMinDist ;
	struct GRid		faceId ;
	struct IGRbsp_curve	*isoUGeom ;
	short			_1 = 1 ;
	IGRboolean		testPlanarity ;
	double			U,
				dIsoSf1,
				dIsoSf2,
				minDist1,
				minDist2,
				distTol ;
	int			num ;
	double			*Tpar,
				*UVpar ;
	IGRpoint		*cvPt,
				*sfPt ;

	sfGeom		= faceGeom	= NULL ;
	faceCount	= 0 ;
	faceDescrs	= NULL ;
	faceNames	= NULL ;
	isoUGeom	= NULL ;
	testPlanarity	= FALSE ;

	sts = vs$get_geometry(	msg	= msg,
				grobjId = &surface->_grid,
				grobjEnv= &surface->mod_env,
				geometry= &sfGeom ) ;
	__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

	{ GRname nm ;
	  int	 j ;
	  sts = vs$listBeamFaces(	msg	= msg,
					beam	= bmId,
					count	= &faceCount,
					names	= &faceNames,
					descrs	= &faceDescrs ) ;
	  __CheckRC( sts, *msg, "vs$listBeamFaces", wrapup ) ;

	  /*
	   * Face `VS_K_nmFlgInfE' is most often the closest one, make it be
	   * tested first then...
	   */
	  DIstmcpy( nm, VS_K_bmGrCmpName, VS_K_bmBody, VS_K_nmFlgInfE, NULL ) ;
	  for( j = 0 ; j < faceCount ; j++ ) {
	    if( !strcmp( nm, faceNames[j] ) ) {
	      strcpy( faceNames[j], faceNames[0] ) ;
	      strcpy( faceNames[0], nm ) ;
	      break ;
	    }
	  }
	}
	/*
	 * We do not need these here...
	 */
	_FREE( faceDescrs ) ; faceDescrs = NULL ;

	minDist1 = minDist2 = MAXDOUBLE ; iMinDist = -1 ;

	BSEXTRACTPAR( &bsRC, BSTOLLENVEC, distTol ) ;

	for( i = 0 ; i < faceCount ; i++ ) {
		/*
		 * Bypass end caps, we only want body faces.
		 */
		extern char DIR_G_car_dir ;
		char	*p = strrchr( faceNames[i],  DIR_G_car_dir ) + 1 ;
		if(    !strcmp( p, VS_K_bmBeginCap )
		    || !strcmp( p, VS_K_bmEndCap   ) ) continue ;

		sts = om$send(	msg	= message NDmacro.ACreturn_foot(
								msg,
								faceNames[i],
								&faceId,
								NULL,
								NULL ),
				senderid= NULL_OBJID,
				targetid= bmId->objid,
				targetos= bmId->osnum ) ;

		/*
		 * EF 10/13/94 :
		 * May be the beam is in 2d rep...
		 */
		if( !( sts & 1 & *msg ) ) continue ;

		sts = vs$get_geometry(	msg	= msg,
					grobjId = &faceId,
					grobjEnv= bmEnv,
					geometry= &faceGeom ) ;
		__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

		BSalloccv(	faceGeom->v_order,
				faceGeom->v_num_poles,
				faceGeom->rational,
				0,
				&isoUGeom,
				&bsRC ) ;
		if( BSERROR( bsRC ) ) { *msg = MSFAIL ; goto wrapup ; }

		U = 0 ;
		BSconstprcv( &bsRC, faceGeom, &_1, &U, &testPlanarity, isoUGeom );
		if( BSERROR( bsRC ) ) { *msg = MSFAIL ; goto wrapup ; }

		Tpar = UVpar = NULL ; cvPt = sfPt = NULL ;
		BSmdistcvsf(	isoUGeom, sfGeom, &num, &Tpar, &UVpar,
				&cvPt, &sfPt, &dIsoSf1, &bsRC ) ;

		_FREE( Tpar ) ; _FREE( cvPt ) ; _FREE( UVpar) ; _FREE( sfPt ) ;
		Tpar = UVpar = NULL ; cvPt = sfPt = NULL ;

		U = 1 ;
		BSconstprcv( &bsRC, faceGeom, &_1, &U, &testPlanarity, isoUGeom );
		if( BSERROR( bsRC ) ) { *msg = MSFAIL ; goto wrapup ; }

		BSmdistcvsf(	isoUGeom, sfGeom, &num, &Tpar, &UVpar,
				&cvPt, &sfPt, &dIsoSf2, &bsRC ) ;

		_FREE( Tpar ) ; _FREE( cvPt ) ; _FREE( UVpar) ; _FREE( sfPt ) ;
		Tpar = UVpar = NULL ; cvPt = sfPt = NULL ;

		BSfreecv( &bsRC, isoUGeom ) ; isoUGeom = NULL ;
		_FREE( faceGeom ) ; faceGeom = NULL ;

		if( dIsoSf2 < dIsoSf1 ) {
			double tmp = dIsoSf1 ;
			dIsoSf1 = dIsoSf2 ;
			dIsoSf2 = tmp ;
		}
		if( dIsoSf1 <= minDist1 && dIsoSf2 <= minDist2 ) {
			minDist1 = dIsoSf1 ;
			minDist2 = dIsoSf2 ;
			iMinDist = i ;
			if( minDist1 <= distTol && minDist2 <= distTol ) {
				/*
				 * Can't get any closer !
				 */
				break ;
			}
		}
	}

	if( iMinDist != -1 ) {
		strcpy( faceName, faceNames[iMinDist] ) ;
	} else {
		/*
		 * EF 10/13/94 :
		 * We cannot found the face name. In most case, it's because
		 * the beam is in 2d rep and we cannot acces to its solid
		 * to find face component, so return the face `VS_K_nmFlgInfE'.
		 */
		DIstmcpy( faceName, VS_K_bmGrCmpName, VS_K_bmBody,
			  VS_K_nmFlgInfE, NULL ) ;
	}

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		_FREE( sfGeom ) ;
		/*
		 * If we erred in the for-loop, `isoUGeom' may not have been
		 * freed, same for `faceGeom'.
		 */
		if( isoUGeom ) BSfreecv( &bsRC, isoUGeom ) ;
		_FREE( faceGeom ) ;
		VSfreeList( faceCount, faceNames ) ;
		return sts ;

} /* VSgetBmFaceClosestToSuppSf */
/*----------------------------------------------------------------------------*/
long VSregenerateBeamAxis( msg, faceId, faceEnv, bmId, cst, delta, bmAxis )

long			*msg ;
struct GRid		*faceId ;
struct GRmd_env 	*faceEnv ;
struct GRid		*bmId ;
struct GRvg_construct	*cst ;
IGRvector		delta ;
struct GRid		*bmAxis ; {

	long			sts ;		/* OM return code	*/
	struct GRid		isoAtU0 ;
	IGRvector		deltaWorld ;
	IGRmatrix		trlMx ;
	short			mxType ;
	double			*envMx = faceEnv->_MATRIX ;
	int			clockwise ;

	bmAxis->objid = NULL_OBJID ;

	/*
	 * EF 09/09/09 :
	 * If the beam profile is oriented clockwise, we take the iso
	 * at u=1, otherwise at u=0.
	 */
	sts = VSisBeamProfileOrientedClockwise( msg, bmId, &clockwise ) ;
	__CheckRC( sts, *msg, "VSisBeamProfileOrientedClockwise", wrapup ) ;

	sts = VSgetIsoAtU( msg,
			   faceEnv,
			   faceId,
			   clockwise ? 1. : 0.,
			   cst,
			   &isoAtU0 ) ;
	__CheckRC( sts, *msg, "VSgetIsoAtU", wrapup ) ;

	VSmxprodvc( envMx, delta, deltaWorld ) ;

	deltaWorld[0] = -deltaWorld[0] ;
	deltaWorld[1] = -deltaWorld[1] ;
	deltaWorld[2] = -deltaWorld[2] ;

	MAtrlmx( msg, deltaWorld, trlMx ) ;
	MAtypemx( msg, trlMx, &mxType ) ;
	sts = om$send(	msg	= message GRgraphics.GRxform(
							msg,
							cst->env_info,
							&mxType,
							trlMx,
							&isoAtU0.objid ),
			senderid= NULL_OBJID,
			targetid= isoAtU0.objid,
			targetos= isoAtU0.osnum ) ;

	*bmAxis = isoAtU0 ;

	wrapup :
		return sts ;

} /* VSregenerateBeamAxis */
/*----------------------------------------------------------------------------*/
long VSgetDataForAxisRegeneration( msg, bmId, bmEnv, faceName, delta )

long			*msg ;
struct GRid		*bmId ;
struct GRmd_env 	*bmEnv ;
GRname			faceName ;
IGRvector		delta ; {

	long			sts ;		/* OM return code	*/
	struct GRid		faceId ;	/* Id of one face	*/
	VSsuppList		bmSupps ;	/* Supports of beam	*/
	int			count ;
	IGRpoint		endPt0OfAxis,
				endPt1OfAxis,
				origin ;
	IGRvector		zvec,
				yvec,
				xvec,
				deltaWorld ;
	struct GRobj_env	fromBeam ;
	int			clockwise ;

	faceId.objid = NULL_OBJID ;

	sts = om$send(	msg	= message VSpart.VSgetSupports(
						msg, bmEnv, &count, bmSupps ),
			senderid= NULL_OBJID,
			targetid= bmId->objid,
			targetos= bmId->osnum ) ;
	__CheckRC( sts, *msg, "VSpart.VSgetSupports", wrapup ) ;

	if( bmEnv->_MATRIX_TYPE != MAIDMX ) {
		VSmulmx( bmSupps[0]._matrix, bmEnv->_MATRIX,
			 bmSupps[0]._matrix, &bmSupps[0]._matrix_type ) ;
		VSmulmx( bmSupps[1]._matrix, bmEnv->_MATRIX,
			 bmSupps[1]._matrix, &bmSupps[1]._matrix_type ) ;
	}

	sts = VSgetBmFaceClosestToSuppSf( msg, bmId, bmEnv, bmSupps + 0,
					  faceName ) ;
	__CheckRC( sts, *msg, "VSgetBmFaceClosestToSuppSf", wrapup ) ;

	/*
	 * Get start point of axis.
	 *
	 * NOTE ( EF 09/06/94 ) :
	 *	We don't use the message GRvg.EMptatpr because it's rejected
	 *	if the axis is an AScompcurve !!!. It's not the case for
	 *	the message GRcurve.GRendpts.
	 */
	sts = om$send(	msg	= message GRcurve.GRendpts(
						msg,
						&bmSupps[1]._matrix_type,
						bmSupps[1]._matrix,
						endPt0OfAxis,
						endPt1OfAxis ),
			senderid= NULL_OBJID,
			targetid= bmSupps[1]._objid,
			targetos= bmSupps[1]._osnum ) ;
	__CheckRC( sts, *msg, "GRcurve.GRendpts", wrapup ) ;

	fromBeam._grid	 = *bmId ;
	fromBeam.mod_env = *bmEnv ;

	sts = VScopyBeamFaceForSupport( msg,
					&fromBeam,
					bmEnv,
					faceName,
					&faceId ) ;

	__CheckRC( sts, *msg, "VScopyBeamFaceForSupport", wrapup ) ;

	sts = VSisBeamProfileOrientedClockwise( msg, bmId, &clockwise ) ;
	__CheckRC( sts, *msg, "VSisBeamProfileOrientedClockwise", wrapup ) ;

	sts = VSgetLocalBeamCS( msg,
				&faceId,
				bmEnv,
				clockwise ? 1. : 0.,
				origin,
				xvec,
				yvec,
				zvec ) ;
	__CheckRC( sts, *msg, "VSgetLocalBeamCS", wrapup ) ;

	deltaWorld[0] = origin[0] - endPt0OfAxis[0] ;
	deltaWorld[1] = origin[1] - endPt0OfAxis[1] ;
	deltaWorld[2] = origin[2] - endPt0OfAxis[2] ;

	delta[0] = deltaWorld[0] ;
	delta[1] = deltaWorld[1] ;
	delta[2] = deltaWorld[2] ;

	*msg = MSSUCC ; sts = OM_S_SUCCESS ;

	wrapup	:
		vs$bulk_delete( grids  = &faceId,
				theEnv = bmEnv ) ;
		return sts ;

} /* VSgetDataForAxisRegeneration */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;
