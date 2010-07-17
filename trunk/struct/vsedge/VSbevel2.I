/* $Id: VSbevel2.I,v 1.5 2001/09/08 19:03:05 ramarao Exp $  */
/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/vsedge/VSbevel2.I
 *
 * Description: functions for computing bevel macro: Bevel, EJ_Bevel, VA_Bevel
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSbevel2.I,v $
 *      Revision 1.5  2001/09/08 19:03:05  ramarao
 *      Fixed TR# 5579.
 *
 *      Revision 1.4  2001/06/07 00:24:43  ramarao
 *      Fixed TR# 5294.
 *
 *      Revision 1.3  2001/06/02 19:32:18  ramarao
 *      Fixed TR# 5285.
 *
 *      Revision 1.2  2001/05/14 15:29:03  ramarao
 *      Fixed TR# 5009.
 *
 *      Revision 1.1  2001/01/17 00:07:21  ramarao
 *      *** empty log message ***
 *
# Revision 1.2  2000/11/27  19:43:46  pinnacle
# ah
#
# Revision 1.1  2000/10/25  19:22:54  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 10/17/00  ah      Creation
 * -------------------------------------------------------------------*/

class implementation Root;

#include "VDtypedef.h"
#include "VDassert.h"
#include "VDobj.h"
#include "VDmem.h"
#include "VDgeom.h"
#include "vdAPImacros.h"
#include "v_miscmacros.h"
#include "v_geommacros.h"
#include "vsdbgmacros.h"
#include "asmacros.h"
#include "VSbevel2.h"

#include "bsmdistptsf.h"
#include "bssfevaln.h"
#include "bsmdstptcv.h"
#include "bsnorvec.h"

#include "EMSssprops.h"
#include "gotextdef.h"
#include "cotxmacros.h"
#include "dp.h"

VDASSERT_FFN("struct/vsedge/VSbevel2.I");

from GR3dpoint import GRgetpolyline;

extern GRclassid	OPP_nci_macro_class_id;

/* -----------------------------------------------
 * Get the plate and surface geometry
 */
static IGRstat VSbevelGetPlateParent(TGRobj_env *macOE,
				     IGRint      nth,
				     TGRobj_env *plateOE,
				     TGRobj_env *srfOE,
				     TGRbsp_surface **srfBsp)
{
  VDASSERT_FN("VSbevelGetPlateParent");

  IGRstat retFlag = 0;
  
  // Arg check
  VDASSERTW(srfBsp);
  *srfBsp = NULL;
  VDASSERTW(plateOE);
  plateOE->obj_id.objid = NULL_OBJID;
  VDASSERTW(srfOE);
  srfOE->obj_id.objid = NULL_OBJID;
  VDASSERTW(macOE);
  
  // Get the parent
  vdobj$GetTemplate(objOE = macOE, nth = nth, templateOE = plateOE);
  VDASSERTW(plateOE->obj_id.objid != NULL_OBJID);

  // Need it's foot
  vdobj$GetFoot(objOE    = plateOE,
		footName = "plate:base",
		footOE	 = srfOE);
  VDASSERTW(srfOE->obj_id.objid != NULL_OBJID);

  vdgeom$Get2(objOE = srfOE, srf = srfBsp);
  VDASSERTW(*srfBsp);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Get the edge geometry
 */
static IGRstat VSbevelGetEdgeParent(TGRobj_env     *macOE,
				     IGRint         nth,
				     TGRobj_env    *edgeOE,
				     TGRbsp_curve **edgeBsp)
{
  VDASSERT_FN("VSbevelGetEdgeParent");

  IGRstat retFlag = 0;
  
  // Arg check
  VDASSERTW(edgeBsp);
  *edgeBsp = NULL;
  VDASSERTW(edgeOE);
  edgeOE->obj_id.objid = NULL_OBJID;
  VDASSERTW(macOE);
  
  // Get the parent
  vdobj$GetTemplate(objOE = macOE, nth = nth, templateOE = edgeOE);
  VDASSERTW(edgeOE->obj_id.objid != NULL_OBJID);

  // The geomotry
  vdgeom$Get2(objOE = edgeOE, crv = edgeBsp);
  VDASSERTW(*edgeBsp);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Get the label parent point
 */
static IGRstat VSbevelGetPointParent(TGRobj_env *macOE,
				     IGRint      nth,
				     TGRobj_env *pointOE,
				     IGRdouble  *pointPt)
{
  VDASSERT_FN("VSbevelGetPointParent");

  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  TGRpolyline polyline;

  IGRint action = 1;
  
  // Arg check
  VDASSERTW(pointPt);
  VDASSERTW(pointOE);
  pointOE->obj_id.objid = NULL_OBJID;
  VDASSERTW(macOE);
  
  // Get the parent
  vdobj$GetTemplate(objOE = macOE, nth = nth, templateOE = pointOE);
  VDASSERTW(pointOE->obj_id.objid != NULL_OBJID);

  // Need the point value (maybe should check size?)
  polyline.points = pointPt;
  sts = om$send(msg = message GR3dpoint.
		GRgetpolyline(&msg,
			      &pointOE->mod_env.md_env.matrix_type,
			       pointOE->mod_env.md_env.matrix,
			      &action,
			      &polyline),
		senderid = NULL_OBJID,
		targetid = pointOE->obj_id.objid,
	 	targetos = pointOE->obj_id.osnum) ;
  VDASSERTW(sts & msg & 1);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Package things up 
 */
typedef struct 
{
  TGRobj_env plateOE;
  
  TGRobj_env      srfOE;
  TGRbsp_surface *srfBsp;

  TGRobj_env     edgeOE;
  TGRbsp_curve  *edgeBsp;
  
  TGRobj_env     edge2OE;
  TGRbsp_curve  *edge2Bsp;
  
  TGRobj_env pointOE;
  IGRdouble  pointPt[3];
  
  IGRdouble  orient[9];
  
  TGRid  textID;
  TGRid  symID;
  TGRid  stockID;
  
    
} Tparent;

/* -----------------------------------------------
 * Standard 2 plate bevel compute
 */
IGRstat	VScomputeBevel(TGRobj_env *macOE ,    // in
		       IGRint	   tempCnt ,  // in
		       IGRint	  *feetCnt ,  // out
		       TGRid	  *feetIDs )  // out
{
  VDASSERT_FN("VScomputeBevel");

  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  Tparent p1,p2;

  TGRobj_env attrOE;
  TGRid      colID;
  
  TGRid         crvID;  
  TGRbsp_curve *crvBsp = NULL;

  IGRchar textStr[128]; // For the label
  IGRint  stock;
  
  // Init
  memset(&p1,0,sizeof(Tparent));
  memset(&p2,0,sizeof(Tparent));
  attrOE.obj_id.objid = NULL_OBJID;
  crvID.objid = NULL_OBJID;
  colID.objid = NULL_OBJID;
  
  // Say Hi
  if (traceFlag) {
    printf(">>> %s\n",fn);
  }

  // Arg check
  VDASSERTW(feetCnt);
  *feetCnt = 0;
  VDASSERTW(feetIDs);

  // Set font size based on label feet
  VSbevelSetFontSize(0,macOE);
  
  // Attributes
  vdobj$GetTemplate(objOE = macOE, nth = 0, templateOE = &attrOE);
  VDASSERTW(attrOE.obj_id.objid != NULL_OBJID);

  // Plates and surfaces
  VSbevelGetPlateParent(macOE,1,&p1.plateOE,&p1.srfOE,&p1.srfBsp);
  VDASSERTW(p1.srfBsp);

  VSbevelGetPlateParent(macOE,2,&p2.plateOE,&p2.srfOE,&p2.srfBsp);
  VDASSERTW(p2.srfBsp);

  // Edges
  VSbevelGetEdgeParent(macOE,3,&p1.edgeOE,&p1.edgeBsp);
  VDASSERTW(p1.edgeBsp);

  VSbevelGetEdgeParent(macOE,4,&p2.edgeOE,&p2.edgeBsp);
  VDASSERTW(p2.edgeBsp);

  // Label points
  VSbevelGetPointParent(macOE,5,&p1.pointOE,p1.pointPt);
  VDASSERTW(p1.pointOE.obj_id.objid != NULL_OBJID);

  VSbevelGetPointParent(macOE,6,&p2.pointOE,p2.pointPt);
  VDASSERTW(p2.pointOE.obj_id.objid != NULL_OBJID);

  if (traceFlag) {
    vdobj$Print(objOE = &attrOE);
    vdobj$Print(objOE = &p1.plateOE);
    vdobj$Print(objOE = &p2.plateOE);
    vdobj$Print(objOE = &p1.edgeOE);
    vdobj$Print(objOE = &p2.edgeOE);
    vdobj$Print(objOE = &p1.pointOE);
    vdobj$Print(objOE = &p2.pointOE);
  }
  
  // Fill in the orientation stuff
  VSbevelFillOrient(p1.srfBsp,&p1.srfOE,p1.pointPt,p1.edgeBsp,p1.orient);
  VSbevelFillOrient(p2.srfBsp,&p2.srfOE,p2.pointPt,p2.edgeBsp,p2.orient);
  
  // Need the overlapping geometry
  VSbevelGetCurveOverlap(p1.edgeBsp,p2.edgeBsp,macOE,&crvBsp);
  VDASSERTW(crvBsp);

  // The collector
  VSbevelCreateFootCollector(&attrOE,macOE,&colID,textStr,&stock);
  VDASSERTW(colID.objid != NULL_OBJID);
  
  // Make the curve
  VDdrawCurve(crvBsp,&macOE->mod_env,&crvID);
  VDASSERTW(crvID.objid != NULL_OBJID);
  
  // First label
  VSbevelCreateTextLabel(textStr,stock,p1.pointPt,p1.orient,macOE,&p1.textID);
  if (p1.textID.objid == NULL_OBJID) {
    printf("*** Problem creating first text label for\n");
    vdobj$Print(objOE = macOE);
    goto wrapup;
  }

  // Second label
  VSbevelCreateTextLabel(textStr,stock,p2.pointPt,p2.orient,macOE,&p2.textID);
  if (p2.textID.objid == NULL_OBJID) {
    printf("*** Problem creating second text label for\n");
    vdobj$Print(objOE = macOE);
    goto wrapup;
  }

  // Package the feet
  feetIDs[0] = colID;
  feetIDs[1] = crvID;
  feetIDs[2] = p1.textID;
  feetIDs[3] = p2.textID;
  *feetCnt = 4;

  // Need stock?
  if (stock) {

    VSbevelCreateStockSymbol(p1.pointPt,p1.orient,macOE,&p1.symID);
    if (p1.symID.objid != NULL_OBJID) {
      feetIDs[*feetCnt] = p1.symID;
      *feetCnt = *feetCnt + 1;
    }
    VSbevelCreateTextLabel("S",0,p1.pointPt,p1.orient,macOE,&p1.stockID);
    if (p1.stockID.objid != NULL_OBJID) {
      feetIDs[*feetCnt] = p1.stockID;
      *feetCnt = *feetCnt + 1;
    }
    
    VSbevelCreateStockSymbol(p2.pointPt,p2.orient,macOE,&p2.symID);
    if (p2.symID.objid != NULL_OBJID) {
      feetIDs[*feetCnt] = p2.symID;
      *feetCnt = *feetCnt + 1;
    }
    VSbevelCreateTextLabel("S",0,p2.pointPt,p2.orient,macOE,&p2.stockID);
    if (p2.stockID.objid != NULL_OBJID) {
      feetIDs[*feetCnt] = p2.stockID;
      *feetCnt = *feetCnt + 1;
    }    
  }
  
  // Done
  retFlag = 1;
  
 wrapup:

  // Free Up
  if ((crvBsp != p1.edgeBsp) && (crvBsp != p2.edgeBsp)) {
    _FREE(crvBsp);
  }
  _FREE(p1.edgeBsp);
  _FREE(p2.edgeBsp);

  _FREE(p1.srfBsp);
  _FREE(p2.srfBsp);

  // Check for errors
  if (!(retFlag & 1)) {
    if (macOE) {      
      printf("*** Bevel Compute Error For %d,%d\n",
	     macOE->obj_id.osnum,macOE->obj_id.objid);    
    }
  }
    
  // Say By
  if (traceFlag) {
    printf("<<< %s %d\n",fn,retFlag);
  }
  return retFlag;
}

/************************************************************************
 * Check if a Bevel/Fab_Stock already exists on the curve,
 * but it won't work well if objs are in different files !
 */
static IGRboolean  GetAllBevelMacros( TGRobj_env      *parentOE ,     // in
				      IGRint	      *nbBevels,      // out
                                      struct GRid     *bevelIDs  )    // out
{
        IGRboolean              retFlag ;
        IGRstat                 sts ;
        IGRlong                 msg ;
        IGRint                  i ;
	IGRchar			macName[128];
        GRclassid               classid ;
        IGRint                  foundCnt ;
        TGRid                   *foundIDs ;
        TGRid                   srcID ;
struct  OM_sd_chanselect        chn ;

SetProc( GetAllBevelMacros ); Begin

        retFlag    = FALSE ;
        foundIDs   = NULL ;
        foundCnt   = 0 ;
	*nbBevels  = 0 ;

        sts = as$make_source (  go_grid = parentOE->obj_id ,
                                mod_env = &parentOE->mod_env,
                                as_grid = &srcID ) ;
        if ( !(sts & 1) || srcID.objid == NULL_OBJID ) {
                __DBGpr_com("Problem sourcing parentOE");
                srcID = parentOE->obj_id ;
        }
        __DBGpr_obj("parentOE", parentOE->obj_id);
        __DBGpr_obj("srcID", srcID);


        // get channel
        sts = om$make_chanselect( channame      = "NDchildren.children" ,
                                  p_chanselect  = &chn ) ;
        if( !(sts & 1) ) {
                __DBGpr_com("om$make_chanselect failed") ;
                goto wrapup;
        }

        // get objs from the channel
        classid = OPP_nci_macro_class_id ;
        sts = VDGetGridsFromChan_of_Class (
                                        &msg,
                                        srcID,
                                        &chn,
                                        classid,
                                        &foundCnt,
                                        &foundIDs ) ;
        __DBGpr_int("foundCnt", foundCnt) ;
        for( i = 0; i < foundCnt; i = i+1 ) {
	    vdobj$Get( objID = &foundIDs[i], macName = macName );
	    if( !strcmp( macName, "Bevel"    ) )
	    {
		bevelIDs[*nbBevels] = foundIDs[i] ;
	 	(*nbBevels)++;
		retFlag = TRUE ;
            }
        }

wrapup:
        if( foundIDs ) _FREE( foundIDs ) ;
End
        return retFlag ;

}

IGRstat  VSbevelCheckForPartialCurve( struct GRobj_env	   edgeOE,
				      struct IGRbsp_curve  *edgeGeom,
				      struct GRmd_env	   cur_env,
				      struct GRid	   *crvID  )
{
BSrc			rc;
IGRlong			sts, msg, sub_ints=100;
IGRint			k, retFlag=0, numDistCvs1=0, numDistCvs2=0, numOvCvs=0, 
			ovLapCode, nbBevels=0;
IGRdouble               tol=0.0000000001, len1, len2;
IGRchar			macName[128], msgStr[128];
struct GRid		macroID, footId, bevelIDs[20];
struct GRmd_env		footEnv;
struct IGRbsp_curve     *crv1Geom=NULL, *crv2Geom=NULL, *mergeCrv=NULL,
			*crv1ToMerge=NULL, *crv2ToMerge=NULL,
		     	**DCvs1=NULL, **DCvs2=NULL, **OCvs=NULL;

   crvID->objid = NULL_OBJID;
   crvID->objid = cur_env.md_id.osnum;

   if( !GetAllBevelMacros( &edgeOE, &nbBevels, bevelIDs ) || ( nbBevels > 2 ) )
	goto wrapup;
 
   macroID = bevelIDs[0];

   sts = vd_$get_geometry( msg = &msg, grobjId = &edgeOE.obj_id,
                     grobjEnv = &edgeOE.mod_env, geometry = &crv1Geom );
   __CheckRC( sts, msg, "vd_$get_geometry", wrapup ) ;

   sts = vd_$return_foot( msg = &msg, name = "curve", 
	      objId = &macroID, footId = &footId, footEnv = &footEnv );
   __CheckRC( sts, msg, "vd_$return_foot: curve", wrapup ) ;

   if( !vd_$is_ancestry_valid( object  = &footId,
                               classid = OPP_GRcurve_class_id ) ) 
	goto wrapup;

   sts = vd_$get_geometry( msg = &msg, grobjId = &footId,
                           grobjEnv = &footEnv, geometry = &crv2Geom );
   __CheckRC( sts, msg, "vd_$get_geometry", wrapup ) ;

   BSchk2cvsov( crv1Geom, crv2Geom, 1.0, 0, &ovLapCode,
                &numDistCvs1, &DCvs1, &numDistCvs2, &DCvs2,
                &numOvCvs, &OCvs, &rc );
   if( rc != BSSUCC ) goto wrapup;
   if( ovLapCode != 4 && ovLapCode != 5 && ovLapCode != 6 ) goto wrapup;

   if( ( numDistCvs1 == 2 ) || ( numDistCvs2 == 2 ) )
   {
      if( numDistCvs1 == 2 )
      {
         crv1ToMerge = DCvs1[0];
         crv2ToMerge = DCvs1[1];
      }
      else
      {
         crv1ToMerge = DCvs2[0];
         crv2ToMerge = DCvs2[1];
      }

      if( crv1Geom->phy_closed )
      {
	VSallocForBSmerge_cv( &msg, crv1ToMerge, crv2ToMerge, &mergeCrv );

        BSmerge_cv( &msg,  crv1ToMerge, crv2ToMerge, mergeCrv );

        BSarclnparc( &msg, mergeCrv );

        VDdrawCurve( mergeCrv, &cur_env, crvID );

        BSfreecv( &msg, mergeCrv );
      }
      else
      {
        if (! MAbctotlen ( msg, crv1ToMerge, &tol, &sub_ints, &len1 ))
           goto wrapup;

        if (! MAbctotlen ( msg, crv2ToMerge, &tol, &sub_ints, &len2 ))
           goto wrapup;

        if( len1 > len2 )  VDdrawCurve( crv1ToMerge, &cur_env, crvID );
        else               VDdrawCurve( crv2ToMerge, &cur_env, crvID );
	retFlag = 1;
	goto wrapup;
      }
   }
   else if( numDistCvs1 > 0 ) 	VDdrawCurve( DCvs1[0], &cur_env, crvID );
   else if( numDistCvs2 > 0 )   VDdrawCurve( DCvs2[0], &cur_env, crvID );
   else goto wrapup;

   retFlag = 1;

   if( nbBevels == 1 ) goto wrapup;

   if( numDistCvs1 )
   {
       for( k=0; k<numDistCvs1; ++k )      BSfreecv( &rc, DCvs1[k] );
       _FREE( DCvs1 );
       numDistCvs1 = 0;
   }
   if( numDistCvs2 )
   {
       for( k=0; k<numDistCvs2; ++k )      BSfreecv( &rc, DCvs2[k] );
       _FREE( DCvs2 );
       numDistCvs2 = 0;
   }
   if( numOvCvs )
   {
       for( k=0; k<numOvCvs; ++k )      BSfreecv( &rc, OCvs[k] );
       _FREE( OCvs );
       numOvCvs = 0;
   }

   macroID = bevelIDs[1];

   _FREE( crv1Geom );
   sts = vd_$get_geometry( msg = &msg, grobjId = crvID,
                     grobjEnv = &cur_env, geometry = &crv1Geom );
   __CheckRC( sts, msg, "vd_$get_geometry", wrapup ) ;

   sts = vd_$return_foot( msg = &msg, name = "curve",
              objId = &macroID, footId = &footId, footEnv = &footEnv );
   __CheckRC( sts, msg, "vd_$return_foot: curve", wrapup ) ;

   if( !vd_$is_ancestry_valid( object  = &footId,
                               classid = OPP_GRcurve_class_id ) )
        goto wrapup;
   
   _FREE( crv2Geom );
   sts = vd_$get_geometry( msg = &msg, grobjId = &footId,
                           grobjEnv = &footEnv, geometry = &crv2Geom );
   __CheckRC( sts, msg, "vd_$get_geometry", wrapup ) ;

   BSchk2cvsov( crv1Geom, crv2Geom, 1.0, 0, &ovLapCode,
                &numDistCvs1, &DCvs1, &numDistCvs2, &DCvs2,
                &numOvCvs, &OCvs, &rc );
   if( rc != BSSUCC ) goto wrapup;
   if( ovLapCode != 4 && ovLapCode != 5 && ovLapCode != 6 ) goto wrapup;

   vd_$bulk_delete( grids  = crvID, theEnv = &cur_env  );

   if( numDistCvs1 > 0 )        VDdrawCurve( DCvs1[0], &cur_env, crvID );
   else if( numDistCvs2 > 0 )   VDdrawCurve( DCvs2[0], &cur_env, crvID );
   else goto wrapup;

   retFlag = 1;

wrapup:
   _FREE( crv1Geom );
   _FREE( crv2Geom );
   if( numDistCvs1 )
   {
       for( k=0; k<numDistCvs1; ++k )      BSfreecv( &rc, DCvs1[k] );
       _FREE( DCvs1 );
       numDistCvs1 = 0;
   }
   if( numDistCvs2 )
   {
       for( k=0; k<numDistCvs2; ++k )      BSfreecv( &rc, DCvs2[k] );
       _FREE( DCvs2 );
       numDistCvs2 = 0;
   }
   if( numOvCvs )
   {
       for( k=0; k<numOvCvs; ++k )      BSfreecv( &rc, OCvs[k] );
       _FREE( OCvs );
       numOvCvs = 0;
   }
   if( retFlag == 0 )
     VDdrawCurve( edgeGeom, &cur_env, crvID );
   return 1;
}

/* -----------------------------------------------
 * Standard 1 plate bevel compute
 */
IGRstat	VScomputeEJ_Bevel(TGRobj_env *macOE ,    // in
			  IGRint      tempCnt ,  // in
			  IGRint     *feetCnt ,  // out
			  TGRid	     *feetIDs )  // out
{
  VDASSERT_FN("VScomputeEJ_Bevel");

  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  Tparent p1;

  TGRobj_env attrOE;
  TGRid      colID;
  TGRid      crvID;  

  TGRbsp_curve *edgeBsp=NULL;

  IGRchar textStr[128]; // For the label
  IGRint  stock;
  
  // Init
  memset(&p1,0,sizeof(Tparent));
  attrOE.obj_id.objid = NULL_OBJID;
  crvID.objid = NULL_OBJID;
  colID.objid = NULL_OBJID;
  
  // Say Hi
  if (traceFlag) {
    printf(">>> %s\n",fn);
  }

  // Arg check
  VDASSERTW(feetCnt);
  *feetCnt = 0;
  VDASSERTW(feetIDs);

  // Set font size based on label feet
  VSbevelSetFontSize(0,macOE);
  
  // Attributes
  vdobj$GetTemplate(objOE = macOE, nth = 0, templateOE = &attrOE);
  VDASSERTW(attrOE.obj_id.objid != NULL_OBJID);

  // Plates and surfaces
  VSbevelGetPlateParent(macOE,1,&p1.plateOE,&p1.srfOE,&p1.srfBsp);
  VDASSERTW(p1.srfBsp);

  // Edges
  VSbevelGetEdgeParent(macOE,2,&p1.edgeOE,&p1.edgeBsp);
  VDASSERTW(p1.edgeBsp);

  // Label points
  VSbevelGetPointParent(macOE,3,&p1.pointOE,p1.pointPt);
  VDASSERTW(p1.pointOE.obj_id.objid != NULL_OBJID);

  if (traceFlag) {
    vdobj$Print(objOE = &attrOE);
    vdobj$Print(objOE = &p1.plateOE);
    vdobj$Print(objOE = &p1.edgeOE);
    vdobj$Print(objOE = &p1.pointOE);
  }
  
  // Fill in the orientation stuff
  VSbevelFillOrient(p1.srfBsp,&p1.srfOE,p1.pointPt,p1.edgeBsp,p1.orient);

  // The collector
  VSbevelCreateFootCollector(&attrOE,macOE,&colID,textStr,&stock);
  VDASSERTW(colID.objid != NULL_OBJID);

  // Make the curve
  VSbevelCheckForPartialCurve( 	p1.edgeOE, p1.edgeBsp, 
				macOE->mod_env, &crvID );
  VDASSERTW(crvID.objid != NULL_OBJID);
  
  // The label
  VSbevelCreateTextLabel(textStr,stock,p1.pointPt,p1.orient,macOE,&p1.textID);
  if (p1.textID.objid == NULL_OBJID) {
    printf("*** Problem creating first text label for\n");
    vdobj$Print(objOE = macOE);
    goto wrapup;
  }

  // Package the feet
  feetIDs[0] = colID;
  feetIDs[1] = crvID;
  feetIDs[2] = p1.textID;
  *feetCnt = 3;

  // Need stock?
  if (stock) {

    VSbevelCreateStockSymbol(p1.pointPt,p1.orient,macOE,&p1.symID);
    if (p1.symID.objid != NULL_OBJID) {
      feetIDs[*feetCnt] = p1.symID;
      *feetCnt = *feetCnt + 1;
    }
    VSbevelCreateTextLabel("S",0,p1.pointPt,p1.orient,macOE,&p1.stockID);
    if (p1.stockID.objid != NULL_OBJID) {
      feetIDs[*feetCnt] = p1.stockID;
      *feetCnt = *feetCnt + 1;
    }    
  }
  
  // Done
  retFlag = 1;
  
 wrapup:

  // Free Up
  _FREE(p1.edgeBsp);
  _FREE(p1.srfBsp);
  _FREE(edgeBsp);

  // Check for errors
  if (!(retFlag & 1)) {
    if (macOE) {      
      printf("*** Bevel Compute Error For %d,%d\n",
	     macOE->obj_id.osnum,macOE->obj_id.objid);    
    }
  }
  
  // Say By
  if (traceFlag) {
    printf("<<< %s %d\n",fn,retFlag);
  }
  return retFlag;
}

/* -----------------------------------------------
 * Fabrication Stock, Basically always an S
 */
IGRstat	VScomputeFab_Stock(TGRobj_env *macOE,    // in
			   IGRint      tempCnt,  // in
			   IGRint     *feetCnt,  // out
			   TGRid      *feetIDs)  // out
{
  VDASSERT_FN("VScomputeFab_Stock");

  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  Tparent p1;

  TGRobj_env attrOE;
  TGRid      colID;
  TGRid      crvID;
  
  IGRint  stock;
  IGRchar textStr[128];
  
  // Init
  memset(&p1,0,sizeof(Tparent));
  attrOE.obj_id.objid = NULL_OBJID;
  crvID.objid = NULL_OBJID;
  colID.objid = NULL_OBJID;
  
  // Say Hi
  if (traceFlag) {
    printf(">>> %s\n",fn);
  }

  // Arg check
  VDASSERTW(feetCnt);
  *feetCnt = 0;
  VDASSERTW(feetIDs);

  // Set font size based on label feet
  VSbevelSetFontSize(0,macOE);
  
  // Attributes
  vdobj$GetTemplate(objOE = macOE, nth = 0, templateOE = &attrOE);
  VDASSERTW(attrOE.obj_id.objid != NULL_OBJID);

  // Plates and surfaces
  VSbevelGetPlateParent(macOE,1,&p1.plateOE,&p1.srfOE,&p1.srfBsp);
  VDASSERTW(p1.srfBsp);

  // Edges
  VSbevelGetEdgeParent(macOE,2,&p1.edgeOE,&p1.edgeBsp);
  VDASSERTW(p1.edgeBsp);

  // Label points
  VSbevelGetPointParent(macOE,3,&p1.pointOE,p1.pointPt);
  VDASSERTW(p1.pointOE.obj_id.objid != NULL_OBJID);

  if (traceFlag) {
    vdobj$Print(objOE = &attrOE);
    vdobj$Print(objOE = &p1.plateOE);
    vdobj$Print(objOE = &p1.edgeOE);
    vdobj$Print(objOE = &p1.pointOE);
  }
  
  // Fill in the orientation stuff
  VSbevelFillOrient(p1.srfBsp,&p1.srfOE,p1.pointPt,p1.edgeBsp,p1.orient);
  
  // The collector
  VSbevelCreateFootCollector(&attrOE,macOE,&colID,textStr,&stock);
  VDASSERTW(colID.objid != NULL_OBJID);
  
  // Make the curve
  VDdrawCurve(p1.edgeBsp,&macOE->mod_env,&crvID);
  VDASSERTW(crvID.objid != NULL_OBJID);
  
  // Package the feet
  feetIDs[0] = colID;
  feetIDs[1] = crvID;
  *feetCnt = 2;

  // Always Stock
  VSbevelCreateTextLabel("S",0,p1.pointPt,p1.orient,macOE,&p1.stockID);
  if (p1.stockID.objid != NULL_OBJID) {
    feetIDs[*feetCnt] = p1.stockID;
    *feetCnt = *feetCnt + 1;
  }    
  VSbevelCreateStockSymbol(p1.pointPt,p1.orient,macOE,&p1.symID);
  if (p1.symID.objid != NULL_OBJID) {
    feetIDs[*feetCnt] = p1.symID;
    *feetCnt = *feetCnt + 1;
  }
  
  // Done
  retFlag = 1;
  
 wrapup:

  // Free Up
  _FREE(p1.edgeBsp);
  _FREE(p1.srfBsp);

  // Check for errors
  if (!(retFlag & 1)) {
    if (macOE) {      
      printf("*** Bevel Compute Error For %d,%d\n",
	     macOE->obj_id.osnum,macOE->obj_id.objid);    
    }
  }
  
  // Say By
  if (traceFlag) {
    printf("<<< %s %d\n",fn,retFlag);
  }
  return retFlag;
}

/* -----------------------------------------------
 * Variables Bevel
 */
IGRstat	VScomputeVariable_Bevel(TGRobj_env *macOE,    // in
				IGRint      tempCnt,  // in
				IGRint     *feetCnt,  // out
				TGRid	   *feetIDs)  // out
{
  VDASSERT_FN("VScomputeVariable_Bevel");

  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  Tparent p1;

  TGRobj_env attrOE;
  TGRid      colID;
  TGRid     crv1ID;  
  TGRid     crv2ID;  

  IGRchar textStr[128]; // For the label
  IGRint  stock;
  
  // Init
  memset(&p1,0,sizeof(Tparent));
  attrOE.obj_id.objid = NULL_OBJID;
  crv1ID.objid = NULL_OBJID;
  crv2ID.objid = NULL_OBJID;
  colID.objid = NULL_OBJID;
  
  // Say Hi
  if (traceFlag) {
    printf(">>> %s\n",fn);
  }

  // Arg check
  VDASSERTW(feetCnt);
  *feetCnt = 0;
  VDASSERTW(feetIDs);

  // Set font size based on label feet
  VSbevelSetFontSize(0,macOE);
  
  // Attributes
  vdobj$GetTemplate(objOE = macOE, nth = 0, templateOE = &attrOE);
  VDASSERTW(attrOE.obj_id.objid != NULL_OBJID);

  // Plates and surfaces
  VSbevelGetPlateParent(macOE,1,&p1.plateOE,&p1.srfOE,&p1.srfBsp);
  VDASSERTW(p1.srfBsp);

  // Edges
  VSbevelGetEdgeParent(macOE,2,&p1.edgeOE,&p1.edgeBsp);
  VDASSERTW(p1.edgeBsp);

  VSbevelGetEdgeParent(macOE,3,&p1.edge2OE,&p1.edge2Bsp);
  VDASSERTW(p1.edge2Bsp);

  // Label points
  VSbevelGetPointParent(macOE,4,&p1.pointOE,p1.pointPt);
  VDASSERTW(p1.pointOE.obj_id.objid != NULL_OBJID);

  if (traceFlag) {
    vdobj$Print(objOE = &attrOE);
    vdobj$Print(objOE = &p1.plateOE);
    vdobj$Print(objOE = &p1.edgeOE);
    vdobj$Print(objOE = &p1.pointOE);
  }
  
  // Fill in the orientation stuff
  VSbevelFillOrient(p1.srfBsp,&p1.srfOE,p1.pointPt,p1.edgeBsp,p1.orient);

  // The collector
  VSbevelCreateFootCollector(&attrOE,macOE,&colID,textStr,&stock);
  VDASSERTW(colID.objid != NULL_OBJID);
  
  // Make the curves
  VDdrawCurve(p1.edgeBsp,&macOE->mod_env,&crv1ID);
  VDASSERTW(crv1ID.objid != NULL_OBJID);

  VDdrawCurve(p1.edge2Bsp,&macOE->mod_env,&crv2ID);
  VDASSERTW(crv2ID.objid != NULL_OBJID);
  
  // First label
  VSbevelCreateTextLabel(textStr,stock,p1.pointPt,p1.orient,macOE,&p1.textID);
  if (p1.textID.objid == NULL_OBJID) {
    printf("*** Problem creating first text label for\n");
    vdobj$Print(objOE = macOE);
    goto wrapup;
  }

  // Package the feet
  feetIDs[0] = colID;
  feetIDs[1] = crv1ID;
  feetIDs[2] = crv2ID;
  feetIDs[3] = p1.textID;
  *feetCnt = 4;

  // Need stock?
  if (stock) {

    VSbevelCreateStockSymbol(p1.pointPt,p1.orient,macOE,&p1.symID);
    if (p1.symID.objid != NULL_OBJID) {
      feetIDs[*feetCnt] = p1.symID;
      *feetCnt = *feetCnt + 1;
    }
    VSbevelCreateTextLabel("S",0,p1.pointPt,p1.orient,macOE,&p1.stockID);
    if (p1.stockID.objid != NULL_OBJID) {
      feetIDs[*feetCnt] = p1.stockID;
      *feetCnt = *feetCnt + 1;
    }    
  }
  
  // Done
  retFlag = 1;
  
 wrapup:

  // Free Up
  _FREE(p1.edgeBsp);
  _FREE(p1.edge2Bsp);
  _FREE(p1.srfBsp);
  
  // Check for errors
  if (!(retFlag & 1)) {
    if (macOE) {      
      printf("*** Bevel Compute Error For %d,%d\n",
	     macOE->obj_id.osnum,macOE->obj_id.objid);    
    }
  }

  // Say By
  if (traceFlag) {
    printf("<<< %s %d\n",fn,retFlag);
  }
  return retFlag;
}

end implementation Root;

