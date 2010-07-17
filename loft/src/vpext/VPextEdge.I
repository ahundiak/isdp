class implementation VDbtBase;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDmem.h"
#include "VDgeom.h"

#include "VDefp.h"
#include "VSefp.h"

#include "VPextInfo.h"
#include "VPpdf.h"

#include "maoptsxfo.h"
#include "maunitvc.h"
#include "mascalvc.h"

#include "bsfndcvcsp.h"
#include "bsfreecv.h"
#include "bsptlngen.h"
#include "bslsqptlnpl.h"
#include "bsalloccv.h"
#include "bsdistptpt.h"

#define vdsDEBUGx 1

static int traceFlag;

/* ----------------------------------------------------------------------
 * The initial cycle fills in the transformed 2d edges and 2d stock edges
 */
IGRstar VPextAdjustPlateEdgesPass1(TVPextPlateInfo *plateInfo, 
				   IGRint nth,
				   TVPextEdgeInfo *edge)
{
  IGRstat retFlag = 0;

  IGRint  j;

  if (traceFlag) {
    printf(">>> VPextAdjustPlateEdgesPass1, %d\n",nth);
    //  vdgeom$Print(crv = edge->crv3D);
  }
  if (plateInfo == NULL) goto wrapup;
  
  // Make 2d curve
  VDgeomCopyCurve(edge->crv3D,&edge->crv2D);
  if (edge->crv2D == NULL) {
    printf("Problem copying 3d curve\n");
    goto wrapup;
  }
  VDgeomTransformCurve(edge->crv2D,&plateInfo->srcSrfMat,NULL);

  if (traceFlag) {
    vdgeom$Print(crv = edge->crv2D);
  }
  
  // Make 2d curve for stock
  VDgeomCopyCurve(edge->crv3D,&edge->crv2Dstk);
  if (edge->crv2Dstk == NULL) {
    printf("Problem copying 3d curve\n");
    goto wrapup;
  }
  VDgeomTransformCurve(edge->crv2Dstk,&plateInfo->srcSrfMat,NULL);

  // Map bevel to edge
#if 1
  VPextGetBevelForEdge(edge->crv3D,&plateInfo->bevels,&j);
  if (j >= 0) edge->bevelInfo = &plateInfo->bevels.info[j];
#endif

  // Done
  retFlag = 1;

wrapup:
  
  if (traceFlag) {
    printf("@@@ VPextAdjustPlateEdgesPass1\n");
  }

  return retFlag;
}

/* ----------------------------------------------------------------------
 * Apply Stock
 */
IGRstar VPextAdjustPlateEdgesPass2(TVPextPlateInfo *plateInfo, 
				   IGRint nth,
				   TVPextEdgeInfo *edge)
{
  IGRstat retFlag = 0;
  IGRstat msg;
  
  IGRdouble adjust = 0.0;
  
  IGRdouble *pt1,*pt2;
  
  IGRpoint  midPt;
  IGRvector midVect;

  IGRint i;
  
  TVPextEdgeInfo *edgex;
  
  // Say hi
  if (traceFlag) {
    printf(">>> VPextAdjustPlateEdgesPass2 %d\n",nth);
  }
  if (plateInfo == NULL) goto wrapup;

  // Ignore if no stock
  if ((!edge->bevelInfo) || (!edge->bevelInfo->hasAdjust)) {
    retFlag = 1;
    goto wrapup;
  }
  
  adjust = edge->bevelInfo->adjust;
  
  // Use geometric midpoint to determine offset vector
  pt1 = &edge->crv2D->poles[0];
  pt2 = &edge->crv2D->poles[3*(edge->crv2D->num_poles-1)];
  
  midPt[0] = pt1[0] + ((pt2[0] - pt1[0]) * .5);
  midPt[1] = pt1[1] + ((pt2[1] - pt1[1]) * .5);
  midPt[2] = pt1[2] + ((pt2[2] - pt1[2]) * .5);
  
  // For now, assume 2d center is 0,0, make a unit vector
  MAunitvc(&msg, midPt, midVect);
  
  // Scale by the stock value to get offset vector
  MAscalvc(&msg,&adjust,midVect,midVect);
  
  // Apply this vector to the stock curve
  // Find the ma routine for doing this later
#if 0
  for(i = 0; i < edge->crv2Dstk->num_poles; i++) {
    edge->crv2Dstk->poles[(3*i)+0] += midVect[0];
    edge->crv2Dstk->poles[(3*i)+1] += midVect[1];
    edge->crv2Dstk->poles[(3*i)+2] += midVect[2];
  }
#endif
  VDgeomTransformCurve(edge->crv2Dstk,NULL,midVect);
  
  /* -------------------------------------------------
   * At this point, the other edges should be extended
   * to the transformed edge.  The most exact solution
   * would be to use bspolyxcvcv.hd however
   * I think we can get away with just tweaking the end points
   */

  // First end
  i = nth + 1;
  if (i >= plateInfo->edges.cnt) i = 0;
 
  edgex = &plateInfo->edges.info[i];

  pt1 =  &edge->crv2Dstk->poles[3*(edge->crv2Dstk->num_poles-1)];
  pt2 = &edgex->crv2Dstk->poles[0];

  pt2[0] = pt1[0];
  pt2[1] = pt1[1];
  pt2[2] = pt1[2];

  // Second end
  i = nth - 1;
  if (i < 0) i = plateInfo->edges.cnt - 1;
  
  edgex = &plateInfo->edges.info[i];

  pt1 = 
  pt1 =  &edge->crv2Dstk->poles[0];
  pt2 = &edgex->crv2Dstk->poles[3*(edgex->crv2Dstk->num_poles-1)];

  pt2[0] = pt1[0];
  pt2[1] = pt1[1];
  pt2[2] = pt1[2];
  
  // Done
  retFlag = 1;

wrapup:
  if (traceFlag) {
    printf("@@@ VPextAdjustPlateEdgesPass2\n");
  }
  return retFlag;
}

/* ----------------------------------------------------------------------
 * Final Pass
 */
IGRstar VPextAdjustPlateEdgesPass3(TVPextPlateInfo *plateInfo, 
				   IGRint nth,
				   TVPextEdgeInfo *edge)
{
  IGRstat retFlag = 0;
  
  IGRdouble adjust = 0.0;
  
  IGRdouble *pt1,*pt2;

  // Say hi
  if (traceFlag) {
    printf(">>> VPextAdjustPlateEdgesPass3, %d\n",nth);
  }
  if (plateInfo == NULL) goto wrapup;

  // Check stock
  if ((edge->bevelInfo) && (edge->bevelInfo->hasAdjust)) {
    adjust = edge->bevelInfo->adjust;
    printf("Edge %d, Stock %.3f, Gap %.3f, Adjust %.3f\n",
	   nth,
	   edge->bevelInfo->stock,
	   edge->bevelInfo->gap,
	   edge->bevelInfo->adjust);
  }
  else printf("Edge %d\n",nth);

  // 3D curve
  pt1 = &edge->crv3D->poles[0];
  pt2 = &edge->crv3D->poles[3*(edge->crv3D->num_poles-1)];
  
  printf("3D  %10.3f,%10.3f,%10.3f\n"
	 "    %10.3f,%10.3f,%10.3f\n",
	 pt1[0],pt1[1],pt1[2],
	 pt2[0],pt2[1],pt2[2]);
  
  // 2D Curve
  pt1 = &edge->crv2D->poles[0];
  pt2 = &edge->crv2D->poles[3*(edge->crv2D->num_poles-1)];
  
  printf("2D  %10.3f,%10.3f,%10.3f\n"
	 "    %10.3f,%10.3f,%10.3f\n",
	 pt1[0],pt1[1],pt1[2],
	 pt2[0],pt2[1],pt2[2]);

  // 2D Curve with stock
  pt1 = &edge->crv2Dstk->poles[0];
  pt2 = &edge->crv2Dstk->poles[3*(edge->crv2Dstk->num_poles-1)];
  
  printf("STK %10.3f,%10.3f,%10.3f\n"
	 "    %10.3f,%10.3f,%10.3f\n",
	 pt1[0],pt1[1],pt1[2],
	 pt2[0],pt2[1],pt2[2]);
  
  // Done
  retFlag = 1;

wrapup:
  printf("\n");

  if (traceFlag) {
    printf("@@@ VPextAdjustPlateEdgesPass3\n");
  }

  return retFlag;
}

/* ----------------------------------------------------------------------
 * Adjust plate edges for stock
 * Only for planar plates for now
 */
IGRstar VPextAdjustPlateEdges(TVPextPlateInfo *plateInfo)
{
  IGRstat retFlag = 0;

  TVPextEdgeInfo *edge;
  IGRint i;
  
  if (traceFlag) {
    printf(">>> VPextAdjustPlateEdges %d\n",plateInfo->edges.cnt);
  }

  for(i = 0; i < plateInfo->edges.cnt; i++) {
    
    edge = &plateInfo->edges.info[i];

    VPextAdjustPlateEdgesPass1(plateInfo,i,edge);
    
  }

  for(i = 0; i < plateInfo->edges.cnt; i++) {
    
    edge = &plateInfo->edges.info[i];

    VPextAdjustPlateEdgesPass2(plateInfo,i,edge);
    
  }

  if (traceFlag) {
    for(i = 0; i < plateInfo->edges.cnt; i++) {
    
      edge = &plateInfo->edges.info[i];

      VPextAdjustPlateEdgesPass3(plateInfo,i,edge);
    
    }
  }

  retFlag = 1;

//wrapup:

  if (traceFlag) {
    printf("@@@ VPextAdjustPlateEdges\n");
  }

  return retFlag;
}

/* ----------------------------------------------------------------------
 * Dump one edge out
 */
IGRstar VPextWritePlateEdge(TVPextPlateInfo *plateInfo, 
			    IGRint nth,
			    TVPextEdgeInfo  *edge)
{
  IGRstat   retFlag = 0;
  
  TVPextBevelInfo *bevel;
  TVPextLabelInfo *label;
  
  IGRint i;
  
  if (traceFlag) {
    printf(">>> VPextWritePlateEdge, %d\n",nth);
    if (plateInfo);
  }

  // Start the edge object
  VPpdfWriteObjBeg(PDF_OBJ_PLATE_EDGE);
  
  // Write out the edge itself
  VPpdfWriteBspCurve2D(PDF_ATR_PLATE_EDGE_CURVE,edge->crv2Dstk);

  // Write any label objects
  for(i = 0; i < plateInfo->labels.cnt; i++) {
    label = &plateInfo->labels.info[i];

    if ((label->type == 1) && (label->index == nth)) {

      VPpdfWriteAttrInt (PDF_ATR_OBJ_BEG,PDF_OBJ_LABEL);
      VPpdfWriteAttrText(PDF_ATR_LABEL_TYPE,     "EDGE");
      VPpdfWriteAttrText(PDF_ATR_LABEL_TEXT,     label->text);
      VPpdfWrite2dPt    (PDF_ATR_LABEL_LOCATION, label->org2D);
      VPpdfWriteAttrInt (PDF_ATR_OBJ_END,PDF_OBJ_LABEL);
      
    }
  }
  
  // If no bevel then done
  bevel = edge->bevelInfo;
  if (!bevel) {
    
    // End the edge object
    VPpdfWriteObjEnd(PDF_OBJ_PLATE_EDGE);
    retFlag = 1;
    goto wrapup;
  }
  // printf("Bevel %s %s\n",bevel->spec,bevel->stock);

  // Fake bevel object
  VPpdfWriteAttrInt (PDF_ATR_OBJ_BEG,PDF_OBJ_BEVEL);
  VPpdfWriteAttrText(PDF_ATR_BEVEL_SPEC,  bevel->spec);
  VPpdfWriteAttrText(PDF_ATR_BEVEL_PROCESS,bevel->process);
  
  // Put out thickness value if have one
  if (bevel->hasThickness) {

    // The actual stock value
    VPpdfWriteAttrReal(PDF_ATR_BEVEL_THICKNESS,bevel->thickness);
  }

  // Put out stock value if have one
  if (bevel->hasStock) {

    // The actual stock value
    VPpdfWriteAttrReal(PDF_ATR_PLATE_EDGE_STOCK,bevel->stock);
  }

  // Put out gap value if have one
  if (bevel->hasGap) {

    // The actual gap value
    VPpdfWriteAttrReal(PDF_ATR_PLATE_EDGE_GAP,bevel->gap);
  }
  
  // Fake bevel object
  VPpdfWriteAttrInt(PDF_ATR_OBJ_END,PDF_OBJ_BEVEL);

  // End the object and done
  VPpdfWriteObjEnd(PDF_OBJ_PLATE_EDGE);
  retFlag = 1;

wrapup:  

  if (traceFlag) {
    printf("@@@ VPextWritePlateEdge\n");
  }

  return retFlag;
}

/* ----------------------------------------------------------------------
 * Write edge stock line
 */
IGRstar VPextWritePlateEdgeStock(TVPextPlateInfo *plateInfo, 
				 IGRint nth,
				 TVPextEdgeInfo  *edge)
{
  IGRstat   retFlag = 0;
  
  // Say hi
  if (traceFlag) {
    printf(">>> VPextWritePlateEdgeStock, %d\n",nth);
    if (plateInfo);
  }

  // If no stock then do nothing
  if ((!edge->bevelInfo) || (!edge->bevelInfo->hasStock)) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Start the edge object
  VPpdfWriteObjBeg  (PDF_OBJ_MARKING_LINE);
  VPpdfWriteAttrText(PDF_ATR_MARKING_LINE_TYPE,"STOCK");

  // Write out the edge itself
  VPpdfWriteBspCurve2D(PDF_ATR_MARKING_LINE_CURVE,edge->crv2D);

  // Done
  VPpdfWriteObjEnd(PDF_OBJ_MARKING_LINE);
  retFlag = 1;

wrapup:  

  if (traceFlag) {
    printf("@@@ VPextWritePlateEdgeStock\n");
  }

  return retFlag;
}

/* ----------------------------------------------------------------------
 * Dump the edges out
 */
IGRstar VPextWritePlateEdges(TVPextPlateInfo *plateInfo)
{
  IGRstat retFlag = 0;
  IGRint  i;

  TVPextEdgeInfo *edge;

  if (traceFlag) {
    printf("Entered VPextWritePlateEdges\n");
  }

  for(i = 0; i < plateInfo->edges.cnt; i++) {
    
    edge = &plateInfo->edges.info[i];
    VPextWritePlateEdge     (plateInfo,i,edge);
    VPextWritePlateEdgeStock(plateInfo,i,edge);
  }
   
  retFlag = 1;
  
//wrapup:

  if (traceFlag) {
    printf("@@@ VPextWritePlateEdges\n");
  }

  return retFlag;
}

/* ---------------------------------------------------
 * Gets the edge info
 */
IGRstat VPextGetPlateEdges(TVPextPlateInfo *plateInfo)
{
  IGRstat retFlag = 0;

  TGRobj_env neatMacOE;

  TGRobj_env footOE;
  IGRchar    footName[32];

  IGRint     edgeFlag;
  IGRint     i;

  // Arg check
  if (plateInfo == NULL) goto wrapup;
  traceFlag = 0;

  // See if already have one
  vsefp$GetAttachedNeatPlateMacro(plateOE  = &plateInfo->srcPlateOE,
				  treeFlag = 0,
				  macOE    = &neatMacOE);

  // Place if don't have one
  if (neatMacOE.obj_id.objid == NULL_OBJID) {

    // printf("Placeing neat_plate macro\n");
    vdefp$PlaceMacro(macName = VDEFP_NEAT_PLATE_MACRO_NAME,
		     tplOEs  = &plateInfo->srcPlateOE,
		     macOE   = &neatMacOE);

  }

  // Fail if still don't have one
  if (neatMacOE.obj_id.objid == NULL_OBJID) {
    printf("Problem getting neat edge macro\n");
    goto wrapup;
  }
  if (traceFlag) vdobj$Print(objOE = &neatMacOE);

  // Cycle through and pull geometry from the feet
  edgeFlag = 1;
  while(edgeFlag) {

    i = plateInfo->edges.cnt;
    sprintf(footName,"edge%02d",i);
    vdobj$GetFoot(objOE    = &neatMacOE,
                  footName =  footName,
                  footOE   = &footOE);
    if (footOE.obj_id.objid == NULL_OBJID) edgeFlag = 0;
    else {
      if (traceFlag) vdobj$Print(objOE = &footOE);
      if (i >= VP_EXT_INFO_MAX) {
        printf("Huge number of plate edges\n");
        goto wrapup;
      }
      vdgeom$Get2(objOE = &footOE, 
                  crv = &plateInfo->edges.info[i].crv3D);
      if (plateInfo->edges.info[i].crv3D == NULL) {
        printf("Problem getting edge geometry\n");
        goto wrapup;
      }
      plateInfo->edges.cnt++;
    }
  }
  // Done
  retFlag = 1;

wrapup:
  traceFlag = 0;
  return retFlag;
}

end implementation VDbtBase;


