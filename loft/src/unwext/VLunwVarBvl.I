/* $Id: VLunwVarBvl.I,v 1.1 2001/09/15 20:40:23 ramarao Exp $  */
/***************************************************************************
 * I/LOFT
 *
 * File:        isdp/loft/src/VLunwVarBvl.I
 *
 * Description: Functions to extend the unwrap contour in variable bevel case
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLunwVarBvl.I,v $
 *      Revision 1.1  2001/09/15 20:40:23  ramarao
 *      Fixed TR# 5568. Extended the unwrap contour in variable bevel case.
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      09/15/01        Rama Rao        File Creation.
 ***************************************************************************/

class implementation VDSroot;

#include <math.h>
#include "EMSmsgdef.h"
#include "VDobj.h"
#include "v_miscmacros.h"
#include "v_datamacros.h"
#include "v_geommacros.h"
#include "vldbgmacros.h"

#include "bsmdstptcv.h"
#include "bscveval.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bsdotp.h"
#include "bsdistptpt.h"
#include "bsmerge_cv.h"
#include "bsarclnparc.h"
#include "bsfreecv.h"

from GRcurve 	 import  	GRmidpoint, GRptextend;
from GRcompcurve import		EMmakecomp;

extern GRclassid OPP_GRpoint_class_id;

extern OM_S_CHANSELECT  AS_to_comp;

static IGRlong VLunwGetTwoClosestCurves( IGRpoint		ptOnVarCrv,
					 IGRpoint       	point,
                                         IGRint         	crvCount,
                                         OM_S_OBJECT_LINKAGE    *crvList,
					 struct GRmd_env	*env,
                                         IGRint         	*index1,
                                         IGRint         	*index2    )
{
BSrc			rc;
IGRlong			sts=MSSUCC, msg;
IGRint                  i;
IGRdouble		par, mdist, dist1, dist2, eval[6];
IGRpoint		crvPnt;
IGRvector		varVec, vec1, vec2;
struct GRobj_env	crvOE;
struct IGRbsp_curve	*crvGeom=NULL;

  SetProc( VLunwGetTwoClosestCurves  ); Begin

  dist1 = dist2 = 1.0e+10;

  crvOE.mod_env = (*env) ;
  __DBGpr_int( "Curve Count", crvCount );

  for( i=0; i<crvCount; ++i )
  {
     crvOE._objid = crvList[i].S_objid;
     crvOE._osnum = crvList[i].osnum;

     _FREE( crvGeom );
     sts = VLgetGeometry( &crvOE, FALSE, NULL_OBJID, 
			  (IGRchar **)&crvGeom, &msg );
     if( !(sts&1&msg) )  continue;

     BSmdstptcv( crvGeom, point, &par, crvPnt, &mdist, &rc) ;
     if( BSERROR(rc) ) continue;

     BScveval( crvGeom, par, 1, (IGRpoint *)eval, &rc );
     if( BSERROR(rc) ) continue;

     BSnorvec( &rc, &eval[3] );
     if( BSERROR(rc) ) continue;

     if( mdist < dist1 )      
     { 
        dist2 = dist1;
        *index2 = *index1;
        dblcpy( vec2, vec1, 3 );
        __DBGpr_vec( "vec2", vec2 );

	dist1   = mdist; 
	*index1 = i;
	dblcpy( vec1, &eval[3], 3 );
	__DBGpr_vec( "vec1", vec1 );
     }
     else if( mdist < dist2 ) 
     { 
	dist2 = mdist; 
	*index2 = i; 
	dblcpy( vec2, &eval[3], 3 );
	__DBGpr_vec( "vec2", vec2 );
     }
  }

  if( fabs( BSdistptpt( &rc, ptOnVarCrv, point ) ) < 0.001 ) goto wrapup;

  BSmkvec( &rc, varVec, ptOnVarCrv, point );
  if( BSERROR(rc) ) goto wrapup;

  BSnorvec( &rc, varVec );
  if( BSERROR(rc) ) goto wrapup;

  __DBGpr_vec( "varVec", varVec );
  __DBGpr_vec( "vec1", vec1 );
  __DBGpr_vec( "vec2", vec2 );

  if( fabs( BSdotp( &rc, varVec, vec1 ) ) <
      fabs( BSdotp( &rc, varVec, vec2 ) ) )
  {
     i = *index1 ;
     *index1 = *index2 ;
     *index2 = i ;
  }

wrapup:
  _FREE( crvGeom );
  End
  return sts;
}

static IGRlong	VLunwGetVarMergedCurves(
				  struct GRobj_env      *contourOE,
				  struct GRid           *mappedObj,
				  struct GRvg_construct *cst,
				  struct GRid		*crvToMap,
				  IGRpoint		usePoint,
				  IGRboolean		*newCurves    )
{
BSrc			rc;
IGRlong                 sts, msg;
IGRint			i, nb_inter;
IGRdouble		par, mdist[2];
IGRpoint		point, crvPt, intersectionPt, spt, ept;
struct GRid             *inters=NULL, infLine, subCurve[4];
struct GRlc_info        curve1Info, curve2Info;
struct GRobj_env	crvOE[4];
struct IGRbsp_curve	*crvGeom=NULL, *crv1Geom=NULL, *crv2Geom=NULL,
			*mergeCrv=NULL;

  SetProc( VLunwGetVarMergedCurves  ); Begin

  curve1Info.located_obj   = mappedObj[0] ;
  curve1Info.module_info   = contourOE->mod_env ;
  curve2Info.located_obj   = mappedObj[1] ;
  curve2Info.module_info   = contourOE->mod_env ;

  *newCurves = FALSE;

  nb_inter = 0;
  sts = EMintersect_two_element( &curve1Info, &curve2Info, TRUE, cst,
                                 &nb_inter, &inters, &msg );
  __DBGpr_int("Number of intersection points ", nb_inter );
  if( nb_inter == 0 ) 
  {
    __DBGpr_com( "Variable Bevel Curves are not intersecting" );
    crvToMap[0] = mappedObj[0] ;
    crvToMap[1] = mappedObj[1] ;
    sts = _VD_SEND_OBJN( crvToMap[0], GRcurve.GRmidpoint( &msg,
          &contourOE->_matrix_type, contourOE->_matrix, NULL, usePoint ) );
    __CheckRC( sts, msg, "GRcurve.GRmidpoint", wrapup );
    goto wrapup;
  }

  __DBGpr_com( "Variable Bevel Curves are intersecting" );

  nb_inter = 1;

  sts = VSsplitCurveWithOneOrTwoPoints( &msg, &curve1Info.module_info,
		&curve1Info.located_obj, nb_inter, cst->env_info,
		inters, NULL, cst, &subCurve[0], &subCurve[1] );
  __CheckRC( sts, msg, "VSsplitCurveWithOneOrTwoPoints", wrapup );

  sts = VSsplitCurveWithOneOrTwoPoints( &msg, &curve2Info.module_info,
                &curve2Info.located_obj, nb_inter, cst->env_info,
                inters, NULL, cst, &subCurve[2], &subCurve[3] );
  __CheckRC( sts, msg, "VSsplitCurveWithOneOrTwoPoints", wrapup );

  sts = VLgetPtCoord( &msg, inters[0], cst->env_info, intersectionPt );
  __CheckRC( sts, msg, "VLgetPtCoord", wrapup );

  sts = VLendpts( &msg, &subCurve[0], cst->env_info, spt, ept );
  __CheckRC( sts, msg, "VLendpts: Curve 0", wrapup );

  if( fabs( BSdistptpt( &rc, intersectionPt, spt ) ) < 0.001 )
	dblcpy( point, ept, 3 );
  else  dblcpy( point, spt, 3 );

  _FREE( crvGeom );
  crvOE[0].obj_id = subCurve[2]; crvOE[0].mod_env = contourOE->mod_env ;
  sts = VLgetGeometry( &crvOE[0], FALSE, NULL_OBJID,
                       (IGRchar **)&crvGeom, &msg );
  if( !(sts&1&msg) )  goto wrapup;

  BSmdstptcv( crvGeom, point, &par, crvPt, &mdist[0], &rc) ;
  if( BSERROR(rc) ) goto wrapup;

  _FREE( crvGeom );
  crvOE[0].obj_id = subCurve[3]; crvOE[0].mod_env = contourOE->mod_env ;
  sts = VLgetGeometry( &crvOE[0], FALSE, NULL_OBJID,
                       (IGRchar **)&crvGeom, &msg );
  if( !(sts&1&msg) )  goto wrapup;

  BSmdstptcv( crvGeom, point, &par, crvPt, &mdist[1], &rc) ;
  if( BSERROR(rc) ) goto wrapup;

  if( mdist[0] < mdist[1] )  
  {
      crvOE[0].obj_id = subCurve[0];
      crvOE[1].obj_id = subCurve[3];
      crvOE[2].obj_id = subCurve[1];
      crvOE[3].obj_id = subCurve[2];
  }
  else
  {
      crvOE[0].obj_id = subCurve[0];   
      crvOE[1].obj_id = subCurve[2];
      crvOE[2].obj_id = subCurve[1];
      crvOE[3].obj_id = subCurve[3];
  }
  for( i=0; i<4; ++i )  crvOE[i].mod_env = contourOE->mod_env;

  _FREE( crv1Geom );
  sts = VLgetGeometry( &crvOE[0], FALSE, NULL_OBJID,
                       (IGRchar **)&crv1Geom, &msg );
  if( !(sts&1&msg) )  goto wrapup;
  BScveval( crv1Geom, 0.5, 0, (IGRpoint *)usePoint, &rc );

  _FREE( crv2Geom );
  sts = VLgetGeometry( &crvOE[1], FALSE, NULL_OBJID,
                       (IGRchar **)&crv2Geom, &msg );
  if( !(sts&1&msg) )  goto wrapup;

  VSallocForBSmerge_cv( &rc, crv1Geom, crv2Geom, &mergeCrv );

  BSmerge_cv( &rc, crv1Geom, crv2Geom, mergeCrv );

  BSarclnparc( &rc, mergeCrv );

  VDdrawCurve( mergeCrv, cst->env_info, &crvToMap[0] );

  BSfreecv( &rc, mergeCrv );
  mergeCrv = NULL;

  _FREE( crv1Geom );
  sts = VLgetGeometry( &crvOE[2], FALSE, NULL_OBJID,
                       (IGRchar **)&crv1Geom, &msg );
  if( !(sts&1&msg) )  goto wrapup;

  _FREE( crv2Geom );
  sts = VLgetGeometry( &crvOE[3], FALSE, NULL_OBJID,
                       (IGRchar **)&crv2Geom, &msg );
  if( !(sts&1&msg) )  goto wrapup;

  VSallocForBSmerge_cv( &rc, crv1Geom, crv2Geom, &mergeCrv );

  BSmerge_cv( &rc, crv1Geom, crv2Geom, mergeCrv );

  BSarclnparc( &rc, mergeCrv );

  VDdrawCurve( mergeCrv, cst->env_info, &crvToMap[1] );

  BSfreecv( &rc, mergeCrv );
  mergeCrv = NULL;

  vdobj$Delete( objOE = crvOE, objCNT = 4, objENV = cst->env_info );

  *newCurves = TRUE ;

wrapup:
  _FREE( crvGeom );
  if( nb_inter > 0 )
  {
     vdobj$Delete( objID  = inters, objCNT = nb_inter, objENV = cst->env_info );
     _FREE( inters );
     nb_inter = 0;
  }
  End
  return sts;
}

IGRlong VLunwExtendUnwrapContour( struct GRobj_env      contourOE,
                                  struct GRid           *inpCrv    )
{
BSrc                    rc;
IGRlong                 sts, msg, rotten_one;
IGRint                  i, nb_inter, crvCount, oldCrvCount, newCrvCount,
			crvIdxToExtend[2], index[2];
IGRdouble               dist1, dist2;
IGRshort		action, props;
IGRpoint                contourCenter, usePoint, point, pt1, pt2, projPt,
			ptCoord, newEndPt;
IGRboolean		*toKeep=NULL, alreadyStored=FALSE, newCurves=FALSE;
OM_S_OBJECT_LINKAGE     crvList[100], oldCrvList[100];
struct GRid             *inters=NULL, infLine, ptId, mappedObj[2];
struct GRvg_construct   cst;
struct GRlc_info        curve1Info, curve2Info, newCrvInfo[100];
struct GRparms          params;
struct GRsymbology	symb;
struct GRobj_env	crvOE, outerCurve;

  SetProc( VLunwExtendUnwrapContour  ); Begin

  VDsupInitCnst( &cst ) ;

  VDobjGetSymbology( &contourOE, NULL, &symb );
  cst.display = &symb.display_attr;
  cst.level   = symb.level;

  sts = msg = MSSUCC;

  nb_inter = 0;
 infLine.objid = NULL_OBJID;

  sts = VLunwGetVarMergedCurves( &contourOE, inpCrv, &cst, 
				 mappedObj, usePoint, &newCurves );
  __CheckRC( sts, msg, "VLunwGetVarMergedCurves", wrapup );
  __DBGpr_vec( "Use Point", usePoint );

  sts = _VD_SEND_OBJN( contourOE.obj_id, GRvg.GRcenter( &msg,
            &contourOE._matrix_type, contourOE._matrix, contourCenter ));
  __CheckRC( sts, msg, "GRvg.GRcenter", wrapup );

  sts = VSmake_infinite_line( &msg, contourCenter, usePoint,
                              &cst, &infLine ) ;
  __CheckRC( sts, msg, "VSmake_infinite_line", wrapup );
  __DBGpr_obj( "Infinite Line ", infLine ) ;

  if( nb_inter > 0 )
  {
     vdobj$Delete( objID  = inters, objCNT = nb_inter, objENV = cst.env_info );
     _FREE( inters );
     nb_inter = 0;
  }

  curve1Info.located_obj = mappedObj[0] ;
  curve1Info.module_info = contourOE.mod_env; 
  curve2Info.located_obj = infLine ;
  curve2Info.module_info = contourOE.mod_env;

  nb_inter = 0;
  sts = EMintersect_two_element( &curve1Info, &curve2Info, TRUE, &cst,
                                 &nb_inter, &inters, &msg );
  if( nb_inter < 1 ) goto wrapup;
  VLgetPtCoord( &msg, inters[0], cst.env_info, pt1 );
  __DBGpr_vec( "First Intersection Point", pt1 );

  if( nb_inter > 0 )
  {
     vdobj$Delete( objID  = inters, objCNT = nb_inter, objENV = cst.env_info );
     _FREE( inters );
     nb_inter = 0;
  }

  curve1Info.located_obj   = mappedObj[1] ;

  sts = EMintersect_two_element( &curve1Info, &curve2Info, TRUE, &cst,
                                 &nb_inter, &inters, &msg );
  if( nb_inter < 1 ) goto wrapup;
  VLgetPtCoord( &msg, inters[0], cst.env_info, pt2 );
  __DBGpr_vec( "Second Intersection Point", pt2 );

  dist1 = BSdistptpt( &rc, contourCenter, pt1 );
  dist2 = BSdistptpt( &rc, contourCenter, pt2 );

  outerCurve.mod_env = contourOE.mod_env;

  if( dist1 < dist2 )   outerCurve.obj_id = mappedObj[1];
  else                  outerCurve.obj_id = mappedObj[0];
  __DBGpr_obj( "Outer Curve", outerCurve.obj_id );

  sts = VLendpts( &msg, &outerCurve.obj_id, &contourOE.mod_env, pt1, pt2 );
  __CheckRC( sts, msg, "VLendpts", wrapup );

  om$get_channel_objects( objid = contourOE._objid,
                          osnum = contourOE._osnum,
                          p_chanselect = &AS_to_comp,
                          list  = crvList,
                          size  = 100,
                          count = (OMuint *) &crvCount );
  __DBGpr_int( "Composite Curve Count", crvCount );

  if( !( toKeep = _MALLOC( crvCount, IGRboolean )) ) 
      vd_$mem_fail( msg = &msg );

  for( i=0; i<crvCount; ++i ) toKeep[i] = TRUE;

  for( i=0; i<2; ++i )
  {
     if( i ) dblcpy( point, pt2, 3 );
     else    dblcpy( point, pt1, 3 );

     sts = _VD_SEND_OBJN( contourOE.obj_id, GRgraphics.GRptproject( &msg,
                            &contourOE._matrix_type, contourOE._matrix,
                            point, projPt, &params ));
     __CheckRC( sts, msg, "GRvg.GRcenter", wrapup );
     __DBGpr_vec( "Variable Curve End Point", point );
     __DBGpr_vec( "Project Point", projPt );

     VLunwGetTwoClosestCurves( point, projPt, crvCount, crvList, cst.env_info,
			       &crvIdxToExtend[i], &index[i] );
     toKeep[index[i]] = FALSE;

     crvOE.mod_env = contourOE.mod_env;
     crvOE._objid  = crvList[crvIdxToExtend[i]].S_objid;
     crvOE._osnum  = crvList[crvIdxToExtend[i]].osnum;

     __DBGpr_obj( "Intersecting First Object", crvOE.obj_id );
     __DBGpr_obj( "Intersecting Second Object", outerCurve.obj_id );

     sts = VScsInt2Elements( &msg, &crvOE, &outerCurve, 
		             &contourOE.mod_env, &ptId );
     __CheckRC( sts, msg, "VScsInt2Elements", wrapup );
     __DBGpr_obj( "Intersection Point Object", ptId );

     if( !vdobj$IsAncestryValid( objID = &ptId,
                                 superClassID = OPP_GRpoint_class_id ) )
     {
        vdobj$Delete( objID = &ptId, objENV = cst.env_info );
	goto wrapup;
     }

     sts = VLgetPtCoord( &msg, ptId, cst.env_info, ptCoord );
     __CheckRC( sts, msg, "VLgetPtCoord", wrapup );
     __DBGpr_vec( "Intersection Point Coordinates", ptCoord );

     vdobj$Delete( objID = &ptId, objENV = cst.env_info );

     sts = _VD_SEND_OBJN( crvOE.obj_id, GRcurve.GRptextend( &msg,
		          cst.env_info, point, ptCoord, newEndPt ) ) ;
     __CheckRC( sts, msg, "GRcurve.GRptextend", wrapup );
     __DBGpr_vec( "New End Point", newEndPt );

     sts = _VD_SEND_OBJN( outerCurve.obj_id, GRcurve.GRptextend( &msg,
                          cst.env_info, point, ptCoord, newEndPt ) ) ;
     __CheckRC( sts, msg, "GRcurve.GRptextend", wrapup );
     __DBGpr_vec( "New End Point", newEndPt );
  }

  for( i=index[0]; i<crvCount; ++i )
  {
     if( ( i == crvIdxToExtend[0] ) || ( i == crvIdxToExtend[1] ) ) break;
     toKeep[i] = FALSE;
  }

  for( i=index[1]; i<crvCount; ++i )
  {
     if( ( i == crvIdxToExtend[0] ) || ( i == crvIdxToExtend[1] ) ) break;
     toKeep[i] = FALSE;
  }

  for( i=index[0]; i>=0; --i )
  {
     if( ( i == crvIdxToExtend[0] ) || ( i == crvIdxToExtend[1] ) ) break;
     toKeep[i] = FALSE;
  }

  for( i=index[1]; i>=0; --i )
  {
     if( ( i == crvIdxToExtend[0] ) || ( i == crvIdxToExtend[1] ) ) break;
     toKeep[i] = FALSE;
  }

  newCrvCount = oldCrvCount = 0;
  
  for( i=0; i<crvCount; ++i )
     if( toKeep[i] == FALSE )  oldCrvList[oldCrvCount++] = crvList[i];

  for( alreadyStored=FALSE, i=0; i<crvCount; ++i )
  {
     newCrvInfo[newCrvCount].module_info   = contourOE.mod_env ;
     if( toKeep[i] == FALSE )
     {
	if( alreadyStored == FALSE )
	{
	  alreadyStored = TRUE;

	  //if( newCurves )
	  {
	     om$send( msg = message GRgraphics.GRdelete( &msg, cst.env_info ),
		      senderid = NULL_OBJID,
		      targetid = crvList[i].S_objid,
		      targetos = crvList[i].osnum );
	  }

	  vd_$grCopy( msg   = &msg, 
		      frObj = &outerCurve.obj_id,
		      frEnv = &contourOE.mod_env,
		      toEnv = cst.env_info,
		      toObj = &newCrvInfo[newCrvCount].located_obj,
		      symb  = &symb );
	  newCrvCount++;
	}
     }
     else
     {
        newCrvInfo[newCrvCount].located_obj.objid = crvList[i].S_objid;
        newCrvInfo[newCrvCount].located_obj.osnum = crvList[i].osnum;
	newCrvCount++;
     }
  }

  action = 0;
  props = GR_RIGID_RELATIONSHIP;
  sts = om$send(msg = message GRgraphics.GRchgprops(
                                        &msg,&action,&props ),
                   p_chanselect = &AS_to_comp,
                   senderid     = contourOE._objid );

  sts = om$send( msg      = message Root.wild_disconnect( AS_to_comp ),
		 senderid = contourOE._objid,
                 targetid = contourOE._objid,
                 targetos = contourOE._osnum);
  __CheckRC( sts, 1, "Root.wild_disconnect:AS_to_comp", wrapup );

  sts = om$send( msg      = message GRcompcurve.EMmakecomp( &msg,
		    &contourOE.mod_env, newCrvCount, newCrvInfo, &rotten_one ),
		 mode = OM_e_wrt_object,
		 senderid = contourOE._objid,
		 targetid = contourOE._objid,
		 targetos = contourOE._osnum  );
  __CheckRC( sts, msg, "GRcompcurve.EMmakecomp", wrapup );  

wrapup:
  _FREE( toKeep );

  if( newCurves )
  {
     vdobj$Delete( objID = mappedObj, objCNT = 2, objENV = cst.env_info );
  }

  if( nb_inter > 0 )
  {
     vdobj$Delete( objID  = inters, objCNT = nb_inter, objENV = cst.env_info );
     _FREE( inters );
  }

  if( infLine.objid != NULL_OBJID )
        vdobj$Delete( objID = &infLine, objENV = cst.env_info );

  End
  return sts;
}

end implementation VDSroot;
