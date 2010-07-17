/* $Id: VSbmmakeseg.I,v 1.2 2001/10/13 19:18:31 ramarao Exp $  */

/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/vsbeam/VSbmmakeseg.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSbmmakeseg.I,v $
 *      Revision 1.2  2001/10/13 19:18:31  ramarao
 *      Fixed TR# 5630.
 *
 *      Revision 1.1.1.1  2001/01/04 21:10:12  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1998/03/13  12:59:00  pinnacle
# Replaced: vsbeam/VSbmmakeseg.I for:  by rchennup for struct
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *	03/13/98	Suresh		modification to handle skinning surface
					in case the MoveCrossSectionNormalToSf
					fails.
 * -------------------------------------------------------------------*/
/*
	I/STRUCT
*/
class implementation EMSsurface ;

#include <math.h>
#include "msdef.h"
#include "bstypes.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSmsgdef.h"
#include "growner.h"
#include "vspart.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsiomacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "maptplpro.h"
#include "matypemx.h"
#include "bscveval.h"
#include "bsdistptpt.h"
#include "bsdistptpts.h"
#include "bststcvfln.h"
#include "vscreatplncs.h"
#include "vsiscvabvpln.h"
#include "vsplcontncrv.h"
#include "vsvecmxproto.h"

/* #define DEBUG_BEAM */

extern long	VSisCvAbovePlane() ;

from	EMSgenbs	import	EMmove_cross_section_normal_to_sf,
				EMplace_skinning_surface ;
from	EMSproject      import	EMplace_surface_of_projection ;
from	GRcurve		import	GRendpts,
				GRtotlength ;

extern OMuword		OPP_EMSproject_class_id,
			OPP_EMSgenbs_class_id ;
/*----------------------------------------------------------------------------*/
long VSgetSegTransExtent(	msg,
				profile,	/* Profile curve	    */
				axisTgt,	/* Tgt to axis at start pnt */
				plNormal,	/* Normal to axis's plane   */
				axis,		/* Axis of beam		    */
				extent )

long			*msg ;
struct GRobj_env	*profile,
			*axis ;
IGRvector		axisTgt,
			plNormal ;
double			*extent ; {

	/*
	 * This function computes the extent of the profile form the axis start
	 * point:
	 *		   extend
	 *       <----------------------------->				
	 *				+------+
	 *       + start point          +--++--+
	 * --plane--------------------     ||
	 *				+--++--+
	 *				+------+
	 *
	 * The extent is the projection on the plane of the maximum distance
	 * from the start point to the profile. It will be the maximun distance
	 * from the axis to the profile at each point of the axis as the
	 * profile gets moved along the axis normal to the plane.
	 *
	 */

	long		sts ;
	IGRpoint	startPt,
			endPt ;
	GRrange		profRg ;
	struct IGRplane	plane ;
	short		type,
			world = TRUE ;
	double		d1,
			d2 ;
	IGRmatrix	l2w,
			w2l ;

	/*
	 * Get the start point of the axis.
	 */
	sts = om$send(	msg	= message GRcurve.GRendpts(
					msg, &axis->_matrix_type,
					axis->_matrix, startPt, endPt ),
			senderid= axis->_objid,
			targetid= axis->_objid,
			targetos= axis->_osnum ) ;

	/*
	 * Compute range profile in a local CS so as to get as square as a range
	 * box with the box points in the profile's plane.
	 * The normal to the profile's plane in our case is the tangent to
	 * the axis at the start point (our profile is placed in the plane
	 * normal to the axis at the start point).
	 */
	plane.point	= startPt ;
	plane.normal	= axisTgt ;

	VScreatePlaneCS( &plane, l2w, w2l ) ;
	MAtypemx( msg, w2l, &type ) ;

	sts = om$send(	msg	= message GRgraphics.GRgetrang(
					msg, &type, w2l, &world, profRg ),
			senderid= profile->_objid,
			targetid= profile->_objid,
			targetos= profile->_osnum ) ;
	__CheckRC( sts, *msg, "GRgraphics.GRgetrang", wrapup ) ;

	/*
	 * Map range points back to world co-ordinates.
	 */
	VSmxprodpt( l2w, profRg + 0, profRg + 0 ) ;
	VSmxprodpt( l2w, profRg + 3, profRg + 3 ) ;

	/*
	 * Now project range points onto the plane of the axis (the profile
	 * may not be positioned upright on this plane but rotated).
	 * and find maximum distance between the start point of the axis
	 * and the projections of the range points.
	 */
	plane.normal	= plNormal ;

	MAptplproj( msg, (IGRpoint *) (profRg + 0), &plane, endPt ) ;
	d1 = BSdistptpts( msg, startPt, endPt ) ;

	MAptplproj( msg, (IGRpoint *) (profRg + 3), &plane, endPt ) ;
	d2 = BSdistptpts( msg, startPt, endPt ) ;

	*extent = sqrt( d1 > d2 ? d1 : d2 ) ;

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		return sts ;
	
} /* VSgetSegTransExtent */
/*----------------------------------------------------------------------------*/
long VSmoveCrossSectionNormalToSf(	msg,
					xsect,
					surface,
					axis,
					cst,
					surfIsPlanar,
					p_segment )
long			*msg ;
struct GRobj_env	*xsect,
			*surface,
			*axis ;
struct GRvg_construct	*cst ;
int			surfIsPlanar ;
struct GRid		*p_segment ; {

	long			sts,		/* OM return code	*/
				emsRC ;		/* EMS return code	*/
	double			rotMx[9],	/* Wants a 3x3 matrix	*/
				axisLength,	/* Length of axis	*/
				lenTol ;	/* Length tolerance	*/
	IGRpoint		side,		/* Side point		*/
				pntAtX ;
	IGRvector		vectPt[2],
				tanAtX,
				normAtX,
				xvecAtX ;
	struct GRlc_info	surfInfo ;
	struct GRlc_info	xsectInfo,
				traceInfo ;
	IGRboolean		onSurf ;
	int			i ;		/* Loop index		*/
	struct GRid		tmpPlane,	/* Temporary plane	*/
				cmpSf ;		/* Composited surface	*/
	struct GRsymbology	Symb ;		/* Symb. for composite	*/
	struct GRprops		axisProps ;	/* Geometry properties  */

	p_segment->objid = NULL_OBJID ;
	p_segment->osnum = cst->env_info->_MD_OS ;
	tmpPlane.objid	 = NULL_OBJID ;

	sts = om$send(	msg	= message GRcurve.GRtotlength(
							msg,
							&axis->_matrix_type,
							axis->_matrix,
							&axisLength ),
			senderid= axis->_objid,
			targetid= axis->_objid,
			targetos= axis->_osnum ) ;
	__CheckRC( sts, *msg, "GRcurve.GRtotlength", wrapup ) ;

	BSEXTRACTPAR( msg, BSTOLLENVEC, lenTol ) ;

	if( axisLength <= lenTol ) {
		/*
		 * Axis is too small ...
		 */
		*msg	= EMS_E_Degenerate ;
		sts	= OM_W_ABORT ;
		goto wrapup ;
	}

	/*
	 * Compute cross-section referential.
	 * Reminder: z - along tangent of trace curve
	 * 	     y - along normal to surface
	 *	     x - cross product of the two above.
	 *	     O - where section is to be placed.
	 */
       	sts = vs$getCS_from_cv_and_sf(	msg	= msg,
					surface	= surface,
					curve	= axis,
					pntParm	= 0.,	/* Start point */
	                                origin	= pntAtX,
                                	tangent	= tanAtX,
                                	normal	= normAtX,
                                	binormal= xvecAtX ) ;
	__CheckRC( sts, *msg, "vs$getCS_from_cv_and_sf", wrapup ) ;

	for( i = 0 ; i < 3 ; i++ ) {
		rotMx[i+0]		= -xvecAtX[i] ;
		rotMx[i+3]		= normAtX [i] ;
 		rotMx[i+6]		= -tanAtX [i] ;
		traceInfo.proj_pnt[i]	= pntAtX[i] ;
		vectPt[0][i]		= 0.0 ;
		vectPt[1][i]		= -xvecAtX[i] ; 
		side[i]			= traceInfo.proj_pnt[i] + normAtX[i] ;
	}
					
	traceInfo.located_obj		= axis->_grid ;
	traceInfo.module_info		= axis->mod_env ;
	traceInfo.geom_parms.polygon_inx= FALSE ;
	xsectInfo.module_info		= xsect->mod_env ;
	xsectInfo.geom_parms.polygon_inx= FALSE ;
	xsectInfo.located_obj		= xsect->_grid ;

	/*
	 * If support surface is a plane and trace curve is planar, check
	 * that curve is within the plane's boundaries, otherwise
	 * `EMmove_cross_section_normal_to_sf' will give weird results at
	 * then ends of the curve outside the boudaries.
	 * If the curve is not fully contained within the plane, create
	 * a temporary plane containing it and use it.
	 */
	sts = om$send( msg      = message GRcurve.GRgeomprops( 
						            msg,
						            &axis->_matrix_type,
						            axis->_matrix,
						            &axisProps ),
		       senderid = axis->_objid,
		       targetid = axis->_objid,
		       targetos = axis->_osnum ) ;
	__CheckRC( sts, *msg, "GRcurve.GRgeomprops", wrapup ) ;

	if( surfIsPlanar && axisProps.planar ) {
		int		abovePlane ;
		double		extent ;

		/*
		 * Compute how far off axis segment will go.
		 */
		sts = VSgetSegTransExtent(	msg,
						xsect,
						tanAtX,
						normAtX,
						axis,
						&extent ) ;
		/*
		 * Add a safety quantum.
		 */
		extent *= 1.1 ;

		/*
		 * Will plane be big enough so that the profile at each point
		 * of the axis will sit entirely on the plane ?
		 */
		sts = VSisCvAbovePlane(	msg,
					axis,
					surface,
					extent,
					&abovePlane ) ;
		__CheckRC( sts, *msg, "VSisCvAbovePlane", wrapup ) ;

		if( !abovePlane ) {
			sts = VSplaneContainingCurve(	msg,
							axis,
							extent,
							cst,
							&tmpPlane ) ;
			__CheckRC( sts, *msg, "VSplaneContainingCurve", wrapup);

			surfInfo.located_obj = tmpPlane ;
			surfInfo.module_info = *cst->env_info ;
		} else {
			surfInfo.located_obj = surface->_grid ;
			surfInfo.module_info = surface->mod_env ;
		}
		
	} else {
		surfInfo.located_obj = surface->_grid ;
		surfInfo.module_info = surface->mod_env ;
	}

	vs$dotsInStsFld() ;

	sts = om$construct(
		msg	= message EMSgenbs.EMmove_cross_section_normal_to_sf(
						&emsRC,
						&onSurf,
						cst,
						&surfInfo,
						&traceInfo,
						&xsectInfo,
						side,
						pntAtX,
						FALSE, /* is left-handed ? */
						rotMx,
						vectPt,
						NULL ),
		osnum	= p_segment->osnum,
		classid = OPP_EMSgenbs_class_id,
		p_objid = &p_segment->objid ) ;

	*msg = emsRC ;
	__CheckRC( sts, *msg, "EMSgenbs.EMmove_cross_section_normal_to_sf", wrapup );

	Symb.display_attr	= *cst->display ;
	Symb.level		= cst->level ;

	sts = vs$recomposite_surface(
					msg		= msg,
					genlSfEnv	= cst->env_info,
					genlSfId	= p_segment,
					compCvEnv	= &xsect->mod_env,
					compCvId	= &xsect->_grid,
					compSfEnv	= cst->env_info,
					compSfSymb	= &Symb,
					compSfId	= &cmpSf ) ;
	__CheckRC( sts, *msg, "vs$recomposite_surface", wrapup ) ;
	*p_segment = cmpSf ;

	wrapup :

		vs$bulk_delete(	grids = &tmpPlane, theEnv = cst->env_info ) ;

		return sts ;

} /* VSmoveCrossSectionNormalToSf */
/*----------------------------------------------------------------------------*/
long VSskinningSurface(	msg,
			xsect,
			surface,
			axis,
			cst,
			p_segment )

long			*msg ;
struct GRobj_env	*xsect,
			*surface,
			*axis ;
struct GRvg_construct	*cst ;
struct GRid		*p_segment ; {

	long			sts,		/* OM return code	*/
				emsRC ;		/* EMS return code	*/
	struct GRlc_info	surfInfo ;
	struct GRlc_info	xsectInfo,
				traceInfo ;
	struct GRid		cmpSf,		/* Composited surface	*/
				loc_segment;
	struct GRsymbology	Symb ;		/* Symb. for composite	*/

	p_segment->objid = loc_segment.objid = NULL_OBJID ;
	p_segment->osnum = loc_segment.osnum = cst->env_info->_MD_OS ;

	xsectInfo.module_info		= xsect->mod_env ;
	xsectInfo.geom_parms.polygon_inx= FALSE ;
	xsectInfo.located_obj		= xsect->_grid ;

	traceInfo.located_obj		= axis->_grid ;
	traceInfo.module_info		= axis->mod_env ;
	traceInfo.geom_parms.polygon_inx= FALSE ;

	surfInfo.located_obj = surface->_grid ;
	surfInfo.module_info = surface->mod_env ;

	sts = om$construct(
		msg	= message EMSgenbs.EMplace_skinning_surface(
							&emsRC,
							cst,
							1,
							&traceInfo,
							1,
							&xsectInfo,
			/* Surface is open	*/	TRUE,
							NULL,
			/* Abs. orientation	*/	FALSE, 
			/* No height scaling	*/	TRUE,
							NULL,
							NULL ),
		osnum	= loc_segment.osnum,
		classid = OPP_EMSgenbs_class_id,
		p_objid = &loc_segment.objid ) ;

	*msg = emsRC ;
	__CheckRC( sts, *msg, "EMSgenbs.EMplace_skinning_surface", wrapup );

	Symb.display_attr	= *cst->display ;
	Symb.level		= cst->level ;

	sts = vs$recomposite_surface(
					msg		= msg,
					genlSfEnv	= cst->env_info,
					genlSfId	= &loc_segment,
					compCvEnv	= &xsect->mod_env,
					compCvId	= &xsect->_grid,
					compSfEnv	= cst->env_info,
					compSfSymb	= &Symb,
					compSfId	= &cmpSf ) ;
	__CheckRC( sts, *msg, "vs$recomposite_surface", wrapup ) ;
	*p_segment = cmpSf ;

	wrapup :
	    return sts ;

} /* VSskinningSurface */
/*----------------------------------------------------------------------------*/
long VSmake_beam_segment(	msg,
				xsect,
				surface,
				axis,
				cst,
				p_segment )
long			*msg ;
struct GRobj_env	*xsect,
			*surface,
			*axis ;
struct GRvg_construct	*cst ;
struct GRid		*p_segment ; {

	long			sts ;		/* OM completion code	*/
	struct GRid		solid ;
	struct IGRbsp_curve	*axisGeom ;
	struct IGRbsp_surface	*sfGeom ;
	int 			isPlanar ;	/* Is surface planar ?	*/
	short			isLinear ;	/* Is axis linear ?	*/
	enum {
		MVXSECT	= 1,
		PLCSKIN = 2,
		SFOFPRJ	= 3
	}			action ;	/* What to do ...	*/
	IGRpoint		startPnt,	/* Start of linear axis	*/
				endPnt ;	/* End   of linear axis	*/
	int			axisOrder,	/* BS order of axis	*/
				sfUorder,
				sfVorder ;
	double			lenTol ;	/* Length tolerance	*/

	vs$dotsInStsFld() ;

	p_segment->objid = NULL_OBJID ;
	p_segment->osnum = cst->env_info->_MD_OS ;

	sts = om$send(	msg	= message GRvg.GRgenabsg(
							msg,
							&axis->_matrix_type,
							axis->_matrix,
							(char **) &axisGeom ),
			senderid= axis->_objid,
			targetid= axis->_objid,
			targetos= axis->_osnum ) ;
	__CheckRC( sts, *msg, "GRvg.GRgenabsg", wrapup ) ;

	axisOrder = axisGeom->order ;

	/*
	 * Test if support axis is a line segment. Do it before NEXT GRgenabsg!
	 */
	BStstcvfln( axisGeom, &isLinear, startPnt, endPnt, msg ) ;
		    
	if( BSERROR( *msg ) ) {
		vs$error( msgval = EMS_E_BSerror ) ;
	}

	/*
	 * CAUTION ! BStstcvfln may not return the start and end points in the
	 * good order.
	 */
	BScveval( axisGeom, 0., 0, (IGRpoint *) startPnt, msg ) ;
	BScveval( axisGeom, 1., 0, (IGRpoint *) endPnt  , msg ) ;

	sts = om$send(	msg	= message GRvg.GRgenabsg(
							msg,
							&surface->_matrix_type,
							surface->_matrix,
							(char **) &sfGeom ),
			senderid= surface->_objid,
			targetid= surface->_objid,
			targetos= surface->_osnum ) ;
	__CheckRC( sts, *msg, "GRvg.GRgenabsg", wrapup ) ;

	sfUorder = sfGeom->u_order ;
	sfVorder = sfGeom->v_order ;

	/*
	 * Choose method to generate beam segment :
	 * - Surface of projection if axis is a line segment and surface
	 *   is a plane, which is fast.
	 * - skinning-surface if axis is a line string and surface has order
	 *   2 in U and V (for move-x-section... does not handle this case).
	 * - move-x-section-normal-tosf otherwise.
	 */
	isPlanar = vs$is_surface_planar(msg	= msg,
					surfId	= &surface->_grid,
					surfEnv	= &surface->mod_env ) ;
	if( isLinear ) {
		
		if( isPlanar ) {
			action = SFOFPRJ ;
		} else 	action = MVXSECT ;

	} else if( axisOrder == 2 ) {
		/*
		 * Line string.
		 */

		action = sfUorder == 2 && sfVorder == 2 ? PLCSKIN : MVXSECT ;

		/*
		 * 05 April 93: we are nod dynamically loading a fixed version
		 * of "bsmvcsnsfvc.o" which handles this case, and does it
		 * better that place-skinning (which did not keep the height of
		 * the cross-section across cusps...). So let's set action to
		 * MVXSECT. The previous setting is kept above just in case we
		 * have to revert to it one day...
		 */
		action = MVXSECT ;

	} else	action = MVXSECT ;

	vs$dotsInStsFld() ;

	switch( action ) {

	case SFOFPRJ :

		/*
		 * If line length is too small there is no way EMS can create
		 * a surface of projection. Since axis is linear, the end points
		 * have been computed above by `BStstcvfln'.
		 */
		BSEXTRACTPAR( msg, BSTOLLENVEC, lenTol ) ;
	
		if( BSdistptpt( msg, startPnt, endPnt ) <= lenTol ) {
			/*
			 * Axis is too small: exit gracefully.
			 */
			*msg	= EMS_E_Degenerate ;
			sts	= OM_W_ABORT ;
			goto wrapup ;
		}

		sts = om$construct(
			msg	= message EMSproject.EMplace_surface_of_projection(
					cst,
					&xsect->_grid,
					&xsect->mod_env,
					NULL,	/* Curve geom : unused	*/
					0,	/* Curve type : unused	*/
					startPnt,
					endPnt,
					FALSE,
					&p_segment->objid ),
			osnum	= p_segment->osnum,
			classid = OPP_EMSproject_class_id,
			p_objid = &p_segment->objid ) ;

		*msg = *cst->msg ;

	        break ;

	case MVXSECT :

		sts = VSmoveCrossSectionNormalToSf(	msg,
							xsect,
							surface,
							axis,
							cst,
							isPlanar,
							p_segment ) ;
		if( !( sts & 1 & *msg ) ) {
			/*
			 goto wrapup ;
			 */
			/*
			 * Do not goto wrapup but try with skinning surface
			 * This can be removed once the 
			 * VSmoveCrossSectionNormalToSf supports knuckles
			 */
			goto skinning_surface ;
		}
		break ;
skinning_surface :
	case PLCSKIN	:
		sts = VSskinningSurface(	msg,
						xsect,
						surface,
						axis,
						cst,
						p_segment ) ;

		if( !( sts & 1 & *msg ) ) {
			goto wrapup ;
		}
		break ;

		default	: /* Invalid case */ vs$inv_arg() ;
	}

	/*
	 * Cap surface.
	 */
	vs$dotsInStsFld() ;

	sts = vs$cap_surface(	msg	= msg,
				cst	= cst,
				surface	= p_segment,
				solid	= &solid ) ;
	__CheckRC( sts, *msg, "vs$cap_surface", wrapup ) ;

	*p_segment = solid ;
	
	wrapup :
		vs$dotsInStsFld( dots = clear ) ;
		return sts ;

} /* VSmake_beam_segment */
/*----------------------------------------------------------------------------*/

end implementation EMSsurface ;

