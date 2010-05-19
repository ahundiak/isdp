/* $Id: VDefpCrvTran.I,v 1.1 2001/01/11 19:04:49 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdefp/VDefpCrvTran.I
 *
 * Description: Debug Translation Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDefpCrvTran.I,v $
 *      Revision 1.1  2001/01/11 19:04:49  art
 *      sp merge
 *
# Revision 1.1  2000/11/27  16:53:24  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/03/00  ah      Creation
 ***************************************************************************/
class implementation Root;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDexp.h"
#include "VDmem.h"
#include "VDgeom.h"
#include "VDefp.h"

#include "VDassert.h"

VDASSERT_FFN("vdefp/VDefpCrvTran.I");

/* -----------------------------------------------
 * Free memory allocated in tran structure
 */
IGRstat VDefpFreeTranInfo(TVDefpTranInfo *info)
{
  VDASSERT_FN("VDefpFreeTranInfo");
  IGRstat retFlag = 0;
  IGRint i;

  // Arg check
  VDASSERTW(info);
  
  // Free edges
  for(i = 0; i < info->edgeCnt; i++) {
    _FREE(info->edgeBsps[i]);
  }  
  _FREE(info->edgeBsp);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Check a proposed list of edges
 * No longer used because know that the edges will match
 */
IGRstat VDefpCheckEdgeList(IGRint edgeCnt, TGRbsp_curve **edgeBsps)
{
  VDASSERT_FN("VDefpCheckEdgeList");
  
  IGRstat retFlag = 0;
  
  IGRint    i,j;
  IGRpoint  pt1,pt2;
  IGRdouble dis;

  // Cycle through
  for(i = 0; i < edgeCnt; i++) {
    j = i + 1;
    if (j == edgeCnt) j = 0;

    VDgeomLinkCurves(edgeBsps[i],edgeBsps[j]);
    
    VDgeomGetCrvPt(edgeBsps[i],1.0,pt1);
    VDgeomGetCrvPt(edgeBsps[j],0.0,pt2);
    VDgeomGetDisPtPt(pt1,pt2,&dis);
    printf("Edge %2d %12.8f\n",i,dis);
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Fill in bunch of transform information
 * For a given plate
 *
 * Assume info has been cleared
 */
IGRstat VDefpGetTranInfoForPlate(TGRobj_env *plateOE,
				 TVDefpTranInfo *info)
{
  VDASSERT_FN("VDefpGetTranInfoForPlate");
  
  IGRstat retFlag = 0;
  IGRstat sts;
      
  IGRint  i;
  BSrc rc;

  IGRdouble dis,par0,par1,dotp;
  
  // Arg check
  VDASSERTW(info);
  VDASSERTW(plateOE);

  // Init some key stuff
  info->edgeBsp = NULL;
  info->edgeCnt = 0;
  
  // Plate
  info->plateOE = *plateOE;
  
  // Get the surface
  vdobj$GetFoot(objOE    = plateOE, 
		footName =  VDEFP_PLATE_BASE_SURF_NAME, 
		footOE   = &info->srfOE);
  VDASSERTW(info->srfOE.obj_id.objid != NULL_OBJID);

  // Need edge geometries
  VDefpGetSurfaceEdgeBsps(&info->srfOE,VDEFP_NEAT_EDGES_MAX,0.0,
			  &info->edgeCnt,info->edgeBsps);
  VDASSERTW(info->edgeCnt);

  // VDefpCheckEdgeList(info->edgeCnt,info->edgeBsps);
  
  // Make a single curve
  BSmergarrcv(info->edgeCnt,info->edgeBsps,&info->edgeBsp,&rc);
  VDASSERTW(info->edgeBsp);
  if (rc != BSSUCC) {
    printf("*** Problem merging curves\n");
  }
  
  // Store its arc len
  vdgeom$GetCrvArcLen(crv =  info->edgeBsp, 
		      len = &info->edgeLen);
  
  // Get some points
  VDgeomGetSymCrvAxis(info->edgeBsp,info->center,info->major,info->minor);
  
  // Some distances
  VDgeomGetDisPtPt(info->center,info->minor,&info->center_minor_distance);
  VDgeomGetDisPtPt(info->center,info->major,&info->center_major_distance);

  // Want included arc length from minor to major
  VDgeomGetDisPtParCrv(info->minor,info->edgeBsp,&dis,&par0);
  VDgeomGetDisPtParCrv(info->major,info->edgeBsp,&dis,&par1);
  vdgeom$GetCrvArcLen(crv  = info->edgeBsp,
		      par0 = par0,
		      par1 = par1,
		      len  = &info->minor_major_distance);
#if 0
  printf("Minor Par %.4f, Major Par %.4f, Distance %.4f\n",
	 par0,
	 par1,
	 info->minor_major_distance);
#endif

  // Some vectors
  BSmkvec(&rc,info->center_minor_vec,info->center,info->minor);
  BSmkvec(&rc,info->center_major_vec,info->center,info->major);

  MAunitvc(&rc,info->center_minor_vec,info->center_minor_vec);
  MAunitvc(&rc,info->center_major_vec,info->center_major_vec);

  BScrossp(&rc,info->center_minor_vec,info->center_major_vec,info->normal);
  
  // Like to know the angle
  VDgeomGetAngleFrom3Points(info->minor,
			    info->center,
			    info->major,
			    &info->angle);
  
  info->angle = VDgeomRadToDeg(info->angle);
  
  // Some tracing
#if 0
  printf("------ Outer Edge Info ------\n");
  printf("%-20s %-8.2f\n",
	 "Edge Length",info->edgeLen);
  printf("%-20s %-8.2f\n",
	 "Arc  Length",info->minor_major_distance);
  printf("%-20s %-8.2f %-82.f\n",
	 "Minor Distance", info->center_minor_distance,par0);
  printf("%-20s %-8.2f %-8.2f\n",
	 "Major Distance", info->center_major_distance,par1);
#endif
#if 0
  printf("------ Outer Edge Info ------\n");
  printf("Center %12.4f %12.4f %12.4f\n",info->center[0],info->center[1],info->center[2]);
  printf("Minor  %12.4f %12.4f %12.4f\n",info->minor [0],info->minor [1],info->minor [2]);
  printf("Major  %12.4f %12.4f %12.4f\n",info->major [0],info->major [1],info->major [2]);
#endif

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}


/* -----------------------------------------------
 * Compute transformation between two plates
 */
IGRstat VDefpComputeCrvTran2(TGRobj_env *macOE,
			     IGRint      opFlag,
			     IGRint     *feetCntx,
			     TGRid      *feetIDs)
{
  VDASSERT_FN("VDefpComputeCrvTran2");
  
  IGRstat retFlag = 0;
  IGRstat sts;
      
  TVDefpTranInfo p1,p2;
  
  TGRobj_env plateOE;
  IGRpoint pts[20];
  
  IGRint i;
  IGRint feetCnt = 0;
  
  BSrc rc;

  TGRmd_env *env;

  TVDgeomMat3x3 mat;
  
  // Init
  memset(&p1,0,sizeof(TVDefpTranInfo));
  memset(&p2,0,sizeof(TVDefpTranInfo));
  
  // Arg check
  VDASSERTW(feetCntx);
  *feetCntx = 0;
  VDASSERTW(feetIDs);
  VDASSERTW(macOE);
  
  env = &macOE->mod_env;
  
  // Get 1st parent, 
  vdobj$GetTemplate(objOE      = macOE,
                    nth        = VDEFP_CRV_TRAN2_TEMP_IDX_PLATE1,
                    templateOE = &plateOE);

  VDASSERTW(plateOE.obj_id.objid != NULL_OBJID);

  // Get the info
  VDefpGetTranInfoForPlate(&plateOE,&p1);
  VDASSERTW(p1.edgeBsp);
  
  // Get 2nd parent, 
  vdobj$GetTemplate(objOE      = macOE,
                    nth        = VDEFP_CRV_TRAN2_TEMP_IDX_PLATE2,
                    templateOE = &plateOE);

  VDASSERTW(plateOE.obj_id.objid != NULL_OBJID);

  // Get the info
  VDefpGetTranInfoForPlate(&plateOE,&p2);
  VDASSERTW(p2.edgeBsp);
  
  // Get the surface
  vdobj$GetFoot(objOE    = &p1.plateOE, 
		footName =  VDEFP_PLATE_BASE_SURF_NAME, 
		footOE   = &p1.srfOE);
  VDASSERTW(p1.srfOE.obj_id.objid != NULL_OBJID);

  // Create Contour Object
  VDdrawCurve(p1.edgeBsp,env,&feetIDs[feetCnt]);
  VDASSERTW(feetIDs[feetCnt].objid != NULL_OBJID);
  feetCnt++;
  
  VDdrawCurve(p2.edgeBsp,env,&feetIDs[feetCnt]);
  VDASSERTW(feetIDs[feetCnt].objid != NULL_OBJID);
  feetCnt++;
  
  // Show useful points
  VDgeomCpyPt(p1.center,pts[0]);
  VDgeomCpyPt(p1.minor, pts[1]);
  VDgeomCpyPt(p1.major, pts[2]);
  VDgeomCpyPt(p1.center,pts[3]);

  VDgeomCpyPt(p2.center,pts[4]);
  VDgeomCpyPt(p2.minor, pts[5]);
  VDgeomCpyPt(p2.major, pts[6]);
  VDgeomCpyPt(p2.center,pts[7]);

  VDdrawLinear(8,(IGRdouble*)pts,env,&feetIDs[feetCnt]);
  VDASSERTW(feetIDs[feetCnt].objid != NULL_OBJID);
  feetCnt++;

  // Are they like
  sts = VDefpComparePlates(1.0,&p1,&p2,mat);
  if (sts & 1) {
  
    UI_status("Like Parts");
    
    // Try a transformation
    for(i = 0; i < 4; i++) {
      VDgeomTransformPt(p1.center,p2.center,mat,pts[i],pts[i]);
      
    }
  
    VDdrawLinear(4,(IGRdouble*)pts,env,&feetIDs[feetCnt]);
    VDASSERTW(feetIDs[feetCnt].objid != NULL_OBJID);
    feetCnt++;
  }
  else UI_status("Not Like");

  // Really need to compare plate 2 against plate 1
  // Just to be sure

  // Done
  *feetCntx = feetCnt;
  retFlag = 1;
  
 wrapup:

  // Free edges
  VDefpFreeTranInfo(&p1);
  VDefpFreeTranInfo(&p2);
  
  return retFlag;
}

/* -----------------------------------------------
 * Compute
 */
IGRstat VDefpComputeCrvTran(TGRobj_env *macOE,
			    IGRint      opFlag,
			    IGRint     *feetCnt,
			    TGRid      *feetIDs)
{
  VDASSERT_FN("VDefpComputeCrvTran");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRobj_env plateOE;
  TGRobj_env srfOE;
  
  TGRbsp_curve *crv = NULL;
  
  IGRpoint center;
  IGRpoint major;
  IGRpoint minor;
  
  TGRbsp_curve *edgeBsps[VDEFP_NEAT_EDGES_MAX];
  IGRint        edgeCnt = 0;
  IGRint        i;
 
  BSrc rc;
  
  TVDefpTranInfo p1;
  
  // Init
  memset(&p1,0,sizeof(TVDefpTranInfo));

  // Arg check
  VDASSERTW(feetCnt);
  *feetCnt = 0;
  VDASSERTW(feetIDs);
  VDASSERTW(macOE);
  
  // Get 1st parent, 
  vdobj$GetTemplate(objOE      = macOE,
                    nth        = VDEFP_CRV_TRAN_TEMP_IDX_PLATE,
                    templateOE = &plateOE);
  VDASSERTW(plateOE.obj_id.objid != NULL_OBJID);

  // Get the info
  VDefpGetTranInfoForPlate(&plateOE,&p1);
  VDASSERTW(p1.edgeBsp);
  
  // Create Object
  i = 0;
  VDdrawCurve(p1.edgeBsp,&macOE->mod_env,&feetIDs[i]);
  VDASSERTW(feetIDs[i].objid != NULL_OBJID);
  
  // Make it
  i++;
  VDdrawLinear(1,p1.center,&macOE->mod_env,&feetIDs[i]);
  VDASSERTW(feetIDs[i].objid != NULL_OBJID);

  i++;
  VDdrawLinear(1,p1.minor,&macOE->mod_env,&feetIDs[i]);
  VDASSERTW(feetIDs[i].objid != NULL_OBJID);

  i++;
  VDdrawLinear(1,p1.major,&macOE->mod_env,&feetIDs[i]);
  VDASSERTW(feetIDs[i].objid != NULL_OBJID);

  i++;  
  *feetCnt = i;
  
  // Done
  retFlag = 1;
  
 wrapup:

  // Free
  VDefpFreeTranInfo(&p1);

  return retFlag;
}

end implementation Root;


