/* $Id: VDefp.h,v 1.4 2001/03/18 22:38:52 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/include/VDefp.h
 *
 * Description: Extract For Production
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDefp.h,v $
 *      Revision 1.4  2001/03/18 22:38:52  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/03/16 16:49:33  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/01/10 15:38:12  art
 *      ah
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.3  2000/11/27  16:25:18  pinnacle
 * ah
 *
 * Revision 1.2  2000/06/19  18:06:20  pinnacle
 * ah
 *
 * Revision 1.1  2000/04/28  20:23:00  pinnacle
 * ah
 *
 * Revision 1.4  2000/03/27  21:26:20  pinnacle
 * ah
 *
 * Revision 1.3  2000/02/25  18:22:02  pinnacle
 * ah
 *
 * Revision 1.2  1999/10/26  18:02:56  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 10/26/99  ah      Added Header
 * 01/10/01  ah      sp merge
 * 03/18/01  ah      Move all the surface transformation stiff to VDefpSrf.h
 ***************************************************************************/
#ifndef VDefp_include
#define VDefp_include 1

#ifndef   VDgeom_include
#include "VDgeom.h"
#endif

// C stuff
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* ------------------------------------------------
 * Trace Flags
 */
extern IGRint VDefpSetTraceFlag __((IGRint traceFlag, IGRint traceValue));
extern IGRint VDefpGetTraceFlag __((IGRint traceFlag));

#define VDEFP_TRACE_PLACE_MACRO        50
#define VDEFP_TRACE_COMPUTE_NEAT       51
#define VDEFP_TRACE_COMPUTE_EFP_BEAM   52
#define VDEFP_TRACE_COMPUTE_DATUM_MARK 53
#define VDEFP_TRACE_VERIFY_PIECE       54
#define VDEFP_TRACE_COMPUTE_EFP_BEAM2D 55

/* ----------------------------------------------
 * neat macro information
 */
#define VDEFP_LIB_NAME "VDefp"

#define VDEFP_NAT_EDGES_MAX  200
#define VDEFP_NEAT_EDGES_MAX 100

#define VDEFP_NAT_EDGE_MACRO_NAME    "nat_edge"
#define VDEFP_NEAT_SURF_MACRO_NAME   "neat_surf"
#define VDEFP_NEAT_PLATE_MACRO_NAME  "neat_plate"
#define VDEFP_NEAT_PLATEO_MACRO_NAME "neat_plateo"

extern IGRstat VDefpComputeNeatEdges __((TGRobj_env *macOE,
                                         IGRint      opFlag,
                                         IGRint     *edgeCnt,
                                         TGRid      *edgeIDs));

extern IGRstat VDefpComputeNatEdges __((TGRobj_env *macOE,
					IGRint      opFlag,
					IGRint     *edgeCnt,
					TGRid      *edgeIDs));

extern IGRstat VDefpGetSurfaceCenter __((TGRobj_env *srfOE,
                                         IGRdouble  *centerPT));

extern IGRstat VDefpAppendEdgeBsp __((TGRbsp_curve *bsp, 
                                      IGRint        bspMax,
                                      IGRdouble     tol, 
				      IGRint        breakCusps,
                                      IGRint       *bspCnt,
                                      TGRbsp_curve **bsps));

extern IGRstat VDefpGetSurfaceEdgeBsps __((TGRobj_env    *srfOE,
                                           IGRint         edgeMax,
                                           IGRdouble      tol, 
                                           IGRint        *edgeCnt,
                                           TGRbsp_curve **edgeBSPs));

/* ----------------------------------------------
 * Datum Mark Macro
 */
#define VDEFP_DATUM_MARK_MACRO_NAME  "datum_mark"
#define VDEFP_DATUM_MARK_FOOT_NAME   "mark"
#define VDEFP_DATUM_MARK_FOOT_MAX     100

#define VDEFP_DATUM_MARK_PARENT_PIECE 0
#define VDEFP_DATUM_MARK_PARENT_PLANE 1

extern IGRstat VDefpComputeDatumMark __((TGRobj_env *macOE,
                                         IGRint      opFlag,
                                         IGRint     *markCnt,
                                         TGRid      *markIDs));

/* ----------------------------------------------
 * EFP Beam Macro
 */
#define VDEFP_EFP_BEAM_MACRO_NAME  "efp_beam"
#define VDEFP_EFP_BEAM_FOOT_NAME   "pt"
#define VDEFP_EFP_BEAM_FOOT_MAX     6

#define VDEFP_EFP_BEAM_PARENT_BEAM 0

extern IGRstat VSefpComputeEfpBeam __((TGRobj_env *macOE,
				       IGRint      opFlag,
				       IGRint     *feetCnt,
				       TGRid      *feetIDs));

/* ----------------------------------------------
 * EFP Beam Macro 2D version
 */
#define VDEFP_EFP_BEAM2D_MACRO_NAME  "efp_beam2d"
#define VDEFP_EFP_BEAM2D_FOOT_NAME   "contour"
#define VDEFP_EFP_BEAM2D_FOOT_MAX     6

#define VDEFP_EFP_BEAM2D_PARENT_BEAM 0
#define VDEFP_EFP_BEAM2D_PARENT_CS   1

extern IGRstat VSefpComputeEfpBeam2D __((TGRobj_env *macOE,
					 IGRint      opFlag,
					 IGRint     *feetCnt,
					 TGRid      *feetIDs));

/* ---------------------------------------------------------
 * Couple of names from struct
 */
#define VDEFP_PLATE_OFFSET_SURF_NAME "plate:offset"
#define VDEFP_PLATE_BASE_SURF_NAME   "plate:base"
#define VDEFP_BEAM_WEB_LEFT_NAME     "beam:body:web_____l"
#define VDEFP_BEAM_TOP_FLANGE_NAME   "beam:body:flg_sup_e"
#define VDEFP_BEAM_BOT_FLANGE_NAME   "beam:body:flg_inf_e"

/* ---------------------------------------------------------
 * Generic place macros with sort of trans table
 */
extern IGRstat VDefpPlaceMacro
__((IGRchar    *libName,
    IGRchar    *macName,
    IGRint      macOpts,
    IGRint      tplCnt,
    TGRobj_env *tplOEs,
    TGRobj_env *macOE));

#omdef vdefp$PlaceMacro(libName = VDEFP_LIB_NAME,
		        macName,
                        macOpts = 0,
                        tplCnt  = 1,
                        tplOEs,
                        macOE)

VDefpPlaceMacro((libName),(macName),(macOpts),(tplCnt),(tplOEs),(macOE))
#endomdef

/* ---------------------------------------------------------
 * Look for attached macros
 */
extern IGRstat VDefpIsMacroAttached
__((IGRchar    *macName,
    TGRid      *macID,
    VDosnum     macOS,
    IGRint      tplCnt,
    TGRobj_env *tplOEs,
    TGRobj_env *macOE));

#omdef vdefp$IsMacroAttached(macName,
                             macID,
		             macOS  = OM_K_NOT_AN_OS,
                             tplCnt = 1,
                             tplOEs,
                             macOE  = NULL)

VDefpIsMacroAttached((macName),(macID),(macOS),(tplCnt),(tplOEs),(macOE))
#endomdef

extern IGRstat VDefpGetAttachedMacro
__((IGRchar    *macName,
    VDosnum     macOS,
    IGRint      tplCnt,
    TGRobj_env *tplOEs,
    IGRint      treeFlag,
    TGRobj_env *macOE));

#omdef vdefp$GetAttachedMacro(macName,
		              macOS    = OM_K_NOT_AN_OS,
                              tplCnt   = 1,
                              tplOEs,
                              treeFlag = 0,
                              macOE    = NULL)

VDefpGetAttachedMacro((macName),(macOS),(tplCnt),(tplOEs),(treeFlag),(macOE))
#endomdef

/* ---------------------------------------------
 * VDefpCrvLens.I
 * Trouble shoot curve length code
 */
#define VDEFP_CRV_LENS_MACRO_NAME  "crv_lens"
#define VDEFP_CRV_LENS_FOOT_NAME   "len"
#define VDEFP_CRV_LENS_FOOT_MAX     300

#define VDEFP_CRV_LENS_PARENT_CRV 0
#define VDEFP_CRV_LENS_PARENT_EXP 1

extern IGRstat VDefpComputeCrvLens __((TGRobj_env *macOE,
				       IGRint      opFlag,
				       IGRint     *cnt,
				       TGRid      *ids));

/* ---------------------------------------------
 * Show production knots
 */
#define VDEFP_CRV_KNOTS_MACRO_NAME  "crv_knots"
#define VDEFP_CRV_KNOTS_FOOT_NAME   "knot"
#define VDEFP_CRV_KNOTS_FOOT_MAX     300

#define VDEFP_CRV_KNOTS_PARENT_CRV 0

extern IGRstat VDefpComputeCrvKnots __((TGRobj_env *macOE,
					IGRint      opFlag,
					IGRint     *cnt,
					TGRid      *ids));

/* ---------------------------------------------
 * VDefpCrvLens.I
 * Show center of curve
 */
#define VDEFP_CRV_CENTER_MACRO_NAME  "crv_center"
#define VDEFP_CRV_CENTER_FOOT_NAME   "center"
#define VDEFP_CRV_CENTER_FOOT_MAX     1

#define VDEFP_CRV_CENTER_PARENT_CRV 0

extern IGRstat VDefpComputeCrvCenter __((TGRobj_env *macOE,
					 IGRint      opFlag,
					 IGRint     *cnt,
					 TGRid      *ids));

/* ---------------------------------------------
 * VDefpCrvLens.I
 * Show axis of curve
 */
#define VDEFP_CRV_AXIS_MACRO_NAME  "crv_axis"
#define VDEFP_CRV_AXIS_FOOT_NAME1  "center"
#define VDEFP_CRV_AXIS_FOOT_NAME2  "major"
#define VDEFP_CRV_AXIS_FOOT_NAME3  "minor"
#define VDEFP_CRV_AXIS_FOOT_MAX    3

#define VDEFP_CRV_AXIS_PARENT_CRV  0

extern IGRstat VDefpComputeCrvAxis __((TGRobj_env *macOE,
				       IGRint      opFlag,
				       IGRint     *cnt,
				       TGRid      *ids));

/* ---------------------------------------------
 * VDefpCrvLens.I
 * Show expansion of curve
 */
#define VDEFP_CRV_EXPAND_MACRO_NAME  "crv_expand"
#define VDEFP_CRV_EXPAND_FOOT_NAME   "curve"
#define VDEFP_CRV_EXPAND_FOOT_MAX    1

#define VDEFP_CRV_EXPAND_PARENT_CRV  0
#define VDEFP_CRV_EXPAND_PARENT_EXP  1

extern IGRstat VDefpComputeCrvExpand __((TGRobj_env *macOE,
					 IGRint      opFlag,
					 IGRint     *cnt,
					 TGRid      *ids));

/* ---------------------------------------------
 * VDefpCrvTran.I
 * Debug translation of curves
 */
#define VDEFP_CRV_TRAN_MACRO_NAME       "crv_tran"

#define VDEFP_CRV_TRAN_FOOT_NAME_CURVE  "curve"
#define VDEFP_CRV_TRAN_FOOT_NAME_CENTER "center"
#define VDEFP_CRV_TRAN_FOOT_NAME_MINOR  "minor"
#define VDEFP_CRV_TRAN_FOOT_NAME_MAJOR  "major"
#define VDEFP_CRV_TRAN_FOOT_NAME_TOP_FLANGE  "topFlangeEdge"
#define VDEFP_CRV_TRAN_FOOT_NAME_BOT_FLANGE  "botFlangeEdge"

#define VDEFP_CRV_TRAN_FOOT_IDX_CURVE      0
#define VDEFP_CRV_TRAN_FOOT_IDX_CENTER     1
#define VDEFP_CRV_TRAN_FOOT_IDX_MINOR      2
#define VDEFP_CRV_TRAN_FOOT_IDX_MAJOR      3
#define VDEFP_CRV_TRAN_FOOT_IDX_TOP_FLANGE 4 
#define VDEFP_CRV_TRAN_FOOT_IDX_BOT_FLANGE 5 

#define VDEFP_CRV_TRAN_FOOT_MAX    24

#define VDEFP_CRV_TRAN_TEMP_NAME_PLATE_BEAM "plate/beam"

#define VDEFP_CRV_TRAN_TEMP_IDX_PLATE  0

#define VDEFP_CRV_TRAN_TEMP_MAX   1

extern IGRstat VDefpComputeCrvTran __((TGRobj_env *macOE,
				       IGRint      opFlag,
				       IGRint     *cnt,
				       TGRid      *ids));


/* -----------------------------------------------
 * Compares two plates
 */
#define VDEFP_CRV_TRAN2_MACRO_NAME        "crv_tran2"

#define VDEFP_CRV_TRAN2_FOOT_NAME_CURVE1  "curve1"
#define VDEFP_CRV_TRAN2_FOOT_NAME_CURVE2  "curve2"
#define VDEFP_CRV_TRAN2_FOOT_NAME_CURVEX  "curvex"
#define VDEFP_CRV_TRAN2_FOOT_NAME_INFO    "info"

#define VDEFP_CRV_TRAN2_FOOT_IDX_CURVE1 0
#define VDEFP_CRV_TRAN2_FOOT_IDX_CURVE2 1
#define VDEFP_CRV_TRAN2_FOOT_IDX_INFO   2
#define VDEFP_CRV_TRAN2_FOOT_IDX_CURVEX 3

#define VDEFP_CRV_TRAN2_FOOT_MAX    4

#define VDEFP_CRV_TRAN2_TEMP_NAME_PLATE1 "plate1"
#define VDEFP_CRV_TRAN2_TEMP_NAME_PLATE2 "plate2"

#define VDEFP_CRV_TRAN2_TEMP_IDX_PLATE1  0
#define VDEFP_CRV_TRAN2_TEMP_IDX_PLATE2  1

#define VDEFP_CRV_TRAN2_TEMP_MAX   2

extern IGRstat VDefpComputeCrvTran2 __((TGRobj_env *macOE,
					IGRint      opFlag,
					IGRint     *cnt,
					TGRid      *ids));

/* -----------------------------------------------
 * Transformation information
 */
typedef struct {

  /*
   * 0 - Plate ; 1 - Beam ;
   */ 
  IGRboolean pieceFlag;   

  /*
   * Piece ID (plate or a beam) and 
   * (plate surface or beam left web)
   */ 
  TGRobj_env pieceOE;
  TGRobj_env srfOE;

  /* 
   * This is a single outer contour bspline made from
   * neat edges for (plate surface or beam left web)
   */   
  TGRbsp_curve *edgeBsp;

  IGRdouble edgeLen;

  IGRdouble center_minor_distance;
  IGRdouble center_major_distance;
  IGRdouble  minor_major_distance;

  IGRpoint center;
  IGRpoint major;
  IGRpoint minor;
  
  IGRvector center_major_vec;
  IGRvector center_minor_vec;
  IGRvector normal;
  IGRdouble angle;
  
  /* 
   * These are the neat contour edges  
   * for (plate surface or beam left web)
   */   
  TGRbsp_curve *edgeBsps[VDEFP_NEAT_EDGES_MAX];
  IGRint        edgeCnt;
  
 
  /* 
   * Inner closed contour edges
   * for Plate's surface or beam's leftWeb 
   */
  TGRbsp_curve *innerCtrBsps[VDEFP_NEAT_EDGES_MAX];
  IGRint        innerContourCnt;


  /* 
   * Top and Bottom flanges for the beams 
   * The neat contour for the flanges will be merged
   * to give a single edge for comparison 
   */
  TGRbsp_curve *flangeBsps[2];

  TGRbsp_curve *otherBsps;
  IGRint        otherCnt;
  
} TVDefpTranInfo;

extern IGRstat VDefpGetPieceTranInfo     __((TGRobj_env     *pieceOE,
					    TVDefpTranInfo *info));
extern IGRstat VDefpGetTranInfoForPlate  __((TGRobj_env     *plateOE,
					    TVDefpTranInfo *info));
extern IGRstat VDefpGetPieceSpecificInfo __((TGRobj_env     *pieceOE,
                                             TVDefpTranInfo *info));

extern IGRstat VDefpInitializeTranInfo __((TVDefpTranInfo *info));
extern IGRstat VDefpFreeTranInfo       __((TVDefpTranInfo *info));

/* -----------------------------------------------
 * vdefp/VDefpLike.I
 */
extern IGRstat VDefpComparePlates2 __((IGRdouble       bs_tol,
				       TVDefpTranInfo *info1,
				       TVDefpTranInfo *info2,
				       TVDgeomMat3x3   mat));

extern IGRstat VDefpComparePlates1 __((IGRdouble       bs_tol,
				       TVDefpTranInfo *info1,
				       TVDefpTranInfo *info2,
				       IGRdouble       minorPar,
				       IGRpoint        minorPt,
				       IGRdouble       minorMajorLen,
				       TVDgeomMat3x3   mat));

extern IGRstat VDefpComparePlates  __((IGRdouble      bs_tol,
				       TVDefpTranInfo *info1,
				       TVDefpTranInfo *info2,
				       TVDgeomMat3x3  mat));

/* -----------------------------------------------
 * Individual attribute comparision routines
 */
extern IGRint VDefpPcmkCompareDouble __((IGRdouble tol, IGRdouble val1, IGRdouble val2));

extern IGRint VDefpPcmkComparePlateThickness  __((IGRdouble thick1, IGRdouble thick2));
extern IGRint VDefpPcmkComparePlateEdgeLength __((IGRdouble len1,   IGRdouble len2));
extern IGRint VDefpPcmkComparePlateArea       __((IGRdouble area1,  IGRdouble area2));
extern IGRint VDefpPcmkCompareBeamLength      __((IGRdouble len1,   IGRdouble len2));
extern IGRint VDefpPcmkCompareBeamHeight      __((IGRdouble height1,IGRdouble height2));



// Cleanup
#if defined(__cplusplus)
}
#endif

#endif




