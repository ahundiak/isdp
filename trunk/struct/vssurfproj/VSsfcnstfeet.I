/*
	I/STRUCT
*/ 
class implementation VSsurfOfProj ;

#include <stdio.h>
#include "bserr.h"
#include "EMSmsgdef.h"
#include "vsiomacros.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bscrossp.h"
#include "bscveval.h"
#include "bsnorvec.h"
#include "vsexpvalue.h"
#include "vsvecmxproto.h"

extern OMuword	OPP_EMSproject_class_id ;

from EMSplane	import EMplaneDef ;
from EMSproject import EMplace_surface_of_projection ;
/*----------------------------------------------------------------------------*/
method ACconstruct_feet(long		*msg ;
			int		purpose,
					countOfInputs ;
			struct GRid	listOfInputs[] ;
			struct GRmd_env	*MyEnv ;
			int		*countOfOutputs ;
			struct GRid 	*listOfOutputs ) {

	long			sts ;		  /* OM return code	      */
	struct GRvg_construct 	cst ;		  /* My construction list     */
	struct GRsymbology	mySymb ;	  /* My symbology	      */
	struct GRobj_env	grInputs[3] ;	  /* 0: plane		      */
						  /* 1: curve		      */
						  /* 2: width ( expression )  */
	struct IGRplane 	planeDef ;	  /* Plane definition	      */
	double			normalPlane[3] ;  /* Normal of plane	      */
	double			pointPlane[3] ;   /* Point on plane	      */
	double			pntTangCurve[6] ; /* Point and tangent of     */
	                                          /* curve at parameter 0.    */
	double			vecProjection[3] ;/* Vector of projection     */
	double			width ;           /* value of width           */
	struct IGRbsp_curve	*curveGeom ;	  /* Curve definition	      */
	long			bsRC ;		  /* BS return code	      */
	double			origin[3] ;	  /* Origin of projection     */

	if( !countOfInputs ) { *msg = MSINARG ; return OM_W_ABORT ; }

	curveGeom = NULL ; listOfOutputs[0].objid = NULL_OBJID ;
	
	vs$dotsInStsFld( dots = 0 ) ;

	/*
	 * Fill construction list.
	 */
	sts = om$send(	msg	= message GRvg.GRgetsymb( msg, &mySymb ),
			mode	= purpose & VS_K_InitialPlacement
					? OM_e_wrt_message
					: OM_e_wrt_object,
			targetid= my_id ) ;
			
	__CheckRC( sts, *msg, "GRvg.GRgetsymb", wrapup ) ;
	
	vs$fill_cnst_list(	Env_info	= MyEnv,
				Display		= &mySymb.display_attr,
				Level		= mySymb.level,
				Cnst_list	= cst ) ;

	/*
	 * Get parents.
	 */
	sts = om$send(	msg	= message VScpx.VSget_graphic_input(
					msg, countOfInputs, listOfInputs,
					grInputs ),
			targetid = my_id ) ;
	__CheckRC( sts, *msg, "VScpx.VSget_graphic_input", wrapup ) ;

	vs$dotsInStsFld() ;
	
	/*
	 * Retrieve normal of plane.
	 */
 	planeDef.normal	= normalPlane ;
 	planeDef.point	= pointPlane ;
 	
	sts = om$send( msg   = message EMSplane.EMplaneDef( 
						     msg,
                                                     &grInputs[0]._matrix_type,
                                                     grInputs[0]._matrix,
                                                     &planeDef ),
		       targetos = grInputs[0]._osnum,
		       targetid = grInputs[0]._objid ) ;
		       
	__CheckRC( sts, *msg, "EMSplane.EMplaneDef", wrapup ) ;
	
	/*
	 * Retrieve point and tangent of curve at parameter 0.
	 */
	vs$get_geometry( msg		= msg,
			 grobjId 	= &grInputs[1].obj_id,
			 grobjEnv	= &grInputs[1].mod_env,
			 geometry	= &curveGeom ) ;
			 
	__CheckRC( 1, *msg, "vs$get_geometry", wrapup ) ;
			 
	BScveval(	curveGeom,
			0.,
			1,
			(IGRpoint *) pntTangCurve,
			&bsRC ) ;
	if( BSERROR( bsRC ) ) { *msg = EMS_E_CurveError ; goto wrapup ; }
	
	/*
	 * Get value of width.
	 */
	sts = VSexpValue( grInputs[2]._objid, grInputs[2]._osnum, &width ) ;
	__CheckRC( sts, 1, "VSexpValue", wrapup ) ;
	
	/*
	 * Compute vector of projection which is the norme vector result of the
	 * cross product between the normal of plane and the vector tangent of
	 * curve, scale by width.
	 */
	BScrossp( &bsRC, normalPlane, pntTangCurve + 3, vecProjection ) ;
	BSnorvec( &bsRC, vecProjection ) ;
	VSscalvc( width, vecProjection, vecProjection ) ;
	
	/*
	 * Create surface of projection.
	 */
	origin[0] = origin[1] = origin[2] = 0. ;	 

	listOfOutputs[0].osnum = cst.env_info->_MD_OS ;
		
	sts = om$construct( 
		classid = OPP_EMSproject_class_id,
		osnum 	= listOfOutputs[0].osnum,
		p_objid	= &listOfOutputs[0].objid,
		msg 	= message EMSproject.EMplace_surface_of_projection(
 							&cst,
 							&grInputs[1].obj_id,
 							&grInputs[1].mod_env,
 							NULL,
 							0,
 							origin,
 							vecProjection,
 							FALSE,
 							&listOfOutputs[0].objid ) ) ;
		       
	__CheckRC( sts, *cst.msg, "EMSproject.EMplace_surface_of_projection", wrapup ) ;
	
	*countOfOutputs = 1 ;
	/*
	 * Update object tag, don't check return code: will be
	 * OM_W_NOTTAGGED if object has no tag connection.
	 */
	om$change_tag_version() ;

	wrapup :		
		vs$dotsInStsFld( dots = clear ) ;
		
		_FREE( curveGeom ) ;
		if( !( sts & 1 & *msg ) ) {
			vs$bulk_delete(	grids	= listOfOutputs,
					theEnv	= MyEnv ) ;
			if( purpose & VS_K_InitialPlacement ) {
				if( *msg & 1 ) *msg = MSFAIL ;
				sts = OM_W_ABORT ;
			} else {
				if( *msg & 1 ) *msg = EMS_E_NoSolution ;
	    			sts = OM_S_SUCCESS ;
	    		}
		}
			
		return sts ;

} /* method ACconstruct_feet */
/*----------------------------------------------------------------------------*/

end implementation VSsurfOfProj ;
