/* $Id: VLunwDimBvl.I,v 1.1 2001/09/19 14:23:28 ramarao Exp $  */
/***************************************************************************
 * I/LOFT
 *
 * File:        isdp/loft/src/VLunwDimBvl.I
 *
 * Description: Functions to place bevel dimensions on unwrap.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLunwDimBvl.I,v $
 *      Revision 1.1  2001/09/19 14:23:28  ramarao
 *      Implemented CR# 5546.
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      09/19/01        Rama Rao        File Creation.
 ***************************************************************************/

class implementation VDSroot;

#include "VDobj.h"
#include "v_miscmacros.h"
#include "vldbgmacros.h"

#include "bsmkvec.h"
#include "bsnorvec.h"
#include "bsmvecsclr.h"

from GRcurve	import	GRmidpoint, GRtotlength;

IGRlong VLunwDimensionCurve( struct GRobj_env		*contourOE,
			     struct GRid		*curveID,
			     IGRint			outside,
			     IGRdouble			offset,
			     struct GRid		*dimLineIDs )
{
BSrc			rc;
IGRlong			sts, msg;
IGRint			i;
IGRshort		transMxType;
IGRdouble		factor, mid_par;
IGRboolean		flag;
IGRpoint		contourCenter, crvCenter, prjPnt, plnPnt, 
			spt, ept, point;
IGRvector		transVec, plnNorm;
IGRmatrix		transMx;
struct GRobj_env	crvOE;
struct GRvg_construct	cst;
struct IGRbsp_curve	*crvGeom=NULL;

   SetProc( VLunwDimensionCurve ); Begin

   VDsupInitCnst( &cst );

   sts = _VD_SEND_OBJN( contourOE->obj_id, GRvg.GRcenter( &msg,
            &contourOE->_matrix_type, contourOE->_matrix, contourCenter ));
   __CheckRC( sts, msg, "GRvg.GRcenter", wrapup );
   __DBGpr_vec( "Unwrap Contour Center", contourCenter );

   sts = _VD_SEND_OBJN( *curveID, GRcurve.GRmidpoint( &msg,
          &contourOE->_matrix_type, contourOE->_matrix, NULL, crvCenter ) );
   __CheckRC( sts, msg, "GRcurve.GRmidpoint", wrapup );
   __DBGpr_vec( "Bevel Curve Center", crvCenter );

   crvOE.obj_id  = *curveID ;
   crvOE.mod_env = contourOE->mod_env;
   sts = VLgetGeometry( &crvOE, FALSE, NULL_OBJID, 
                        (IGRchar **)&crvGeom, &msg );
   __CheckRC( sts, msg, "VLgetGeometry: Bevel Curve", wrapup ) ;

   /* Make a plane perpendicular to bvlCrv at mid point of bvlCrv */
   flag = FALSE ; factor=1.0 ; mid_par=0.5;
   BSpl_nor_tc( &rc, crvGeom, &mid_par, &flag, &factor,
		plnPnt, plnNorm, NULL );
   if( BSERROR(rc) ) goto wrapup;

   /* Project Contour Center to mid plane to get projected point pnt */
   BSproj1( &rc, contourCenter, plnNorm, plnPnt, prjPnt ) ;

   if( outside ) BSmkvec( &rc, transVec, prjPnt, crvCenter ) ;
   else 	 BSmkvec( &rc, transVec, crvCenter, prjPnt ) ;
   if( BSERROR(rc) ) goto wrapup;
   __DBGpr_vec( "Translation Vector", transVec );

   BSnorvec( &rc, transVec );
   if( BSERROR(rc) ) goto wrapup;
   __DBGpr_vec( "Normalized Translation Vector", transVec );

   BSmvecsclr( &rc, &offset, transVec );
   if( BSERROR(rc) ) goto wrapup;

   MAidmx( &msg, transMx ) ;
   VStranslatemx( transVec, transMx, transMx ) ;
   MAtypemx( msg, transMx, &transMxType ) ;

   dimLineIDs[0].osnum = contourOE->_osnum;
   sts = _VD_SEND_OBJN( *curveID, GRgraphics.GRcptform( &msg,
	  		&contourOE->mod_env, transMx, 
			cst.env_info, &dimLineIDs[0].objid ) );
   __CheckRC( sts, msg, "GRgraphics.GRcptform", wrapup );
   __DBGpr_obj( "Copied & Transformed Curve", dimLineIDs[0] );

   sts = VLendpts( &msg, curveID, &contourOE->mod_env, spt, ept );
   __CheckRC( sts, msg, "VLendpts: Bevel Curve", wrapup );

   for( i=0; i<3; ++i ) point[i] = spt[i] + (2*transVec[i]) ;

   sts = VLcreateLineSeg( spt, point, cst.env_info, &cst, 
			  &dimLineIDs[1], &msg );
   __CheckRC( sts, msg, "VLcreateLineSeg: Start Point", wrapup );

   for( i=0; i<3; ++i ) point[i] = ept[i] + (2*transVec[i]) ;

   sts = VLcreateLineSeg( ept, point, cst.env_info, &cst, 
			  &dimLineIDs[2], &msg );
   __CheckRC( sts, msg, "VLcreateLineSeg: End Point", wrapup );

wrapup:
   _FREE( crvGeom );
   End ;
   return sts ;
}

end implementation VDSroot;
