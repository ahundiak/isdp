/* $Id: VDgeomNatEd2.I,v 1.1 2001/03/16 17:10:46 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdgeom/VDgeomNatEd.I
 *
 * Description: Natural Edge Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDgeomNatEd2.I,v $
 *      Revision 1.1  2001/03/16 17:10:46  ahundiak
 *      *** empty log message ***
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/24/00  ah      Creation
 * 04/11/00  ah      TR179901283 Warning on invalid internal geometry
 * 07/27/00  ah      Do not return so called invalid inner geometry
 * 10/18/00  ah      Added more trace messages
 ***************************************************************************/

class implementation Root;

#include "VDtypedef.h"
#include "VDassert.h"
#include "VDlog.h"

#include "VDobj.h"
#include "VDchn.h"
#include "VDmem.h"
#include "VDgeom.h"

#include "VDdbgProto.h"

#include "EMSopt.h"
#include "EMSlcdef.h"

VDASSERT_FFN("vdgeom/VDgeomNatEd2.C");

from EMSsurface   import EMmk_nat_bdry;
from EMSsurface   import EMgetedges;
from EMSedge      import EMgetxyzobj;

from GRvg         import GRgeomprops;
from GRgraphics   import GRcopy;
from GRcurve      import GRendpts;

/* -----------------------------------------------
 * Get the natural edges of a surface
 * Calling routine must deallocate the edge array
 *
 * Need to return the enviroment since the surface may be 
 * copied and thus the edges may be in a different os then
 * the original surface
 *
 * In some cases, the original surface is copied.  The copied surface
 * is returned in srfOEx.  The user must delete this object after
 * processing the edges
 *
 */
IGRstat VDgeom2GetSurfaceNaturalEdges(TGRobj_env *srfOE,
				      TGRobj_env *srfOEx,
				      TGRmd_env  *edgeEnv,
				      IGRint     *edgeCnt,
				      TGRid     **edgeIDs)
{
  VDASSERT_FN("VDgeom2GetSurfaceNaturalEdges");
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  IGRint  cnt;
  IGRlong option;
  IGRint  size = 0;
  
  // Say hi
  // traceFlag = 1;
  if (traceFlag) printf(">>> %s\n",fn);

  // Arg check
  VDASSERTW(edgeCnt); *edgeCnt = 0;
  VDASSERTW(edgeIDs); *edgeIDs = NULL;
  VDASSERTW(edgeEnv); gr$get_module_env(buffer = edgeEnv);
  VDASSERTW(srfOEx);  srfOEx->obj_id.objid = NULL_OBJID;
  VDASSERTW(srfOE &&  srfOE->obj_id.objid != NULL_OBJID);

  if (traceFlag) vdobj$Print(objOE = srfOE);
  
  /* ---------------------------------------------------
   * If the surface has an owner, make a copy
   * Otherwise, the loop stuff gets confused
   */
  vdchn$Get2(objOE = srfOE, chnIDx = VDCHN_IDX_TO_OWNERS, cnt = &cnt);

  if (cnt != 0) {
    sts = om$send(msg = message EMSsurface.
		  GRcopy(&msg,
			 &srfOE->mod_env,
			  edgeEnv,
			 &srfOEx->obj_id.objid),
		  senderid = NULL_OBJID,
		  targetid = srfOE->obj_id.objid, 
		  targetos = srfOE->obj_id.osnum);
    if (!(sts & msg & 1)) {
      printf("Problem making copy of surface while getting edges\n");
      goto wrapup;
    }
    VDASSERTW(srfOEx->obj_id.objid != NULL_OBJID);
    
    srfOEx->obj_id.osnum = edgeEnv->md_id.osnum;
    srfOEx->mod_env = *edgeEnv;
    srfOE = srfOEx;  // Just swaps the pointer, not the content
    if (traceFlag) {
      printf("Copy ");
      vdobj$Print(objOE = srfOE);
    }
    // if (1) goto wrapup;
    
  }

  /* ---------------------------------------------------
   * Now we know what this thing does,
   * used on some of the chock surfaces
   * without it get a single edge that sort of looks like
   * a big curve
   *
   * I think it depends on the method used to create the surface
   * Based on vs$make_natural_boundary
   */
  vdchn$Get2(objOE = srfOE, chnIDx = VDCHN_IDX_TO_LOOPSET, cnt = &cnt);
  if (traceFlag) printf("Number of loop_sets %d\n",cnt);

  if (cnt == 0) {
    if (traceFlag) printf("Made natural boundaries\n");
    sts = om$send(msg = message EMSsurface.
		  EMmk_nat_bdry(&msg, &srfOE->mod_env.md_env, NULL ),
		  senderid = NULL_OBJID,
		  targetid = srfOE->obj_id.objid,
		  targetos = srfOE->obj_id.osnum);
    if (!(sts & msg & 1)) {
      printf("Problem creating natural boundaries while getting surface edges\n");
    }
  }

  // Save the enviroment (don't always copy surface)
  *edgeEnv = srfOE->mod_env;
  
  // Get the master edge objects
  option = EMS_OPT_ALL;
  option = EMS_OPT_CONNECTABLE;
  sts = om$send(msg = message EMSsurface.
		EMgetedges(&msg,
			    option,
			    edgeIDs,
			   &size,
			    edgeCnt,
			   NULL,NULL,NULL,NULL),
		senderid = srfOE->obj_id.objid,
		targetid = srfOE->obj_id.objid,
		targetos = srfOE->obj_id.osnum);

  if ((!(sts & msg & 1)) || (*edgeCnt < 1)) {
    printf("Problem with EMSsurface.EMgetedges, Edge Count %d\n",*edgeCnt);
    goto wrapup;
  }
  if (traceFlag) printf("Number of original natural edges is %d\n",*edgeCnt);
  
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  return retFlag;
}

/* -----------------------------------------------
 * Given a natural edge (generated by EMgetedges)
 * Return the so called xyz object and it geometry
 */
IGRstat VDgeom2GetSurfaceXYZEdge(TGRobj_env    *a_edgeOE,
				 TGRid         *a_edgeID,
				 TGRmd_env     *a_edgeEnv,
				 IGRint         a_wantFlag,
				 TGRobj_env    *a_xyzOE,
				 TGRbsp_curve **a_crv)
{
  VDASSERT_FN("VDgeomGetSurfaceXYZEdge");
  
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  TGRobj_env edgeOE;
  TGRobj_env xyzOE;
  TGRobj_env xyzOEx;

  IGRint getIt = 0;
  IGRint closed;
  
  // Arg check
  if (a_xyzOE) a_xyzOE->obj_id.objid = NULL_OBJID;
  if (a_crv)  *a_crv = NULL;
  
  // Get the natural edge
  edgeOE.obj_id.objid        = NULL_OBJID;
  edgeOE.mod_env.md_id.objid = NULL_OBJID;
  if (a_edgeOE)  edgeOE         = *a_edgeOE;
  if (a_edgeID)  edgeOE.obj_id  = *a_edgeID;
  if (a_edgeEnv) edgeOE.mod_env = *a_edgeEnv;
  if (edgeOE.obj_id.objid        == NULL_OBJID) goto wrapup;
  if (edgeOE.mod_env.md_id.objid == NULL_OBJID) goto wrapup;
  
  // Have the system create an object containing edge curve
  // Actually get a GA object not GR
  xyzOE = edgeOE;
  xyzOE.obj_id.objid = NULL_OBJID;
  
  sts = om$send(msg = message EMSedge.
		EMgetxyzobj(&msg,
			    0,
			    &xyzOE.mod_env.md_env, /* xyzinfo   */
			    NULL,                  /* xyzcv     */
			    NULL,                  /* xyzcvtype */
			    NULL,                  /* xyzsymb   */
			    NULL,                  /* xyzattr   */
			     xyzOE.obj_id.osnum,   /* xyzos     */
			    &xyzOE.obj_id.objid),  /* Output    */
                senderid = NULL_OBJID,
		targetid = edgeOE.obj_id.objid,
		targetos = edgeOE.obj_id.osnum) ;

  if ((!(sts & msg & 1)) || (xyzOE.obj_id.objid == NULL_OBJID)) {
    printf("*** Problem with EMSedge.EMgetxyzobj\n");
    vdobj$Print(objOE = &xyzOE);
    goto wrapup;
  }

  if (traceFlag) {
    printf("XYZ  ");
    vdobj$Print(objOE = &xyzOE);
  }

  // Making a copy converts from GA3dlinestr to GR3dlinestr
  xyzOEx = xyzOE;
  xyzOEx.obj_id.objid = NULL_OBJID;
 
  sts = om$send(msg = message EMSedge.
		GRcopy(&msg,
		       &xyzOE.mod_env,
		       &xyzOEx.mod_env,
		       &xyzOEx.obj_id.objid),
		senderid = NULL_OBJID,
		targetid = xyzOE.obj_id.objid, 
		targetos = xyzOE.obj_id.osnum);

  if ((!(sts & msg & 1)) || (xyzOEx.obj_id.objid == NULL_OBJID)) {
    printf("*** Problem copying EMSedge object\n");
    vdobj$Print(objOE = &xyzOE);
    goto wrapup;
  }
  vdobj$Delete(objOE = &xyzOE);
  xyzOE = xyzOEx;

  if (traceFlag) {
    printf("XYZ  ");
    vdobj$Print(objOE = &xyzOE);
  }
    
  /* Want open or closed or both */
  if (a_wantFlag == VDGEOM_WANT_BOTH) getIt = 1;
  else {
    getIt = 0;
    VDgeomIsCurveObjectClosed(&xyzOE,0.0,&closed);

    /* Hack here, sometimes get a single line string as the entire edge
     * Assume the very first edge is always on the contour
     * and ask for BOTH for the first edge
     * Need to drill a hole in a chock to see
     */
    if ((a_wantFlag == VDGEOM_WANT_OPEN)   && (closed == 0)) getIt = 1;
    if ((a_wantFlag == VDGEOM_WANT_CLOSED) && (closed != 0)) getIt = 1;
    
  }
  
  // Do we want it?
  if (getIt == 0) {
    goto wrapup;
  }
  
  /* Get the geometry if requested */
  if (a_crv) {
    vdgeom$Get2(objOE = &xyzOE, crv = a_crv);
  }
  
  // Return the object if requested
  if (a_xyzOE) {
    *a_xyzOE = xyzOE;
    xyzOE.obj_id.objid = NULL_OBJID; // So it won't be deleted
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  vdobj$Delete(objOE = &xyzOE);
  return retFlag;
}

/* -----------------------------------------------
 * Wrapper to get all surface contour geometry
 *
 * bsps == NULL just returns count
 *
 * If i_bsps is passed and there is sufficient room
 * as indicated by i_bspMax then use it otherwise
 * allocate enough room
 *
 * Calling routine needs to free o_bsps as well as
 * the individual bsp entries
 */
IGRstat VDgeom2GetSurfaceNaturalContourGeometry(TGRobj_env     *i_srfOE,

						IGRint          i_bspMax,
						TGRbsp_curve  **i_bsps,

						IGRint         *o_bspCnt,
						TGRbsp_curve ***o_bsps)
{
  VDASSERT_FN("VDgeom2GetSurfaceNaturalContourGeometry");  
  IGRstat retFlag = 0;
  
  struct {
    TGRobj_env srfOE;
    TGRmd_env  env;
    IGRint     cnt;
    IGRint     i;
    TGRid     *ids;
  } nat;
  
  struct {
    IGRint cnt;
    IGRint i;
    TGRbsp_curve **bsps;
    TGRbsp_curve  *bsp;
  } edge;
  
  IGRpoint pt1,pt2;
  
  // Init
  memset(&nat,0,sizeof(nat));
  nat.srfOE.obj_id.objid = NULL_OBJID;
  memset(&edge,0,sizeof(edge));

  // Arg check
  if (o_bsps) *o_bsps = NULL;
  VDASSERTW(o_bspCnt); *o_bspCnt = 0;
  VDASSERTW(i_srfOE && i_srfOE->obj_id.objid != NULL_OBJID);
  
  // Say hi
  if (traceFlag) {
    printf("--------------------------------------\n");
    printf(">>> %s\n",fn);
    vdobj$Print(objOE = i_srfOE);
  }
  
  // Get natural edges
  VDgeom2GetSurfaceNaturalEdges(i_srfOE,
				&nat.srfOE,
				&nat.env,
				&nat.cnt,
				&nat.ids);
  if (traceFlag) {
    printf("Nat Edge Count %d\n",nat.cnt);
  }

  // Maybe only want the count
  if (o_bsps == NULL) {
    *o_bspCnt = nat.cnt;
    retFlag = 1;
    goto wrapup;
  }
  
  // Alloc room
  if (nat.cnt <= i_bspMax) edge.bsps = i_bsps;
  else edge.bsps = calloc(nat.cnt,sizeof(TGRbsp_curve*));
  VDASSERTW(edge.bsps);
  
  // Get the edge geometries
  for(nat.i = 0; nat.i < nat.cnt; nat.i++) {

    // Get the real edge object
    VDgeom2GetSurfaceXYZEdge(NULL,&nat.ids[nat.i],&nat.env,
			     VDGEOM_WANT_BOTH,NULL,
			     &edge.bsp);

    VDASSERTW(edge.bsp);
    edge.bsps[edge.cnt] = edge.bsp;
    edge.cnt++;
    
    // Inform
    if (traceFlag) {
      VDgeomGetCrvPt(edge.bsp,0.0,pt1);	
      VDgeomGetCrvPt(edge.bsp,1.0,pt2);	
      printf("Edge %3d %8.2f %8.2f %8.2f\n",nat.i,pt1[0],pt1[1],pt1[2]);
      printf("         %8.2f %8.2f %8.2f\n",      pt2[0],pt2[1],pt2[2]);
    }
  }

  // Results
  *o_bspCnt = edge.cnt;
  *o_bsps   = edge.bsps;

  // Reset so wrapup will not free
  edge.bsps = NULL;
  edge.cnt  = 0;
  
  // Done
  retFlag = 1;
  
 wrapup:

  // Surface stuff
  vdobj$Delete(objOE = &nat.srfOE);
  _FREE(nat.ids);

  // Good cleanup on error
  if (edge.bsps) {  
    for(edge.i = 0; edge.i < edge.cnt; edge.i++) {
      _FREE(edge.bsps[edge.i]);
    }
    if (edge.bsps != i_bsps) _FREE(edge.bsps);
  }
  
  // Say bi
  if (traceFlag) printf("<<< %s, %d\n",fn,retFlag);
  return retFlag;
  
}

/* -----------------------------------------------
 * Given an array of bsp curves, 
 * a tolerance
 * and a starting index, 
 * pretend to stitch together the curves
 *
 * Return the ending index of the first non-stichable curve
 * 
 * The snap flag forces the stichable end points to match exactly
 *
 * Outputs
 * No more curves bspEnd = bspBeg = bspCnt
 *
 * First curve is closed bspEnd = bspBeg + 1
 *
 * Say the first three curves can be stiched but not the fourth
 * i.e. curves 2,3,4 for a closed curve
 * bspBeg = 2
 *          2 and 3 can be stiched
 *          3 and 4 can be stiched
 *          4 and 5 cannot be stiched
 * bspEnd = 5
 */
IGRstat VDgeom2GetNthMergeableCurve(TGRbsp_curve **bsps,
				    IGRint         bspCnt,
				    IGRint         bspBeg,
				    IGRdouble      tol,
				    IGRint         snapFlag,
				    IGRint        *bspEnd)
{
  VDASSERT_FN("VDgeomGetNthMergeableCurve");
  IGRstat retFlag = 0;

  IGRint nth;
  TGRbsp_curve *bsp0 = NULL;
  TGRbsp_curve *bsp1 = NULL;
  TGRbsp_curve *bsp2 = NULL;
  
  IGRpoint pt1,pt2;
  IGRdouble distance;
  
  // Arg check
  VDASSERTW(bspEnd); *bspEnd = bspCnt;
  VDASSERTW(bsps);
  
  // Want it set to something
  if (tol < .001) tol = .001;
  
  // See if at end
  if (bspBeg >= bspCnt) goto wrapup;
  
  // The very first curve might be closed
  bsp0 = bsps[bspBeg];
  VDgeomGetCrvEndPts(bsp0,pt1,pt2);
  VDgeomGetDisPtPt(pt1,pt2,&distance);
  if (distance <= tol) {  
    if (snapFlag) VDgeomCloseCurve(bsp0);
    *bspEnd = bspBeg + 1;
    retFlag = 1;
    goto wrapup;
  }
 
  /* ---------------------------------------------
   * The bspBeg curve is open
   * Just to keep the logic a bit easier, 
   *if this is the last curve then return
   */
  if ((bspBeg +1) >= bspCnt) {
    *bspEnd = bspBeg + 1;
    retFlag = 1;
    goto wrapup;
  }
    
  // Cycle and look for stichable curves
  for(nth = bspBeg + 1; nth < bspCnt; nth++) {

    // Next curve
    bsp1 = bsps[nth-1];
    bsp2 = bsps[nth];

    // Check end points
    VDgeomGetCrvPt(bsp1,1.0,pt1);	
    VDgeomGetCrvPt(bsp2,0.0,pt2);	
    VDgeomGetDisPtPt(pt1,pt2,&distance);

    // Stichable?
    if (distance > tol) {

      /* ----------------------------------------
       * So bsp1 and bsp2 are not stichable
       *
       * See if the first curve (bsp0) and bsp1
       * can from a closed curve
       * and snap if desired
       */
      if ((bsp0 != bsp1) && (snapFlag)) {
	VDgeomGetCrvPt(bsp0,0.0,pt1);	
	VDgeomGetCrvPt(bsp1,1.0,pt2);	
	VDgeomGetDisPtPt(pt1,pt2,&distance);
	if (distance <= tol) VDgeomLinkCurves(bsp1,bsp0);
      }
      
      // Not stichable
      *bspEnd = nth;
      retFlag = 1;
      goto wrapup;
    }
    // Snap it
    if (snapFlag) VDgeomLinkCurves(bsp1,bsp2);
  }
  
  /* ---------------------------------------------
   * At this point have at least two stichable
   * curves at the end of the list
   * so see if they form a closed curve
   */
  if ((bsp0 != bsp2) && (snapFlag)) {
    VDgeomGetCrvPt(bsp0,0.0,pt1);	
    VDgeomGetCrvPt(bsp2,1.0,pt2);	
    VDgeomGetDisPtPt(pt1,pt2,&distance);
    if (distance <= tol) VDgeomLinkCurves(bsp2,bsp0);
  }

  // Done
  *bspEnd = nth;
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Merge all the stichable edges together
 * Stiched entries will be freed and NULLED out
 * 
 */
IGRstat VDgeom2MergeNaturalEdges(TGRbsp_curve **bsps, 
				 IGRint         bspCnt, 
				 IGRdouble      tol)
{
  VDASSERT_FN("VDgeom2MergeNaturalEdges");
  IGRstat retFlag = 0;
  
  IGRint i;
  IGRint j;
  IGRint k;
  IGRint n;
  
  TGRbsp_curve *mergeBsp;
  BSrc rc;
  
  // Argcheck
  VDASSERTW(bsps);
  
  // Cycle through and get infor on merges
  for(i = 0; i < bspCnt; i = j) {

    // Indicated how many can be merged
    VDgeom2GetNthMergeableCurve(bsps,bspCnt,i,tol,1,&j);

    // printf("Back from GetNthMergeableCurve, %d %d %d\n",i,j,bspCnt);
    
    n = j - i;
    if (n > 1) {

      // Make a merge
      mergeBsp = NULL;
      BSmergarrcv(n,&bsps[i],&mergeBsp,&rc);
      VDASSERTW(mergeBsp);
      if ((mergeBsp == NULL) || (rc != BSSUCC)) {
	printf("*** Problem merging curves\n");
      }   
      else {
	for(k = i; k < j; k++) {
	  _FREE(bsps[k]);
	  bsps[k] = NULL;
	}
	bsps[i] = mergeBsp;
      }
    }
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

end implementation Root;








