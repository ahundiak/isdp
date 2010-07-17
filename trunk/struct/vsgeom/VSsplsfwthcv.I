/* $Id: VSsplsfwthcv.I,v 1.1.1.1 2001/01/04 21:10:40 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsgeom/VSsplsfwthcv.I
 *
 * Description: Split face with curve
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VSsplsfwthcv.I,v $
 * Revision 1.1.1.1  2001/01/04 21:10:40  cvs
 * Initial import to CVS
 *
# Revision 1.2  1999/04/12  11:30:10  pinnacle
# TR 179900266
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/10/99  ah      TR179900266 Some spliits failing, changed ZERO_U
 ***************************************************************************/

class implementation EMSsfmkface ;

#include <stdlib.h>
#include "OMmacros.h"
#include "msdef.h"
#include "bserr.h"
#include "bstypes.h"
#include "growner.h"
#include "EMSopt.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSlmdef.h"
#include "EMSlm.h"
#include "EMSmsgdef.h"
#include "EMSdpb.h"
#include "vsdef.h"
#include "vs.h"
#include "vspart.h"
#include "vsglobals.h"
#include "vsiomacros.h"
#include "vsdatamacros.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bscveval.h"
#include "bsptnorsf.h"
#include "vsmkinfline.h"

extern OMuword		OPP_GRcompcurve_class_id,
			OPP_GRbcsubbc_class_id ;

from GRlinear	import	GRgetpolyline ;
from GRcurve	import	GRsplit ;
from EMSsubbs	import	EMreduce_range,
			EMproject_curve_onto_surface ;
from GRsubbc	import	EMmerge_curves ;
/*----------------------------------------------------------------------------*/
long VSmergeCompCurve( msg, ccId, ccEnv, cst, delInputCv, mergedcvId )

long			*msg ;
struct GRid		*ccId,
			*mergedcvId ;
struct GRmd_env		*ccEnv ;
struct GRvg_construct	*cst ;
int			delInputCv ; {

	/*
	 * This function is interfaced by macro `vs$mergeCompCurve'
	 * defined in "vsgeommacros.h"
	 */
	long			sts ;
	struct GRlc_info	ccInfo ;

	mergedcvId->objid	= NULL_OBJID ;
	mergedcvId->osnum	= cst->env_info->_MD_OS ;

	sts = om$construct(	classid	= OPP_GRbcsubbc_class_id,
				osnum	= mergedcvId->osnum,
				p_objid	= &mergedcvId->objid ) ;
	if( !( sts & 1 ) ) vs$om_error( sts = sts ) ;

	ccInfo.located_obj	= *ccId ;
	ccInfo.module_info	= *ccEnv ;

	sts = om$send(	msg	= message GRsubbc.EMmerge_curves(
							1, &ccInfo, cst, msg ),
			senderid= mergedcvId->objid,
			targetid= mergedcvId->objid,
			targetos= mergedcvId->osnum ) ;
	__CheckRC( sts, *msg, "GRsubbc.EMmerge_curves", wrapup ) ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			vs$bulk_delete(	grids	= mergedcvId,
					theEnv	= cst->env_info ) ;
		} else if( delInputCv ) {
			vs$bulk_delete(	grids	= ccId,
					theEnv	= ccEnv ) ;
		}
		return sts ;

} /* VSmergeCompCurve */
/*----------------------------------------------------------------------------*/
long VSextendLineToInfinity( msg, lineEnv, lineId, modEnv, infLine )

long		*msg ;
struct GRid	*lineId,
		*infLine ;
struct GRmd_env	*lineEnv,
		*modEnv ; {

	long			sts ;
	int			action ;
	struct IGRpolyline	line ;
	double			buffer[6] ;
	struct GRvg_construct	cst ;

	infLine->objid = NULL_OBJID ;
	action	= 0 ;
	sts = om$send(	msg	= message GRlinear.GRgetpolyline(
							msg,
							&lineEnv->_MATRIX_TYPE,
							lineEnv->_MATRIX,
							&action,
							&line ),
			senderid= lineId->objid,
			targetid= lineId->objid,
			targetos= lineId->osnum ) ;
	if(    sts == OM_W_UNKNOWN_MSG
	   || ( sts & 1 & *msg ) && line.num_points != 2 ) {
		/*
		 * Input object not linear or not a line segment.
		 */
		*msg = MSSUCC ; sts = OM_S_SUCCESS ; goto wrapup ;
	}
	__CheckRC( sts, *msg, "GRlinear.GRgetpolyline", wrapup ) ;

	line.points = buffer ;
	action = 1 ;
	sts = om$send(	msg	= message GRlinear.GRgetpolyline(
							msg,
							&lineEnv->_MATRIX_TYPE,
							lineEnv->_MATRIX,
							&action,
							&line ),
			senderid= lineId->objid,
			targetid= lineId->objid,
			targetos= lineId->osnum ) ;
	__CheckRC( sts, *msg, "GRlinear.GRgetpolyline", wrapup ) ;

	/*
	 * The infinite line will be a temporary object which will be
	 * deleted soon: don't bother putting it in the R-tree.
	 */
	vs$fill_cnst_list(	Msg		= msg,
				Env_info	= modEnv,
				Properties	= GRNOT_IN_RTREE,
				Cnst_list	= cst ) ;

	VSmake_infinite_line( msg, buffer + 0, buffer + 3, &cst, infLine ) ;
	__CheckRC( 1, *msg, "VSmake_infinite_line", wrapup ) ;

	wrapup :
		return sts ;

} /* VSextendLineToInfinity */
/*----------------------------------------------------------------------------*/
static int VSisCvPmOnSf( cvGeom, u, sfGeom, point )

struct IGRbsp_curve	*cvGeom ;
double			u ;
struct IGRbsp_surface	*sfGeom ;
IGRpoint		point ; {

	long		rc ;
	IGRpoint	pt0 ;
	double		distance,
			Upm,
			Vpm ;
	int		npt,
			inArea = FALSE ;

	BScveval( cvGeom, u, 0, (IGRpoint *) pt0, &rc ) ;
	if( BSERROR( rc ) ) goto wrapup ;

	BSptnorsf( sfGeom, pt0, &npt, &Upm, &Vpm, point, &distance, &rc ) ;
	if( BSERROR( rc ) ) goto wrapup ;

	if( npt == 0 ) {
		OM_BLOCK_MOVE( pt0, point, sizeof( IGRpoint ) ) ;
		inArea = FALSE ;
	} else inArea = TRUE ;

	wrapup :
		return inArea ;

} /* VSisCvPmOnSf */
/*----------------------------------------------------------------------------*/
static long VSprocessCvForMkFace( msg, cvId, cvEnv, sfId, sfEnv, newCv )

long			*msg ;
struct GRid		*cvId,
			*sfId,
			*newCv ;
struct GRmd_env		*cvEnv,
			*sfEnv ; {

	long			sts ;	/* OM return code	*/
	struct IGRbsp_curve	*cvGeom ;
	struct IGRbsp_surface	*sfGeom ;
	struct GRid		inCv ;
	struct GRparms		proj_parm ;
	double			u,
				min_u,
				max_u ;
	IGRpoint		point,
				min_p,
				max_p ;
	OM_S_OBJID		otherCv ;
	short			nbCvs ;

#define STEP	0.02

// TR179900266 Was 1.e-10
#define ZERO_U	(1.e-15)

	cvGeom = NULL ; sfGeom = NULL ; inCv.objid = NULL_OBJID ;

	/*
	 * Do not bother if input curve is a line segment and surface is
	 * planar.
	 */
	if(    vs$is_curve_linear(	msg	= msg,
					curveId = cvId,
					curveEnv= cvEnv )
	    && vs$is_surface_planar(	msg	= msg,
	    				surfId	= sfId,
	    				surfEnv	= sfEnv ) ) {
		*newCv = *cvId ; *msg = MSSUCC ; sts = OM_S_SUCCESS ;
		goto wrapup ;
	}

	/*
	 * GRsplit destroys the original curve so we have to copy it.
	 */
	sts = vs$grCopy(	msg	= msg,
				frEnv	= cvEnv,
				frObj	= cvId,
				toEnv	= cvEnv,
				toObj	= &inCv ) ;
	__CheckRC( sts, *msg, "vs$grCopy", wrapup ) ;

	*newCv = inCv ;
	sts = vs$get_geometry(	msg	= msg,
				grobjId	= &inCv,
				grobjEnv= cvEnv,
				geometry= &cvGeom ) ;
	__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

	sts = vs$get_geometry(	msg	= msg,
				grobjId	= sfId,
				grobjEnv= sfEnv,
				geometry= &sfGeom ) ;
	__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

	vs$dotsInStsFld() ;

	/* search start point on surface */
	for( u = 0 ; u < 1 ; u += STEP ) {
   		if( VSisCvPmOnSf( cvGeom, u, sfGeom, point ) ) {
   			break ;
   		}
		OM_BLOCK_MOVE(point, min_p, sizeof( IGRpoint ) ) ;
	}

	if( u < ZERO_U ) {
		/* Initial point in the area  */
	} else {
		/* Search better starting point */
		min_u = u - STEP ;
		max_u = u ;
		OM_BLOCK_MOVE( point, max_p, sizeof( IGRpoint ) ) ;

		do {
			u = 0.5 * ( min_u + max_u ) ;
			if( VSisCvPmOnSf( cvGeom, u, sfGeom, point ) ) {
				max_u = u ;
				OM_BLOCK_MOVE( point, max_p, sizeof( IGRpoint));
			} else {
				min_u = u ;
				OM_BLOCK_MOVE( point, min_p, sizeof( IGRpoint));
			}
		} while( max_u - min_u > ZERO_U ) ;
		
		vs$dotsInStsFld() ;

		/* split starting part of the curve */
		proj_parm.u		= min_u ;
		proj_parm.leaf_id	= *newCv ;

		sts = om$send(	msg	= message GRcurve.GRsplit( msg,
								cvEnv,
								min_p,
								&proj_parm,
								&otherCv,
								&newCv->objid,
								&nbCvs ),
				senderid= NULL_OBJID,
				targetos= newCv->osnum,
				targetid= newCv->objid ) ;
		__CheckRC( sts, *msg, "GRcurve.GRsplit", wrapup ) ;

		vs$dotsInStsFld() ;
 		/*
 		 * `inCv' is now gone.
 		 */
 		inCv.objid = NULL_OBJID ;
 
	  	if( nbCvs == 2 ) {
  			vs$bulk_delete(	objids	= &otherCv,
  					theEnv	= cvEnv ) ;
		} else newCv->objid = otherCv ;

		_FREE( cvGeom ) ;

		sts = vs$get_geometry(	msg	= msg,
					grobjId	= newCv,
					grobjEnv= cvEnv,
					geometry= &cvGeom ) ;
		__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;
 
	}

	/* Same story now for end point */

	for( u = 1 ; u > 0 ; u -= STEP ) {
		if( VSisCvPmOnSf( cvGeom, u, sfGeom, point ) ) {
			break ;
		}
		OM_BLOCK_MOVE( point, max_p, sizeof( IGRpoint ) ) ;
	}

	vs$dotsInStsFld() ;

	if( u >= 1 - ZERO_U ) {
		/* Final point in the area  */
	} else {
		/* Search better ending point */
		min_u = u ;
		max_u = u + STEP;
		OM_BLOCK_MOVE( point, min_p, sizeof( IGRpoint ) ) ;

		do {
			u = 0.5*( min_u + max_u);
			if( VSisCvPmOnSf( cvGeom, u, sfGeom, point ) ) {
				min_u = u;
				OM_BLOCK_MOVE( point, min_p, sizeof( IGRpoint ) ) ;
			} else {
				max_u = u;
				OM_BLOCK_MOVE( point, max_p, sizeof( IGRpoint ) ) ;
			}
		} while( max_u - min_u > ZERO_U ) ;

		vs$dotsInStsFld() ;
		/* split starting part of the curve */

		proj_parm.u		= max_u;
		proj_parm.leaf_id	= *newCv ;

		sts = om$send(	msg	= message GRcurve.GRsplit( msg,
								cvEnv,
								min_p,
								&proj_parm,
								&newCv->objid,
								&otherCv,
								&nbCvs ),
				senderid= NULL_OBJID,
				targetos= newCv->osnum,
				targetid= newCv->objid ) ;
		__CheckRC( sts, *msg, "GRcurve.GRsplit", wrapup ) ;
  
		vs$dotsInStsFld() ;

 		/*
 		 * `inCv' is now gone, if we did not go through the previous
 		 * GRsplit.
 		 */
  		inCv.objid = NULL_OBJID ;

	  	if( nbCvs == 2 ) {
  			vs$bulk_delete(	objids	= &otherCv,
  					theEnv	= cvEnv ) ;
		} else newCv->objid = otherCv ;
	}

	sts = OM_S_SUCCESS ;
	*msg= MSSUCC ;

	wrapup :
		_FREE( sfGeom ) ; _FREE( cvGeom ) ;
		if(    !IF_NULL_OBJID( inCv.objid )
		    && !IF_EQ_OBJID( inCv.objid, newCv->objid ) ) {
			vs$bulk_delete(	grids	= &inCv,
  					theEnv	= cvEnv ) ;
		}
		if( !( sts & 1 & *msg ) ) {
			if( !( IF_EQ_OBJID( newCv->objid, inCv.objid ) ) ) {
				vs$bulk_delete(	grids	= newCv,
  						theEnv	= cvEnv ) ;
  			}
  			newCv->objid = NULL_OBJID ;
		}
		return sts ;
#undef STEP

} /* VSprocessCvForMkFace */
/*----------------------------------------------------------------------------*/
long VSsplitSurfaceWithCurve( msg, surfId, surfEnv, curveId, curveEnv,
				resultSymb, resultList )

long		*msg ;
struct GRid	*surfId,
		*curveId,
		resultList[] ;
struct GRmd_env	*surfEnv,
		*curveEnv ;
struct GRsymbology
		*resultSymb ; {

	/*
	 * This function is interfaced by macro `vs$split_surface_with_curve'
	 * defined in "vsgeommacros.h"
	 */
	long			sts,		/* OM return code	*/
				emsRC ;		/* EMS error status	*/
        struct GRid		splitSurf,	/* Result of make-face	*/
        			activeId,	/* Active id of oldPlate*/
        			compressed ;	/* Compressed surf.	*/
	struct GRvg_construct   cst ;		/* ... of make-face	*/
	struct GRlc_info	entry ;		/* Input curve to mkface*/
	struct EMSmkf_grouping_info
				grp_info ;
	long			countOfBadCrvs,
				countOfBadPnts,
				badCrvIndices[50];
	int			count ;		/* Of components	*/
	IGRpoint		*BadPnts = NULL;/* List of bad points	*/
	unsigned short		dprAddOpt ;	/* Add-to-DPR option	*/
	struct IGResbs		mkfAttr ;	/* Make-face attributes	*/
	struct GRobj_env	curve ;
	struct GRid		newCurve ;	/* Ext. of cv. if line,
						    merged cv. if comp
						    curve.		*/
	struct GRid		reducedCv ;	/* Reduction of cv. if
						   is extends past sf.	*/


	newCurve.objid = reducedCv.objid = NULL_OBJID ;

	vs$dotsInStsFld( dots = 1 ) ;

	/*
	 * The following splitting process will not work with a composite
	 * curve: it will only use one of the components, so merge composite
	 * curves...
	 */
	if( vs$is_ancestry_valid(	object	= curveId,
					classid	= OPP_GRcompcurve_class_id ) ) {
		struct GRvg_construct	ccCst ;
		/*
		 * The merged curve will be a temporary object which will be
		 * deleted soon: don't bother putting it in the R-tree.
		 */
		vs$fill_cnst_list(
				Msg		= msg,
				Env_info	= curveEnv,
				Level		= resultSymb->level,
				Display		= &resultSymb->display_attr,
				Properties	= GRNOT_IN_RTREE,
				Cnst_list	= ccCst ) ;

		sts = vs$mergeCompCurve(msg		= msg,
					ccId		= curveId,
					ccEnv		= curveEnv,
					cst		= &ccCst,
					mergedCvId	= &newCurve ) ;
		__CheckRC( sts, *msg, "vs$mergeCompCurve", wrapup ) ;

		curveId = &newCurve ;

		vs$dotsInStsFld() ;
	} else {
		sts = VSextendLineToInfinity(	msg,
						curveEnv,
						curveId,
						curveEnv,
						&newCurve ) ;
		__CheckRC( sts, *msg, "VSextendLineToInfinity", wrapup ) ;
		if( !IF_NULL_OBJID( newCurve.objid ) ) {
			curveId = &newCurve ;
		}
	}

		
	/*
	 * Fill construction list.
	 */
	vs$fill_cnst_list(	Env_info	= surfEnv,
				Display		= &resultSymb->display_attr,
				Level		= resultSymb->level,
				Class_attr	= &mkfAttr,
				Cnst_list	= cst ) ;

	/* We may have here to process the curve input to make-face for the
	 * following reason :
	 * Make-face operation much like the impose surface boundary operation
	 * assumes the input curve that is being used lies on the surface. For
	 * splitting the uv space by the 3D curve, it then projects the 
	 * curve along surface normals. 
	 *
	 * If part of the curve is extending past the surface on which you are
	 * making face, projection along surface normals
	 *
	 *   ______    _____
	 *   |    |   /
	 *  _________/    Linestring
	 *   |____|
	 *
	 *   Surface
	 *
	 * Causes the curve to deviate at the end from the line string. The 
	 * algorithm that is used for projection along surface normals involves
	 * (from a conceptual sense) stroking the input curve and then getting
	 * the minimum distance point of each vertex of the input curve onto the
	 * surface and then joining the resultant points. Hence if the line
	 * string extends past the surface the minimum distance points tend to
	 * travel along the edge and that is why you may observe the deviation.
	 *
	 * This problem occurs when splitting a free-form surface with a line
	 * string that extends beyond surface boundaries.
	 * The following call will return a new curve identical to the input
	 * curve but chopped out so as not to extend past the surface.
	 * If the input curve is a line segment and the surface is planar,
	 * then nothing will be performed and the output curve will be set to
	 * the input curve (which means if you want to get rid of the new curve
	 * returned, make sure first that it is not equal to the input curve ! )
	 */

	sts = VSprocessCvForMkFace( msg, curveId, curveEnv,
				    surfId, surfEnv, &reducedCv ) ;


	if( !( sts & 1 & *msg ) ) {
		/*
		 * Keep the original curve : che sera sera.
		 */
		reducedCv.objid = NULL_OBJID ;
		entry.located_obj = *curveId ;
		entry.module_info = *curveEnv ;

	} else {
		entry.located_obj = reducedCv ;
		entry.module_info = *curveEnv ;
	}
	vs$dotsInStsFld() ;

	sts = om$send( msg	= message EMSsurface.EMgetactiveid(
								msg,
								&activeId,
								NULL ),
			senderid= surfId->objid,
			targetid= surfId->objid,
			targetos= surfId->osnum ) ;
	__CheckRC( sts, *msg, "EMSsurface.EMgetactiveid", wrapup ) ;


	mkfAttr.u_rules		= 0 ;
	mkfAttr.v_rules		= 0 ;
	mkfAttr.is_polydis	= 0 ;
	mkfAttr.is_surfdis	= TRUE ;
	mkfAttr.is_slowdis	= FALSE ;
	countOfBadCrvs		= 0 ;
	countOfBadPnts		= 0 ;


	sts = om$send(	targetid= activeId.objid,
			targetos= activeId.osnum,
			senderid= activeId.objid,
			msg	= message EMSsurface.EMmake_face(
					msg,
					message EMSsfmkface.EMmake_face_execute(
						&emsRC,
						activeId,
						surfEnv,
		/* Count of curves :	*/	1,
		/* List of curves :	*/	&entry,
		/* Construction list :	*/	&cst,
		/* Count of bad points :*/	&countOfBadPnts,
		/* List of bad points :	*/	&BadPnts,
		/* Want bad curves :	*/	TRUE,
		/* Count of bad curves :*/	&countOfBadCrvs,
		/* Indices of bad crvs :*/	badCrvIndices,
		/* Want statuses :	*/	TRUE,
						EMS_PROCESS_PHASE1,
						(char *) &grp_info,
		/* Display options :	*/	0,
		/* Display ids :	*/	NULL,
		/* Display count :	*/	NULL,
		/* Track point		*/	NULL
					),
					&splitSurf ) ) ;
	if( *msg & 1 ) *msg = emsRC ;
	__CheckRC( sts, *msg, "EMSsurface.EMmake_face", wrapup ) ;

	vs$dotsInStsFld() ;
	
	/*
	 * Adding the created face to DPR, if we don't we can only locate one
	 * face ...
	 */
	dprAddOpt = EMS_DO_DISPLAY;
	sts = om$send(	msg	= message EMSsfdpr.EMadd(	msg,
								&activeId,
								NULL,
								surfEnv,
								&dprAddOpt ),
			targetid= splitSurf.objid,
			senderid= splitSurf.objid,
			targetos= splitSurf.osnum ) ;
	__CheckRC( sts, *msg, "EMSsfdpr.EMadd", wrapup ) ;

	sts = om$send(	msg	= message EMSdpr.EMmake_primitive1(
							msg,
							surfEnv,
							&compressed ),
			senderid= splitSurf.objid,
			targetid= splitSurf.objid,
			targetos= splitSurf.osnum ) ;
	__CheckRC( sts, *msg, "EMSsfdpr.EMmake_primitive1", wrapup ) ;
	splitSurf = compressed ;

	vs$dotsInStsFld() ;
	/*
	 * We now want to get the two parts, result of the split which are
	 * owned by a complex surface.
	 */
	sts = om$send(	msg	= message GRowner.GRget_components(
						msg,
						surfEnv,
						resultList,
						2,
						&count,
						/* From = */ 0,
						/* To   = */ 1 ),
			senderid= splitSurf.objid,
			targetid= splitSurf.objid,
                  	targetos= splitSurf.osnum ) ;
	__CheckRC( sts, *msg, "GRowner.GRget_components", wrapup ) ;
			
	/*
	 * Sort sub-surfaces, first and second will always be on same side of
	 * boundary curve. We here assume that there are 2 sub-plates...
	 * This must be done BEFORE dropping complex (so common edges may be
	 * found).
	 */
	curve._grid	= *curveId ;
	curve.mod_env	= *curveEnv ;
	VSsort_sub_surfaces(	msg,
				resultList + 0,
				resultList + 1,
				surfEnv,
				&curve,
				resultList + 0,
				resultList + 1 ) ;
	__CheckRC( 1, *msg, "VSsort_sub_surfaces", wrapup ) ;
	
	vs$dotsInStsFld() ;
	/*
	 * Disconnect them from the make-face object, then kill it.
	 */
	sts = om$send(	msg	= message GRowner.GRdrop( msg, surfEnv ),
			senderid= splitSurf.objid,
			targetid= splitSurf.objid,
			targetos= splitSurf.osnum ) ;
	__CheckRC( sts, *msg, "GRowner.GRdrop", wrapup ) ;

	/*
	 * CAUTION !!! If we do send this messages, one of the two sub-surface
	 * (I do not not know which, so both are sent the message ...)
	 * will behave as if it had the size of the original surface as regards
	 * intersections and projections, thus giving false results.
	 */
	for( count = 0 ; count < 2 ; count++ ) {
		sts = om$send(	msg	= message EMSsubbs.EMreduce_range(
						msg, surfEnv, &compressed.objid,
						1. ),
				senderid= resultList[count].objid,
				targetid= resultList[count].objid,
				targetos= resultList[count].osnum ) ;
		__CheckRC( sts, *msg, "EMSsurface.EMreduce_range", wrapup ) ;
		resultList[count].objid = compressed.objid ;

		vs$dotsInStsFld() ;
	}

        wrapup :
        	/*
        	 * Delete intermediate results.
        	 */
        	if( countOfBadPnts ) _FREE( BadPnts ) ;

		/*
		 * Warning: vs$bulk_delete below sets `newCurve.objid' to
		 * NULL_OBJID, so also set `reducedCv.objid' to NULL_OBJID
		 * if it is equal to `newCurve.objid'.
		 */
		if( IF_EQ_OBJID( reducedCv.objid, newCurve.objid ) ) {
			reducedCv.objid = NULL_OBJID ;
		}
        	vs$bulk_delete(	count	= 1,
				grids	= &newCurve,
				theEnv	= curveEnv ) ;

		if( !IF_EQ_OBJID( reducedCv.objid, curveId->objid ) ) {
	        	vs$bulk_delete(	count	= 1,
					grids	= &reducedCv,
					theEnv	= curveEnv ) ;
		}

		vs$dotsInStsFld( dots = clear ) ;

                return sts ;

} /* VSsplitSurfaceWithCurve */
/*----------------------------------------------------------------------------*/

end implementation EMSsfmkface ;
