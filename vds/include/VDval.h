/* $Id: VDval.h,v 1.13 2002/06/07 14:46:37 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/include/VDval.h
 *
 * Description: Low level validation routines
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDval.h,v $
 *      Revision 1.13  2002/06/07 14:46:37  ahundiak
 *      ah
 *
 *      Revision 1.12  2002/05/09 17:45:45  ahundiak
 *      ah
 *
 *      Revision 1.11  2002/02/27 16:37:18  ahundiak
 *      ah
 *
 *      Revision 1.10  2001/11/09 18:10:12  ahundiak
 *      ah
 *
 *      Revision 1.9  2001/11/09 15:36:57  ahundiak
 *      ah
 *
 *      Revision 1.8  2001/11/09 14:17:55  ahundiak
 *      ah
 *
 *      Revision 1.7  2001/08/02 15:34:09  ahundiak
 *      ah
 *
 *      Revision 1.6  2001/07/29 16:59:02  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/07/28 17:30:34  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/07/23 16:01:13  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/06/22 15:00:37  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/06/03 14:40:53  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/05/24 18:35:35  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/23/01  ah      Created
 ***************************************************************************/

#ifndef VDval_include
#define VDval_include

#ifndef   VDtypedefc_include
#include "VDtypedefc.h"
#endif

#ifndef   VDtypedef_include
#ifndef   VDgeomc_include
#include "VDgeomc.h"
#endif
#endif

#ifndef   VDvalConv_include
#include "VDvalConv.h"
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ----------------------------------------------
 * vdval/x1/VDvalMaterial.c
 */
extern void    VDvalQryMaterials  __((TGRid *materialIDs));
extern void    VDvalWebMaterials  __((TGRid *materialIDs));
extern void    VDvalFileMaterials __((TGRid *materialIDs));
extern void    VDvalGetMaterials  __((TGRid *materialIDs));

extern void    VDvalGetGrade         __((IGRchar *grade, TGRid     *gradeID));
extern void    VDvalGetGradeMaterial __((IGRchar *grade, IGRchar   *material));
extern IGRstat VDvalGetGradeDensity  __((IGRchar *grade, IGRdouble *density, IGRchar *units));

extern void    VDvalCreateMaterialXmlFile __(());

extern void    VDsysFindFile __((IGRchar *dir, IGRchar *name, IGRchar *path));

/* ----------------------------------------------
 * vdval/x1/VDvalFamily.c
 */
extern void VDvalQryFamilys  __((TGRid *familyIDs));
extern void VDvalWebFamilys  __((TGRid *familyIDs));
extern void VDvalFileFamilys __((TGRid *familyIDs));
extern void VDvalGetFamilys  __((TGRid *familyIDs));

extern void VDvalGetPart  __((IGRchar *family, 
			      IGRchar *part_num, 
			      IGRchar *material, 
			      TGRid   *partID));

extern IGRstat VDvalGetPartThickness  __((IGRchar   *family, 
					  IGRchar   *part_num, 
					  IGRchar   *material, 
					  IGRdouble *thickness));

extern IGRstat VDvalIsPartFamilyMaterialValid  __((IGRchar *family, 
						   IGRchar *part_num, 
						   IGRchar *material));


extern IGRstat VDvalIsPartFamilyMaterialThicknessValid  __((IGRchar  *family, 
							    IGRchar  *part_num, 
							    IGRchar  *material, 
							    IGRdouble thickness));

/* ----------------------------------------------
 * vdval/x1/VDvalStaging.c
 */
extern void VDvalWebStaging  __((TGRid *stagingIDs));
extern void VDvalFileStaging __((TGRid *stagingIDs));
extern void VDvalGetStaging  __((TGRid *stagingIDs));

extern void VDvalGetStagingStage __((IGRchar *stageType, TGRid *stageID));

extern void VDvalGetStageType __((IGRchar *type, IGRchar *name, IGRchar *stage_type));

extern IGRstat VDvalIsParentStageTypeValid __((IGRchar *stageType, IGRchar *parentStageType));
extern IGRstat VDvalIsStageTypeValid       __((IGRchar *stageType));
extern IGRstat VDvalIsStagePlatenValid     __((IGRchar *stageType, IGRchar *platen));

extern void VDvalGetStageMinNumKids __((IGRchar *stageType, IGRint  *numKids));
extern void VDvalGetStageFmt        __((IGRchar *stageType, IGRchar *fmt));
extern void VDvalGetStageDesc       __((IGRchar *stageType, IGRchar *desc));

/* ----------------------------------------------
 * vdval/x1/VDvalStdPcmk.c
 */
extern void VDvalMakeStdGeomKeyFromStuff __((IGRchar *macro,
					     IGRchar *fam1,
					     IGRchar *part1,
					     IGRchar *fam2,
					     IGRchar *part2, 
					     IGRchar *geom_key));

extern void VDvalMakeStdGeomKeyFromNode __((TGRid *infoID, IGRchar *geom_key));
extern void VDvalSaveStdGeomKeyToNode   __((IGRchar *geom_key, TGRid *infoID));

extern void VDvalQryXmlStdPcmk2ByGeom __((IGRchar *geom_key, IGRchar *grade, IGRchar *thick, IGRchar *pcmk));
extern void VDvalQryStdPcmk2ByGeom    __((IGRchar *geom_key, IGRchar *grade, IGRchar *thick, IGRchar *pcmk));

extern void VDvalQryXmlStdPcmk2ByPcmk __((IGRchar *pcmk, TGRid *pcmkID));
extern void VDvalQryStdPcmk2ByPcmk    __((IGRchar *pcmk, TGRid *pcmkID));

extern void VDvalQryXmlStdGeom2 __((IGRchar *geom_key, TGRid *geomID));
extern void VDvalQryStdGeom2    __((IGRchar *geom_key, TGRid *geomID));

extern int VDvalStdPcmk2CompareGeom           __((const void *p1, const void *p2));
extern int VDvalStdPcmk2CompareGeomGradeThick __((const void *p1, const void *p2));
extern int VDvalStdPcmk2ComparePcmk           __((const void *p1, const void *p2));

#define VDCTX_STD_PCMK_ATR_PCMK      "pcmk"
#define VDCTX_STD_PCMK_ATR_MACRO     "macro_name"
#define VDCTX_STD_PCMK_ATR_FAM1      "family_name1"
#define VDCTX_STD_PCMK_ATR_FAM2      "family_name2"
#define VDCTX_STD_PCMK_ATR_PART1     "part_num1"
#define VDCTX_STD_PCMK_ATR_PART2     "part_num2"
#define VDCTX_STD_PCMK_ATR_GRADE     "grade"
#define VDCTX_STD_PCMK_ATR_THICK     "thickness"
#define VDCTX_STD_PCMK_ATR_GEOM_KEY  "geom_key"
#define VDCTX_STD_PCMK_ATR_GEOM_STS  "geom_sts"
#define VDCTX_STD_PCMK_ATR_GEOM_TXT  "geom_txt"

#define VDCTX_STD_PCMK_ATR_OUTER_CONTOUR "outer_contour"

/* ----------------------------------------------
 * vdval/om/VDvalStdPc.c
 */
extern IGRstat VDvalGetStdPcmk1Key   __((TGRobj_env *pieceOE, IGRchar *key));
extern IGRstat VDvalGetStdPcmk2Info  __((TGRobj_env *pieceOE, IGRchar *geom_key, IGRchar *grade, IGRchar *thick));

/* ----------------------------------------------
 * vds/vdval/x2/VDvalStaging.c
 */
extern void VDvalValidateStagingTree __((TGRid *treeID, IGRint *errorCnt));

/* ----------------------------------------------
 * vds/vdval/x2/VDvalPcmk.c
 */
extern void VDvalValidateStagingPieceMarks __((TGRid *stagingID, TGRid *platesID));

/* ----------------------------------------------
 * vds/vdval/x2/VDvalParse.c
 */
extern void VDvalParseSetDrawFlag __((IGRint  flag, TGRsymbology *symb));
extern void VDvalParseGetDrawFlag __((IGRint *flag, TGRsymbology *symb));

extern void VDvalStripWhitespace __((IGRchar **buf));

extern IGRdouble VDvalParseDouble  __((IGRchar **buf));
extern IGRint    VDvalParseInteger __((IGRchar **buf));
extern void      VDvalParseText    __((IGRchar **buf, IGRchar *txt));
    
extern IGRstat VDvalParseLineArc       __((IGRchar *buf, IGRdouble z, TGRbsp_curve **crv_result));
extern IGRstat VDvalParseEllipseCurve  __((IGRchar *buf, IGRdouble z, TGRbsp_curve **crv_result));
extern IGRstat VDvalParseCircleCurve   __((IGRchar *buf, IGRdouble z, TGRbsp_curve **crv_result));
extern IGRstat VDvalParseFlatOvalCurve __((IGRchar *buf, IGRdouble z, TGRbsp_curve **crv_result));
extern IGRstat VDvalParseGenericCurve  __((IGRchar *buf, IGRdouble z, TGRbsp_curve **crv_result, IGRchar *shape));

/* ----------------------------------------------
 * vds/vdval/x2/VDvalBsp.c
 */
extern void VDvalConvertBspCurveToText __((TGRbsp_curve *crv, IGRchar **txt));
extern void VDvalConvertTextToBspCurve __((IGRchar  *txt, TGRbsp_curve **crv));

extern void VDvalConvertDoubleToText   __((IGRdouble val, IGRint dec, IGRchar *txt));
  
extern void    VDvalConvertPointToText __((IGRpoint pt,  IGRchar *txt));
extern IGRstat VDvalConvertTextToPoint __((IGRchar *txt, IGRpoint pt));

extern IGRstat VDvalConvertTextToPoints __((IGRchar *txt, IGRint    *cnt, IGRdouble *pts));
extern void    VDvalConvertPointsToText __((IGRint   cnt, IGRdouble *pts, IGRchar  **txt));

extern void    VDvalConvertDoublesToText __((IGRint   cnt, IGRdouble *dbls, IGRint dec, IGRchar **txt));
extern IGRstat VDvalConvertTextToDoubles __((IGRchar *txt, IGRint *cnt, IGRdouble *dbls));

extern void VDvalConvertBspSurfaceToText __((TGRbsp_surface *srf, IGRchar **txt));
extern void VDvalConvertTextToBspSurface __((IGRchar *txt, TGRbsp_surface **srf));

extern void VDvalFreeBspSurface  __((TGRbsp_surface *srf));

/* ----------------------------------------------
 * vds/vdval/x2/VDvalError.c
 */
extern void VDvalResetLogErrorData __(());
extern void VDvalSetPieceError     __((TGRid *pieceID));
extern void VDvalSetStageError     __((TGRid *stageID)); 
extern void VDvalLogError          __((IGRchar *fmt, ...));
  
/* ----------------------------------------------
 * VDvalTolerance.c
 */
extern void VDvalWebTolerances  __((TGRid *toleranceIDs));
extern void VDvalFileTolerances __((TGRid *toleranceIDs));
extern void VDvalGetTolerances  __((TGRid *toleranceIDs));

extern IGRstat VDvalGetTolerance __((IGRchar *name, IGRdouble *value));

#define VDTOL_STANDARD_PLATE_THICKNESS "standard_plate_thickness"
#define VDTOL_MIN_AREA_OUTER_CONTOUR   "min_area_outer_contour"
#define VDTOL_CONTOUR_GAP              "contour_gap"
#define VDTOL_EDGE_NOT_CLOSED          "edge_not_closed"
#define VDTOL_MIN_AREA_HOLE            "min_area_hole"
#define VDTOL_MIN_DIS_HOLE_CONTOUR     "min_dis_hole_contour"
#define VDTOL_PLATE_HOLE_AREA_FACTOR   "plate_hole_area_factor"
#define VDTOL_MIN_DIS_HOLE_CENTERS     "min_dis_hole_centers" 
#define VDTOL_MIN_DIS_HOLE_HOLE        "min_dis_hole_hole"
#define VDTOL_MIN_HOLE_DIMENSION       "min_hole_dimension"
#define VDTOL_MIN_LINE_ARC_SEG_LEN     "min_line_arc_seg_len"

#define VDTOL_MIN_COG_CHANGED          "min_cog_changed"
#define VDTOL_MIN_ORG_CHANGED          "min_org_changed"
#define VDTOL_MIN_ROT_CHANGED          "min_rot_changed"
#define VDTOL_MIN_REF_CHANGED          "min_ref_changed"
#define VDTOL_MIN_LEN_CHANGED          "min_len_changed"
#define VDTOL_MIN_AREA_CHANGED         "min_area_changed"
#define VDTOL_MIN_MASS_CHANGED         "min_mass_changed"
#define VDTOL_MIN_SIZE_CHANGED         "min_size_changed"



/* ----------------------------------------------
 * Cleanup
 */
#if defined(__cplusplus)
}
#endif

#endif
