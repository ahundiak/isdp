/* $Id: VLunwChkLen.I,v 1.1 2002/04/16 13:58:57 ramarao Exp $  */
/***************************************************************************
 * I/LOFT
 *      
 * File:        isdp/loft/src/unwext/VLunwChkLen.I
 *
 * Description: Function to check the unwrap lengths against the base and
 * 		offset surface curves.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLunwChkLen.I,v $
 *      Revision 1.1  2002/04/16 13:58:57  ramarao
 *      Implemented CR# 5993.
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      04/16/02        Rama Rao        File Creation.
 ***************************************************************************/

class implementation VDSroot;

#include "EMSmsgdef.h"
#include "VDobj.h"
#include "VDefp.h"
#include "VDmem.h"
#include "VDgeom.h"
#include "VDchn.h"
#include "vddrwattr.h"
#include "v_datamacros.h"
#include "v_geommacros.h"
#include "vsplatedef.h"
#include "vlstructure.h"
#include "vlmsg.h"
#include "vlunfold.h"
#include "vlcontmacros.h"
#include "vldbgmacros.h"

from GRcurve	import	GRtotlength;
from VLunwObj	import	VLgetInst_devSrf;

extern OM_S_CHANSELECT  AS_to_comp;

extern GRclassid OPP_GR3dtext_class_id, OPP_GR3dlineseg_class_id;

static statGetClosestCurve( struct GRid		  	inpCrv,
	     	     	    IGRint			crvCount,
	     	            struct GRid			*crvList,
		     	    struct GRmd_env		crvEnv,
		     	    IGRint			*index     )
{
BSrc			rc;
IGRint			i;
IGRlong			sts, msg;
struct GRobj_env	crvOE;
IGRdouble       	spt[3], ept[3], mid_pt[3], mdist, spt1[3], spt2[3], 
			ept1[3], ept2[3], maxDist, minDist=1.0e+6, par, 
			dotp, pt[3];
struct IGRbsp_curve	*inpGeom=NULL, *crvGeom=NULL;

   *index = -1;

   crvOE.obj_id.objid = inpCrv.objid;
   crvOE.obj_id.osnum = inpCrv.osnum;
   crvOE.mod_env = crvEnv;
   sts = VLgetGeometry( &crvOE, FALSE, NULL_OBJID,
                        (IGRchar **)&inpGeom, &msg );
   __CheckRC( sts, msg, "VLgetGeometry", wrapup );

   for( i=0; i<crvCount; ++i )
   {
      _FREE( crvGeom );

      maxDist=0.0;

      crvOE.obj_id.objid = crvList[i].objid;
      crvOE.obj_id.osnum = crvList[i].osnum;

      sts = VLgetGeometry( &crvOE, FALSE, NULL_OBJID,
                           (IGRchar **)&crvGeom, &msg );
      __CheckRC( sts, msg, "VLgetGeometry", wrapup );

      MAbcendpts( &rc, inpGeom, spt1, ept1 );
      if( !(rc&1) ) continue;

      MAbcendpts( &rc, crvGeom, spt2, ept2 );
      if( !(rc&1) ) continue;

      vl$dotProduct( msg   = &rc,
                     sPnt1 = spt1,
                     ePnt1 = ept1,
                     sPnt2 = spt2,
                     ePnt2 = ept2,
                     dot   = &dotp );
      if( !(rc&1) || fabs( dotp ) < 0.9 )  continue;

      MAbcendpts( &rc, crvGeom, spt, ept );
      if( !(rc&1) ) continue;

      BSmdstptcv( inpGeom, spt, &par, pt, &mdist, &rc );
      if( rc != BSSUCC ) continue;
      if( mdist > maxDist ) maxDist = mdist;

      BSmdstptcv( inpGeom, ept, &par, pt, &mdist, &rc );
      if( rc != BSSUCC ) continue;
      if( mdist > maxDist ) maxDist = mdist;

      BScvmidpt( crvGeom, &par, mid_pt, &rc );
      if( rc != BSSUCC ) continue;

      BSmdstptcv( inpGeom, mid_pt, &par, pt, &mdist, &rc );
      if( rc != BSSUCC ) continue;
      if( mdist > maxDist ) maxDist = mdist;

      if( maxDist < minDist )
      {
	 minDist = maxDist ;
         *index  = i;
      }
   }

wrapup:
   _FREE( inpGeom );
   _FREE( crvGeom );
   return sts;
}

IGRlong	static statSetNULL( struct GRid *crvID )
{
IGRlong		sts, msg;
IGRdouble	crvLen=0.0;
struct GRmd_env	md_env;

    sts = vdobj$IsAncestryValid( objID = crvID,
                                 superClassID = OPP_GR3dlineseg_class_id );
    if( !(sts&1) ) return 0;

    gr$get_module_env( buffer = &md_env );

    sts = om$send(  msg      = message GRcurve.GRtotlength(
                                     &msg, &md_env.md_env.matrix_type,
                                     md_env.md_env.matrix,
                                     &crvLen ),
                    senderid = crvID->objid,
                    targetid = crvID->objid,
                    targetos = crvID->osnum    );
    if( crvLen > 50.0 ) return 0;

    crvID->objid = NULL_OBJID;

    return 1;
}

IGRlong	VLunwCheckLengths( struct GRobj_env	unwrapOE,
			   IGRint		*lengthCount,
			   struct GRid		**unwrapCrvIDs,
			   IGRdouble		**lengthList )
{
BSrc			rc;
IGRlong			sts, msg;
IGRint			i, j, baseEdgeCnt=0, offsetEdgeCnt=0, cnt=0,
			numCrv=0, crvCount=0, index;
IGRdouble               tol, fromMat[16], toMat[16], trfMat[16], unwrapLen,
			baseLen, offsetLen;
IGRboolean		deleteBase=FALSE, deleteOffset=FALSE;
IGRshort                trfMatType;
struct GRid		testCrv, *Crvs=NULL, *baseCrvIDs=NULL, *offsetCrvIDs=NULL,
			*baseMapCrvIDs=NULL, *offsetMapCrvIDs=NULL;
struct GRvg_construct   cst;
struct unw_obj_plat     dev;
VDpartAttr              attr;
OM_S_OBJECT_LINKAGE     crvList[100];
struct GRobj_env        plateOE, srfOE, crvOE, unwSrfOE, contourOE, drwOE;
struct IGRbsp_curve     *baseEdgeGeom[VDEFP_NEAT_EDGES_MAX],
			*offsetEdgeGeom[VDEFP_NEAT_EDGES_MAX];

   SetProc( VLunwCheckLengths ); Begin

   __DBGpr_obj( "Input Unwrap Object", unwrapOE.obj_id );

   *lengthCount = 0;
   *lengthList = NULL;
   *unwrapCrvIDs = NULL;

   baseEdgeCnt = 0;
   baseMapCrvIDs = NULL;

   offsetEdgeCnt = 0;
   offsetMapCrvIDs = NULL;

   /* Initialize the 'dev' structure */
   dev.devsrf  = NULL;
   dev.surface = NULL;
   dev.P       = NULL;
   dev.def     = NULL;
   dev.Param_u = NULL;
   dev.Param_v = NULL;

   //attr.Iwant = VL_I_devStruct ;
   attr.Iwant = VL_I_getOpts;
   attr.specific = (void *) &dev ;
   sts = om$send( msg = message GRvg.GRgetattr( &msg, (char *)&attr ),
		  senderid = NULL_OBJID,
                  targetid = unwrapOE.obj_id.objid,
                  targetos = unwrapOE.obj_id.osnum  );
   __CheckRC( sts, msg, "GRvg.GRgetattr", wrapup );

   vdobj$GetFoot(  objOE    = &unwrapOE,
                   footName = UNFOLD_NAM_UNWSRF,
                   footOE   = &unwSrfOE );
   __DBGpr_obj( "UnwrapSrf Feet ", unwSrfOE.obj_id );

   sts = VLgetGeometry( &unwSrfOE, TRUE, NULL_OBJID,
                        (IGRchar **)&dev.devsrf, &msg );
   __CheckRC( sts, msg, "VLgetGeometry", wrapup );

   sts = VLgetGeometry( &dev.surf_id, TRUE, NULL_OBJID,
                        (IGRchar **)&dev.surface, &msg );
   __CheckRC( sts, msg, "VLgetGeometry", wrapup );

   __DBGpr_obj( "UVSrf Feet ", dev.uvSrfId );
   if( dev.tesselation_option == ARC_LENGTH  &&
       ( om$is_objid_valid ( osnum = dev.uvSrfId.osnum ,
                             objid = dev.uvSrfId.objid ) == OM_S_SUCCESS ))
   {
       struct GRobj_env      uvSrf_id;
       struct IGRbsp_surface *uvSurf=NULL;

       uvSrf_id.obj_id  = dev.uvSrfId;
       uvSrf_id.mod_env = unwrapOE.mod_env;
       sts = VLgetGeometry( &uvSrf_id, FALSE, NULL_OBJID,
                            (IGRchar **)&uvSurf, &msg );
       if( sts&1&msg )
       {
           sts = VLunwFillDevStructureFromSrf( &msg, uvSurf, &dev );
       }
       _FREE(uvSurf);
   }

   vdobj$GetTemplate( objOE      = &unwrapOE,
                      nth        = 1,
                      templateOE = &plateOE );
   if( plateOE.obj_id.objid == NULL_OBJID ) goto wrapup;
   __DBGpr_obj( "Parent Plate", plateOE.obj_id );

   vdobj$GetFoot(  objOE    = &plateOE,
                   footName = VS_K_plBotSfPathABS,
                   footOE   = &srfOE );
   if( srfOE.obj_id.objid == NULL_OBJID ) goto wrapup;
   __DBGpr_obj( "Plate Base Surface", srfOE.obj_id );

   vdgeom$GetTolerance(cht = &tol);
   sts = VDefpGetSurfaceEdgeBsps( &srfOE, VDEFP_NEAT_EDGES_MAX,
                                  tol, &baseEdgeCnt, baseEdgeGeom );
   __CheckRC( sts, 1, "VDefpGetSurfaceEdgeBsps", wrapup );
   __DBGpr_int("Number Of Neat Edges on Base Surface", baseEdgeCnt );

   VDsupInitCnst( &cst ) ;
   crvOE.mod_env = *(cst.env_info);

   attr.Iwant = VL_I_fromMat ;
   attr.specific = (void *) fromMat ;
   sts = om$send( msg = message GRvg.GRgetattr( &msg, (char *)&attr ),
                  senderid = NULL_OBJID,
                  targetid = unwrapOE.obj_id.objid,
                  targetos = unwrapOE.obj_id.osnum  );
   __CheckRC( sts, msg, "GRvg.GRgetattr", wrapup );

   attr.Iwant = VL_I_toMat ;
   attr.specific = (void *) toMat ;
   sts = om$send( msg = message GRvg.GRgetattr( &msg, (char *)&attr ),
                  senderid = NULL_OBJID,
                  targetid = unwrapOE.obj_id.objid,
                  targetos = unwrapOE.obj_id.osnum  );
   __CheckRC( sts, msg, "GRvg.GRgetattr", wrapup );

   VLunwGetExternalContour( &unwrapOE, &contourOE );
   __DBGpr_obj( "Unwrap Outer Contour", contourOE.obj_id );

   crvCount = 0;
   om$get_channel_objects( objid = contourOE.obj_id.objid,
                           osnum = contourOE.obj_id.osnum,
                           p_chanselect = &AS_to_comp,
                           list  = crvList,
                           size  = 100,
                           count = (OMuint *) &crvCount );
   __DBGpr_int( "Outer Contour Composite Curve Count", crvCount );

   if( !crvCount )
   {
	crvCount = 1;
	crvList[0].S_objid = contourOE.obj_id.objid;
	crvList[0].osnum   = contourOE.obj_id.osnum;
   }

   if( !((*unwrapCrvIDs) = _MALLOC( crvCount, struct GRid ) ) )
        vd_$mem_fail( msg = &msg );

   for( i=0; i<crvCount; ++i )
   {
       (*unwrapCrvIDs)[i].objid = crvList[i].S_objid;
       (*unwrapCrvIDs)[i].osnum = crvList[i].osnum;
   }

   vdobj$GetFoot(objOE = &unwrapOE, footName = "geom", footOE = &drwOE);
   if (drwOE.obj_id.objid == NULL_OBJID) goto wrapup;

   vdchn$Get2( objOE  = &drwOE,
               chnIDx = VDCHN_IDX_TO_COMPONENTS,
               cnt    = &cnt);
   for(i=(cnt-1); i>0; --i ) 
   {
      IGRchar 		buf[256];
      struct GRid	txtID;

      vdchn$Get2( objOE  = &drwOE,
		  chnIDx = VDCHN_IDX_TO_COMPONENTS,
		  nth    = i,
		  outID = &txtID );
      sts = vdobj$IsAncestryValid( objID = &txtID,
		      		   superClassID = OPP_GR3dtext_class_id );
      if( !(sts&1) ) continue;

      VDcvgGetTextInfo( NULL, &txtID, buf, 0, NULL );
      VDstrlwr( buf );
      if( !strcmp( buf, "stock" ) )
      {
	 struct GRid		stockID;

	 stockID.objid = NULL_OBJID;
         vdchn$Get2( objOE  = &drwOE,
	             chnIDx = VDCHN_IDX_TO_COMPONENTS,
		     nth    = i-1,
		     outID  = &stockID );
         if(stockID.objid == NULL_OBJID) continue;

	 index = -1;
	 statGetClosestCurve( stockID, crvCount, (*unwrapCrvIDs),
	                      contourOE.mod_env, &index );
	 __DBGpr_int( "Matching Index for Stock Line", index );
	 if( index == -1 ) continue;

	 if( index == 0 ) statSetNULL( &(*unwrapCrvIDs)[crvCount-1] );
	 else		  statSetNULL( &(*unwrapCrvIDs)[index-1] );

	 if( index == crvCount ) statSetNULL( &(*unwrapCrvIDs)[0] );
	 else			 statSetNULL( &(*unwrapCrvIDs)[index+1] );

	 (*unwrapCrvIDs)[index] = stockID;

	 cnt = crvCount;
	 crvCount = 0;

	 for( j=0; j<cnt; ++j )
         {
	   if( (*unwrapCrvIDs)[j].objid == NULL_OBJID ) continue;
           (*unwrapCrvIDs)[crvCount] = (*unwrapCrvIDs)[j];
	   crvCount++;
	 }  
      }	 
   }


   if( baseEdgeCnt != crvCount ) 
   {
     goto check_offset;
   }

   if( !(baseMapCrvIDs = _MALLOC( crvCount, struct GRid ) ) ) 
	vd_$mem_fail( msg = &msg );

   if( !(baseCrvIDs = _MALLOC( crvCount, struct GRid ) ) )
        vd_$mem_fail( msg = &msg );

   for( i=0; i<baseEdgeCnt; ++i )
   {
       numCrv = 0;
       _FREE( Crvs );
       cst.geometry   = NULL;

       VDdrawCurve( baseEdgeGeom[i], NULL, &crvOE.obj_id );

       if( dev.developpable > 0 )
       {
           sts = VLapplyTransf( &crvOE.obj_id, 1, &crvOE.mod_env,
                          fromMat, toMat, trfMat, &trfMatType, &msg );
           __CheckRC( sts, msg, "VLapplyTransf", wrapup );
	   testCrv = crvOE.obj_id ;
       }
       else
       {
          sts = VLprojAndMapCrvOntoSrf( &dev, 1, &crvOE, FALSE,
                                        &cst, NULL, NULL, &numCrv, &Crvs );
          __CheckRC( sts, 1, "VLprojAndMapCrvOntoSrf", wrapup ) ;
          __DBGpr_int("VLprojAndMapCrvOntoSrf returns ", numCrv );
	  if( !numCrv ) continue;
	  testCrv = Crvs[0];
       }

       vd_$grCopy( msg     = &msg,
                   frEnv   = cst.env_info,
                   frObj   = &testCrv,
                   toEnv   = cst.env_info,
                   toObj   = &baseMapCrvIDs[i] );

       if( numCrv )
         VSbulkDeleteByGRids( cst.env_info, numCrv, Crvs );

       baseCrvIDs[i] = crvOE.obj_id;
   } 

   for( i=0; i<baseEdgeCnt; ++i )     _FREE( baseEdgeGeom[i] );

   deleteBase = TRUE ;

check_offset:
   vdobj$GetFoot(  objOE    = &plateOE,
                   footName = VS_K_plTopSfPathABS,
                   footOE   = &srfOE );
   if( srfOE.obj_id.objid == NULL_OBJID ) goto wrapup;
   __DBGpr_obj( "Plate Offset Surface", srfOE.obj_id );

   sts = VDefpGetSurfaceEdgeBsps( &srfOE, VDEFP_NEAT_EDGES_MAX,
                                  tol, &offsetEdgeCnt, offsetEdgeGeom );
   __CheckRC( sts, 1, "VDefpGetSurfaceEdgeBsps", wrapup );
   __DBGpr_int("Number Of Neat Edges on Offset Surface", offsetEdgeCnt );

   if( offsetEdgeCnt != crvCount ) 
   {
	goto check_unwrap;
   }

   if( !(offsetMapCrvIDs = _MALLOC( crvCount, struct GRid ) ) )
        vd_$mem_fail( msg = &msg );

   if( !(offsetCrvIDs = _MALLOC( crvCount, struct GRid ) ) )
	vd_$mem_fail( msg = &msg );

   for( i=0; i<offsetEdgeCnt; ++i )
   {
       numCrv = 0;
       VDdrawCurve( offsetEdgeGeom[i], NULL, &crvOE.obj_id );

       if( dev.developpable > 0 )
       {
           sts = VLapplyTransf( &crvOE.obj_id, 1, &crvOE.mod_env,
                          fromMat, toMat, trfMat, &trfMatType, &msg );
           __CheckRC( sts, msg, "VLapplyTransf", wrapup );
           testCrv = crvOE.obj_id ;
       }
       else
       {
          _FREE( Crvs );
          sts = VLprojAndMapCrvOntoSrf( &dev, 1, &crvOE, FALSE,
                                        &cst, NULL, NULL, &numCrv, &Crvs );
          __CheckRC( sts, 1, "VLprojAndMapCrvOntoSrf", wrapup ) ;
          __DBGpr_int("VLprojAndMapCrvOntoSrf returns ", numCrv );
          if( !numCrv ) continue;
          testCrv = Crvs[0];
       }

       vd_$grCopy( msg     = &msg,
                   frEnv   = cst.env_info,
                   frObj   = &testCrv,
                   toEnv   = cst.env_info,
                   toObj   = &offsetMapCrvIDs[i] );

       if( numCrv )
         VSbulkDeleteByGRids( cst.env_info, numCrv, Crvs );

       offsetCrvIDs[i] = crvOE.obj_id;
   }

   deleteOffset = TRUE ;

   for( i=0; i<offsetEdgeCnt; ++i )   _FREE( offsetEdgeGeom[i] );

check_unwrap:

   if( !((*lengthList) = _MALLOC( 3*crvCount, IGRdouble ) ) )
        vd_$mem_fail( msg = &msg );

   for( i=0; i<crvCount; ++i )
   { 
       sts = om$send(  msg      = message GRcurve.GRtotlength(
                                       &msg, &cst.env_info->md_env.matrix_type,
					cst.env_info->md_env.matrix,
					&unwrapLen ),
                       senderid = (*unwrapCrvIDs)[i].objid,
                       targetid = (*unwrapCrvIDs)[i].objid,
                       targetos = (*unwrapCrvIDs)[i].osnum    );
       __CheckRC( sts, msg, "GRcurve.GRtotlength", wrapup ) ;
       __DBGpr_dbl( "Unwrap Curve Length", unwrapLen );
       (*lengthList)[3*(*lengthCount)] = unwrapLen ;

       if( baseMapCrvIDs )
       {
	  index = -1;
	  statGetClosestCurve( 	(*unwrapCrvIDs)[i], crvCount, baseMapCrvIDs,
			 	contourOE.mod_env, &index );
	  __DBGpr_int( "Matching Index for base", index );

          sts = om$send(  msg      = message GRcurve.GRtotlength(
                                       &msg, &cst.env_info->md_env.matrix_type,
                                        cst.env_info->md_env.matrix,
                                        &baseLen ),
                       senderid = baseCrvIDs[index].objid,
                       targetid = baseCrvIDs[index].objid,
                       targetos = baseCrvIDs[index].osnum     ) ;
          __CheckRC( sts, msg, "GRcurve.GRtotlength", wrapup ) ;
          __DBGpr_dbl( "Base Length", baseLen );
          (*lengthList)[3*(*lengthCount)+1] = baseLen ;
       }
       else
       {
	  (*lengthList)[3*(*lengthCount)+1] = -1.0;
       }

       if( offsetMapCrvIDs )
       {
          index = -1;
          statGetClosestCurve( (*unwrapCrvIDs)[i], crvCount, offsetMapCrvIDs, 
                               contourOE.mod_env, &index );
          __DBGpr_int( "Matching Index for Offset", index );

          sts = om$send(  msg      = message GRcurve.GRtotlength(
                                       &msg, &cst.env_info->md_env.matrix_type,
                                        cst.env_info->md_env.matrix,
                                        &offsetLen ),
                       senderid = offsetCrvIDs[index].objid,
                       targetid = offsetCrvIDs[index].objid,
                       targetos = offsetCrvIDs[index].osnum     ) ;
          __CheckRC( sts, msg, "GRcurve.GRtotlength", wrapup ) ;
          __DBGpr_dbl( "Offset Length", offsetLen );
          (*lengthList)[3*(*lengthCount)+2] = offsetLen ;
       }
       else
       {
          (*lengthList)[3*(*lengthCount)+2] = -1.0;
       }
       (*lengthCount)++;
   }

wrapup:

   for( i=0; i<dev.devsrf->num_boundaries; ++i ) 
   { _FREE( dev.devsrf->bdrys[i].points ); }
   _FREE( dev.devsrf->bdrys );

   for( i=0; i<dev.surface->num_boundaries; ++i ) 
   { _FREE( dev.surface->bdrys[i].points ); }

   _FREE( dev.surface->bdrys );
   _FREE( dev.P   );
   _FREE( dev.def );
   _FREE( dev.Param_u );
   _FREE( dev.Param_v );
   _FREE( dev.surface );
   _FREE( dev.devsrf );
   _FREE( Crvs );

   if( deleteBase ) 
   {
	VSbulkDeleteByGRids( cst.env_info, baseEdgeCnt, baseMapCrvIDs );
	VSbulkDeleteByGRids( cst.env_info, baseEdgeCnt, baseCrvIDs );
   }

   if( deleteOffset )
   {
	VSbulkDeleteByGRids( cst.env_info, offsetEdgeCnt, offsetMapCrvIDs );
	VSbulkDeleteByGRids( cst.env_info, offsetEdgeCnt, offsetCrvIDs );
   }

   _FREE( baseMapCrvIDs );
   _FREE( offsetMapCrvIDs );
   _FREE( baseCrvIDs );
   _FREE( offsetCrvIDs );

   for( i=0; i<baseEdgeCnt; ++i )     _FREE( baseEdgeGeom[i] );

   End
   return sts;
}

end implementation VDSroot;
