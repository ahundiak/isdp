/* $Id: VSintcvsf.I,v 1.2 2001/02/14 21:18:40 ramarao Exp $  */
/***************************************************************************
* I/STRUCT
*
* File: vsgeom/VSintcvsf.I 
*
* Description:
*
* Dependencies:
*
* Revision History:
*      $Log: VSintcvsf.I,v $
*      Revision 1.2  2001/02/14 21:18:40  ramarao
*      Modifications Related to __DBGpr_com() macro.
*
*      Revision 1.1.1.1  2001/01/04 21:10:40  cvs
*      Initial import to CVS
*
# Revision 1.2  1999/11/12  20:06:32  pinnacle
# tr179900753
#
*
* History:
*      MM/DD/YY  AUTHOR  DESCRIPTION
*      08/18/99  Jayadev For Planar freeform surfaces TR179900753
***************************************************************************/
/*
	I/STRUCT
	
	This function intersects a curve and a surface. 
	`pntInt' is the first intersection point with respect to the 
	curve's intersection and `pm' the paramater value of this point on 
	the curve.
	If no intersection is found, this function returns EMS_W_NoSolution.
*/ 
class implementation GRvg ;

#include <stdio.h>
#include <stdlib.h>
#include "msdef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "EMSmsgdef.h"
#include "vspart.h"
#include "vsglobals.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
#include "vsgeommacros.h"
#include "vssplitdef.h"
/*
 * Includes of function prototypes.
 */
#include "EMSsffmacros.h"
#include "vsintcvsf.h"

extern OMuword          OPP_EMSgenbs_class_id; // added for TR179900753

from EMSplane	import EMplaneDef ;
from GRlinear	import GRgetpolyline ;
/*----------------------------------------------------------------------------*/
long VSintersectCurveAndSurface( msg, curveId, curveEnv,
				      surfId, surfEnv, 
				 infIfPlanar,
	 		         pntInt, pm )

long		*msg ;
struct GRid	*curveId,
		*surfId ;
struct GRmd_env	*curveEnv,
		*surfEnv ;
int		infIfPlanar ;
IGRpoint	pntInt ;
double		*pm ; {

  /* The following five variables are added for TR179900753 */
        IGRlong                         stat;  
	struct GRid                     resID;
	struct GRobj_env                surfOE;
	OMuword                         classID;
	int                             tried_once;

	int				sts,
					is_planar = FALSE ,
					action = 1,
					count = 1 ;
	struct  IGRbsp_curve		*curveGeom = NULL ;
	struct  IGRplane		planeDef ;
	double  			normalSurf[3],
					pointSurf[3] ;
	int				nb_inter = 0 ;
	struct GRlc_info		surfInfo,
					curveInfo ;
	struct GRvg_construct		cst ;
	struct GRid			*pntsId = NULL ;
	struct IGRpolyline		point ;
				
        // init
	resID.objid = NULL_OBJID; //TR179900753
	tried_once  = FALSE;

       	/*
       	 * Fill construction list.
       	 */       	 
	vs$fill_cnst_list(	Msg		= msg,
				Env_info	= surfEnv,
				Cnst_list	= cst ) ;

        /*
         * Check if surface is planar.
         */
        if( infIfPlanar ) {
        	is_planar = vs$is_surface_planar( msg 		= msg,
        					  surfId	= surfId,
        					  surfEnv	= surfEnv ) ;
        				  
	}
	
	/*
	 * If surface is planar, it will be considered as an infinite plane.
	 */
	om$get_classid( objid      = surfId->objid,
			osnum      = surfId->osnum,
			p_classid  = &classID);

	if( is_planar && (classID != OPP_EMSgenbs_class_id)) {//for TR179900753
		/*
		 * Retrieve normal and one point of planar surface.
		 */
		planeDef.normal = normalSurf ;
		planeDef.point  = pointSurf ;

		sts = om$send( msg = message EMSplane.EMplaneDef( 
							 msg,
						         &surfEnv->_MATRIX_TYPE,
						         surfEnv->_MATRIX,
						         &planeDef ) ,
			       senderid = surfId->objid,
			       targetid = surfId->objid,
			       targetos = surfId->osnum ) ;
		__CheckRC( sts, *msg, "EMSplane.EMplaneDef", wrapup ) ;
		
		/*
		 * Intersect surface and curve.
		 */		 
		sts = vs$get_geometry( msg	= msg,
				       grobjId	= curveId,
				       grobjEnv	= curveEnv,
				       geometry	= &curveGeom ) ;
		__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

		nb_inter = vs$isPlaneClippingCurve(
						cvGeom		= curveGeom,
						plane		= &planeDef,
						firstIntPoint	= pntInt,
						firstIntPm	= pm ) ;
		if( nb_inter < 1 ) {
			/*
			 * No solution found.
			 */
			 *msg = EMS_W_NoSolution ;
			 sts = OM_W_ABORT ;
			 goto wrapup ;
		}
	} else {
		double	u ;

		/*
		 * Surface is not planar. Intersect the surface and the curve.
		 */
		surfInfo.located_obj 	= *surfId ;
		surfInfo.module_info 	= *surfEnv ;
		curveInfo.located_obj	= *curveId ;
		curveInfo.module_info 	= *curveEnv ;
               
/*****************start modification for TR179900753 **************************/
		
		/* Surface is planar but a freeform surface (EMSgenbs class)
		 * extend it for intersection 
		 */
		if(is_planar) {
		  surfOE.obj_id.objid = (*surfId).objid;
		  surfOE.obj_id.osnum = (*surfId).osnum;
		  surfOE.mod_env      = *surfEnv;
		  
		  stat = VSextendOffsetSurface(&surfOE,1000.0,0.0,surfEnv,&resID);
		  if(!(stat&1)) 
	          {
  __DBGpr_com( "Attempt to extend the planar freeform surface failed" ) ;
		  }
		  else{ 
		    if(resID.objid != NULL_OBJID) surfInfo.located_obj = resID;
		  }
		}
		
/*******************end modification for TR179900753 **************************/
	 try_again:	
		sts = EMintersect_two_element( &surfInfo,
	 				       &curveInfo,
	 				       TRUE,
	 				       &cst,
	 				       &nb_inter,
	 				       &pntsId,
					       msg ) ;	
		if( nb_inter < 1 ) {
		if((!is_planar) && (!tried_once)) // check if already tried
		{ // this block of code is added for TR179900753
		  // extend the surface and try again
		  nb_inter = 0;
		  pntsId   = NULL;

		  surfOE.obj_id.objid = (*surfId).objid;
		  surfOE.obj_id.osnum = (*surfId).osnum;
		  surfOE.mod_env      = *surfEnv;
		  
		  stat = VSextendOffsetSurface(&surfOE,1000.0,0.0,surfEnv,&resID);
		  if(!(stat&1)){
 __DBGpr_com( "Attempt to extend the non_planar freeform surface failed" ); 
	 goto give_up;
		  }
		  else{ 
		    if(resID.objid != NULL_OBJID) surfInfo.located_obj = resID;
		    else goto give_up;
		  }
		  
		  tried_once = TRUE;
		  goto try_again;
		} // end of block for TR179900753
		give_up:
			if( *msg == EMS_E_NoDynamicMemory ) {
			 	 sts = OM_E_NODYNMEM ;
			} else {
				*msg = EMS_W_NoSolution ;
				sts = OM_W_ABORT ;
			}
			goto wrapup ;
		} 
		
		/*
		 * Retrieve definition of the first intersection point.
		 */
		point.points	= pntInt ;
		point.num_points= 1 ;
		
		sts = om$send( msg	= message GRlinear.GRgetpolyline(
							msg,
							&surfEnv->_MATRIX_TYPE,
							surfEnv->_MATRIX,
							&action,
							&point ),
		               senderid = pntsId[0].objid,
		               targetid = pntsId[0].objid,
		               targetos = pntsId[0].osnum ) ;
		__CheckRC( sts, *msg, "GRlinear.GRgetpolyline", wrapup ) ;
		
		/*
		 * Retrieve parameter value on the curve at the first 
		 * intersection point.
		 */
		sts = om$send(	msg	= message GRvg.EMpratpt(
		 					msg,
							&surfEnv->_MATRIX_TYPE,
							surfEnv->_MATRIX,
							pntInt,
							&u,
							&count ),
			senderid= curveId->objid,
			targetid= curveId->objid,
			targetos= curveId->osnum ) ;
		__CheckRC( sts, *msg, "GRvg.EMpratpt", wrapup ) ;

		*pm = u ;
				
		/*
		 * Delete intersections found.
  		 */
		vs$bulk_delete( count	= nb_inter,
				grids	= pntsId,
				theEnv	= surfEnv ) ;
	}

	wrapup :

	  // for TR179900753
	  if(resID.objid != NULL_OBJID) 
	    vs$bulk_delete( count	= 1,
			    grids	= &resID,
			    theEnv	= surfEnv ) ;
	
	_FREE( curveGeom ) ;
	_FREE( pntsId ) ;
	return sts ;
	
} /* VSintersetCurveAndSurface */
/*----------------------------------------------------------------------------*/

end implementation GRvg ;
