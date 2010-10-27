/* -----------------------------------------------
 * Just some code copied from VDvalSpades.c
 * Useful for debugging mempry related crashes
 *
 * Not used by the regular program
 *
 * WARNING - 19 Oct 2001
 * Got it to compile but no testing was done
 */
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDxml.h"
#include "VDctx.h"
#include "VDxdom.h"
#include "VDgeomc.h"
#include "VDval.h"
#include "VDvalSpades.h"

VDASSERT_FFN("vdbin/sp_val/test.c");
/* -----------------------------------------------
 * Process one plate edge
 */
static void processPlateEdge(TGRid *edgeID, void *data, IGRint *stopWalk)
{
  VDASSERT_FN("processPlateEdge");

  IGRstat sts;
  
  TGRid *plateID = data;
  TGRid  crvID;
  
  IGRchab nodeType;
  IGRchar *txt;

  TGRbsp_curve *crv_edge   = NULL;
  TGRbsp_curve *crv_outer  = NULL;
  TGRbsp_curve *crv_merged = NULL;
  
  IGRpoint pt1,pt2;
  IGRdouble dis;
  
  IGRdouble tol;
  IGRdouble z = 0.0;
  IGRdouble *range;
  
  // Only want plate edges
  VDctxGetNodeType(edgeID,nodeType);
  if (strcmp(nodeType,"PDF_OBJ_PLATE_EDGE")) goto wrapup;

  // Need to be careful about long attributes
  VDctxGetBinAtr(edgeID,"PDF_ATR_PLATE_EDGE_CURVE",(void**)&txt);
  VDASSERTW(txt);
#if 0
  // Need the z depth
  VDctxGetBinAtr(plateID,"range",NULL,(void*)&range);
  if (range) z = range[2];
  else       z = 0.0;
#endif
  // Get the geometry
  sts = VDvalParseLineArc(txt,z,&crv_edge);
  if (sts == 0) {
    VDvalLogError("Problem processing plate edge curve");
  }
  VDASSERTW(crv_edge);
  VDctxSetBinAtr(edgeID,"PDF_ATR_PLATE_EDGE_CURVE",crv_edge,NULL);
#if 0
  // Add this curve to form a composite outer contour
  VDctxGetBinAtr(plateID,"outer_contour",NULL,(void*)&crv_outer);
  if (crv_outer == NULL) {
    VDgeom2CopyCurve(crv_edge,&crv_outer);
    VDctxAppBinAtr(plateID,"outer_contour","contour",crv_outer);
    goto wrapup;
  }
    
  // The edge itself should not be closed
  VDgeom2GetCrvEndPts(crv_edge,pt1,pt2);
  VDgeom2GetDisPtPt(pt1,pt2,&dis);
  VDvalGetTolerance(VDTOL_EDGE_NOT_CLOSED,&tol);
  if (dis < tol) {
    VDvalLogError("Closed outer contour segment at %.2f,%.2f,%.2f",
	     pt1[0],pt1[1],pt1[2]);
    drawPoint(pt1);
  }

  // Check for gaps
  VDgeom2GetCrvPt(crv_outer,1.0,pt1);
  VDgeom2GetCrvPt(crv_edge, 0.0,pt2);
  VDgeom2GetDisPtPt(pt1,pt2,&dis);
  VDvalGetTolerance(VDTOL_CONTOUR_GAP,&tol);
  if (dis > tol) {
    VDvalLogError("Gap between two outer contour segments of %.2f at %.2f,%.2f,%.2f",
	     dis,pt1[0],pt1[1],pt1[2]);
    drawPoint(pt1);
  }
  VDgeom2LinkCurves(crv_outer,crv_edge);
  VDgeom2MergeTwoCurves(crv_outer,crv_edge,&crv_merged);

  // Update the attribute
  VDctxAppBinAtr(plateID,"outer_contour","contour",crv_merged);
  free(crv_outer);
#endif

 wrapup:
  return;
}
/* -----------------------------------------------
 * Check various attributes
 */
IGRstat processPlateAttributes(TGRid *plateID, void *datax, IGRint *stopWalk)
{
  VDASSERT_FN("processPlateAttributes");
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchab family,part_num,material,grade;
  IGRchab buf;
  IGRchar *p;
  
  IGRdouble thickness1;
  IGRdouble thickness2;
  IGRdouble tol;
  
  IGRpoint pt3d1,pt3d2,pt3d3;
  IGRpoint pt2d1,pt2d2,pt2d3;
  IGRint   i;

  IGRdouble *pts;  
  IGRdouble *range;
  IGRdouble *matrix;
  
  // Arg check
  VDASSERTW(plateID && plateID->objid != NULL_OBJID);
  
  // Need these
  VDctxGetTxtAtr(plateID,"PDF_ATR_PIECE_FAMILY",   family);
  VDctxGetTxtAtr(plateID,"PDF_ATR_PIECE_PART_NUM", part_num);
  VDctxGetTxtAtr(plateID,"PDF_ATR_PIECE_MAT_TYPE", material);
  VDctxGetTxtAtr(plateID,"PDF_ATR_PIECE_MAT_GRADE",grade);

  if (*family < ' ') {
    VDvalLogError("Missing plate family");
    goto wrapup;
  }
  if (*part_num < ' ') {
    VDvalLogError("Missing plate part_num");
    goto wrapup;
  }
  if (*material < ' ') {
    VDvalLogError("Missing plate material");
    goto wrapup;
  }
  if (*grade < ' ') {
    VDvalLogError("Missing plate grade");
    goto wrapup;
  }

  // See if material-grade match
  VDvalGetGradeMaterial(grade,buf);
  if (strcmp(material,buf)) {
    VDvalLogError("Invalid grade(%s) material(%s) combination",
	     grade,material);
    goto wrapup;
  }

  // Get the thickness which also validates the part
  sts = VDvalGetPartThickness(family,part_num,material,&thickness1);
  if (sts == 0) {
    VDvalLogError("Invalid family(%s) part_num(%s) material(%s) combination",
	     family,part_num,material);
    goto wrapup;
  }
  VDctxGetDblAtr(plateID,"PDF_ATR_PLATE_THICKNESS",&thickness2);

  VDvalGetTolerance(VDTOL_STANDARD_PLATE_THICKNESS,&tol);

  if (fabs(thickness1 - thickness2) >= tol) {
    VDvalLogError("Invalid plate thickness %.2f, should be %.2f",
	     thickness2,thickness1);
    goto wrapup;
  }
  // The 4x3 matrix
  VDctxGetBinAtr(plateID,"PDF_ATR_PIECE_MATRIX",(void**)&p);
  if ((p == NULL) || (*p == 0)) {
    VDvalLogError("No 4x3 translation matrix");
    goto wrapup;
  }
  matrix = malloc(16 * sizeof(IGRdouble));
  for(i = 0; i < 12; i++) {
    matrix[i] = VDvalParseDouble(&p);
  }
  matrix[12] = matrix[13] = matrix[14] = 0.0;
  matrix[15] = 1.0;
  VDctxAppBinAtr(plateID,"matrix",matrix,NULL);

  // The range just because
  VDctxGetBinAtr(plateID,"PDF_ATR_PIECE_RANGE",(void**)&p);
  if ((p == NULL) || (*p == 0)) {
    VDvalLogError("No piece range");
    goto wrapup;
  }
  range = malloc(6 * sizeof(IGRdouble));
  for(i = 0; i < 6; i++) {
    range[i] = VDvalParseDouble(&p);
  }
  VDctxAppBinAtr(plateID,"range",range,NULL);

  // Save points just for grins
  VDctxGetBinAtr(plateID,"PDF_ATR_PIECE_3D_REF_PTS",(void**)&p);
  if ((p == NULL) || (*p == 0)) {
    VDvalLogError("No 3d reference points");
    goto wrapup;
  }
  pts = malloc(sizeof(IGRdouble) * 9);
  for(i = 0; i < 9; i++) {
    pts[i] = VDvalParseDouble(&p);
  }
  VDctxAppBinAtr(plateID,"pts",pts,NULL);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Routine to validates a spades plate
 */
void processSpadesPlate(TGRid *plateID, void *data, IGRint *stopWalk)
{
  VDASSERT_FN("processSpadesPlate");

  // Init
  VDvalResetLogErrorData();
  
  // Only for plates
  VDASSERTW(plateID && plateID->objid != NULL_OBJID);
  if (!VDctzIsPlate(plateID)) goto wrapup;
  VDvalSetPieceError(plateID);
  
  // Check the attributes, pulling out some good stuff
  processPlateAttributes(plateID,NULL,stopWalk);

  // Process the outer contour
  //VDvalSpadesPlateOuterContour(plateID,info,stopWalk);
  
  // Process the holes
  //VDctxWalkNode(plateID,1,VDvalSpadesPlateHole,info,stopWalk);

  // Bounce the holes against each other
  //validatePlateHoles(plateID,info,stopWalk);
 
  // Done
 wrapup:
  VDvalResetLogErrorData();
  return;
}

/* -----------------------------------------------
 * Main routine
 */
IGRstat VDvalValidateSpadesFilex(IGRchar *fileName, IGRint useMacros, IGRint drawPoints)
{
  VDASSERT_FN("VDvalValidateSpadesFilex");
  
  IGRstat retFlag = 0;
  TGRid   treeID;
  IGRint  stopWalk = 0;
  
  // Init
  treeID.objid = NULL_OBJID;
  
  // Arg check
  VDASSERTW(fileName && *fileName);
  
  // Make the tree
  VDxdomCreateTreeFromXmlFile(fileName,&treeID);
  VDASSERTW(treeID.objid != NULL_OBJID);

  // Walk it
  VDctxWalkNode(&treeID,1,processSpadesPlate,NULL,&stopWalk);

  // Done
  retFlag = 1;
  
 wrapup:
  VDctxDeleteNode(&treeID);
  return retFlag;
}
