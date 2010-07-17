/* --------------------------------------------
 * This actually works pretty good
 * Still need details on freeing up memory
 */

/* example-start tree tree.c */
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDctx.h"
#include "VDgeomc.h"
#include "VDxdom.h"

#include "VLsmsXml.h"
#include "VDcvgXml.h"

#include "VDcvg2.h"
#include "VDpdf2.h"

#include "glib.h"
#include "xdom.h"

VDASSERT_FFN("VLsmsPdf.c");

#define TRACE_FLAG 0
#define TRACE_PCMK ""

static IGRchar s_pcmk[32];
static IGRint  s_flag;

/* -----------------------------------------------
 * Call this before reporting a problem to
 * dump out the piece mark
 */
static void logPcmk()
{
  if (s_flag) return;
  if (*s_pcmk) VLsmsLog1(1,1,"PCMK %s\n",s_pcmk);
  s_flag = 1;
}

/* -----------------------------------------------
 * Write an attribute
 */
static void writeTxt(TGRid *nodeID, IGRchar *nodeName, TVDpdfFileInfo *pdfFile, IGRint pdfName)
{
  IGRchab buf;
  
  VDctxGetTxtAtr(nodeID,nodeName,buf);
  VDpdfWriteAttrText(pdfFile,pdfName,buf);
}
static void writeTxx(TGRid *nodeID, IGRchar *nodeName, TVDpdfFileInfo *pdfFile, IGRint pdfName)
{
  IGRchab buf;
  
  VDctxGetTxtAtr(nodeID,nodeName,buf);
  if (*buf) {
    VDpdfWriteAttrText(pdfFile,pdfName,buf);
  }
}
static void writeInt(TGRid *nodeID, IGRchar *nodeName, TVDpdfFileInfo *pdfFile, IGRint pdfName)
{
  IGRchab buf;
  IGRint  value;
  
  VDctxGetTxtAtr(nodeID,nodeName,buf);
  value = atoi(buf);
  VDpdfWriteAttrInt(pdfFile,pdfName,value);
}
static void writeDbl(TGRid *nodeID, IGRchar *nodeName, TVDpdfFileInfo *pdfFile, IGRint pdfName)
{
  IGRchab buf;
  IGRdouble  value;
  
  VDctxGetTxtAtr(nodeID,nodeName,buf);
  value = atof(buf);
  VDpdfWriteAttrReal(pdfFile,pdfName,value);
}

/* -----------------------------------------------
 * Recursive routine for writing a tree node
 */
static void writeTreeNode(TGRid *nodeID, TVDpdfFileInfo *pdfFile)
{
  VDASSERT_FN("writeTreeNode");

  IGRchab nodeType;
  
  IGRint length;
  IGRchab buf;

  IGRint i;
  TGRid  childID;
  
  // Common info
  VDpdfWriteObjBeg(pdfFile,PDF_OBJ_TREE_NODE);
  writeTxt(nodeID,XML_PDF_TREE_NODE_TYPE,  pdfFile,PDF_ATR_TREE_NODE_TYPE);
  writeTxt(nodeID,XML_PDF_TREE_NODE_NAME,  pdfFile,PDF_ATR_TREE_NODE_NAME);
  writeTxt(nodeID,XML_PDF_TREE_NODE_STAGE, pdfFile,PDF_ATR_TREE_NODE_STAGE);
  writeTxt(nodeID,XML_PDF_TREE_NODE_PARENT,pdfFile,PDF_ATR_TREE_NODE_PARENT);
  writeTxt(nodeID,XML_PDF_TREE_NODE_PATH,  pdfFile,PDF_ATR_TREE_NODE_PATH);
  writeInt(nodeID,XML_PDF_TREE_NODE_QTY,   pdfFile,PDF_ATR_TREE_NODE_QTY);

  // Leafs
  VDctxGetTxtAtr(nodeID,XML_PDF_TREE_NODE_TYPE,nodeType);
  if (!strcmp(nodeType,"PLATE") || !strcmp(nodeType,"BEAM")) {

    writeTxt(nodeID,XML_PDF_TREE_NODE_PCMK,       pdfFile,PDF_ATR_TREE_NODE_PCMK);
    writeTxt(nodeID,XML_PDF_TREE_NODE_FAMILY,     pdfFile,PDF_ATR_PIECE_FAMILY);
    writeTxt(nodeID,XML_PDF_TREE_NODE_PART_NUM,   pdfFile,PDF_ATR_PIECE_PART_NUM);
    writeTxt(nodeID,XML_PDF_TREE_NODE_GRADE,      pdfFile,PDF_ATR_PIECE_MAT_GRADE);
    writeTxt(nodeID,XML_PDF_TREE_NODE_NOTES,      pdfFile,PDF_ATR_TREE_NODE_NOTES);
    writeTxx(nodeID,XML_PDF_TREE_NODE_NOTES2,     pdfFile,PDF_ATR_TREE_NODE_NOTES2);
    writeTxx(nodeID,XML_PDF_TREE_NODE_NOTES3,     pdfFile,PDF_ATR_TREE_NODE_NOTES3);
    writeTxx(nodeID,XML_PDF_TREE_NODE_NOTES4,     pdfFile,PDF_ATR_TREE_NODE_NOTES4);
    writeTxx(nodeID,XML_PDF_TREE_NODE_NOTES5,     pdfFile,PDF_ATR_TREE_NODE_NOTES5);
    writeTxt(nodeID,XML_PDF_TREE_NODE_DESTINATION,pdfFile,PDF_ATR_TREE_NODE_DESTINATION);

    // Some special beam attributes
    if (!strcmp(nodeType,"BEAM")) {

      // Spades wants integers
      VDctxGetTxtAtr(nodeID,XML_PDF_BEAM_3D_LENGTH,buf);
      length = (atof(buf) + .5);
      VDpdfWriteAttrInt(pdfFile,PDF_ATR_BEAM_CUT_LENGTH,length);
    }
      
    // Primary process
    writeTxt(nodeID,XML_PDF_PIECE_PRI_PROCESS,pdfFile,PDF_ATR_BEAM_PRIMARY_PROCESS);

    // Seconday if have one
    VDctxGetTxtAtr(nodeID,XML_PDF_PIECE_SEC_PROCESS,buf);
    if (*buf) {	
      VDpdfWriteAttrText(pdfFile,PDF_ATR_BEAM_ADDITIONAL_PROCESS,buf);
    }
  }
  else {

    writeTxt(nodeID,XML_PDF_TREE_NODE_DESC,  pdfFile,PDF_ATR_TREE_NODE_DESC);
    writeTxt(nodeID,XML_PDF_TREE_NODE_NOTES, pdfFile,PDF_ATR_TREE_NODE_NOTES);
    writeTxx(nodeID,XML_PDF_TREE_NODE_NOTES2,pdfFile,PDF_ATR_TREE_NODE_NOTES2);
    writeTxx(nodeID,XML_PDF_TREE_NODE_NOTES3,pdfFile,PDF_ATR_TREE_NODE_NOTES3);
    writeTxx(nodeID,XML_PDF_TREE_NODE_NOTES4,pdfFile,PDF_ATR_TREE_NODE_NOTES4);
    writeTxx(nodeID,XML_PDF_TREE_NODE_NOTES5,pdfFile,PDF_ATR_TREE_NODE_NOTES5);

    // Fili Wars
    VDctxGetTxtAtr(nodeID,XML_PDF_TREE_NODE_PLATEN,buf);
    
    if (!strcmp(buf,"AREA-B")) strcpy(buf,"B");
    VDpdfWriteAttrText(pdfFile,PDF_ATR_TREE_NODE_PLATEN,buf);

    writeInt(nodeID,XML_PDF_TREE_NODE_SEQUENCE,pdfFile,PDF_ATR_TREE_NODE_SEQUENCE);
  }

  // Write kids
  for(i = 0; VDctxGetNthTreeChild(nodeID,i,&childID); i++) {
    writeTreeNode(&childID,pdfFile);
  }

  // Done
  VDpdfWriteObjEnd(pdfFile,PDF_OBJ_TREE_NODE);
}
/* -----------------------------------------------
 * Fill text info
 */
static void fillTextInfo(TGRid *textID, TVDcvgText *text)
{
  IGRchab buf;
  IGRdouble angle;
  
  VDctxGetTxtAtr(textID,XML_CVG_TEXT_X1,text->x1);
  VDctxGetTxtAtr(textID,XML_CVG_TEXT_Y1,text->y1);
  VDctxGetTxtAtr(textID,XML_CVG_TEXT_X2,text->x2);
  VDctxGetTxtAtr(textID,XML_CVG_TEXT_Y2,text->y2);

  VDctxGetTxtAtr(textID,XML_CVG_TEXT_ANGLE,buf);
  angle = atof(buf);
  angle = VDgeom2RadToDeg(angle);
  sprintf(text->angle,"%f",angle);

  VDctxGetTxtAtr(textID,XML_CVG_TEXT_HEIGHT,text->height);
  VDctxGetTxtAtr(textID,XML_CVG_TEXT_WIDTH, text->width);
  VDctxGetTxtAtr(textID,XML_CVG_TEXT_FONT,  text->font);
  VDctxGetTxtAtr(textID,XML_CVG_TEXT_JUST,  text->just);
  VDctxGetTxtAtr(textID,XML_CVG_TEXT_VALUE, text->value);
  
 wrapup:
    return;
}
/* -----------------------------------------------
 * Fill curve info
 */
static void fillCurveInfo(TGRid *crvID, TVDcvgCurve *crv)
{
  VDASSERT_FN("fillCurveInfo");
  
  IGRchab buf;

  TGRid  vertexID;
  IGRint i;
  
  TVDcvgVertex *vertex;
  
  // Init
  memset(crv,0,sizeof(TVDcvgVertex));
  
  // Curve info
  VDctxGetTxtAtr(crvID,XML_CVG_CURVE_TYPE,          crv->type);
  VDctxGetTxtAtr(crvID,XML_CVG_CURVE_RADIUS,buf);   crv->radius    = atof(buf);
  VDctxGetTxtAtr(crvID,XML_CVG_CURVE_CENTER_X,buf); crv->center[0] = atof(buf);
  VDctxGetTxtAtr(crvID,XML_CVG_CURVE_CENTER_Y,buf); crv->center[1] = atof(buf);
  VDctxGetTxtAtr(crvID,XML_CVG_CURVE_CENTER_Z,buf); crv->center[2] = atof(buf);
  VDctxGetTxtAtr(crvID,XML_CVG_CURVE_MAJOR_X, buf); crv->major [0] = atof(buf);
  VDctxGetTxtAtr(crvID,XML_CVG_CURVE_MAJOR_Y, buf); crv->major [1] = atof(buf);
  VDctxGetTxtAtr(crvID,XML_CVG_CURVE_MAJOR_Z, buf); crv->major [2] = atof(buf);
  VDctxGetTxtAtr(crvID,XML_CVG_CURVE_MINOR_X, buf); crv->minor [0] = atof(buf);
  VDctxGetTxtAtr(crvID,XML_CVG_CURVE_MINOR_Y, buf); crv->minor [1] = atof(buf);
  VDctxGetTxtAtr(crvID,XML_CVG_CURVE_MINOR_Z, buf); crv->minor [2] = atof(buf);

  // Count vertexes
  for(i = 0; VDctxGetNthTreeChild(crvID,i,&vertexID); i++);
  VDASSERTW(i);
  crv->numVertexes = i;
  crv->maxVertex   = i;
  crv->vertexes    = g_new(TVDcvgVertex,i);
    
  // Fill them up
  for(i = 0; VDctxGetNthTreeChild(crvID,i,&vertexID); i++) {
    vertex = &crv->vertexes[i];
    VDctxGetTxtAtr(&vertexID,XML_CVG_VERTEX_TYPE,     buf); vertex->type      = *buf;
    VDctxGetTxtAtr(&vertexID,XML_CVG_VERTEX_EX,       buf); vertex->endx      = atof(buf);
    VDctxGetTxtAtr(&vertexID,XML_CVG_VERTEX_EY,       buf); vertex->endy      = atof(buf);
    VDctxGetTxtAtr(&vertexID,XML_CVG_VERTEX_MX,       buf); vertex->midx      = atof(buf);
    VDctxGetTxtAtr(&vertexID,XML_CVG_VERTEX_MY,       buf); vertex->midy      = atof(buf);
    VDctxGetTxtAtr(&vertexID,XML_CVG_VERTEX_CX,       buf); vertex->cenx      = atof(buf);
    VDctxGetTxtAtr(&vertexID,XML_CVG_VERTEX_CY,       buf); vertex->ceny      = atof(buf);
    VDctxGetTxtAtr(&vertexID,XML_CVG_VERTEX_RADIUS,   buf); vertex->radius    = atof(buf);
    VDctxGetTxtAtr(&vertexID,XML_CVG_VERTEX_BULGE,    buf); vertex->bulge     = atof(buf);
    VDctxGetTxtAtr(&vertexID,XML_CVG_VERTEX_INC_ANGLE,buf); vertex->inc_angle = atof(buf);
  }
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Bevel processing
 */
typedef struct 
{  
  IGRchar   type[80];
  IGRchar   process[256];
  IGRdouble thick1,thick2;
  IGRdouble stock, gap;
  IGRdouble angle_a,size_a;
  IGRdouble angle_b,size_b;
  IGRdouble angle_c,size_c;
  IGRdouble angle_d,size_d;
  IGRdouble angle_e,size_e;
  IGRpoint  pt1,pt2;
  IGRint    v1,v2;
  IGRint    skip;

} Tbevel;

#define BEVEL_TOL 1.0

/* -----------------------------------------------
 * Returns true if vertex starts at point
 */
static IGRstat checkVertexPoint(TVDcvgVertex *vertex, IGRdouble *pt, IGRdouble tol)
{
  IGRstat retFlag = 0;
  IGRdouble value;
  
  value = fabs(vertex->endx - pt[0]);
  if (value > tol) goto wrapup;

  value = fabs(vertex->endy - pt[1]);
  if (value > tol) goto wrapup;
  
  retFlag = 1;
  
wrapup:
  return retFlag;
}
/* -------------------------------------
 * To maintain compatibility with the original code
 * we split any linear segments to map the bevel point.
 *
 * However, we don't split arcs.
 * And we ignore any that don't match arcs or segments
 *
 * Unit 3430 is a good test case.
 * Really need to clean up and perhaps rething the bevel process
 * once we are totally converted to the new code.
 */
static IGRstat checkBevelPoint(TVDcvgCurve *crv, Tbevel *bevel, IGRpoint pt, IGRint breakFlag)
{
  VDASSERT_FN("checkBevelPoint");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRint  i,j;

  IGRpoint  pt1,pt2,pt3;
  IGRdouble dis,dis1,dis2;
  
  TGRbsp_curve *bsp;
  IGRchar       bspBuf[VDGEOM_SIZE_BUF];

  IGRdouble tol = BEVEL_TOL;
  
  // Init
  bsp = (TGRbsp_curve*)bspBuf;
  
  // Check for direct end point match
  for(i = 0; i < (crv->numVertexes - 1); i++) {
    sts = checkVertexPoint(&crv->vertexes[i],pt,tol);
    if (sts == 1) {
      retFlag = 1;
      goto wrapup;
    }
  }

  // Check if near a segment
  for(i = 0; i < (crv->numVertexes - 1); i++) {

    // Check line segment
    if (crv->vertexes[i+1].type == *XML_CVG_VERTEX_TYPE_LINE_TO) {

      // Pull the points
      pt1[0] = crv->vertexes[i].endx;
      pt1[1] = crv->vertexes[i].endy;
      pt1[2] = 0.0;
      pt2[0] = crv->vertexes[i+1].endx;
      pt2[1] = crv->vertexes[i+1].endy;
      pt2[2] = 0.0;
      
      // Make a line
      VDgeom2MakeLineCurve(pt1,pt2,&bsp);

      // Find the distance
      VDgeom2GetDisPtCv(pt,bsp,&dis);
      if (dis < tol) {

	// printf("Bevel seg point %f %f\n",pt[0],pt[1]);

	// If the segment was broken, would the lines be too short?
	/* ---------------------------------------
	 * Should probably just shift the bevel end point if
	 * splitting the segment would result in a tinyline
	 * Don't do that yet to maintain compatibility
	 */
	VDgeom2GetDisPtPt(pt,pt1,&dis1);
	if (dis1 < 10.0) {
	  //printf("Tiny broken segment 1 %.2f %.2f, Dis %.2f\n",pt[0],pt[1],dis1);
	}
	VDgeom2GetDisPtPt(pt,pt2,&dis2);
	if (dis2 < 10.0) {
	  //printf("Tiny broken segment 2 %.2f %.2f, Dis %.2f\n",pt[0],pt[1],dis2);
	}
	
	// Break the segment
	if (breakFlag) {
	  
	  if (crv->numVertexes >= crv->maxVertex) {
	    crv->maxVertex += 10;
	    crv->vertexes = g_renew(TVDcvgVertex,crv->vertexes,crv->maxVertex);
	  }
	  for(j = crv->numVertexes; j > i; j--) {
	    crv->vertexes[j] = crv->vertexes[j-1];
	  }
	  crv->vertexes[i+1].endx = pt[0];
	  crv->vertexes[i+1].endy = pt[1];
	  crv->vertexes[i+1].type = *XML_CVG_VERTEX_TYPE_LINE_TO;
	  crv->numVertexes++;
	}
	
	// Done
	retFlag = 1;
	goto wrapup;
      }
    }
    // Check arc segment
    if (crv->vertexes[i+1].type == *XML_CVG_VERTEX_TYPE_CARC_TO) {

      pt1[0] = crv->vertexes[i].endx;
      pt1[1] = crv->vertexes[i].endy;
      pt1[2] = 0.0;
      pt2[0] = crv->vertexes[i+1].midx;
      pt2[1] = crv->vertexes[i+1].midy;
      pt2[2] = 0.0;
      pt3[0] = crv->vertexes[i+1].endx;
      pt3[1] = crv->vertexes[i+1].endy;
      pt3[2] = 0.0;

      // Make an arc
      VDgeom2MakeArcCurve(pt1,pt2,pt3,&bsp);

      // Find the distance
      VDgeom2GetDisPtCv(pt,bsp,&dis);
      if (dis < tol) {
	//printf("Bevel arc point %f %f\n",pt[0],pt[1]);
	//retFlag = 1;
	goto wrapup;
      }
    }
    
  }
  
  // printf("Bevel bad point %f %f\n",pt[0],pt[1]);
  
 wrapup:
  return retFlag;
}
static void checkBevel(TVDcvgCurve *crv, Tbevel *bevel, IGRint breakFlag)
{
  VDASSERT_FN("checkBevel");
  IGRstat sts;
  
  // Basically make sure points can be mapped
  sts = checkBevelPoint(crv,bevel,bevel->pt1,breakFlag);
  if (sts == 0) bevel->skip = 1;
  sts = checkBevelPoint(crv,bevel,bevel->pt2,breakFlag);
  if (sts == 0) bevel->skip = 1;
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Know that all the valid bevel endpoints
 * map to curv vertexes, now set the v1,v2 values
 * in the bevels themselves for later use
 */
static void setBevelVertexInfo(TVDcvgCurve *crv, Tbevel *bevel)
{
  VDASSERT_FN("setBevelVertexInfo");
  
  IGRstat sts;
  
  IGRint i;
  IGRdouble tol = BEVEL_TOL;
  IGRint state = 0;
  
  // Ignored skipped ones
  bevel->v1 = -1;
  bevel->v2 = -1;
  if (bevel->skip == 1) goto wrapup;

  // Cycle through
  for(i = 0; (i < crv->numVertexes) && (state < 2); i++) {

    // Second point
    if (state == 1) {
      sts = checkVertexPoint(&crv->vertexes[i],bevel->pt2,tol);
      if (sts) {

	state = 2;

	// Assume begining and ending vertexes are the same
	if (i) bevel->v2 = i;
	else   bevel->v2 = crv->numVertexes - 1;
      }
    }
      
    // First Point
    if (state == 0) {
      sts = checkVertexPoint(&crv->vertexes[i],bevel->pt1,tol);
      if (sts) {
	state = 1;
	bevel->v1 = i;
      }
    }
  }
  if (state != 2) {
    logPcmk();
    VLsmsLog1(1,1,"Problem assigning bevel vertex points\n");
    bevel->skip = 1;
  }
  if (bevel->v1 == bevel->v2) {
    logPcmk();
    VLsmsLog1(1,1,"Problem assigning bevel vertex points\n");
    bevel->skip = 1;
  }

  /* ---------------------------------------------
   * There are a few cases where the bevel is not
   * correctly parameterized.  Need to fix the extraction code.
   * But correct it here.  
   *
   * There is the assumption that a bevel starting at v=0
   * is correctly parameterized.
   */
  if (bevel->v2 < bevel->v1) {
    i = bevel->v1;
    bevel->v1 = bevel->v2;
    bevel->v2 = i;
  }
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Call this after writing the curve
 */
static void writeBevel(Tbevel *bevel, TVDpdfFileInfo *pdfFile)
{
  
  // Type and process
  VDpdfWriteAttrInt (pdfFile,PDF_ATR_OBJ_BEG,PDF_OBJ_BEVEL);
  VDpdfWriteAttrText(pdfFile,PDF_ATR_BEVEL_SPEC,   bevel->type);
  VDpdfWriteAttrText(pdfFile,PDF_ATR_BEVEL_PROCESS,bevel->process);

  // Stock
  if (bevel->stock > .01) {
    VDpdfWriteAttrReal(pdfFile,PDF_ATR_PLATE_EDGE_STOCK,bevel->stock);
  }
  // gap
  if (bevel->gap > .01) {
    VDpdfWriteAttrReal(pdfFile,PDF_ATR_PLATE_EDGE_GAP,bevel->gap);
  }
    
  // Thickness of thinner adjacent plate
  if (bevel->thick2 > .01) {
    VDpdfWriteAttrReal(pdfFile,PDF_ATR_BEVEL_THICKNESS,bevel->thick2);
  }
    
  // Done
  VDpdfWriteAttrInt (pdfFile,PDF_ATR_OBJ_END,PDF_OBJ_BEVEL);

 wrapup:
  return;
}

/* -----------------------------------------------
 * Write a segment of the outer contour
 * possibly with a bevel
 */
static void writeSegment(TVDcvgCurve *crv, 
			 IGRint       bevelCnt, 
			 Tbevel      *bevels, 
			 IGRint      *segment, 
			 TVDpdfFileInfo *pdfFile)
{
  VDASSERT_FN("writeSegment");
  
  IGRint bevelIndex1;
  IGRint bevelIndex2;
  IGRint i;

  IGRint vertexCnt;

  Tbevel *bevel;

  IGRdouble tol = BEVEL_TOL;

  IGRstat sts;
  
  IGRint vNext = 100000;

  TVDcvgVertex *vertexes = NULL;
  IGRint        vertexType;
  
  // Say hi
  traceFlag = TRACE_FLAG;
  if (traceFlag) {
    logPcmk();
    VLsmsLog1(1,1,">>> %s, bevelCnt %d, segment %d\n",fn,bevelCnt,*segment);
  }
  
  // Make sure have stuff left
  if ((*segment+1) >= crv->numVertexes) {
    *segment = crv->numVertexes;
    goto wrapup;
  }
  /* -----------------------------------
   * We end up writing out vertexCnt vertices
   * The first one is always considered a "line to"
   * even if it's an arc because the contour has been split.
   * Need it to be a line because the arc mid point is actually before
   * the endpoint of the vertex
   *
   * Be a bit consertive and restore the vertex type when done with it
   */
  vertexes = &crv->vertexes[*segment];
  vertexType = vertexes->type;
  vertexes->type = *XML_CVG_VERTEX_TYPE_LINE_TO;
  
  // Does this segment have a bevel?
  for(i = 0; i < bevelCnt; i++) {

    // Skip marked ones
    bevel = &bevels[i];
    if (bevel->skip == 0) {
      
      // Starts a bevel
      if (bevel->v1 == *segment) {

	vertexCnt = bevel->v2 - bevel->v1 + 1;
	
	VDpdfWriteObjBeg  (pdfFile,PDF_OBJ_PLATE_EDGE);
	VDpdfWriteCvgCurve(pdfFile,PDF_ATR_PLATE_EDGE_CURVE,vertexCnt,vertexes);
	writeBevel(bevel,pdfFile);
	VDpdfWriteObjEnd  (pdfFile,PDF_OBJ_PLATE_EDGE);
	bevel->skip = 1;
	*segment = bevel->v2;
	goto wrapup;
      }

      // Find first bevel after it
      if (bevel->v1 > *segment) {
	if (vNext > bevel->v1) vNext = bevel->v1;
      }
    }
  }
  if (traceFlag) {
    logPcmk();
    VLsmsLog1(1,1,"No bevel, vNext %d\n",vNext);
  }
  
  if (vNext == 100000) vertexCnt = crv->numVertexes - *segment;
  else                 vertexCnt = vNext - *segment + 1;
      
  VDpdfWriteObjBeg  (pdfFile,PDF_OBJ_PLATE_EDGE);
  VDpdfWriteCvgCurve(pdfFile,PDF_ATR_PLATE_EDGE_CURVE,vertexCnt,vertexes);
  VDpdfWriteObjEnd  (pdfFile,PDF_OBJ_PLATE_EDGE);
  
  if (vNext == 100000) *segment = crv->numVertexes;
  else                 *segment = vNext;
    
 wrapup:
  if (vertexes) vertexes->type = vertexType;
  return;
}

/* -----------------------------------------------
 * Write a contour
 */
static IGRstat writeContour(TGRid *contourID, IGRint type, TVDpdfFileInfo *pdfFile)
{
  VDASSERT_FN("writeContour");

  IGRstat retFlag = 0;
  
  TGRid edgeID;
  TGRid bevelID;
  TGRid curveID;
  TGRid vertexID;
  TGRid ptID;
  
  TVDcvgCurve crv;
  
  TVDcvgVertex *vertex;
  IGRint i;
  
  IGRchab buf;

  Tbevel *bevel;
  Tbevel *bevels = NULL;
  Tbevel  bevelList[16];
  IGRint  bevelCnt = 0;
  
  IGRint  loopCnt;
  
  // Init
  memset(&crv,0,sizeof(TVDcvgCurve));
  
  // Get to the curve
  VDctxGetChildNodeByType(contourID,XML_SMS_EDGE,&edgeID);
  VDASSERTW(edgeID.objid != NULL_OBJID);

  VDctxGetChildNodeByType(&edgeID,XML_CVG_CURVE,&curveID);
  VDASSERTW(curveID.objid != NULL_OBJID);

  // Curve info
  fillCurveInfo(&curveID,&crv);
  VDASSERTW(crv.vertexes);
  
  // Bevel information
  bevelCnt = 0;
  for(i = 0; VDctxGetNthTreeChild(&edgeID,i,&bevelID); i++) {
    if (VDctxIsNodeType(&bevelID,XML_SMS_BEVEL)) bevelCnt++;
  }
  if (bevelCnt) {

    if (bevelCnt < 16) bevels = bevelList;
    else               bevels = g_new(Tbevel,bevelCnt);
    VDASSERTW(bevels);

    bevelCnt = 0;
    for(i = 0; VDctxGetNthTreeChild(&edgeID,i,&bevelID); i++) {
      if (VDctxIsNodeType(&bevelID,XML_SMS_BEVEL)) {

	bevel = &bevels[bevelCnt];
	bevelCnt++;

	bevel->skip = 0;
	VDctxGetTxtAtr(&bevelID,XML_SMS_BEVEL_TYPE,   bevel->type);
	VDctxGetTxtAtr(&bevelID,XML_SMS_BEVEL_PROCESS,bevel->process);
	VDctxGetTxtAtr(&bevelID,XML_SMS_BEVEL_THICK1, buf); bevel->thick1  = atof(buf);
	VDctxGetTxtAtr(&bevelID,XML_SMS_BEVEL_THICK2, buf); bevel->thick2  = atof(buf);
	VDctxGetTxtAtr(&bevelID,XML_SMS_BEVEL_STOCK,  buf); bevel->stock   = atof(buf);
	VDctxGetTxtAtr(&bevelID,XML_SMS_BEVEL_GAP,    buf); bevel->gap     = atof(buf);
	VDctxGetTxtAtr(&bevelID,XML_SMS_BEVEL_ANGLE_A,buf); bevel->angle_a = atof(buf);
	VDctxGetTxtAtr(&bevelID,XML_SMS_BEVEL_ANGLE_B,buf); bevel->angle_b = atof(buf);
	VDctxGetTxtAtr(&bevelID,XML_SMS_BEVEL_ANGLE_C,buf); bevel->angle_c = atof(buf);
	VDctxGetTxtAtr(&bevelID,XML_SMS_BEVEL_ANGLE_D,buf); bevel->angle_d = atof(buf);
	VDctxGetTxtAtr(&bevelID,XML_SMS_BEVEL_ANGLE_E,buf); bevel->angle_e = atof(buf);
	VDctxGetTxtAtr(&bevelID,XML_SMS_BEVEL_SIZE_A, buf); bevel->size_a  = atof(buf);
	VDctxGetTxtAtr(&bevelID,XML_SMS_BEVEL_SIZE_B, buf); bevel->size_b  = atof(buf);
	VDctxGetTxtAtr(&bevelID,XML_SMS_BEVEL_SIZE_C, buf); bevel->size_c  = atof(buf);
	VDctxGetTxtAtr(&bevelID,XML_SMS_BEVEL_SIZE_D, buf); bevel->size_d  = atof(buf);
	VDctxGetTxtAtr(&bevelID,XML_SMS_BEVEL_SIZE_E, buf); bevel->size_e  = atof(buf);

	// First Point
	VDctxGetNthTreeChild(&bevelID,0,&ptID);
	VDASSERTW(ptID.objid != NULL_OBJID);
	VDctxGetTxtAtr(&ptID,"x",buf); bevel->pt1[0] = atof(buf);
	VDctxGetTxtAtr(&ptID,"y",buf); bevel->pt1[1] = atof(buf);
	bevel->pt1[2] = 0.0;

	// Second point
	VDctxGetNthTreeChild(&bevelID,1,&ptID);
	VDASSERTW(ptID.objid != NULL_OBJID);
	VDctxGetTxtAtr(&ptID,"x",buf); bevel->pt2[0] = atof(buf);
	VDctxGetTxtAtr(&ptID,"y",buf); bevel->pt2[1] = atof(buf);
	bevel->pt2[2] = 0.0;
	
      }
    }
  }
     
  /* -------------------------------------------
   * Make sure that all bevels match to a vertex
   * for backwards compatibility, a single problem
   * in matching end points will result in no bevels
   * being sent
   *
   * Check bevels will break up segments if required
   * For backwards compatibility, scan once with no breaks
   * Then do it again
   */
  for(i = 0; i < bevelCnt; i++) {
    checkBevel(&crv,&bevels[i],0);
  }
  for(i = 0; i < bevelCnt; i++) {
    if (bevels[i].skip) {
      bevelCnt = 0;
      logPcmk();
      VLsmsLog1(1,1,"*** Bevel point not on a vertex, skipping bevels for this plate\n");
    }
  }
  for(i = 0; i < bevelCnt; i++) {
    checkBevel(&crv,&bevels[i],1);
  }
  
  /* ---------------------------------------------
   * An inner contour (type == 1) is written as a
   * parametric curve.  So far anyways, if a bevel is present
   * the entire curve is beveled.  Should probably put in a check
   * for this but leave it for now
   */
  if (type == 1) {

    TGRid labelID;
    TGRid textID;
    TVDcvgText text;
    
    // Write the geometry with bevels
    VDpdfWriteObjBeg  (pdfFile,PDF_OBJ_HOLE);
    VDpdfWriteAttrText(pdfFile,PDF_ATR_HOLE_TYPE,"generic");
    VDpdfWriteCvgCurveParametric(pdfFile,PDF_ATR_HOLE_CURVE,&crv);
    if (bevelCnt) {
      writeBevel(&bevels[0],pdfFile);
      //printf("Bevel on hole\n");
    }

    // Penetration holes might have a label
    VDctxGetChildNodeByType(contourID,XML_SMS_MARKING,&labelID);
    if (labelID.objid != NULL_OBJID) {

      VDctxGetChildNodeByType(&labelID,XML_SMS_EDGE,&edgeID);
      if (edgeID.objid != NULL_OBJID) {
	
	VDctxGetChildNodeByType(&edgeID,XML_CVG_TEXT,&textID);
	if (textID.objid != NULL_OBJID) {
	    
	  fillTextInfo(&textID,&text);
	  VDpdfWriteCvgLabel(pdfFile,1,"PEN",&text);
	  
	}
      }
    }
    
    // Done
    VDpdfWriteObjEnd(pdfFile,PDF_OBJ_HOLE);
    retFlag = 1;
    goto wrapup;
  }

  // Fill in starting and ending vertexes
  for(i = 0; i < bevelCnt; i++) {
    setBevelVertexInfo(&crv,&bevels[i]);
  }

  /* ---------------------------------------------
   * At this point, all the bevel endpoints match
   * a vertex endpoint.  Any bevels that do will 
   * have their skip flag set and get ignored.
   *
   * So now the trick will be to break up the curve
   * by bevel end points
   */
  for(i = 0, loopCnt = 0; (i < crv.numVertexes) && (loopCnt < crv.numVertexes); loopCnt++) {  
    writeSegment(&crv,bevelCnt,bevels,&i,pdfFile);
  }
  if (i < crv.numVertexes) {
    logPcmk();
    VLsmsLog1(1,1,"*** Loop count failed for writeSegment\n");
    goto wrapup;
  }
  retFlag = 1;
  
 wrapup:
  g_free(crv.vertexes);
  if (bevels != bevelList) g_free(bevels);
  
  return retFlag;
}

/* -----------------------------------------------
 * Write a marking
 */
static IGRstat writeMarkingPart(TGRid *markingID, TGRid *edgeID, TVDpdfFileInfo *pdfFile)
{
  VDASSERT_FN("writeMarking");

  IGRstat retFlag = 0;

  TGRid markingInfoID;
  
  IGRchab markingType;
  IGRchab buf;
  IGRchar *p;

  struct {
    IGRchar type[64];
    IGRchar pcmk[64];
    IGRchar name[64];
    IGRchar node[64];
  } info;

  IGRint markedSide = 0;
  
  TVDcvgText text;
  TVDcvgCurve crv;
  
  IGRint i,j;
  TGRid childID;
  TGRid crvID;

  IGRint didDir;
  
  TGRid     dirID;
  TGRid     hatID;
  IGRpoint  pt,pt1,pt2;
  IGRvector vec;
  BSrc rc;
  
  IGRint numCurves = 0;
  
  // Which side
  VDctxGetTxtAtr(markingID,XML_SMS_MARKING_MARKED_SIDE,buf);
  if (!strcmp(buf,XML_SMS_MARKING_MARKED_SIDE_FAR)) markedSide = 1;
  
  // Get the marking info
  VDctxGetChildNodeByType(markingID,XML_SMS_MARKING_PART_INFO,&markingInfoID);
  VDASSERTW(markingInfoID.objid != NULL_OBJID);
  VDctxGetTxtAtr(&markingInfoID,XML_SMS_MARKING_PART_INFO_MARKED_BY,buf);
  VDASSERTW(*buf);
  
  // Parse out
  memset(&info,0,sizeof(info));
  p = strchr(buf,',');
  if (p) {
    *p = 0; strcpy(info.type,buf); strcpy(buf,p+1);
  }
  p = strchr(buf,',');
  if (p) {
    *p = 0; strcpy(info.pcmk,buf); strcpy(buf,p+1);
  }
  p = strchr(buf,',');
  if (p) { *p = 0; strcpy(info.name,buf); strcpy(buf,p+1);
  }
  strcpy(info.node,buf);

  // Doit
  VDpdfWriteObjBeg(pdfFile,PDF_OBJ_MARKING_LINE);

  VDpdfWriteAttrText(pdfFile,PDF_ATR_MARKING_LINE_TYPE,info.type);
  VDpdfWriteAttrText(pdfFile,PDF_ATR_TREE_NODE_NAME,   info.name);
  VDpdfWriteAttrText(pdfFile,PDF_ATR_TREE_NODE_PCMK,   info.pcmk);
  VDpdfWriteAttrInt (pdfFile,PDF_ATR_MARKING_LINE_MTL_SURFACE,markedSide);
  
  // Put out any labels
  for(i = 0; VDctxGetNthTreeChild(edgeID,i,&childID); i++) {
    if (VDctxIsNodeType(&childID,XML_CVG_TEXT)) {

      fillTextInfo(&childID,&text);

      // Skip the actual piace mark numbers (all digits)
      for(p = text.value; (*p >= '0') && (*p <= '9'); p++);
      if (*p) {
	VDpdfWriteCvgLabel(pdfFile,1,"PART",&text);
      }
    }
  }

  // Put out the actual mark
  for(i = 0; VDctxGetNthTreeChild(edgeID,i,&childID); i++) {
    if (VDctxIsNodeType(&childID,XML_SMS_MARKING_PART_INFO_CURVE_ACTUAL)) {

      // Could have multiple curves
      for(j = 0; VDctxGetNthTreeChild(&childID,j,&crvID); j++) {
	numCurves++;
	fillCurveInfo(&crvID,&crv);
	VDpdfWriteCvgCurve(pdfFile,PDF_ATR_MARKING_LINE_CURVE,
			   crv.numVertexes,
			   crv.vertexes);
	g_free(crv.vertexes);
	
      }
    }
  }
  if (numCurves < 1) {
    logPcmk();
    VLsmsLog1(1,1,"No curves for marking line %s\n",info.pcmk);
  }

  // Most of the time, material direction comes from the hat
  didDir = 0;

  VDctxGetChildNodeByType(edgeID,XML_SMS_MARKING_PART_INFO_CURVE_HAT,&hatID);

  if (hatID.objid != NULL_OBJID) {

    VDctxGetChildNodeByType(&hatID,XML_CVG_CURVE,&crvID);

    if (crvID.objid != NULL_OBJID) {

	fillCurveInfo(&crvID,&crv);
      
	pt1[0] = crv.vertexes[0].endx;
	pt1[1] = crv.vertexes[0].endy;
	pt1[2] = 0.0;

	pt2[0] = crv.vertexes[1].endx;
	pt2[1] = crv.vertexes[1].endy;
	pt2[2] = 0.0;

	g_free(crv.vertexes);
	
	BSmkvec (&rc,vec,pt1,pt2);
	MAunitvc(&rc,vec,vec);

	for(i = 0; i < 3; i++) {
	  pt[i] = pt1[i] + (vec[i] * 10000.0);
	}
	  
	VDpdfWrite2dPt(pdfFile,PDF_ATR_MARKING_LINE_MTL_POINT,pt);
	didDir = 1;
	  
    }
  }
  
  // But sometimes use the materialline
  if (didDir == 0) {
    VDctxGetChildNodeByType(edgeID,XML_SMS_MARKING_PART_INFO_CURVE_MTL_DIR,&dirID);
    if (dirID.objid != NULL_OBJID) {
      VDctxGetChildNodeByType(&dirID,XML_CVG_CURVE,&crvID);
      if (crvID.objid != NULL_OBJID) {
	fillCurveInfo(&crvID,&crv);
	pt[0] = crv.vertexes[0].endx;
	pt[1] = crv.vertexes[0].endy;
	pt[2] = 0.0;
	g_free(crv.vertexes);
	VDpdfWrite2dPt(pdfFile,PDF_ATR_MARKING_LINE_MTL_POINT,pt);
	didDir = 1;
      }
    }
  }
  if (didDir == 0) {
    logPcmk();
    VLsmsLog1(1,1,"No material direction for marking line %s\n",info.pcmk);
  }
  
  // Done
  VDpdfWriteObjEnd(pdfFile,PDF_OBJ_MARKING_LINE);
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Write a marking label
 */
static void writeMarkingLabel(TGRid *markingID, TGRid *edgeID, TVDpdfFileInfo *pdfFile)
{
  VDASSERT_FN("writeMarkingLabel");
  IGRint i;
  TGRid textID;
  
  TVDcvgText text;
  
  // All standalone labels shoud just be text
  for(i = 0; VDctxGetNthTreeChild(edgeID,i,&textID); i++) {

    if (VDctxIsNodeType(&textID,XML_CVG_TEXT)) {
      fillTextInfo(&textID,&text);
      VDpdfWriteCvgLabel(pdfFile,0,"REF",&text);
    }
    else {
      logPcmk();
      VLsmsLog1(1,1,"Have label with something other than text objects\n");
    }
  }
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Write a marking
 */
static IGRstat writeMarking(TGRid *markingID, TVDpdfFileInfo *pdfFile)
{
  VDASSERT_FN("writeMarking");

  IGRstat retFlag = 0;
  
  IGRchab markingType;

  TGRid edgeID;
  TGRid childID;
  
  TVDcvgCurve crv;
  TVDcvgText  text;
  
  IGRint i;
  IGRint didIt;
  
  // Graphics are wrapped in an edge
  VDctxGetChildNodeByType(markingID,XML_SMS_EDGE,&edgeID);
  VDASSERTW(edgeID.objid != NULL_OBJID);
  
  // Switch on the type
  VDctxGetTxtAtr(markingID,XML_SMS_MARKING_TYPE,markingType);
  if (!strcmp(markingType,XML_SMS_MARKING_TYPE_LABEL)) {
    writeMarkingLabel(markingID,&edgeID,pdfFile);
    retFlag = 1;
    goto wrapup;
  }
  if (!strcmp(markingType,XML_SMS_MARKING_TYPE_PART)) {
    writeMarkingPart(markingID,&edgeID,pdfFile);
    retFlag = 1;
    goto wrapup;
  }
  // All other marks are handled generically
  VDpdfWriteObjBeg(pdfFile,PDF_OBJ_MARKING_LINE);
  VDstrupr(markingType);
  VDpdfWriteAttrText(pdfFile,PDF_ATR_MARKING_LINE_TYPE,markingType);

  // Cycle through
  for(i = 0; VDctxGetNthTreeChild(&edgeID,i,&childID); i++) {
    didIt = 0;
    if (VDctxIsNodeType(&childID,XML_CVG_TEXT)) {
      fillTextInfo(&childID,&text);
      VDpdfWriteCvgLabel(pdfFile,1,markingType,&text);
      didIt = 1;
    }
    if (VDctxIsNodeType(&childID,XML_CVG_CURVE)) {
      fillCurveInfo(&childID,&crv);
      VDpdfWriteCvgCurve(pdfFile,PDF_ATR_MARKING_LINE_CURVE,
			 crv.numVertexes,
			 crv.vertexes);
      free(crv.vertexes);
      didIt = 1;
    }
    if (didIt == 0) {
      logPcmk();
      VLsmsLog1(1,1,"Have something besides text or curve in generic marking\n");
    }
  }
  VDpdfWriteObjEnd(pdfFile,PDF_OBJ_MARKING_LINE);
    
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Converts a cvg list of vertexes to a bsp curve
 * Caller must free the curve
 */
static void convertCvgCurveToBsp(TVDcvgCurve *crv, TGRbsp_curve **bsp)
{
  VDASSERT_FN("convertCvgCurveToBsp");

  IGRpoint pt1,pt2,pt3;

  IGRchar       crv_buf[VDGEOM_SIZE_BUF];
  TGRbsp_curve *crv_segment;
  TGRbsp_curve *crv_merged;

  IGRint i;
  
  // Arg check
  VDASSERTW(bsp); *bsp = NULL;
  VDASSERTW(crv && crv->numVertexes && crv->vertexes);

  // Start with nothing
  pt1[2] = pt2[2] = pt3[2] = 0;
  crv_segment = (TGRbsp_curve*)crv_buf;

  // First vertex is a move to
  pt1[0] = crv->vertexes[0].endx;
  pt1[1] = crv->vertexes[0].endy;
  
  // Cycle through
  for(i = 1; i < crv->numVertexes; i++) {

    pt2[0] = crv->vertexes[i].endx;
    pt2[1] = crv->vertexes[i].endy;
    
    switch(crv->vertexes[i].type) {

      case 'a':
	pt3[0] = crv->vertexes[i].midx;
	pt3[1] = crv->vertexes[i].midy;
	VDgeom2MakeArcCurve (pt1,pt3,pt2,&crv_segment);
	break;
	
      case 'l':
	VDgeom2MakeLineCurve(pt1,pt2,&crv_segment);
	break;

      default:
	VDASSERTW(0);
	
    }

    // Either the first or append it
    if (*bsp == NULL) {
      VDgeom2CopyCurve(crv_segment,bsp);
      VDASSERTW(*bsp);
    }
    else {

      VDgeom2MergeTwoCurves(*bsp,crv_segment,&crv_merged);
      if (crv_merged == NULL) { 
	logPcmk();
	VLsmsLog1(1,1,"Merge curve failed while mapping penetration lable to hole\n");
	goto wrapup;
      }
      g_free(*bsp);
      *bsp = crv_merged;
    }

    // Next segment
    pt1[0] = pt2[0];
    pt1[1] = pt2[1];
    
  }
  
  // Done
 wrapup:
  return;
}

/* -----------------------------------------------
 * See if the given label applies to the hole contour
 */
static void addHoleLabel(TGRid *plateID, TGRid *holeID, TGRid *labelID)
{
  VDASSERT_FN("addHoleLabel");
  
  TGRid childID;
  TGRid edgeID;
  TGRid textID;
  TGRid crvID;
  
  IGRchab buf;
  
  TVDcvgCurve crv;
  TVDcvgText  text;

  IGRpoint   cenLabel;
  IGRdouble *cenHole;
  
  TGRbsp_curve *bsp = NULL;
  
  IGRdouble dis;

  xmlNodePtr holePtr;
  xmlNodePtr labelPtr;
  
  // Check to see if the hole already has a label attached
  VDctxGetChildNodeByType(holeID,XML_SMS_MARKING,&childID);
  if (childID.objid != NULL_OBJID) goto wrapup;

  // Is the label in fact a penetration label
  VDctxGetTxtAtr(labelID,XML_SMS_MARKING_TYPE,buf);
  if (strcmp(buf,XML_SMS_MARKING_TYPE_LABEL)) goto wrapup;

  VDctxGetChildNodeByType(labelID,XML_SMS_EDGE,&edgeID);
  if (edgeID.objid == NULL_OBJID) goto wrapup;
  
  VDctxGetChildNodeByType(&edgeID,XML_CVG_TEXT,&textID);
  if (textID.objid == NULL_OBJID) goto wrapup;
  
  fillTextInfo(&textID,&text);
  if (strncmp(text.value,"PEN-",4)) goto wrapup;
  
  // Get the center
  /* ---------------------------------------------
   * Not sure if need to worry about rotation or not
   * Check later
   * Also, some penetrations will actually be on the outer contour
   */
  cenLabel[0] =  (atof(text.x1) + atof(text.x2)) * .5;
  cenLabel[1] = ((atof(text.y1) + atof(text.y2)) * .5) + (atof(text.height) * .5);
  cenLabel[2] = 0.0;
  
  // Now see if the center has been calculated for the hole yet
  VDctxGetBinAtr(holeID,"center",(void**)&cenHole);
  if (cenHole == NULL) {

    VDctxGetChildNodeByType(holeID,XML_SMS_EDGE,&edgeID);
    if (edgeID.objid == NULL_OBJID) goto wrapup;
  
    VDctxGetChildNodeByType(&edgeID,XML_CVG_CURVE,&crvID);
    if (crvID.objid == NULL_OBJID) goto wrapup;

    // Need the bsp curve
    fillCurveInfo(&crvID,&crv);
    convertCvgCurveToBsp(&crv,&bsp);
    VDASSERTW(bsp);  
    g_free(crv.vertexes);
    
    // Store the center
    cenHole = g_new(IGRdouble,3);
    VDgeom2GetCurveCenter(bsp,cenHole);
    g_free(bsp);
    bsp = NULL;
    VDctxAppBinAtr(holeID,"center",cenHole,NULL);

  }
  
  // See if it's close
  VDgeom2GetDisPtPt(cenLabel,cenHole,&dis);
  if (dis > 10.0) goto wrapup;
  
  // Transfer
  holePtr  = xdom_nodeid_get_node(holeID);
  labelPtr = xdom_nodeid_get_node(labelID);
  xmlUnlinkNode(labelPtr);
  xmlAddChild(holePtr,labelPtr);
    
 wrapup:
  g_free(bsp);
  
  return;
}

/* -----------------------------------------------
 * Write a plate
 */
static IGRstat writePlate(TGRid *plateID, TVDpdfFileInfo *pdfFile)
{
  VDASSERT_FN("writePlate");

  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRid partInfoID;
  TGRid prodInfoID;
  TGRid plate3DID;

  TGRid pointID;
  TGRid rangeID;
  TGRid matrixID;
  TGRid contourID,contoursID;
  TGRid markingID,markingsID;
  
  IGRint qty = 0;
  
  IGRint i,j;
  TGRid  childID;

  IGRchab pcmk;
  IGRchab buf;
  IGRchar *p;

  IGRdouble thickness,expand;
  IGRdouble ref[16];
  
  IGRint isPlanar,flip;

  // Init logger
  s_flag = 0;
  *s_pcmk = 0;
  
  // Get the master part info
  VDctxGetChildNodeByType(plateID,XML_SMS_PART_INFO,&partInfoID);
  VDASSERTW(partInfoID.objid != NULL_OBJID);

  // Calc qty and get default prod info
  qty = 0;
  prodInfoID.objid = NULL_OBJID;
  for(i = 0; VDctxGetNthTreeChild(&partInfoID,i,&childID); i++) {
    if (VDctxIsNodeType(&childID,XML_SMS_PROD_INFO)) {

      // Save first
      if (prodInfoID.objid == NULL_OBJID) prodInfoID = childID;
      
      // Update qty
      VDctxGetTxtAtr(&childID,XML_SMS_PROD_INFO_QTY,buf);
      qty += atoi(buf);
    
    }
  }
  VDASSERTW(prodInfoID.objid != NULL_OBJID);
  VDASSERTW(qty);

  // Filter pcmks for debugging
  VDctxGetTxtAtr(&prodInfoID,XML_SMS_PROD_INFO_PCMK,pcmk);
  if (*TRACE_PCMK && strcmp(pcmk,TRACE_PCMK)) goto wrapup;
  strcpy(s_pcmk,pcmk);
  
  // Start
  VDpdfWriteObjBeg(pdfFile,PDF_OBJ_PLATE);

  // Format already matches spades
  writeTxt(&prodInfoID,XML_SMS_PROD_INFO_ASSEMBLY,pdfFile,PDF_ATR_TREE_NODE_PARENT);

  // Parse the name out of the part_name
  VDctxGetTxtAtr(&partInfoID,XML_SMS_PART_INFO_PART_NAME,buf);
  p = strrchr(buf,':');
  if (p) strcpy(buf,p+1);
  VDpdfWriteAttrText(pdfFile,PDF_ATR_TREE_NODE_NAME,buf);

  // Match spades pcmk format
  VDctxGetTxtAtr(&prodInfoID,XML_SMS_PROD_INFO_PCMK,buf);
  for(p = buf; *p == '0'; p++);
  strcpy(buf,p);
  VDpdfWriteAttrText(pdfFile,PDF_ATR_TREE_NODE_PCMK,buf);

  // Family and part_num come from the name as well
  VDctxGetTxtAtr(&partInfoID,XML_SMS_PART_INFO_PART_NAME,buf);
  p = strchr(buf,':');
  if (p) *p = 0;
  VDpdfWriteAttrText(pdfFile,PDF_ATR_PIECE_FAMILY,buf);
  if (p) {
    strcpy(buf,p+1);
    p = strchr(buf,':');
    if (p) *p = 0;
  }
  VDpdfWriteAttrText(pdfFile,PDF_ATR_PIECE_PART_NUM,buf);

  // Material is easy
  writeTxt(&partInfoID,XML_SMS_PART_INFO_MATERIAL_TYPE, pdfFile,PDF_ATR_PIECE_MAT_TYPE);
  writeTxt(&partInfoID,XML_SMS_PART_INFO_MATERIAL_GRADE,pdfFile,PDF_ATR_PIECE_MAT_GRADE);

  // Optional production type
  VDctxGetTxtAtr(&partInfoID,XML_SMS_PART_INFO_PROD_TYPE,buf);
  if (*buf) {
    VDstrupr(buf);
    VDpdfWriteAttrText(pdfFile,PDF_ATR_PIECE_PROD_TYPE,buf);
  }
  
  // Thickness is a double
  VDctxGetTxtAtr(plateID,XML_SMS_PLATE_THICKNESS,buf);
  thickness = atof(buf);
  VDpdfWriteAttrReal(pdfFile,PDF_ATR_PLATE_THICKNESS,thickness);

  // 3D Information
  VDctxGetChildNodeByType(&partInfoID,XML_PDF_PLATE_3D,&plate3DID);
  VDASSERTW(plate3DID.objid != NULL_OBJID);

  // Expansion
  VDctxGetTxtAtr(&plate3DID,XML_PDF_PLATE_3D_EXPAND_MAJOR,buf);
  expand = atof(buf);
  if (expand < .1) expand = 1.0;
  VDpdfWriteAttrReal(pdfFile,PDF_ATR_PLATE_EXPAND_MAJOR,expand);

  VDctxGetTxtAtr(&plate3DID,XML_PDF_PLATE_3D_EXPAND_MINOR,buf);
  expand = atof(buf);
  if (expand < .1) expand = 1.0;  
  VDpdfWriteAttrReal(pdfFile,PDF_ATR_PLATE_EXPAND_MINOR,expand);

  // Add planar flag
  VDctxGetTxtAtr(&plate3DID,XML_PDF_PLATE_3D_IS_PLANAR,buf);
  isPlanar = atoi(buf);
  VDpdfWriteAttrInt(pdfFile,PDF_ATR_PLATE_PLANE,isPlanar);

  // Tells spades if base or offset
  // 08 Feb 2000, turned this flip on, 1 = offset
  VDctxGetTxtAtr(plateID,XML_SMS_PLATE_NEAR_SIDE,buf);
  if (!strcmp(buf,XML_SMS_PLATE_NEAR_SIDE_OFFSET)) flip = 1;
  else flip = 0;
  VDpdfWriteAttrInt(pdfFile,PDF_ATR_PLATE_FLIP,flip);

  // Material direction
  writeTxt(&plate3DID,XML_PDF_PLATE_3D_MATERIAL_DIRECTION,pdfFile,PDF_ATR_PLATE_MAT_DIR);

  // Three reference points
  for(i = 0; i < 3; i++) {

    VDctxGetNthTreeChild(&plate3DID,i,&pointID);

    VDctxGetTxtAtr(&pointID,"x",buf); ref[(i*3)+0] = atof(buf);
    VDctxGetTxtAtr(&pointID,"y",buf); ref[(i*3)+1] = atof(buf);
    VDctxGetTxtAtr(&pointID,"z",buf); ref[(i*3)+2] = atof(buf);
  }
  VDpdfWrite3dPts(pdfFile,PDF_ATR_PIECE_3D_REF_PTS, 3, ref);

  // Range Information
  VDctxGetChildNodeByType(&partInfoID,XML_CVG_RANGE,&rangeID);
  VDASSERTW(rangeID.objid != NULL_OBJID);

  VDctxGetTxtAtr(&rangeID,"x1",buf); ref[0] = atof(buf);
  VDctxGetTxtAtr(&rangeID,"y1",buf); ref[1] = atof(buf);
  VDctxGetTxtAtr(&rangeID,"z1",buf); ref[2] = atof(buf);
  VDctxGetTxtAtr(&rangeID,"x2",buf); ref[3] = atof(buf);
  VDctxGetTxtAtr(&rangeID,"y2",buf); ref[4] = atof(buf);
  VDctxGetTxtAtr(&rangeID,"z2",buf); ref[5] = atof(buf);

  VDpdfWriteReals(pdfFile,PDF_ATR_PIECE_RANGE,6,ref);

  // 4x3 matrix
  VDctxGetChildNodeByType(&partInfoID,XML_CVG_MATRIX_4X3,&matrixID);
  VDASSERTW(matrixID.objid != NULL_OBJID);

  VDctxGetTxtAtr(&matrixID,"i00",buf); ref[ 0] = atof(buf);
  VDctxGetTxtAtr(&matrixID,"i01",buf); ref[ 1] = atof(buf);
  VDctxGetTxtAtr(&matrixID,"i02",buf); ref[ 2] = atof(buf);
  VDctxGetTxtAtr(&matrixID,"i03",buf); ref[ 3] = atof(buf);
  VDctxGetTxtAtr(&matrixID,"i10",buf); ref[ 4] = atof(buf);
  VDctxGetTxtAtr(&matrixID,"i11",buf); ref[ 5] = atof(buf);
  VDctxGetTxtAtr(&matrixID,"i12",buf); ref[ 6] = atof(buf);
  VDctxGetTxtAtr(&matrixID,"i13",buf); ref[ 7] = atof(buf);
  VDctxGetTxtAtr(&matrixID,"i20",buf); ref[ 8] = atof(buf);
  VDctxGetTxtAtr(&matrixID,"i21",buf); ref[ 9] = atof(buf);
  VDctxGetTxtAtr(&matrixID,"i22",buf); ref[10] = atof(buf);
  VDctxGetTxtAtr(&matrixID,"i23",buf); ref[11] = atof(buf);

  VDpdfWriteReals(pdfFile,PDF_ATR_PIECE_MATRIX,12,ref);

  // Outer contour
  VDctxGetChildNodeByType(plateID,XML_SMS_PLATE_CONTOUR,&contourID);
  VDASSERTW(contourID.objid != NULL_OBJID);
  sts = writeContour(&contourID,0,pdfFile);
  if (!(sts & 1)) {
    logPcmk();
    VLsmsLog1(1,1,"Problem writing plate outer contour\n");
    goto wrapup;
  }
  
  // Add penetration labels to inner contours
  VDctxGetChildNodeByType(plateID,XML_SMS_INNER_CONTOURS,&contoursID);
  VDctxGetChildNodeByType(plateID,XML_SMS_MARKINGS,      &markingsID);
  if (contoursID.objid != NULL_OBJID && markingsID.objid != NULL_OBJID) {
    for(i = 0; VDctxGetNthTreeChild(&contoursID,i,&contourID); i++) {
      for(j = 0; VDctxGetNthTreeChild(&markingsID,j,&markingID); j++) {
	addHoleLabel(plateID,&contourID,&markingID);
      }
    }
  }
  
  // Inner contours
  VDctxGetChildNodeByType(plateID,XML_SMS_INNER_CONTOURS,&contoursID);
  if (contoursID.objid != NULL_OBJID) {
    for(i = 0; VDctxGetNthTreeChild(&contoursID,i,&contourID); i++) {
      sts = writeContour(&contourID,1,pdfFile);
      if (!(sts & 1)) {
	logPcmk();
	VLsmsLog1(1,1,"Problem writing plate inner contour\n");
	goto wrapup;
      }
    }
  }

  // Markings
  VDctxGetChildNodeByType(plateID,XML_SMS_MARKINGS,&markingsID);
  if (markingsID.objid != NULL_OBJID) {
    for(i = 0; VDctxGetNthTreeChild(&markingsID,i,&markingID); i++) {
      sts = writeMarking(&markingID,pdfFile);
      if (!(sts & 1)) {
	logPcmk();
	VLsmsLog1(1,1,"Problem writing plate marking\n");
	goto wrapup;
      }
    }
  }

  // Finish
  VDpdfWriteObjEnd(pdfFile,PDF_OBJ_PLATE);
  retFlag = 1;
  
 wrapup:
  return retFlag;
  
}

/* -----------------------------------------------
 * Generate spades and dxf files
 */
IGRstat VLsms2GenerateDxfPdf(IGRchar *xmlFileName, 
			     IGRchar *unitReal, 
			     IGRchar *unitTest,
			     IGRint   pre_translate)
{
  VDASSERT_FN("VLsms2GenerateDxfPdf");
  
  IGRstat retFlag = 0;
  TGRid smsID;

  TGRid childID;
  IGRchab nodeType;
  IGRint i;
  
  TVDpdfFileInfo pdfFile;
  
  TGRid setupID;
  TGRid shipID;
  TGRid stagingTreeID;
  TGRid stagingNodeID;

  TGRid platesID;
  TGRid plateID;
  
  IGRchar spadesName     [32];
  IGRchar spadesNamex   [128];
  IGRchar spadesXmlName  [32];
  IGRchar spadesPdfName  [32];
  IGRchar spadesChrName  [32];
  IGRchar spadesTarName  [32];
  IGRchar spadesXmlNamex[128];
  IGRchar spadesPdfNamex[128];
  IGRchar spadesChrNamex[128];

  IGRchar *p;
  IGRchar unit[32];
  IGRchar app [32];
  IGRchar cmd[256];
  
  // Init
  smsID.objid = NULL_OBJID;
  memset(&pdfFile,0,sizeof(TVDpdfFileInfo));
  
  // Arg check
  VDASSERTW(xmlFileName && *xmlFileName);
  VDASSERTW(unitReal && *unitReal);
  
  // Load the tree
  VDxdomCreateTreeFromXmlFile(xmlFileName,&smsID);
  VDASSERTW(smsID.objid != NULL_OBJID);

  // Grab the setup object
  VDctxGetChildNodeByType(&smsID,XML_PDF_SETUP,&setupID);
  VDASSERTW(setupID.objid != NULL_OBJID);

  // Build a bunch of file names
  strcpy (spadesName,"spades");
  sprintf(spadesXmlName,"%s.xml",spadesName);
  sprintf(spadesPdfName,"%s.pdf",spadesName);
  sprintf(spadesChrName,"%s.chr",spadesName);
  
  VDctxGetTxtAtr(&setupID,XML_PDF_SETUP_PDF_NAME,spadesNamex);
  sprintf(spadesXmlNamex,"%s.xml",spadesNamex);
  sprintf(spadesPdfNamex,"%s.pdf",spadesNamex);
  sprintf(spadesChrNamex,"%s.chr",spadesNamex);
  
  // Need hull app and unit
  strcpy(unit,"XXXX");
  strcpy(app,"A");
  p = strchr(spadesNamex,'.');
  if (p) strcpy(spadesNamex,p+1);
  p = strchr(spadesNamex,'.');
  if (p) {
    *p = 0;
    strcpy(app,spadesNamex);
    strcpy(spadesNamex,p+1);
  }
  p = strchr(spadesNamex,'.');
  if (p) {
    *p = 0;
    strcpy(unit,spadesNamex);
  }
  sprintf(spadesTarName,"sp%s%s.tar",unit,app);
    
  // Open the binary file
  VDpdfOpenOutputFile(&pdfFile,spadesPdfName);
  VDpdfWriteObjBeg(&pdfFile,PDF_OBJ_ROOT);
    
  // Dump out the setup object
  VDpdfWriteObjBeg(&pdfFile,PDF_OBJ_SETUP);
  writeTxt(&setupID,XML_PDF_SETUP_INTERNAL_UNITS,&pdfFile,PDF_ATR_SETUP_INTERNAL_UNITS);
  writeTxt(&setupID,XML_PDF_SETUP_PDF_NAME,      &pdfFile,PDF_ATR_SETUP_FILE_NAME);
  writeTxt(&setupID,XML_PDF_SETUP_PDM_CAT,       &pdfFile,PDF_ATR_SETUP_PDM_CAT);
  writeTxt(&setupID,XML_PDF_SETUP_PDM_PART,      &pdfFile,PDF_ATR_SETUP_PDM_PART);
  writeTxt(&setupID,XML_PDF_SETUP_PDM_REV,       &pdfFile,PDF_ATR_SETUP_PDM_REV);
  writeTxt(&setupID,XML_PDF_SETUP_PDM_STATUS,    &pdfFile,PDF_ATR_SETUP_PDM_STATUS);
  writeInt(&setupID,XML_PDF_SETUP_PRE_TRANSLATE, &pdfFile,PDF_ATR_SETUP_PRE_TRANSLATE);
  VDpdfWriteObjEnd(&pdfFile,PDF_OBJ_SETUP);

  // Ship object
  VDctxGetChildNodeByType(&smsID,XML_PDF_SHIP,&shipID);
  VDASSERTW(shipID.objid != NULL_OBJID);

  VDpdfWriteObjBeg(&pdfFile,PDF_OBJ_SHIP);
  writeTxt(&shipID,XML_PDF_SHIP_NAME,               &pdfFile,PDF_ATR_SHIP_NAME);
  writeTxt(&shipID,XML_PDF_SHIP_OWNER,              &pdfFile,PDF_ATR_SHIP_OWNER);
  writeTxt(&shipID,XML_PDF_SHIP_HULL,               &pdfFile,PDF_ATR_SHIP_HULL);
  writeTxt(&shipID,XML_PDF_SHIP_HULL_APP,           &pdfFile,PDF_ATR_SHIP_HULL_APP);
  writeTxt(&shipID,XML_PDF_SHIP_DIMENSIONS,         &pdfFile,PDF_ATR_SHIP_DIMENSIONS);
  writeTxt(&shipID,XML_PDF_SHIP_GLOBAL_COORD_SYSTEM,&pdfFile,PDF_ATR_SHIP_GLOBAL_COORD_SYSTEM);
  writeDbl(&shipID,XML_PDF_SHIP_FWD_PERPENDICULAR,  &pdfFile,PDF_ATR_SHIP_FWD_PERPENDICULAR);
  VDpdfWriteObjEnd(&pdfFile,PDF_OBJ_SHIP);

  // Staging tree if have one
  VDctxGetChildNodeByType(&smsID,XML_PDF_TREE,&stagingTreeID);
  if (stagingTreeID.objid != NULL_OBJID) {

    // Tree info
    VDpdfWriteObjBeg(&pdfFile,PDF_OBJ_TREE);
    writeTxt(&stagingTreeID,XML_PDF_TREE_NAME,&pdfFile,PDF_ATR_TREE_NAME);
    writeTxt(&stagingTreeID,XML_PDF_TREE_REV, &pdfFile,PDF_ATR_TREE_REV);

    // Walk through and print nodes
    VDctxGetNthTreeChild(&stagingTreeID,0,&stagingNodeID);
    VDASSERTW(stagingNodeID.objid != NULL_OBJID);
    writeTreeNode(&stagingNodeID,&pdfFile);
    
    // Done with tree
    VDpdfWriteObjEnd(&pdfFile,PDF_OBJ_TREE);
  }
  
  // Grab the plates
  VDctxGetChildNodeByType(&smsID,XML_SMS_PLATES,&platesID);
  if (platesID.objid != NULL_OBJID) {

    VDpdfWriteObjBeg(&pdfFile,PDF_OBJ_PLATES);

    // Cycle through
    for(i = 0; VDctxGetNthTreeChild(&platesID,i,&plateID); i++) {
      writePlate(&plateID,&pdfFile);
    }
    
    VDpdfWriteObjEnd(&pdfFile,PDF_OBJ_PLATES);
  }
  
  // Finish up
  VDpdfWriteObjEnd(&pdfFile,PDF_OBJ_ROOT);
  VDpdfCloseOutputFile(&pdfFile);
    
  // Verify which creates the spades xml file
  VDpdfVerifyFile   (spadesPdfName);
  VDpdfVerifyChrFile(spadesPdfName);

  // Official names
  sprintf(cmd,"cp %s %s",spadesPdfName,spadesPdfNamex);system(cmd);
  sprintf(cmd,"cp %s %s",spadesXmlName,spadesXmlNamex);system(cmd);
  sprintf(cmd,"cp %s %s",spadesChrName,spadesChrNamex);system(cmd);

  // Tar then
  sprintf(cmd,"tar -cf %s %s %s %s",
	  spadesTarName,spadesPdfNamex,spadesXmlNamex,spadesChrNamex);
  system (cmd);
  sprintf(cmd,"chmod 777 %s",spadesTarName);  system(cmd);
  sprintf(cmd,"rm %s",       spadesPdfNamex); system(cmd);
  sprintf(cmd,"rm %s",       spadesXmlNamex); system(cmd);
  sprintf(cmd,"rm %s",       spadesChrNamex); system(cmd);

  // Done
  retFlag = 1;
  
 wrapup:
  VDctxDeleteNode(&smsID);
  return retFlag;
  
}
