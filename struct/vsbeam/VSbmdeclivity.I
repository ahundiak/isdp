/* $Id: VSbmdeclivity.I,v 1.1 2001/11/09 23:28:10 ramarao Exp $  */
/*************************************************************************
 * I/STRUCT
 *
 * File:        isdp/struct/vsbeam/VSbmdeclivity.I
 *
 * Description: Function to retrieve the declivity angle of a stiffener.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSbmdeclivity.I,v $
 *      Revision 1.1  2001/11/09 23:28:10  ramarao
 *      Implemented CR# 3976.
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      11/10/01   Rama Rao     File Creation
 *************************************************************************/

class implementation VScpx;

#include <math.h>
#include "VDobj.h"
#include "bsmdstptcv.h"
#include "bsmkvec.h"
#include "bsnorvec.h"
#include "bsvalues.h"
#include "bscrossp.h"
#include "maang2vc.h"
#include "vsmiscmacros.h"
#include "vssectiondef.h"
#include "vsplatedef.h"
#include "vsstfnrdef.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"

from GRcurve	import	GRendpts;
from VSbeam 	import	VSgetSegmentEnds, VSgetSupportAxis, 
			VSextractProfile;
from VSxscurve	import	VStransUsrNmToCmp;
from VSstfBeam  import  VSgetPlateSide, VSgetStiffenedPlate;
from VSfeature  import  VSforwardToOriginal;

extern GRclassid OPP_VStwsBeam_class_id, OPP_VSbeam_class_id;

IGRlong VSstfGetDeclivityAngle( struct GRobj_env	beamOE,
				IGRint			end_num,
				IGRdouble		*declivity )
{
BSrc			rc;
IGRlong			sts, msg;
IGRint			numParam, mySide;
IGRdouble		par, mdist, angle, sfParam[2];
IGRpoint		end_pt[2], pt, startpt, endpt, use_pt;
IGRvector		vecWebLeft, nmOfSurf, nmOfWebLeft;
IGRchar			*sideName;
struct GRid		xsID, cmpID;
struct GRobj_env	axisOE, srfOE, plateOE;
struct IGRbsp_curve	*crvGeom=NULL;
struct GRvg_construct	cst;
struct IGRplane		plane;

   VDsupInitCnst( &cst ) ;

   xsID.objid = NULL_OBJID;
   *declivity = 90.0;

   __DBGpr_obj( "Input Beam Object", beamOE.obj_id );

   if( !vs$is_ancestry_valid( object  = &beamOE.obj_id,
                              classid = OPP_VSbeam_class_id  ) )
     return MSFAIL;

   sts = om$send( msg = message VSfeature.VSforwardToOriginal(
                        &msg,
                        OM_e_wrt_object,
		        msg     = message VSstfBeam.VSgetPlateSide(
                                       &msg, &mySide ) ),
                  senderid = NULL_OBJID,
                  targetid = beamOE._objid,
                  targetos = beamOE._osnum  );
   __CheckRC( sts, msg,"VSstfBeam.VSgetPlateSide", wrapup ) ;

   switch( mySide )
   {
       default                  :
       case VS_K_stOnTopOfPlate :
                sideName = VS_K_plTopSfPathABS ;
                break ;
       case VS_K_stOnBotOfPlate :
                sideName = VS_K_plBotSfPathABS ; break ;
   }
   __DBGpr_str( "Stiffener Side", sideName );

   if( vs$is_ancestry_valid( object  = &beamOE.obj_id,
		      	     classid = OPP_VStwsBeam_class_id  ) )
   {
      struct GRid 	bmSuppID, parentID;

      vdobj$GetParent( objOE = &beamOE, idx = 0, parentID = &bmSuppID );
      if( bmSuppID.objid == NULL_OBJID ) goto wrapup;

      vdobj$GetParent( objID = &bmSuppID, idx = 0, parentID = &parentID );
      if( parentID.objid == NULL_OBJID ) goto wrapup;

      vdobj$GetParent( objID = &parentID, idx = 0, 
		       parentID = &plateOE.obj_id );
      if( plateOE._objid == NULL_OBJID ) goto wrapup;
      plateOE.mod_env = beamOE.mod_env;
   }
   else
   {
      sts = om$send( 	msg = message VSfeature.VSforwardToOriginal(
                        &msg,
                        OM_e_wrt_object,
      		  	msg = message VSstfBeam.VSgetStiffenedPlate(
                                &msg, &plateOE ) ),
                  senderid = NULL_OBJID,
                  targetid = beamOE._objid,
                  targetos = beamOE._osnum ) ;
      __CheckRC( sts, msg, "VSstfBeam.VSgetStiffenedPlate", wrapup ) ;
   }
   __DBGpr_obj( "Plate Object", plateOE.obj_id );

   srfOE._objid = NULL_OBJID;
   vdobj$GetFoot( objOE    = &plateOE,
                  footName = sideName,
                  footOE   = &srfOE      );
   if( srfOE._objid == NULL_OBJID ) goto wrapup;
   __DBGpr_obj( "Plate Surface", srfOE.obj_id );

   sts = om$send( msg = message VSbeam.VSgetSegmentEnds(
				  &msg, &beamOE.mod_env, end_pt ),
		  senderid = NULL_OBJID,
		  targetid = beamOE._objid,
		  targetos = beamOE._osnum   );
   __CheckRC( sts, msg, "VSbeam.VSgetSegmentEnds", wrapup );
   __DBGpr_vec( "Beam Start Point", end_pt[0] );
   __DBGpr_vec( "Beam End Point", end_pt[1] );

   if( end_num == 0 ) 	dblcpy( use_pt, end_pt[0], 3 );
   else			dblcpy( use_pt, end_pt[1], 3 );

   sts = om$send( msg = message VSbeam.VSgetSupportAxis(
                                  &msg, &beamOE.mod_env, &axisOE ),
                  senderid = NULL_OBJID,
                  targetid = beamOE._objid,
                  targetos = beamOE._osnum   );
   __CheckRC( sts, msg, "VSbeam.VSgetSupportAxis", wrapup );
   __DBGpr_obj( "Beam Axis", axisOE.obj_id );

   sts = vs$get_geometry( msg = &msg, grobjId = &axisOE.obj_id,
			  grobjEnv = &axisOE.mod_env, geometry = &crvGeom );
   __CheckRC( sts, msg, "VSget_geometry:Beam Axis", wrapup );

   BSmdstptcv( crvGeom, use_pt, &par, pt, &mdist, &rc );
   __CheckBSRC( rc, "BSmdstptcv:Beam Axis", wrapup );
   __DBGpr_dbl( "Starting Parameter", par );

   sts = om$send( msg = message VSfeature.VSforwardToOriginal(
                        &msg,
                        OM_e_wrt_object,
   		        msg = message VSbeam.VSextractProfile(
                           	&msg, &beamOE.mod_env, NULL, NULL, par,
				&cst, AC_3D_REP, &xsID ) ),
                  senderid = NULL_OBJID,
                  targetid = beamOE._objid,
                  targetos = beamOE._osnum   );
   __CheckRC( sts, msg, "VSbeam.VSextractProfile", wrapup );
   __DBGpr_obj( "CrossSection Geometry", xsID );

   sts = om$send( msg = message VSxscurve.VStransUsrNmToCmp(
				 &msg, VS_K_nmWebL, NULL, &cmpID ),
                  senderid = NULL_OBJID,
                  targetid = xsID.objid,
                  targetos = xsID.osnum   );
   __CheckRC( sts, msg, "VSbeam.VStransUsrNmToCmp", wrapup );
   __DBGpr_obj( "Web Left Component Curve ID", cmpID );

   sts = om$send ( msg = message GRcurve.GRendpts(
                         &msg, &cst.env_info->md_env.matrix_type,
			 cst.env_info->md_env.matrix, startpt, endpt ),
                   senderid = NULL_OBJID,
                   targetid = cmpID.objid,
                   targetos = cmpID.osnum );
   __CheckRC( sts, msg, "GRcurve.GRendpts", wrapup );
   __DBGpr_vec( "Web Left Component Curve Start Point", startpt );
   __DBGpr_vec( "Web Left Component Curve Point", endpt );

   BSmkvec( &rc, vecWebLeft, startpt, endpt ) ;
   __CheckBSRC( rc, "BSmkvec", wrapup );

   plane.point  = pt;
   plane.normal = nmOfSurf;

   sts = om$send ( msg = message GRvg.GRdetplane( &msg,
			  &cst.env_info->md_env.matrix_type, 
			  cst.env_info->md_env.matrix, &plane ),
                   senderid = NULL_OBJID,
                   targetid = xsID.objid,
                   targetos = xsID.osnum );
   __CheckRC( sts, msg, "GRcurve.GRendpts", wrapup );
   __DBGpr_vec( "CrossSection Normal", nmOfSurf );

   BScrossp( &rc, vecWebLeft, nmOfSurf, nmOfWebLeft );
   __CheckBSRC( rc, "BScrossp", wrapup );

   BSnorvec( &rc, nmOfWebLeft );
   __CheckBSRC( rc, "BSnorvec", wrapup );
   __DBGpr_vec( "Web Left Plane Normal", nmOfWebLeft );

   sts = om$send( msg = message GRvg.EMpratpt( &msg, &srfOE._matrix_type,
			  srfOE._matrix, use_pt, sfParam, &numParam ),
                  senderid = NULL_OBJID,
                  targetid = srfOE._objid,
                  targetos = srfOE._osnum ) ;
   __CheckRC( sts, msg, "GRvg.EMpratpt", wrapup ) ;
   __DBGpr_dbl( "Surface U-parameter", sfParam[0] );
   __DBGpr_dbl( "Surface V-parameter", sfParam[1] );

   sts = vs$get_normal( msg    = &msg,
                        sfId   = &srfOE._grid,
                        sfEnv  = &srfOE.mod_env,
                        parm   = sfParam,
                        normal = nmOfSurf ) ;
   __CheckRC( sts, msg, "vs$get_normal", wrapup ) ;
   __DBGpr_vec( "Plate Surface Normal", nmOfSurf ) ;

   MAang2vc( &rc, nmOfSurf, nmOfWebLeft, &angle ) ;

   if( angle > 0.5*M_PI && angle < 1.5*M_PI )
   {
       angle = angle - M_PI;
   } 
   else if ( angle >= 1.5*M_PI && angle <= 2*M_PI ) 
   {
       angle = angle - 2*M_PI;
   }
   angle = angle*180/M_PI;

   *declivity= fabs( angle ) ;

   __DBGpr_dbl( "Declivity Angle", angle );

wrapup:
   if( xsID.objid != NULL_OBJID )
     vs$bulk_delete( grids = &xsID, theEnv = cst.env_info );

   _FREE( crvGeom );
   return 1;
}

end implementation VScpx;
