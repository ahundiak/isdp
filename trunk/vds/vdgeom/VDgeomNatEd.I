/* $Id: VDgeomNatEd.I,v 1.3 2001/10/04 16:07:16 ramarao Exp $  */

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
 *      $Log: VDgeomNatEd.I,v $
 *      Revision 1.3  2001/10/04 16:07:16  ramarao
 *      Fixed TR# 5525 and TR# 5564.
 *
 *      Revision 1.2  2001/01/11 18:41:18  art
 *      sp merge
 *
# Revision 1.6  2000/10/18  18:28:16  pinnacle
# ah
#
# Revision 1.5  2000/07/27  20:40:00  pinnacle
# ah
#
# Revision 1.2  2000/04/25  16:15:56  pinnacle
# ah
#
# Revision 1.1  2000/04/11  17:14:28  pinnacle
# ah
#
# Revision 1.2  2000/03/28  17:19:00  pinnacle
# ah
#
# Revision 1.1  2000/03/27  21:29:44  pinnacle
# ah
#
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
#include "VDobj.h"
#include "VDchn.h"
#include "VDmem.h"
#include "VDgeom.h"

#include "VDdbgProto.h"

#include "EMSopt.h"
#include "EMSlcdef.h"

static int traceFlag;

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
 * is returened in srfOEx.  The user must delete this object after
 * processing the edges
 *
 */
IGRstat VDgeomGetSurfaceNaturalEdges(TGRobj_env *srfOE,
				     TGRobj_env *srfOEx,
				     TGRmd_env  *edgeEnv,
				     IGRint     *edgeCnt,
				     TGRid     **edgeIds)
{
  IGRchar fn[] = "VDgeomGetSurfaceNaturalEdges";
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  IGRint  cnt;
  IGRlong option;
  IGRint  size = 0;
  
  // Say hi
  // traceFlag = 1;
  if (traceFlag) {
    printf(">>> %s\n",fn);
    vdobj$Print(objOE = srfOE);
  }

  // Arg check
  if (edgeCnt) *edgeCnt = 0;
  if (edgeIds) *edgeIds = NULL;
  if (edgeEnv)  gr$get_module_env(buffer = edgeEnv);
  if (srfOEx)   srfOEx->obj_id.objid = NULL_OBJID;

  if ((edgeCnt == NULL) || (edgeIds == NULL) || (edgeEnv == NULL)) goto wrapup;
  if ((srfOE   == NULL) || (srfOE->obj_id.objid == NULL_OBJID))    goto wrapup;
  if  (srfOEx  == NULL) goto wrapup;

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

    srfOEx->obj_id.osnum = edgeEnv->md_id.osnum;
    srfOEx->mod_env = *edgeEnv;
    srfOE = srfOEx;
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
			    edgeIds,
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
IGRstat VDgeomGetSurfaceXYZEdge(TGRobj_env    *a_edgeOE,
				TGRid         *a_edgeID,
				TGRmd_env     *a_edgeEnv,
				IGRint         a_wantFlag,
				TGRobj_env    *a_xyzOE,
				TGRbsp_curve **a_crv)
{
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
 * Wrapper to get sufrace contour geomotry
 */
IGRstat VDgeomGetSurfaceNaturalOuterContourGeometry(TGRobj_env    *srfOE,
						    IGRint         bspMax,
						    IGRint        *bspCnt,
						    TGRbsp_curve **bsps)
{
  IGRchar fn[] = "VDgeomGetSurfaceNaturalOuterContourGeometry";
  BSrc	  rc;
  IGRstat retFlag = 0;
  IGRboolean bool_stat;
  
  struct {
    TGRobj_env srfOE;
    TGRmd_env  env;
    IGRint     cnt;
    IGRint     i;
    TGRid     *ids;
  } nat;
  
  struct {
    IGRint max;
    IGRint cnt;
    IGRint i;
    IGRint want;
    
    TGRbsp_curve *bsp;
  } edge;
  
  IGRpoint  pt0,pt1;
  IGRpoint  pt1x,pt2x;
  IGRdouble dist, arc_length, start_par=0.0, mid_par=0.5, end_par=1.0 ;
  IGRint    isClosed = 0, edgeCnt=0;
  
  IGRint traceFlagx;
  
  // Say hi
  traceFlagx = traceFlag;
  // traceFlagx = 1;
  if (traceFlagx) {
    printf("--------------------------------------\n");
    printf(">>> %s\n",fn);
    vdobj$Print(objOE = srfOE);
  }
  
  // Init
  memset(&nat,0,sizeof(nat));
  nat.srfOE.obj_id.objid = NULL_OBJID;

  memset(&edge,0,sizeof(edge));
  
  // Arg check
  if (bspCnt) *bspCnt = 0;
  if ((bspCnt == NULL) || (bsps == NULL)) goto wrapup;
  
  // Get natural edges
  VDgeomGetSurfaceNaturalEdges(srfOE,
			       &nat.srfOE,
			       &nat.env,
			       &nat.cnt,
			       &nat.ids);
  if (traceFlagx) {
    printf("Nat Edge Count %d\n",nat.cnt);
  }

  // Get the edge geometries
  for(nat.i = 0; nat.i < nat.cnt; nat.i++) {

    if (nat.i == 0) edge.want = VDGEOM_WANT_BOTH;
    else            edge.want = VDGEOM_WANT_OPEN;
    
    // Get the real edge object
    VDgeomGetSurfaceXYZEdge(NULL,
			    &nat.ids[nat.i],
			    &nat.env,
			     edge.want,
			     NULL,
			    &edge.bsp);

    if (edge.bsp) {

      // Inform
      if (traceFlagx) {
	VDgeomGetCrvPt(edge.bsp,0.0,pt1x);	
	VDgeomGetCrvPt(edge.bsp,1.0,pt2x);	
	printf("Edge %3d %8.2f %8.2f %8.2f\n",nat.i,pt1x[0],pt1x[1],pt1x[2]);
	printf("         %8.2f %8.2f %8.2f\n",      pt2x[0],pt2x[1],pt2x[2]);
      }

      BSarclen( &rc, &bool_stat, edge.bsp, &start_par, &end_par,
		&mid_par, &arc_length );
      if( arc_length < 0.01 )
      {
	_FREE( edge.bsp );
	continue;
      }
      
      // Add to list
      if (*bspCnt < bspMax) {
	bsps[*bspCnt] = edge.bsp;
	*bspCnt = *bspCnt + 1;
	if (isClosed == 1) {

	  // Flags the caller that may have invalid internal geometry
	  retFlag = 3;
	}
      }

      /* -----------------------------------------
       * TR179901283
       * For surfaces with internal cutouts, first get the
       * surface edges then get the internal cuts, most internal
       * cutouts are physically closed and thus can be filtered
       * but it's possible (with invalid modeling techniques) to have
       * internal line string holes which are not closed
       *
       * Put a check in here so we stop getting edges once a closed
       * outer contour has been obtained, it's quicker anyways
       *
       * But we are assuming that the complete external contour comes first
       * before any problem internal cutouts.
       */
      if (nat.i == 0) VDgeomGetCrvPt(edge.bsp,0.0,pt0);
      VDgeomGetCrvPt(edge.bsp,1.0,pt1);
      VDgeomGetDisPtPt(pt0,pt1,&dist);

      /* -----------------------------------------
       * Disable the actual fix
       * The neat plate will flag invalid surface modeling
       * techniques which will probably mess up unwrap
       */
      /* 27 July 2000 
       * Turn the fix back on, unwrap deals with these just fine
       * I think, in fact, placing neat curves on internal cutouts actually
       * breaks the unwrap.
       */
      if (dist <= .01) nat.i = nat.cnt;
      if (dist <= .01) isClosed = 1;
      
    }
    else {
      if (traceFlagx) {
	printf("Edge %3d NO GEOMETRY\n",nat.i);
      }
    }
  }
  
  // Done
  if (retFlag == 0) retFlag = 1;
  
 wrapup:

  vdobj$Delete(objOE = &nat.srfOE);
  _FREE(nat.ids);

  if (traceFlagx) {
    printf("<<< %s, %d\n",fn,retFlag);
  }

  return retFlag;
  
}

end implementation Root;

