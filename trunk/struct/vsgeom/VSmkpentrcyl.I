/* $Id: VSmkpentrcyl.I,v 1.3 2001/03/14 00:51:26 jayadev Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsgeom/VSmkpentrcyl.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSmkpentrcyl.I,v $
 *      Revision 1.3  2001/03/14 00:51:26  jayadev
 *      reduced range supplied
 *
 *      Revision 1.2  2001/01/16 23:42:31  ramarao
 *      *** empty log message ***
 *
# Revision 1.3  2000/11/27  21:39:06  pinnacle
# Replaced: struct/vsgeom/VSmkpentrcyl.I for:  by jpulapar for Service Pack
#
# Revision 1.2  2000/11/27  20:29:58  pinnacle
# Replaced: struct/vsgeom/VSmkpentrcyl.I for:  by jpulapar for Service Pack
#
# Revision 1.1  2000/11/27  17:17:08  pinnacle
# Created: struct/vsgeom/VSmkpentrcyl.I by jpulapar for Service Pack
#
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1997/09/26  15:08:58  pinnacle
# TR179701283
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTIO
 *      09/26/97        ah              added header
 *      09/26/97        ah		TR179701287, TR179701283
 *					Migrate had stopped working
 *      11/27/00        Jayadev         EvalFromTo1() BuildSrf() replaced
 *					EMS methods for solid/surface creation
 *				        BSfndptin() replaced VScenterOfCurve()	
 *					pinnacle backup VSmkpencyl.SAV without
 *					these changes 
 ***************************************************************************/

class implementation EMSproject ;

#include <stdlib.h>
#include "msdef.h"
#include "ma.h"
#include "bserr.h"
#include "bstypes.h"
#include "bsparameters.h"
#include "growner.h"
#include "EMSmsgdef.h"
#include "EMSasopts.h"

#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "matrlmx.h"
#include "matypemx.h"
#include "bscveval.h"
#include "bsctrarplcv.h"
#include "bsdistptpt.h"
#include "bsdotp.h"
#include "bslngen.h"
#include "bsmkvec.h"
#include "bsptonnsdsf.h"
#include "bsxtractpar.h"

extern void BSfndptin();
extern EvalFromTo1();
extern BuildSrf();
extern IGRdouble BSdistptpt();
from GRowner import GRget_components ;
/*----------------------------------------------------------------------------*/
long VSmakePenetratingCyl( msg, objId, objEnv, cvId, cvEnv, 
                           cst, cylinder, solidRange)

long			*msg ;
struct GRid		*objId,
			*cvId,
			*cylinder ;
struct GRmd_env 	*objEnv,
			*cvEnv ;
struct GRvg_construct	*cst ; 
GRrange			solidRange ; {

	/*
	 * Given an input planar curve and a graphic object, this function
	 * constructs a cylinder (surface), generated from the curve, such
	 * that this cylinder goes through the graphic object (of course if an
	 * intersection is possible between the cylinder and the object,
	 * given the vector of projection which is here taken to be the normal
	 * to the curve, possibly reversed so as to point towards the graphic
	 * object ).
	 * The cylinder is always constructed with its normal pointing inwards.
	 * It is not cheked here whether the cylinder will actually penetrate
	 * the object (ie. if intersections exist); it is only garanteed that
	 * if it can, it will.
	 */

	long		sts ,stat;		/* OM return code		*/
	GRrange 	objRng, 	/* Range of input object	*/
			cvRng ; 	/* Range of input curve 	*/
	struct IGRplane cvPlane ;	/* Plane of input curve 	*/
	IGRvector	plNormal,	/* Normal to plane of curve	*/
			transVec,	/* To translate cylinder	*/
			ctrPjCvToCtr ;	/* Vector projection point of	*/
					/* center of curve to center	*/
					/* of curve.			*/
	IGRpoint	plPoint,	/* Point on plane of curve	*/
			start,		/* Start point for sf. of proj. */
			stop,		/* Stop  point for sf. of proj. */
			center, 	/* Center of curve.		*/
			centerPjCv,	/* Center of curve projected	*/
					/* onto curve.			*/
			normalSf ;	/* Normal of sf. of proj.	*/
	struct GRparms	pmPj ;		/* Parameters of projected pnt. */
	IGRmatrix	transMx ;	/* Tranlation matrix for cyl.	*/
	short		transMxType ;	/* Type of the tranlation matrix*/
	double		d,		/* Omni-purpose local variable	*/
			maxDist,	/* Max. dist( curve, object )	*/
			normalPm[2] ;	/* Parameters to get normal of	*/
					/* surface.			*/
	int		i,		/* Loop index			*/
			j,		/* Yet another loop index	*/
			parmsCount ;	/* Parameters count.		*/
	IGRboolean	world = TRUE ;	/* For GRgetrang		*/
	struct GRprops	gprops ;	/* Geom. props of input curve	*/
	struct GRid	curve,
			surface ;
	int		composite ;	/* Composite curve/surface ?	*/

	IGRboolean	nat_side ;	/* Natural normal side		*/
	struct GRid	TempSrf, SOL;
	BSrc		bsrc ;		/* BS return Code		*/
	  struct GRlc_info	cvInfo ;
	  double			dist ,FromTo[9];

	struct IGRbsp_surface   *sfGeom = NULL;	    /* Surface Geometry */
	struct IGRbsp_curve	*cvGeom = NULL;
  	IGRushort opts;

	cylinder->objid = NULL_OBJID ;

	cvPlane.point = plPoint ;
	cvPlane.normal= plNormal ;
	sts = om$send(	msg	= message GRvg.GRdetplane(
							msg,
							&cvEnv->_MATRIX_TYPE,
							cvEnv->_MATRIX,
							&cvPlane ),
			senderid= NULL_OBJID,
			targetid= cvId->objid,
			targetos= cvId->osnum ) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;
        if(solidRange) 
        {
          __DBGpr_com("RANGE SUPPLIED");
          for(i = 0; i<6; i++) objRng[i] = solidRange[i];
        }
        else
        {
          __DBGpr_com("RANGE COMPUTED");
	  sts = om$send(msg	= message GRgraphics.GRgetrang(
			        		msg,
						&objEnv->_MATRIX_TYPE,
						objEnv->_MATRIX,
						&world,
						objRng ),
			senderid= NULL_OBJID,
			targetid= objId->objid,
	  		targetos= objId->osnum ) ;
	  if( !( sts & 1 & *msg ) ) goto wrapup ;
        }

	/*
	 * If the vector start point/end point is in the same direction as the
	 * normal of the curve, then we have to ask for a negative orientation
	 * of the cylinder so that the normal will point inwards.
	 */
	for( i = 0 ; i < 3 ; i++ ){ 
		start[i]	= cvPlane.point[i] ;
		stop [i]	= start[i]+ cvPlane.normal[i];
	}


	vs$get_geometry(msg            = msg,
			grobjId        = cvId,
			grobjEnv       = cvEnv,
			geometry       = &cvGeom ) ;
	__CheckRC( 1, *msg, "vs$get_geometry", wrapup ) ;
	
	if( cvGeom->phy_closed ) {
	  struct EMSpoint_info 	base, height ;
	  struct GRlc_info	sfInfo ;
	  struct GRlc_info    	stPlaneInfo; 
	  struct GRlc_info    	endPlaneInfo; 
	  struct GRevent		baseEvent, heightEvent;
	  struct GRvg_construct	cnstlist ;
	  GRobjid			my_solid ,SURF, dummy;
	  
	  base.type = height.type =  EMSdatainfo_numeric ;
	  
	  dist = BSdistptpt( msg, start, stop );
	  
	  baseEvent.event.value = dist ;
	  baseEvent.located_object[0].located_obj.objid = NULL_OBJID;
	  baseEvent.subtype = 1;
	  base.ptevent = &baseEvent ;
	  
	  height.ptevent = &heightEvent ;
	  
	  cvInfo.located_obj = *cvId ;
	  cvInfo.module_info = *cvEnv ;
	  
 	  stPlaneInfo.located_obj.objid = NULL_OBJID;
	  endPlaneInfo.located_obj.objid = NULL_OBJID;
	  
	  EMinitvgcnstr( msg, cst->env_info, cst->display, 0 ,&cnstlist);
	  
	  EMgetvgcnstr ( NULL, NULL, cst->env_info, cst->level,
			 cst->display, 0, 0, &cnstlist);
	  
	  cnstlist.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE | GRIS_NEW;
	  
	  EvalFromTo1( objRng, &cvInfo, start,stop, FromTo, msg );
	  if(!(*msg&1)) {
	    printf("\n Failed in EvalFromTo \n");
	  }
	  
	  BuildSrf( &cvInfo, FromTo, &cnstlist, &TempSrf, msg );
	  if(!(*msg&1)) {
	    printf("\n Failed in BuildSrf \n");
	  }
	  
	  SOL.osnum = TempSrf.osnum;
#ifdef DEBUG
	  printf("tempSrf[%d,%d] \n",TempSrf.objid,TempSrf.osnum);
#endif
	  vs$cap_surface( msg = msg, 
			  cst = &cnstlist, 
			  surface = &TempSrf, 
			  solid   = &SOL);

#ifdef DEBUG
	  printf("SOL[%d,%d] \n",SOL.objid,SOL.osnum);
#endif
	  
	  if(!(*msg&1)){
	    SOL.objid = NULL_OBJID;
	    om$send(msg      = message GRgraphics.GRdelete(msg,cnstlist.env_info),
		    senderid = NULL_OBJID,
		    targetid = SURF,
		    targetos = TempSrf.osnum );
	    om$send(msg      = message GRgraphics.GRdelete(msg,cnstlist.env_info),
		    senderid = NULL_OBJID,
		    targetid = SOL.objid,
		    targetos = SOL.osnum );
#ifdef DEBUG
 printf("\n Failed to make cut_cylinder for closed curve[%d,%d] \n",cvId->objid,cvId->osnum);
#endif
	    goto wrapup; 
	  }
	  else{
	    cylinder->objid = SOL.objid ;
	    cylinder->osnum = SOL.osnum ;
	    goto wrapup ;
	  }
	}
	
	cylinder->osnum = cst->env_info->_MD_OS ;
	  
	  EvalFromTo1( objRng, &cvInfo, start,stop, FromTo, msg );
	  if(!(*msg&1)) {
	    printf("\n Failed in EvalFromTo \n");
	  }
	  
	  BuildSrf( &cvInfo, FromTo, cst, &cylinder, msg );
	  if(!(*msg&1)) {
	    printf("\n Failed in BuildSrf \n");
	  }
	
	/*
	 * We want the cylinder's normal to point inwards. We compare the
	 * vector from center of curve projected onto curve to center of curve
	 * with the normal of the cylinder at center of curve projected onto
	 * surface. Beware that if the input curve is composite, the cylinder
	 * is a composite surface. In this case, take component #0 of curve
	 * and component #0 of surface (they match).
	 */
	sts = om$send(	msg	= message GRvg.GRgeomprops(
							msg,
							&cvEnv->_MATRIX_TYPE,
							cvEnv->_MATRIX,
							&gprops ),
		       senderid = NULL_OBJID,
		       targetid = cvId->objid,
		       targetos = cvId->osnum ) ;
	__CheckRC( sts, *msg, "GRvg.GRgeomprops", wrapup ) ;

	if( GRCC == gprops.subtype ) {
		int	count ;

		composite = TRUE ;
		sts = om$send(	msg	= message GRowner.GRget_components(
						msg,
						cvEnv,
						&curve,
						1,
						&count,
						0,
						0 ),
				senderid = NULL_OBJID,
				targetid = cvId->objid,
				targetos = cvId->osnum ) ;
		__CheckRC( sts, *msg, "GRowner.GRget_components", wrapup ) ;

		sts = om$send(	msg	= message GRvg.GRgeomprops(
							msg,
							&cvEnv->_MATRIX_TYPE,
							cvEnv->_MATRIX,
							&gprops ),
			      senderid = NULL_OBJID,
			      targetid = curve.objid,
		 	      targetos = curve.osnum ) ;
		__CheckRC( sts, *msg, "GRvg.GRgeomprops", wrapup ) ;

		if( GRLN == gprops.subtype ) {
			/* Cannot use a line seg to compute a center of
			 * curve: use whole curve...
			 */
			curve = *cvId ;
		}
	} else {
		composite = FALSE ;
		curve	= *cvId ;
	}
/*
	sts = VScenterOfCurve( msg, &curve, cvEnv, center ) ;
	__CheckRC( sts, *msg, "VScenterOfCurve", wrapup ) ;
*/
	BSfndptin(cvGeom,center,msg);
 	if(!(*msg&1))
	{
	  printf("\n BSfndptin failed \n");
	  sts = VScenterOfCurve( msg, &curve, cvEnv, center ) ;
	  __CheckRC( sts, *msg, "VScenterOfCurve", wrapup ) ;
	}
 
	sts = om$send( msg	= message GRgraphics.GRptproject(
							   msg,
							   &cvEnv->_MATRIX_TYPE,
							   cvEnv->_MATRIX,
							   center,
							   centerPjCv,
							   &pmPj ),
		       senderid = NULL_OBJID,
		       targetid = curve.objid,
		       targetos = curve.osnum ) ;
	__CheckRC( sts, *msg, "GRgraphics.GRptproject", wrapup ) ;

	BSmkvec( msg, ctrPjCvToCtr, centerPjCv, center ) ;

	if( composite ) {
	  IGRpoint tmp ;
	
	  sts = om$send( msg	= message GRgraphics.GRptproject(
						msg,
						&cst->env_info->_MATRIX_TYPE,
						cst->env_info->_MATRIX,
						center,
						tmp,
						&pmPj ),
			senderid = NULL_OBJID,
			targetid = cylinder->objid,
			targetos = cylinder->osnum ) ;
	  __CheckRC( sts, *msg, "GRgraphics.GRptproject", wrapup ) ;

	  surface = pmPj.leaf_id ;
	} else {
	  surface = *cylinder ;
	}

	sts = om$send( msg	= message EMSproject.EMpratpt(
						   msg,
						   &cst->env_info->_MATRIX_TYPE,
						   cst->env_info->_MATRIX,
						   centerPjCv,
						   normalPm,
						   &parmsCount ),
			senderid = NULL_OBJID,
			targetid = surface.objid,
			targetos = surface.osnum ) ;
	__CheckRC( sts, *msg, "EMSproject.EMpratpt", wrapup ) ;

	if( !parmsCount ) { normalPm[0] = 0.5 ; normalPm[1] = 0 ; }

	sts = vs$get_normal(	msg	= msg,
				sfId	= &surface,
				sfEnv	= cst->env_info,
				parm	= normalPm,
				normal	= normalSf ) ;
	__CheckRC( sts, *msg, "vs$get_normal", wrapup ) ;

	vs$get_geometry(msg            = msg,
			grobjId        = &surface,
			grobjEnv       = cst->env_info,
			geometry       = &sfGeom ) ;
	__CheckRC( 1, *msg, "vs$get_geometry", wrapup ) ;

	BSptonnsdsf( sfGeom, center, &nat_side, &bsrc);
	
	/*
	 * Commented out as the surface has to be revesed if the centre
	 * of the curve is on the opposite side of the natural normal
	 * and the pos_orient flag of the surface on which the normal 
	 * is evaluated. This checking is done by the above BS function.
	 */
/*	if( BSdotp( msg, ctrPjCvToCtr, normalSf ) < 0 )   */

	if( !(nat_side ) &&  (sfGeom->pos_orient) ||
	     (nat_side ) && !(sfGeom->pos_orient))  {
		sts = om$send(	msg	= message EMSsurface.EMrevorient( msg ),
				senderid= NULL_OBJID,
				targetid= cylinder->objid,
				targetos= cylinder->osnum ) ;
		__CheckRC( sts, *msg, "EMSsurface.EMrevorient", wrapup ) ;


	}	

	/*
	 * Move cylinder such as its middle coincides with the curve.
	 */
	MAtrlmx( msg, transVec, transMx ) ;
	MAtypemx( msg, transMx, &transMxType ) ;

	sts = om$send(	msg	= message GRgraphics.GRxform(
							msg,
							cst->env_info,
							&transMxType,
							transMx,
							&cylinder->objid ),
			senderid= NULL_OBJID,
			targetid= cylinder->objid,
			targetos= cylinder->osnum ) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;

	*msg = MSSUCC ; sts = OM_S_SUCCESS ;

	wrapup :
                _FREE( cvGeom );
		_FREE( sfGeom )
		if( !( sts & 1 & *msg ) ) {
			vs$bulk_delete( grids	= cylinder,
					theEnv	= cst->env_info ) ;
		}
		return sts ;

} /* VSmakePenetratingCyl */
/*----------------------------------------------------------------------------*/
int VScenterOfCurve( msg, cvId, cvEnv, center )

long		*msg ;
struct GRid	*cvId ;
struct GRmd_env *cvEnv ;
IGRpoint	center ; {

	/*
	 * Input curve is supposed planar ...
	 */
	struct IGRbsp_curve	*cvGeom ;
	double			area ;

	cvGeom = NULL ;

	vs$get_geometry(	msg	= msg,
				grobjId = cvId,
				grobjEnv= cvEnv,
				geometry= &cvGeom ) ;
	if( !( *msg & 1 ) ) goto wrapup ;

	if( cvGeom->phy_closed ) {
		BSctrarplcv( 1, &cvGeom, center, &area, msg ) ;
		if( BSERROR( *msg ) ) { *msg = MSFAIL ; goto wrapup ; }
	} else {
		/*
		 * Well, close it !
		 */
		struct IGRbsp_curve	lineSeg,
					*cvs[2] ;
		double			lsPoles[12],
					lsKnots[6] ;
		IGRpoint		end0,
					end1 ;
		int			i ;

		lineSeg.poles	= lsPoles ;
		lineSeg.knots	= lsKnots ;

		BScveval( cvGeom, 0., 0, (IGRpoint *) end0, msg ) ;
		BScveval( cvGeom, 1., 0, (IGRpoint *) end1, msg ) ;
		BSlngen( msg, end0, end1, &lineSeg, &i ) ;

		cvs[0] = cvGeom ;
		cvs[1] = &lineSeg ;

		BSctrarplcv( 2, cvs, center, &area, msg ) ;
		if( BSERROR( *msg ) ) { *msg = MSFAIL ; goto wrapup ; }
	}

	*msg = MSSUCC ;

	wrapup :
		_FREE( cvGeom ) ;
		return *msg & 1 ;

} /* VScenterOfCurve */
/*----------------------------------------------------------------------------*/
end implementation EMSproject ;
