/* $Id: VDefpEdge2.I,v 1.7.4.1 2002/07/16 16:58:32 ramarao Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdefp/VDefpEdge2.I
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDefpEdge2.I,v $
 *      Revision 1.7.4.1  2002/07/16 16:58:32  ramarao
 *      Fixed TR# 6547.
 *
 *      Revision 1.7  2001/06/16 17:27:38  ramarao
 *      Fixed TR# 5288.
 *
 *      Revision 1.6  2001/04/26 21:56:43  ramarao
 *      Fixed ETL# 7962.
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/24/00  ah      Creation
 * 04/11/00  ah      TR179901283 Warning
 * 05/19/00  ah      No knuckle processing for single line string plates.
 * 05/22/00  ah      Filter out points in edge geometries
 * 10/18/00  ah      TR179902030 Increase the nat edge limit from 100 to 200
 * 11/17/10  ah      SOL10 - TR
 ***************************************************************************/
class implementation Root;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDmem.h"
#include "VDgeom.h"
#include "VDefp.h"

#include "VDdbgProto.h"

#include "EMSopt.h"
#include "EMSlcdef.h"

#include "acdef.h"
#include "acmacros.h"
#include "asmacros.h"
#include "macro.h"

#include "bsdirfitcv.h"

static int traceFlag;

from EMSsurface   import EMmk_nat_bdry;
from EMSsurface   import EMgetedges;
from EMSsubbs     import EMget_edges;
from EMSedge      import EMgetxyzobj;

from ACrg_collect import ACset_list_attribute;

from ci_macro     import init;

from GRvg         import GRchgdp;
from GRvg         import GRchglevel;
from GRvg         import GRgetsymb;
from GRvg         import GRputsymb;
from GRvg         import GRcenter;
from GRvg         import GRgeomprops;

from GRgraphics   import GRchgname;
from GRgraphics   import GRputname;
from GRgraphics   import GRcopy;
from ACncpx       import ACmplace;
from GRconnector  import GRrigidconn;
from GRgraphics   import GRaltconstruct;

extern VDclassid OPP_nci_macro_class_id;
extern VDclassid OPP_ACrg_collect_class_id;
extern GRclassid OPP_GR3dlineseg_class_id;

//#define DEBUG 1
/* -----------------------------------
 * Debug trace flag
 */
IGRstat VDefpEdgeGetTraceFlag2()
{
  IGRstat retFlag = VDdbgGetTraceFlag(VDEFP_TRACE_COMPUTE_NEAT);
  return  retFlag;
}

/* ------------------------------------------------------------------
 * Try to merge curve into existing list
 */
IGRstat VDefpMergeCurve(TGRbsp_curve  *crv1,
			IGRint         mergeIt,
			IGRint         a_edgeMax,
			IGRint        *a_edgeCnt,
			TGRbsp_curve **a_edgeBsps)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRint  i;
  
  TGRbsp_curve *crv0 = NULL;
  TGRbsp_curve *crv2 = NULL;
  
  IGRdouble dist;
  
  // Arg check
  if ((crv1 == NULL) || (a_edgeCnt == NULL) || (a_edgeBsps == NULL)) goto wrapup;

  /* ---------------------------------------------
   * For some knuckle plates, getting some points slipping through
   *
   * This might a bug in the loop which checks knots
   * Or they might be something else going on
   *
   * Use a very tight tolerance and filter out all points
   */
  if ((crv1->order == 2) && (crv1->rational == 0) && (crv1->num_poles == 2)) {
    VDgeomGetDisPtPt(&crv1->poles[0],&crv1->poles[3],&dist);
    if (dist < .0001) {
      // printf("### Discarding point in VDefpMergeCurve\n");
      retFlag = 1;
      goto wrapup;
    }
  }
    
  // See if we should even try
  if ((mergeIt == 0) || (*a_edgeCnt == 0)) 
  {
    if (*a_edgeCnt < a_edgeMax) {
      a_edgeBsps[*a_edgeCnt] = crv1;
      *a_edgeCnt = *a_edgeCnt + 1;
    }
    retFlag = 1;
    goto wrapup;
  }
  
  // See if mergable
  crv0 = a_edgeBsps[*a_edgeCnt-1];
  sts = VDgeomTestProductionMerge(crv0,crv1,0.0,0.0);
  if (!(sts & 1)) {
    if (*a_edgeCnt < a_edgeMax) {
      a_edgeBsps[*a_edgeCnt] = crv1;
      *a_edgeCnt = *a_edgeCnt + 1;
    }
    retFlag = 1;
    goto wrapup;
  }
    
  // Merge them
  VDgeomMergeTwoCurves(crv0,crv1,&crv2);
  if (crv2 == NULL) {
    
    // Merge failed, oh well
    if (*a_edgeCnt < a_edgeMax) {
      a_edgeBsps[*a_edgeCnt] = crv1;
      *a_edgeCnt = *a_edgeCnt + 1;
    }
    retFlag = 1;
    goto wrapup;
  }

  // Swap out
  _FREE(crv0);
  _FREE(crv1);
  a_edgeBsps[*a_edgeCnt-1] = crv2;
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ------------------------------------------------------------------
 * Append and break at cusp points
 */
IGRstat VDefpAppendCurve(TGRbsp_curve  *a_crv,
			 IGRint         breakCusps,
			 IGRint         mergeIt,
			 IGRint         a_edgeMax,
			 IGRint        *a_edgeCnt,
			 TGRbsp_curve **a_edgeBsps)
{
  IGRstat       retFlag = 1;
  BSrc          rc;
  IGRboolean    start_count=FALSE;
  TGRbsp_curve  *crv;
  IGRdouble     par1,par2, start_par, end_par;

  struct {
    IGRdouble *cusps;
    IGRint    num;
    IGRint    i;
  } cusp;
  
  // Arg check
  if ((a_crv == NULL) || (a_edgeCnt == NULL) || (a_edgeBsps == NULL)) goto wrapup;

  // Get the cusps
  cusp.num = 0;
  cusp.cusps = _MALLOC( ( a_crv->num_poles + a_crv->order - 1 ),
                        IGRdouble );
  if (breakCusps) BSfndcvcsp(a_crv,&cusp.num,cusp.cusps,&rc);
  
  // If no cusps just add the curve
  if (cusp.num == 0) {
    VDefpMergeCurve(a_crv,mergeIt,a_edgeMax,a_edgeCnt,a_edgeBsps);
    retFlag = 1;
    goto wrapup;
  }
  
  // Make sure get last one
  cusp.cusps[cusp.num] = 1.0;
  cusp.num++;
  par1 = 0.0;

  start_count = FALSE; 
  start_par = end_par = 0.0;
 
  // Loop through
  for(cusp.i = 0; cusp.i < cusp.num; cusp.i++) {

    par2 = cusp.cusps[cusp.i];

    if ((par2 - par1) > .001)   // This value is critical for some line strings
    {
      if( ( end_par - start_par ) > 0.001 )
      { 
          VDgeomExtractCurve(a_crv,start_par,end_par,&crv);
          VDefpMergeCurve(crv,mergeIt,a_edgeMax,a_edgeCnt,a_edgeBsps);
      } 
      VDgeomExtractCurve(a_crv,par1,par2,&crv);
      // printf("Merging %12.4f %12.4f\n",par1,par2);

      VDefpMergeCurve(crv,mergeIt,a_edgeMax,a_edgeCnt,a_edgeBsps);

      start_count = FALSE;
      start_par = end_par = 0.0;
    }
    else
    {
        if( start_count == FALSE ) 
        { 
            start_par = par1; 
            start_count = TRUE; 
        }
        end_par = par2;
    }
    par1 = par2;
  }
  
  // Free the curve
  _FREE(a_crv);
  
  // Done
  retFlag = 1;
  
wrapup:
  _FREE( cusp.cusps );
  return retFlag;
}

/* -----------------------------------------------
 * Direct fit a curve
 */
IGRstat VDgeomDirectFitCurve(TGRbsp_curve *crv, 
			     IGRdouble     par1,
			     IGRdouble     par2,
			     TGRbsp_curve **fit)
{
  IGRstat retFlag = 0;
  BSrc    rc;
  
  TGRbsp_curve *crvx = NULL;
  
  // Arg check
  if (fit == NULL) goto wrapup; *fit = NULL;
  if (crv == NULL) goto wrapup;
  
  // Might need to extract
  if ((par1 > .01) || (par2 < .99)) {
    VDgeomExtractCurve(crv,par1,par2,&crvx);
    if (crvx == NULL) goto wrapup;
    crv = crvx;
  }
  
  // Alloc
  vdgeom$AllocCrv(order     = 4,
		  num_poles = crv->num_poles + 3,
		  crv       = fit);

  if (fit == NULL) {
    printf("Problem allocating curve information\n");
    goto wrapup;
  }

  BSdirfitcv((IGRlong)    crv->num_poles,
	     (IGRpoint *) crv->poles,
	     (IGRshort) 4, 
	     0, 0, FALSE, NULL, NULL,
	     *fit,
	     &rc);

  if (rc != BSSUCC) {
    printf("Problem direct fitting curve\n");
    goto wrapup;
  }

  retFlag = 1;
  
wrapup:
  _FREE(crvx);
  return retFlag;
}

/* ------------------------------------------------------------------
 * At this point, have a line string and we are writing it
 * out in sections
 *
 * This routine is called once per section and returns
 * index of last knot written
 */
IGRstat VDefpAppendLineStringSection(IGRint         knuckleFlag,
				     TGRbsp_curve  *a_crv,
				     IGRint         a_numKnots,
				     IGRdouble     *a_knots,
				     IGRint        *a_knotI,
				     IGRint         a_edgeMax,
				     IGRint        *a_edgeCnt,
				     TGRbsp_curve **a_edgeBsps)

{
  IGRchar fn[] = "VDefpAppendLineStringSection";
  IGRstat retFlag = 0;
  
  IGRint i,j,k,flag;

  TGRbsp_curve *crv;
  
  IGRdouble angle;
  IGRdouble knuckleAngle = 95.0;
  
  IGRint traceFlagx;
  
  // Say hi
  traceFlagx = traceFlag;
  // traceFlagx = 1;
  if (traceFlagx) printf(">>> %s, %d\n",fn,*a_knotI);
  
  // See if done
  i = *a_knotI;
  j = i+1;
  if (j >= a_numKnots) goto wrapup; // Zero breaks out of loop

  // Maybe only one more segment left
  if ((j +1) == a_numKnots) {
    
    // Has to be a straight segment
    VDgeomExtractCurve(a_crv,a_knots[i],a_knots[j],&crv);
    VDefpAppendCurve(crv,0,1,a_edgeMax,a_edgeCnt,a_edgeBsps);
    *a_knotI = j;
    goto wrapup;  // Zero to break out of loop
  }
  
  // Got at least two segments, see what the angle is
  VDgeomGetCurveAngle(a_crv,a_knots[i],a_knots[i+1],a_knots[i+2],&angle);
  angle = VDgeomRadToDeg(angle);
  // printf("Knot %3d %8.2f\n",i,angle);
  
  // Disable knuckle detection
  if (knuckleFlag == 0) knuckleAngle = 170.0;
  
  // Right angle
  if (angle < knuckleAngle) {

    // Straight segment then a break
    VDgeomExtractCurve(a_crv,a_knots[i],a_knots[j],&crv);
    VDefpAppendCurve(crv,0,1,a_edgeMax,a_edgeCnt,a_edgeBsps);
    *a_knotI = j;
    retFlag = 1;
    goto wrapup;

  }

  // Bunch of small angles
  if (angle > 170.0) {
    flag = 1;
    while(flag) {
      k = j + 1;
      if (k >= a_numKnots) flag = 0;
      else {
	VDgeomGetCurveAngle(a_crv,a_knots[k-2],a_knots[k-1],a_knots[k],&angle);
	angle = VDgeomRadToDeg(angle);
	if (angle > 170.0) j = k;
	else flag = 0;
      }
    }
    // So j points to the last parameter value
    VDgeomExtractCurve(a_crv,a_knots[i],a_knots[j],&crv);
    VDefpAppendCurve(crv,0,1,a_edgeMax,a_edgeCnt,a_edgeBsps);
    *a_knotI = j;
    retFlag = 1;
    goto wrapup;
  }

  // Knuckle stuff
  flag = 1;
  while(flag) {
    k = j + 1;
    if (k >= a_numKnots) flag = 0;
    else {
      VDgeomGetCurveAngle(a_crv,a_knots[k-2],a_knots[k-1],a_knots[k],&angle);
      angle = VDgeomRadToDeg(angle);
      if ((angle >= 95.0) && (angle <= 170.0)) j = k;
      else flag = 0;
    }
  }

  // So j points to the last parameter value
  VDgeomExtractCurve(a_crv,a_knots[i],a_knots[j],&crv);
  VDefpAppendCurve(crv,0,1,a_edgeMax,a_edgeCnt,a_edgeBsps);
  *a_knotI = j;
  retFlag = 1;

  // Done
 wrapup:
  if (traceFlagx) printf("<<< %s, %d, %d\n",
			 fn,*a_knotI,retFlag);
  return retFlag;
}

  
/* ------------------------------------------------------------------
 * Specialized routine for dealing with line strings from edge curves
 *
 * Add the ability to disable knuckle processing
 */
IGRstat VDefpAppendLineString(IGRint         knuckleFlag,
			      TGRbsp_curve  *a_crv,
			      IGRint         a_edgeMax,
			      IGRint        *a_edgeCnt,
			      TGRbsp_curve **a_edgeBsps)
{
  IGRchar fn[] = "VDefpAppendLineString";
  
  IGRstat retFlag = 0;

  TVDgeomKnots knots;
  IGRdouble    knotsBuf[512];
  
  IGRint mergeIt = 1;

  IGRint traceFlagx = 0;
    
  // Init
  VDgeomInitKnots(&knots,knotsBuf,512);
  
  // Arg check
  if ((a_crv == NULL) || (a_edgeCnt == NULL) || (a_edgeBsps == NULL)) goto wrapup;

  // Only care about second order curves with more than 2 poles
  if ((a_crv->order != 2) || (a_crv->num_poles <= 2)) goto wrapup;

  /* Physically closed (complete profile) gets broken up
   * So far, only small details do this.  If any larger plates
   * with lots of line strings are enountered then
   * need to deal with them as well
   *
   * Physically closed are not treated like other line string because
   * in some cases we want to keep line strings with cusps in them
   * as one element
   */
  // if (a_crv->phy_closed) goto wrapup;
   
  // Get some knots
  vdgeom$GetKnotsFromCurve(crv = a_crv, knots = &knots);

  // Say Hi for real
  traceFlagx = traceFlag;
  // traceFlagx = 1;
  if (traceFlagx) {
    printf("----\n");
    printf(">>> %s Order %d, Poles %d, knots %d\n",fn,
	   a_crv->order,
	   a_crv->num_poles,
	   knots.cnt);
    vdgeom$Print(crv = a_crv);
  }

  // Loop on each segment, knotI is updated
  knots.i = 0;
  while(VDefpAppendLineStringSection(knuckleFlag,
				     a_crv,
				     knots.cnt,
				     knots.knots,
				    &knots.i,
				     a_edgeMax,
				     a_edgeCnt,
				     a_edgeBsps));

  // Curve is always used
  _FREE(a_crv);
  retFlag = 1;
  
wrapup:
  VDgeomFreeKnots(&knots);

  if (traceFlagx) {
    printf("<<< %s %d\n",fn,retFlag);
  }
  
  return retFlag;
}

/* ------------------------------------
 * Get the edges of a surface object
 * Outputs include count, room for 100 bsp pointers, room
 * for 100 edge obejcts
 */
IGRstat VDefpGetSurfaceEdgeBsps(TGRobj_env    *srfOE,
				IGRint         edgeMax,
				IGRdouble      tol, 
				IGRint        *edgeCnt,
				TGRbsp_curve **edgeBsps)
{
  IGRchar fn[] = "VDefpGetSurfaceEdgeBsps";
  
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  struct {
    IGRint max;
    IGRint cnt;
    IGRint i;
    TGRbsp_curve *bsp;
    TGRbsp_curve *bsps[VDEFP_NAT_EDGES_MAX];
  } edge;
 
  IGRint traceFlagx;
  IGRint i,j;
  
  TGRbsp_curve *crv0,*crv1,*crv2;
  IGRpoint pt1,pt2;
  
  FILE *file;
  
  IGRint knuckleFlag = 1; // Enable knucle processing
  
  // Init
  memset(&edge,0,sizeof(edge));
  edge.max  = VDEFP_NAT_EDGES_MAX;
  
  // Say hi
  traceFlagx = traceFlag;
  //traceFlagx = 1;
  if (traceFlagx) {
    //file = stdout;
    file = fopen("/dev/null","wt");
    if (file == NULL) file = stdout;
    fprintf(file,">>> %s\n",fn);
    vdobj$Print(objOE = srfOE,file = file);
  }

  // Arg check
  if (edgeCnt) *edgeCnt = 0;
  if ((srfOE == NULL) || (srfOE->obj_id.objid == NULL_OBJID)) goto wrapup;
  if ((edgeCnt == NULL) || (edgeBsps == NULL)) goto wrapup;
  
  // Get the natural edge geometry
  sts = VDgeomGetSurfaceNaturalOuterContourGeometry(srfOE,
						    edge.max,
						    &edge.cnt,
						    edge.bsps);
  
  // TR179901283  Warn the user about bad internal cutouts
  if (sts == 3) retFlag = 3;
  
  // If there is only one curve then break it up and be done
  /* Not good enough, some shell plates actually unwrap as 
   * a single line string with many poles
   */
  /* Try to break up single line stings but disable knockle detection
   * And see what happens.  getting planar plates with single line string
   * but many poles.
   */
  if (edge.cnt == 1) knuckleFlag = 0;
  
#if 0
  if (edge.cnt == 1) {
    edge.bsp = edge.bsps[0];
    VDefpAppendCurve(edge.bsp,1,1,edgeMax,edgeCnt,edgeBsps);
    retFlag = 1;
    goto wrapup;
  }
#endif

  // Loop through
  for(edge.i = 0; edge.i < edge.cnt; edge.i++) {

    edge.bsp = edge.bsps[edge.i];
    
    // Special routine for linestrings
    sts = VDefpAppendLineString(knuckleFlag,edge.bsp,edgeMax,edgeCnt,edgeBsps);
    
    if (!(sts & 1)) {

      // This will break along cusps
      VDefpAppendCurve(edge.bsp,1,1,edgeMax,edgeCnt,edgeBsps);
    }
  }
 
  // Possible that the first and last curves should be merged
  if (*edgeCnt > 1) {
    crv0 = edgeBsps[*edgeCnt-1];
    crv1 = edgeBsps[0];
    sts = VDgeomTestProductionMerge(crv0,crv1,0.0,0.0);

    if (sts & 1) {

      VDgeomMergeTwoCurves(crv0,crv1,&crv2);
      if (crv2) {
	_FREE(crv0);
	_FREE(crv1);
	edgeBsps[0] = crv2;
	*edgeCnt = *edgeCnt - 1;
      }
    }
  }
  
  // One last scan for linear curves
  for(i = 0; i < *edgeCnt; i++) {
    crv0 = edgeBsps[i];
    if ((crv0->order == 2) && (crv0->num_poles == 2));
    else {
      sts = VDgeomIsCrvLinear(crv0,0.0);
      if (sts & 1) {

	// Replace with linesegment
	crv1 = NULL;
	VDgeomGetCrvPt(crv0,0.0,pt1);
	VDgeomGetCrvPt(crv0,1.0,pt2);
	VDgeomMakeLineCurve(pt1,pt2,&crv1);
	if (crv1) {
	  _FREE(crv0);
	  edgeBsps[i] = crv1;
	}
      }
    }
  }

  /* ---------------------------------------------
   * 06 Nov 2000 Just for grins, try rounding the curves
   * and see if various tolerance issues go away
   */
  for(i = 0; i < *edgeCnt; i++) {
    VDgeomRoundCurve(edgeBsps[i]);
  }

  /* ---------------------------------------------
   * 03 Nov 2000 Its possible that the end points
   * Could be ever so slightly off so force them
   * to match exactly to preclude later merge problems
   */
  for(i = 0; i < *edgeCnt; i++) {
    j = i + 1;
    if (j == *edgeCnt) j = 0;
    VDgeomLinkCurves(edgeBsps[i],edgeBsps[j]);
  }
  
  // Done
  if (retFlag == 0) retFlag = 1;

wrapup:
  
  if (traceFlagx) {
    fprintf(file,"<<< %s %d %d\n",fn,*edgeCnt,retFlag);
    if (file != stdout) fclose(file);
  }
  
  return retFlag;
}

IGRstat VDefpGetSurfaceEdgeBspsBS( TGRobj_env     *srfOE,
                                   IGRint         edgeMax,
                                   IGRdouble      tol,
                                   IGRint         *edgeCnt,
                                   TGRbsp_curve   **edgeBsps)
{
  BSrc    rc;
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  struct {
    IGRint max;
    IGRint cnt;
    IGRint i;
    TGRbsp_curve *bsp;
    TGRbsp_curve *bsps[VDEFP_NAT_EDGES_MAX];
  } edge;

  IGRint traceFlagx;
  IGRint i,j,numRealCvs=0;

  TGRbsp_curve  **realCvs=NULL;

  // Init
  memset(&edge,0,sizeof(edge));
  edge.max  = VDEFP_NAT_EDGES_MAX;

  for( i=0; i<VDEFP_NAT_EDGES_MAX; ++i ) edge.bsps[i] = NULL;

  // Arg check
  if (edgeCnt) *edgeCnt = 0;
  if ((srfOE == NULL) || (srfOE->obj_id.objid == NULL_OBJID)) goto wrapup;
  if ((edgeCnt == NULL) || (edgeBsps == NULL)) goto wrapup;

  // Get the natural edge geometry
  sts = VDgeomGetSurfaceNaturalOuterContourGeometry(srfOE,
                                                    edge.max,
                                                    &edge.cnt,
                                                    edge.bsps   );

  if( 0 )
  {
     FILE       *fp=NULL;

     fp = fopen( "test.txt", "w" );

     fprintf( fp, "Chord Height Tolerance = %g\n", tol );
     fprintf( fp, "Input Edge Count = %d\n", edge.cnt );

     for( i=0; i<edge.cnt; ++i )
       BSprintbspc( fp, NULL, edge.bsps[i], FALSE );

     fclose( fp );
  }

  BStstcvscsp( edge.cnt, edge.bsps, TRUE, 1, 0.01, tol,
               &numRealCvs, &realCvs, &rc );
  if( rc != BSSUCC || numRealCvs == 0 ) goto wrapup;

  /*
   * Make sure that BStstcvscsp is returning less than VDEFP_NEAT_EDGES_MAX.
   */
  if( numRealCvs > VDEFP_NEAT_EDGES_MAX )
  {
      /*
       * Free the memory.
       */
       if( realCvs )
       {
          for( i=0; i<numRealCvs; ++i ){
              if( realCvs[i] ) BSfreecv( &rc, realCvs[i] );
          }
          _FREE( realCvs );
       }
       for( i=0; i<VDEFP_NAT_EDGES_MAX; ++i )   _FREE( edge.bsps[i] );
       /*
	* Call art's routine.
	*/
       sts = VDefpGetSurfaceEdgeBsps( srfOE, edgeMax, tol, edgeCnt, edgeBsps );
       return sts;
  }

  *edgeCnt = numRealCvs;

  for( i=0; i<numRealCvs; ++i )
  {
        if( i == edgeMax ) break;

        edgeBsps[i] = NULL;
        VDgeomAllocCrv( realCvs[i]->order, realCvs[i]->num_poles,
             realCvs[i]->rational, realCvs[i]->num_boundaries, 0, &edgeBsps[i] );
        BScv_copy(&rc,realCvs[i], edgeBsps[i]);
  }
  retFlag = 1;

wrapup:

  if( realCvs )
  {
    for( i=0; i<numRealCvs; ++i ) BSfreecv( &rc, realCvs[i] );
    _FREE( realCvs );
  }
  for( i=0; i<VDEFP_NAT_EDGES_MAX; ++i )   _FREE( edge.bsps[i] );
  return retFlag;
}


end implementation Root;
