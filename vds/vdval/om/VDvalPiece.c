/* $Id: VDvalPiece.c,v 1.10.2.1 2003/06/17 15:28:08 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdval/om/VDvalPiece.c
 *
 * Description: Model Piece Attribute Routines
 *
 * Dependencies:
 *
 * Revision History:
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/15/01  ah      Creation, started with vdcty/rrv/VDrrvTree.c
 * 06/17/03  ah      CR5144 Add plate/web area tolerances for snapshot
 * 11/17/10  ah      SOL10
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDtest.h"

#include "VDlog.h"
#include "VDctx.h"
#include "VDobj2.h"
#include "VDss.h"

#include "VDsys.h"
#include "VDtag.h"

#include "VDval.h"
#include "VDvalLike.h"

VDASSERT_FFN("vdval/om/VDvalPiece.c");

/* -------------------------------------------------
 * Logs a header message for a model error
 */
static void logModelErrHeader(TGRobj_env *modelOE, IGRint *errCnt)
{  
  if (*errCnt == 0) {
    VDlogPrintObject(VDLOG_WARN,1,"*** Problem with ",modelOE,NULL);
  }
  *errCnt = *errCnt + 1;
}

/* -------------------------------------------------
 * These are attributes want from all pieces
 */
static void addPieceTxtAtr(TGRobj_env *modelOE, TGRid *pieceID, 
			   IGRchar *modelAtrName, IGRchar *pieceAtrName, 
			   IGRint *errCnt)
{
  VDASSERT_FN("addPieceTxtAtr");
  IGRstat retFlag = 0;
  
  IGRchab buf;

  VDoeGetTxtAtr(modelOE,modelAtrName,buf);

  VDctxAppTxtAtr(pieceID,pieceAtrName,buf);

  if (*buf == 0) {
    logModelErrHeader(modelOE,errCnt);
    VDlogPrintFmt(VDLOG_WARN,1,"No value for %s",modelAtrName);
  }
  
  retFlag = 1;
  
 wrapup:
  return;
}
  
/* -------------------------------------------------
 * Add's a plate area and planar props
 */
static void addPlateAreaAtr(TGRobj_env *modelOE, TGRid *pieceID, IGRint *errCnt)
{

  TGRobj_env srfOE;
  
  IGRdouble area    = 2000.0;
  IGRdouble areaMin = 500.0;
  IGRint    isPlanar;
  IGRpoint  centerPt;
  
  IGRchar buf[128];
  
  // Get the base surface
  VDobjGetFoot(modelOE,NULL,"plate:base",&srfOE);
  if (srfOE.obj_id.objid == NULL_OBJID) {
    logModelErrHeader(modelOE,errCnt);
    VDlogPrintFmt(VDLOG_WARN,1,"    Cannot get base surface");
    goto wrapup;
  }

  // Planar
  VDgeomGetSurfacePlanarProps(&srfOE,0.0,&isPlanar,NULL,NULL);
  VDctxAppIntAtr(pieceID,VDCTX_ATR_SS_PLATE_IS_PLANAR,isPlanar);

  // Area
  VDgeomGetSurfaceAreaProps(&srfOE,&area,centerPt,NULL);
  VDctxAppDblAtr(pieceID,VDCTX_ATR_SS_PLATE_AREA,area);

  VDvalGetTolerance(VDTOL_MIN_PLATE_AREA,&areaMin);
  if (area < areaMin) {
    logModelErrHeader(modelOE,errCnt);
    VDlogPrintFmt(VDLOG_WARN,1,"    Small plate area %f, min is %f",area,areaMin);
  }
  
  // Center, reduce accuracy since only need this for comparision
  sprintf(buf,"%.2f,%.2f,%.2f",centerPt[0],centerPt[1],centerPt[2]);
  VDctxAppTxtAtr(pieceID,VDCTX_ATR_SS_PLATE_CENTER,buf);
  
 wrapup:
  return;
}

/* -------------------------------------------------
 * Add's a plate thickness making sure it a whole number
 */
static void addPlateThicknessAtr(TGRobj_env *modelOE, TGRid *pieceID, IGRint *errCnt)
{
  IGRchab buf;
  IGRchar *p;

  VDoeGetTxtAtr(modelOE,"plate_thk",buf);
  
  VDctxAppTxtAtr(pieceID,VDCTX_ATR_SS_PLATE_THICKNESS,buf);

  p = strchr(buf,'.');
  if (!p || !strcmp(p,".0")) goto wrapup;

  logModelErrHeader(modelOE,errCnt);
  VDlogPrintFmt(VDLOG_WARN,1,"    Invalid plate thickness %s",buf);
  
 wrapup:
  return;
}

/* -------------------------------------------------
 * Add's a plate's stock/bevel information
 */
static void addPlateBevelAtr(TGRobj_env *modelOE, TGRid *pieceID, IGRint *errCnt)
{
  IGRchab buf;
  
  // Grab em
  VDoeGetTxtAtr(modelOE,"SA_PPL:VSppstock:GetBevelInfo",buf);

  // Take whatever we get
  if (*buf) {
    VDctxAppTxtAtr(pieceID,VDCTX_ATR_SS_PLATE_BEVELS,buf);
  }

 wrapup:
  return;
}
 
/* -------------------------------------------------
 * Plate attributes
 */
IGRstat VDvalAddPlateAttributes(TGRobj_env *modelOE, TGRid *pieceID, IGRint *errCnt, IGRint wantFlag)
{
  VDASSERT_FN("VDvalAddPlateAttributes");
  IGRstat retFlag = 1;
  IGRstat scan;
  
  IGRchab buf;
  IGRchab grade,thick;
  
  // Arg check
  VDASSERTW(modelOE && modelOE->obj_id.objid != NULL_OBJID);
  VDASSERTW(pieceID && pieceID->objid        != NULL_OBJID);
  VDASSERTW(errCnt);
  
  // Look for standard key
  VDvalGetStdPcmk1Key(modelOE,buf);
  if (*buf) {
    VDctxAppTxtAtr(pieceID,VDCTX_ATR_SS_PIECE_PCMK_KEY,buf);
  }

  // Look for geom key
  VDvalGetStdPcmk2Info(modelOE,buf,grade,thick);
  if (*buf) {
    VDctxAppTxtAtr(pieceID,VDCTX_ATR_SS_PIECE_GEOM_KEY,buf);
  }
  
  // Thickness
  addPlateThicknessAtr(modelOE,pieceID,errCnt);

  // Done with the quick scan stuff
  if (wantFlag < VDVAL_DOM_WANT_MED) {
    retFlag = 1;
    goto wrapup;
  }

  // Area
  addPlateAreaAtr(modelOE,pieceID,errCnt);

  // Bevels
  addPlateBevelAtr(modelOE,pieceID,errCnt);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Add's a beam cut length make sure it's at least
 * VDTOL_MIN_CUT_LENGTH long.
 */
static void addBeamLengthAtr(TGRobj_env *modelOE, TGRid *pieceID, IGRint *errCnt)
{
  IGRchab buf;
  IGRdouble minCutLength = 10.0;

  VDoeGetTxtAtr(modelOE,"memb_cut_leng",buf);

  VDctxAppTxtAtr(pieceID,VDCTX_ATR_SS_BEAM_CUT_LENGTH,buf);

  VDvalGetTolerance(VDTOL_MIN_CUT_LENGTH,&minCutLength);
  if (atof(buf) >= minCutLength) goto wrapup;
    
  logModelErrHeader(modelOE,errCnt);
  VDlogPrintFmt(VDLOG_WARN,1,"    Invalid beam length %s",buf);
  
 wrapup:
  return;
}

/* -------------------------------------------------
 * Add's a beam end treatment information
 */
static void addBeamTreatmentAtr(TGRobj_env *modelOE, TGRid *pieceID, IGRint *errCnt)
{
  IGRchab buf;
  
  // Grab em
  VDoeGetTxtAtr(modelOE,"end_treats",buf);

  // Take whatever we get
  VDctxAppTxtAtr(pieceID,VDCTX_ATR_SS_BEAM_TREATMENTS,buf);

  // Is it ok not to have end treatments?
  // logModelErrHeader(modelOE,errCnt);
  // VDlogPrintFmt(VDLOG_WARN,1,"    Invalid beam treatment information %s",buf);
  
 wrapup:
  return;
}
/* -------------------------------------------------
 * Add's a beam stock information
 */
static void addBeamStockAtr(TGRobj_env *modelOE, TGRid *pieceID, IGRint *errCnt)
{
  IGRchab buf;
  
  // Grab em
  VDoeGetTxtAtr(modelOE,"SA_PPL:VSppstock:GetStockInfo",buf);

  // Take whatever we get
  if (*buf) {
    VDctxAppTxtAtr(pieceID,VDCTX_ATR_SS_BEAM_STOCKS,buf);
  }

 wrapup:
  return;
}
   
/* -------------------------------------------------
 * Beam attributes
 */
IGRstat VDvalAddBeamAttributes(TGRobj_env *modelOE, TGRid *pieceID, IGRint *errCnt, IGRint wantFlag)
{
  VDASSERT_FN("VDrrvAddBeamAttributes");
  IGRstat retFlag = 1;
  IGRstat scan;
  
  IGRchab buf;

  TGRobj_env srfOE;
  IGRint     isPlanar;
  IGRdouble  area;
  IGRdouble  minArea = 500.0;
  IGRpoint   centerPt;
  
  // Arg check
  VDASSERTW(modelOE && modelOE->obj_id.objid != NULL_OBJID);
  VDASSERTW(pieceID && pieceID->objid        != NULL_OBJID);
  VDASSERTW(errCnt);

  addPieceTxtAtr(modelOE,pieceID,"x_Height",       VDCTX_ATR_SS_BEAM_HEIGHT, errCnt);
  addPieceTxtAtr(modelOE,pieceID,"x_Web_Thickness",VDCTX_ATR_SS_BEAM_WEB_THK,errCnt);

  // Done with the quick scan stuff
  if (wantFlag < VDVAL_DOM_WANT_MED) {
    retFlag = 1;
    goto wrapup;
  }
  
  addBeamTreatmentAtr(modelOE,pieceID,errCnt);  
  addBeamStockAtr    (modelOE,pieceID,errCnt);  
  addBeamLengthAtr   (modelOE,pieceID,errCnt);  

  // Need left web
  VDobjGetFoot(modelOE,NULL,"beam:body:web_____l",&srfOE);
  if (srfOE.obj_id.objid == NULL_OBJID) {
    logModelErrHeader(modelOE,errCnt);
    VDlogPrintFmt(VDLOG_WARN,1,"    Cannot get left web");
    goto wrapup;
  }

  // Planar
  VDgeomGetSurfacePlanarProps(&srfOE,0.0,&isPlanar,NULL,NULL);
  VDctxAppIntAtr(pieceID,VDCTX_ATR_SS_BEAM_IS_PLANAR,isPlanar);

  // Area
  VDgeomGetSurfaceAreaProps(&srfOE,&area,centerPt,NULL);
  VDctxAppDblAtr(pieceID,VDCTX_ATR_SS_BEAM_AREA,area);

  VDvalGetTolerance(VDTOL_MIN_WEB_AREA,&minArea);
  if (area < minArea) {  
    logModelErrHeader(modelOE,errCnt);
    VDlogPrintFmt(VDLOG_WARN,1,"    Small beam left web area %f, min is %f",area,minArea);
  }

  // Center, reduce accuracy since only need this for comparision
  sprintf(buf,"%.2f,%.2f,%.2f",centerPt[0],centerPt[1],centerPt[2]);
  VDctxAppTxtAtr(pieceID,VDCTX_ATR_SS_BEAM_CENTER,buf);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}
 
/* -------------------------------------------------
 * These are attributes want from all pieces
 */
IGRstat VDvalAddPieceAttributes(TGRobj_env *modelOE, TGRid *pieceID, IGRint *errCnt, IGRint wantFlag)
{
  VDASSERT_FN("VDrrvAddPieceAttributes");
  IGRstat retFlag = 1;
  IGRstat sts;
  
  IGRchab buf;
  
  // Arg check
  VDASSERTW(modelOE && modelOE->obj_id.objid != NULL_OBJID);
  VDASSERTW(pieceID && pieceID->objid        != NULL_OBJID);
  VDASSERTW(errCnt);
  
  // Component path is one way to access the object
  sts = VDvalAddModelCompPathAttribute(modelOE,pieceID);
  if (!(sts & 1)) *errCnt = *errCnt + 1;
  
  // Another is through tag information
  VDvalAddModelTagAttribute(modelOE,pieceID);
  if (!(sts & 1)) *errCnt = *errCnt + 1;
  
  // Symbology is always nice
  VDvalAddModelSymbologyAttribute(modelOE,pieceID);
  if (!(sts & 1)) *errCnt = *errCnt + 1;
    
  // Just pull em out (need some error checking here)
  addPieceTxtAtr(modelOE,pieceID,"family_name",VDCTX_ATR_SS_PIECE_FAMILY,  errCnt);
  addPieceTxtAtr(modelOE,pieceID,"part_num",   VDCTX_ATR_SS_PIECE_PART_NUM,errCnt);
  addPieceTxtAtr(modelOE,pieceID,"material",   VDCTX_ATR_SS_PIECE_MATERIAL,errCnt);
  addPieceTxtAtr(modelOE,pieceID,"grade",      VDCTX_ATR_SS_PIECE_GRADE,   errCnt);

  // Validate the combo of family,part,grade and material

  /* ---------------------------------------------
   * For now, ignore most user attributes,
   * Maybe later grab them all but need to think about
   * it first
   *
   * However, "reserved" is one attribute specifically requested
   */
  VDoeGetTxtAtr(modelOE,"reserved",buf);
  VDctxAppTxtAtr(pieceID,VDCTX_ATR_SS_PIECE_RESERVED,buf);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/******************************************************************yyyy*/
/* -------------------------------------------------
 * These are attributes want from all bevels, pens or pcgs
 */
static void addNodeTxtAtr(	TGRobj_env	*modelOE, 
				TGRid		*pieceID, 
				IGRchar		*collName,
				IGRchar		*modelAtrName,
				IGRchar		*pieceAtrName, 
				IGRint		*errCnt)
{
  VDASSERT_FN("addNodeTxtAtr");
  
  IGRchab	buf;
  TGRobj_env	collOE;

  VDASSERTW(*collName != 0);

  collOE.obj_id.objid = NULL_OBJID;
  VDobjGetFoot(modelOE,NULL,collName,&collOE);
  VDASSERTW(collOE.obj_id.objid != NULL_OBJID);

  VDSGetAttTxt(&collOE.obj_id, modelAtrName, buf);

  VDctxAppTxtAtr(pieceID,pieceAtrName,buf);

  if (*buf == 0) {
    logModelErrHeader(modelOE,errCnt);
    VDlogPrintFmt(VDLOG_WARN,1,"No value for %s",modelAtrName);
  }
  
wrapup:
  return;
}

/* -------------------------------------------------
 * These are attributes want from all bevels, pens or pcgs
 */
static void addNodeDblAtr(	TGRobj_env	*modelOE, 
				TGRid		*pieceID, 
				IGRchar		*collName,
				IGRchar		*modelAtrName, 
				IGRchar		*pieceAtrName, 
				IGRint		*errCnt)
{
  VDASSERT_FN("addObjTxtAtr");

  IGRdouble	value; 
  IGRchab	buf;
  TGRobj_env	collOE;

  VDASSERTW(*collName != 0);

  collOE.obj_id.objid = NULL_OBJID;
  VDobjGetFoot(modelOE,NULL,collName,&collOE);
  VDASSERTW(collOE.obj_id.objid != NULL_OBJID);

  VDSGetAttDbl(&collOE.obj_id, modelAtrName, &value);

  sprintf( buf, "%g", value );
  VDctxAppTxtAtr(pieceID,pieceAtrName,buf);

  if (*buf == 0) {
    logModelErrHeader(modelOE,errCnt);
    VDlogPrintFmt(VDLOG_WARN,1,"No value for %s",modelAtrName);
  }
  
 wrapup:
  return;
}
  

/* -------------------------------------------------
 * These are attributes want from all bevels, pens or pcgs
 */
IGRstat VDvalAddBevelAttributes(TGRobj_env *modelOE, TGRid *pieceID, IGRint *errCnt, IGRint wantFlag)
{
  VDASSERT_FN("VDvalAddBevelAttributes");
  IGRstat	retFlag = 1;
  IGRstat	sts;
  
  // Arg check
  VDASSERTW(modelOE && modelOE->obj_id.objid != NULL_OBJID);
  VDASSERTW(pieceID && pieceID->objid        != NULL_OBJID);
  VDASSERTW(errCnt);
  
  // Component path is one way to access the object
  sts = VDvalAddModelCompPathAttribute(modelOE,pieceID);
  if (!(sts & 1)) *errCnt = *errCnt + 1;
  
  // Another is through tag information
  sts = VDvalAddModelTagAttribute(modelOE,pieceID);
  if (!(sts & 1)) *errCnt = *errCnt + 1;
  
  // Symbology is always nice
  VDvalAddModelSymbologyAttribute(modelOE,pieceID);
  if (!(sts & 1)) *errCnt = *errCnt + 1;
    
  // Just pull bevel attributes out
  addNodeTxtAtr (	modelOE,pieceID,
			"attributes", 
			"macro_type",
			VDCTX_ATR_SS_BEVEL_MACRO_TYPE, errCnt);
  addNodeTxtAtr(	modelOE,pieceID,
			"attributes", 
			"bevel_type",
			VDCTX_ATR_SS_BEVEL_BEVEL_TYPE, errCnt);
  addNodeTxtAtr(	modelOE,
			pieceID,
			"attributes", 
			"process_type",
			VDCTX_ATR_SS_BEVEL_PROCESS_TYPE, errCnt);
  addNodeDblAtr(	modelOE,
			pieceID,
			"attributes", 
			"stock_value",
			VDCTX_ATR_SS_BEVEL_STOCK_VALUE, errCnt);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Get penetration shape
 */
static void getPenShape( TGRobj_env *modelOE, IGRchar *shape )
{
  VDASSERT_FN("getPenShape");
  IGRchab	buf;
  TGRobj_env	collOE;

  VDASSERTW(shape != NULL);
  *shape = 0; 

  collOE.obj_id.objid = NULL_OBJID;
  VDobjGetFoot(modelOE,NULL,"Attributes",&collOE);
  VDASSERTW(collOE.obj_id.objid != NULL_OBJID);

  VDSGetAttTxt(&collOE.obj_id, "macro_name", buf);
  VDASSERTW(*buf != 0);

  strcpy( shape, buf );

wrapup:
  return;
}

/* -------------------------------------------------
 * These are attributes want from all pens and pcgs
 */
IGRstat VDvalAddPenAttributes(TGRobj_env *modelOE, TGRid *pieceID, IGRint *errCnt, IGRint wantFlag)
{
  VDASSERT_FN("VDvalAddPenAttributes");
  IGRstat	retFlag = 1;
  IGRstat	sts;
  IGRchab	macName, shape;

  // Arg check
  VDASSERTW(modelOE && modelOE->obj_id.objid != NULL_OBJID);
  VDASSERTW(pieceID && pieceID->objid        != NULL_OBJID);
  VDASSERTW(errCnt);
  
  // Component path is one way to access the object
  sts = VDvalAddModelCompPathAttribute(modelOE,pieceID);
  if (!(sts & 1)) *errCnt = *errCnt + 1;
  
  // Another is through tag information
  sts = VDvalAddModelTagAttribute(modelOE,pieceID);
  if (!(sts & 1)) *errCnt = *errCnt + 1;
  
  // Symbology is always nice
  VDvalAddModelSymbologyAttribute(modelOE,pieceID);
  if (!(sts & 1)) *errCnt = *errCnt + 1;
    
  VDobjGetMacroName(modelOE, NULL, macName);
  
     /*
      Pen Shape		geom parameters
      rd		diameter
      rh		radius
      fo		width, depth
      el		width, depth
      rt		width, depth
      rc		width, depth, radius_corner
     */
  getPenShape(modelOE, shape);

  // Just pull pen or pcg attributes out
  if( !strcmp(macName, "penMacro") ) {
     addNodeTxtAtr (	modelOE,
			pieceID,
			"Attributes",
			"CoordSystem",
			VDCTX_ATR_SS_PEN_CS,  errCnt);
     addNodeTxtAtr (	modelOE,
			pieceID,
			"Attributes",
			"compartment",
			VDCTX_ATR_SS_PEN_COMPARTMENT,  errCnt);
     addNodeTxtAtr (	modelOE,
			pieceID,
			"Attributes",
			"revision",
			VDCTX_ATR_SS_PEN_REVISION,  errCnt);
     addNodeTxtAtr (	modelOE,
			pieceID,
			"Attributes",
			"macro_lib",
			VDCTX_ATR_SS_PEN_MACRO_LIB,  errCnt);
     addNodeTxtAtr (	modelOE,
			pieceID,
			"Attributes",
			"shape",
			VDCTX_ATR_SS_PEN_SHAPE,  errCnt);
     addNodeTxtAtr (	modelOE,
			pieceID,
			"Attributes",
			"type",
			VDCTX_ATR_SS_PEN_TYPE,  errCnt);
     addNodeTxtAtr (	modelOE,
			pieceID,
			"Attributes",
			"structure_to_cut",
			VDCTX_ATR_SS_PEN_STRUCT_CUT,  errCnt);
     addNodeTxtAtr (	modelOE,
			pieceID,
			"Attributes",
			"long_axis",
			VDCTX_ATR_SS_PEN_LONG_AXIS,  errCnt);
     addNodeTxtAtr (	modelOE,
			pieceID,
			"Attributes",
			"description",
			VDCTX_ATR_SS_PEN_DESCRIPTION,  errCnt);
     addNodeTxtAtr (	modelOE,
			pieceID,
			"Attributes",
			"macro_name",
			VDCTX_ATR_SS_PEN_SHAPE_MACRO,  errCnt);

     if( !strcmp(shape, "rd") ) {
        addNodeDblAtr (	modelOE,
			pieceID,
			"Attributes",
			"diameter",
			VDCTX_ATR_SS_PEN_SHAPE_DIAMETER,  errCnt);
     }
     else if( !strcmp( shape, "rh") ) {
        addNodeDblAtr (	modelOE,
			pieceID,
			"Attributes",
			"radius",
			VDCTX_ATR_SS_PEN_SHAPE_RADIUS,  errCnt);
     }
     else {
        addNodeDblAtr (	modelOE,
			pieceID,
			"Attributes",
			"width",
			VDCTX_ATR_SS_PEN_SHAPE_WIDTH,  errCnt);

        addNodeDblAtr (	modelOE,
			pieceID,
			"Attributes",
			"depth",
			VDCTX_ATR_SS_PEN_SHAPE_DEPTH,  errCnt);
	if( !strcmp( shape, "rc") ) {
             addNodeDblAtr (	modelOE,
				pieceID,
				"Attributes",
				"radius_corner",
				VDCTX_ATR_SS_PEN_SHAPE_RAD_CORN,  errCnt);
	}
     }
  }      // end of penMacro
  else { // begin pcgMacro
     addNodeTxtAtr (	modelOE,
			pieceID,
			"Attributes",
			"Approval",
			VDCTX_ATR_SS_PCG_APPROVAL,  errCnt);
     addNodeTxtAtr (	modelOE,
			pieceID,
			"Attributes",
			"PenetrationName",
			VDCTX_ATR_SS_PCG_PEN_NAME,  errCnt);
     addNodeTxtAtr (	modelOE,
			pieceID,
			"Attributes",
			"FwdAftPlane",
			VDCTX_ATR_SS_PCG_FA_PLANE,  errCnt);
     addNodeDblAtr (	modelOE,
			pieceID,
			"Attributes",
			"FwdAftValue",
			VDCTX_ATR_SS_PCG_FA_VALUE,  errCnt);
     addNodeTxtAtr (	modelOE,
			pieceID,
			"Attributes",
			"ReferenceDeck",
			VDCTX_ATR_SS_PCG_REF_DECK,  errCnt);
     addNodeTxtAtr (	modelOE,
			pieceID,
			"Attributes",
			"CutType",
			VDCTX_ATR_SS_PCG_CUT_TYPE,  errCnt);
     addNodeDblAtr (	modelOE,
			pieceID,
			"Attributes",
			"Vertical_ABL",
			VDCTX_ATR_SS_PCG_VERTICAL_ABL,  errCnt);
     addNodeTxtAtr (	modelOE,
			pieceID,
			"Attributes",
			"Vertical_XorY",
			VDCTX_ATR_SS_PCG_VERTICAL_XY,  errCnt);
     addNodeTxtAtr (	modelOE,
			pieceID,
			"Attributes",
			"CoordSystem",
			VDCTX_ATR_SS_PCG_CS,  errCnt);
     addNodeTxtAtr (	modelOE,
			pieceID,
			"Attributes",
			"compartment",
			VDCTX_ATR_SS_PCG_COMPARTMENT, errCnt);
     addNodeTxtAtr (	modelOE,
			pieceID,
			"Attributes",
			"revision",
			VDCTX_ATR_SS_PCG_REVISION, errCnt);
     addNodeTxtAtr (	modelOE,
			pieceID,
			"Attributes",
			"macro_lib",
			VDCTX_ATR_SS_PCG_MACRO_LIB, errCnt);
     addNodeTxtAtr (	modelOE,
			pieceID,
			"Attributes",
			"shape",
			VDCTX_ATR_SS_PCG_SHAPE, errCnt);
     addNodeTxtAtr (	modelOE,
			pieceID,
			"Attributes",
			"type",
			VDCTX_ATR_SS_PCG_TYPE, errCnt);
     addNodeTxtAtr (	modelOE,
			pieceID,
			"Attributes",
			"structure_to_cut",
			VDCTX_ATR_SS_PCG_STRUCT_CUT, errCnt);
     addNodeTxtAtr (	modelOE,
			pieceID,
			"Attributes",
			"long_axis",
			VDCTX_ATR_SS_PCG_LONG_AXIS, errCnt);
     addNodeTxtAtr (	modelOE,
			pieceID,
			"Attributes",
			"description",
			VDCTX_ATR_SS_PCG_DESCRIPTION, errCnt);
     addNodeTxtAtr (	modelOE,
			pieceID,
			"Attributes",
			"macro_name",
			VDCTX_ATR_SS_PCG_SHAPE_MACRO, errCnt);

     if( !strcmp( shape, "rd") ) {
        addNodeDblAtr (	modelOE,
			pieceID,
			"Attributes",
			"diameter",
			VDCTX_ATR_SS_PCG_SHAPE_DIAMETER,  errCnt);
     }
     else if( !strcmp( shape, "rh") ) {
        addNodeDblAtr (	modelOE,
			pieceID,
			"Attributes",
			"radius",
			VDCTX_ATR_SS_PCG_SHAPE_RADIUS,  errCnt);
     }
     else {
        addNodeDblAtr (	modelOE,
			pieceID,
			"Attributes",
			"width",
			VDCTX_ATR_SS_PCG_SHAPE_WIDTH,  errCnt);

        addNodeDblAtr (	modelOE,
			pieceID,
			"Attributes",
			"depth",
			VDCTX_ATR_SS_PCG_SHAPE_DEPTH,  errCnt);
	if( !strcmp( shape, "rc") ) {
             addNodeDblAtr (	modelOE,
				pieceID,
				"Attributes",
				"radius_corner",
				VDCTX_ATR_SS_PCG_SHAPE_RAD_CORN,  errCnt);
	}
     }
  }


  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}
