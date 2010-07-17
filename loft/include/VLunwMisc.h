/* $Id: VLunwMisc.h,v 1.2 2001/01/16 18:13:42 ramarao Exp $  */

/***************************************************************************
 * I/LOFT
 *
 * File:        include/VLunwMisc.h
 *
 * Description:	Some Misc Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLunwMisc.h,v $
 *      Revision 1.2  2001/01/16 18:13:42  ramarao
 *      *** empty log message ***
 *
 * Revision 1.3  2000/06/19  18:07:58  pinnacle
 * ah
 *
 * Revision 1.2  2000/05/26  17:51:16  pinnacle
 * ah
 *
 * Revision 1.1  2000/05/23  20:36:52  pinnacle
 * Created: loft/include/VLunwMisc.h by impd252 for Service Pack
 *
 * Revision 1.3  2000/02/25  20:03:04  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 09/14/99  ah      Creation
 ***************************************************************************/
#ifndef VLunwMisc_include
#define VLunwMisc_include

#ifndef   VDtypedef_include
#include "VDtypedef.h"
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ----------------------------------------------------
 * Used to extract gtraphics from the unwrap component
 */
#define VLEXT_TYPE_CONTOUR    "CONTOUR"
#define VLEXT_TYPE_MIN_REC    "MIN_REC"
#define VLEXT_TYPE_STOCK_LINE "STOCK_LINE"
#define VLEXT_TYPE_STOCK_TEXT "STOCK_TEXT"

/* ----------------------------------------------------
 * Prototypes
 */
extern IGRstat VLunwGetExternalContour __((TGRobj_env *unwrapOE, TGRobj_env *contourOE));
extern IGRstat VLunwGetMinRectangle    __((TGRobj_env *unwrapOE, TGRobj_env *rectOE));
extern IGRstat VLunwGetRange           __((TGRobj_env *unwrapOE, GRrange range));

extern IGRstat VLunwGetInternalContours __((TGRobj_env *unwrapOE,
					    IGRint      contourMax,
					    IGRint     *contourCnt,
					    TGRobj_env *contourOEs));

extern IGRstat VLunwGetFeatures         __((TGRobj_env *unwrapOE,
					    IGRint      featureMax,
					    IGRint     *featureCnt,
					    TGRobj_env *featureOEs));

extern FILE   *VLunwOpenSetupFilex      __((IGRchar *fileName, 
					    IGRchar *a_filePath));

extern FILE   *VLunwOpenSetupFile       __((TGRobj_env *unwrapOE, 
					    IGRchar    *a_filePath));

extern IGRstat VLunwGetDrawingObject    __((TGRobj_env *unwrapOE, 
					    TGRobj_env *drwOE));

extern IGRstat VLunwGetSymbologyFromBuf __((IGRchar *buf, 
					    IGRchar *type, 
					    TGRsymbology *symb));

extern IGRstat VLunwGetSymbologyFromSetupFile  __((TGRobj_env   *unwrapOE, 
						   IGRchar      *type, 
						   TGRsymbology *symb));

extern IGRstat VLunwCheckSymbology __((TGRid *objID, TGRsymbology *a_symb));

extern IGRstat VLunwGetComponents  __((TGRobj_env *unwrapOE, 
				       IGRchar    *type, 
				       IGRint      max, 
				       IGRint     *cnt, 
				       TGRobj_env *compOEs));

extern IGRstat VLunwGetUnwrapForPlate   __((TGRobj_env *plateOE,   TGRobj_env *unwrapOE));
extern IGRstat VLunwGetUnwrapForFeature __((TGRobj_env *featureOE, TGRobj_env *unwrapOE));

extern IGRstat VLunwGetPlateForUnwrap __((TGRobj_env *unwrapOE, 
					  TGRid      *unwrapID, 
					  TGRobj_env *plateOE));

extern IGRstat VLunwGetUnwrapAttribute __((TGRid     *unwrapID, 
					   IGRchar   *name, 
					   IGRchar   *txt, 
					   IGRdouble *dbl));

/* ----------------------------------------------------
 * Some transformation stuff
 */
extern IGRstat VLunwGetMatrixes __((TGRobj_env *unwrapOE, 
				    IGRdouble  *fromMat, 
				    IGRdouble  *toMat));

extern IGRstat VLunwGetMatrix   __((TGRobj_env *unwrapOE, 
				    IGRint      dir,        // 0 - 3d to 2d
				    IGRshort   *trfMatType,
				    IGRdouble  *trfMat));


extern IGRstat VLunwTransform __((TGRobj_env *unwrapOE, 
				  TGRobj_env *objOE));

extern IGRstat VLunwGet3DPts  __((TGRobj_env *unwrapOE, 
				  IGRdouble  *pt2d, 
				  IGRdouble  *pt3d));

extern IGRstat VLunwCopyObject __((TGRobj_env *unwrapOE, 
				   IGRint      dir,
				   TGRobj_env *fromOE, 
				   TGRobj_env *toOE));


/* ----------------------------------------------------
 * Bevel stuff
 */

#define  REGULAR_BEVEL_TYPE	0
#define	 STOCK_BEVEL_TYPE	1
#define  VARIABLE_BEVEL_TYPE	2

typedef struct 
{    
  IGRchar   specx  [128];  // Original spec
  IGRchar   spec   [128];  // Adjust for unwrap
  IGRchar   process[128];
  IGRchar   msg    [128];
  
  IGRdouble stock;
  IGRdouble gap;
  IGRdouble thickness,adj_thickness;
} TVLunwBevelInfo;

typedef struct 
{
  TVLunwBevelInfo info;
  IGRint	  type;
  TGRid	          bevelID;
  TGRid	          contourID;
  TGRobj_env      contourOE;
  IGRpoint	  end1;
  IGRpoint	  end2;
  IGRdouble       par1;
  IGRdouble       par2;
} TVLunwUnwrapBevelInfo;

extern IGRstat VLunwHackUpEdgeAttribute __((TGRid *edgeID));

extern IGRstat VLunwGetBevelAttribute   __((TGRid     *bevelID, 
					    IGRchar   *a_name, 
					    IGRchar   *txt, 
					    IGRdouble *dbl));

extern IGRstat VLunwBevelGetGap __((TGRid      *edgeID,
				    TGRobj_env *plateOE,
				    IGRchar    *bevelSpec,
				    IGRdouble  *gap));

extern IGRstat VLunwGetUnwrapBevelInfos __(( FILE                  *file,
                                  	     TGRobj_env            *unwrapOE,
                                  	     IGRint                 maxInfo,
                                  	     IGRint                *numInfo,
                                  	     TVLunwUnwrapBevelInfo *infos ));

extern IGRstat VLunwGetUnwrapBevelSpec __((TGRid   *unwrapID, 
					   TGRid   *bevelID, 
					   IGRchar *spec));

extern IGRstat VLunwGetBevelInfo __((TGRid           *unwrapID,
				     TGRid           *bevelID,
				     TVLunwBevelInfo *info));

extern IGRstat VLunwIsBevel __((TGRobj_env *bevelOE, TGRid *bevelID)); 

/* ----------------------------------------
 * Metric conversions
 */
#define INCH_TO_MM     25.6
#define BEVEL_CHAMFER  ((INCH_TO_MM *  2.0) / 16.0)
#define BEVEL_MM_01_16 ((INCH_TO_MM *  1.0) / 16.0)
#define BEVEL_MM_02_16 ((INCH_TO_MM *  2.0) / 16.0)
#define BEVEL_MM_03_16 ((INCH_TO_MM *  3.0) / 16.0)
#define BEVEL_MM_04_16 ((INCH_TO_MM *  4.0) / 16.0)
#define BEVEL_MM_05_16 ((INCH_TO_MM *  5.0) / 16.0)
#define BEVEL_MM_06_16 ((INCH_TO_MM *  6.0) / 16.0)
#define BEVEL_MM_07_16 ((INCH_TO_MM *  7.0) / 16.0)
#define BEVEL_MM_08_16 ((INCH_TO_MM *  8.0) / 16.0)
#define BEVEL_MM_12_16 ((INCH_TO_MM * 12.0) / 16.0)
#define BEVEL_MM_16_16 ((INCH_TO_MM * 16.0) / 16.0)
#define BEVEL_MM_24_16 ((INCH_TO_MM * 24.0) / 16.0)
#define BEVEL_MM_30_16 ((INCH_TO_MM * 30.0) / 16.0)
#define BEVEL_MM_32_16 ((INCH_TO_MM * 32.0) / 16.0)
  
/* ----------------------------------------------------
 * Clean up
 */
#if defined(__cplusplus)
}
#endif

#endif
