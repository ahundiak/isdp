#ifndef VPpdf_include
#define VPpdf_include

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

typedef struct {
  unsigned short  recType;
  unsigned char  dataType;
  unsigned char  dataLen;
} TVPpdfRecord;

typedef struct IGRarc TGRarc;

typedef struct 
{
  IGRint    flat;
  
  IGRpoint  origin;
  IGRpoint  axis1;
  IGRpoint  axis2;
  
  IGRdouble radius;
  IGRdouble major;
  IGRdouble minor;
} TGRoval;

typedef struct 
{
  IGRpoint  center;
  IGRdouble radius;
} TGRcir_arc;


/* ------------------------------------------
 * Misc objects
 */
#define PDF_OBJ_DT  0x00
#define PDF_OBJ_LEN 0x00

#define PDF_OBJ_BEG_MASK      0x8000
#define PDF_OBJ_END_MASK      0x4000

#include "VPpdfAttrs.h"

/* --------------------------------------------------
 * Some functions
 */
#if defined(__cplusplus)
extern "C" {
#endif

extern IGRstar  VPpdfSetBinFile   __((FILE *file));
extern FILE    *VPpdfGetBinFile   __(());

extern IGRstar VPpdfWriteInt  __((IGRlong   val));
extern IGRstar VPpdfWriteReal __((IGRdouble val));

extern IGRstar VPpdfWriteAttrReal __((IGRint recType, IGRdouble val));
extern IGRstar VPpdfWriteAttrInt  __((IGRint recType, IGRlong   val));
extern IGRstar VPpdfWriteAttrText __((IGRint recType, IGRchar  *val));

extern IGRstar VPpdfWriteObjBeg  __((IGRint   recType));
extern IGRstar VPpdfWriteObjEnd  __((IGRint   recType));
extern IGRstar VPpdfWriteAttrEnd __((IGRchar *recDesc));

extern IGRstar VPpdfWriteHdr __((IGRint recType, IGRint dataType, IGRint dataLen));

extern IGRstar VPpdfWriteBspOval   __((IGRint recType, TGRoval       *oval));
extern IGRstar VPpdfWriteBspCirArc __((IGRint recType, TGRcir_arc    *arc));
extern IGRstar VPpdfWriteBspCurve  __((IGRint recType, TGRbsp_curve  *bsp));
extern IGRstar VPpdfWriteMatrix    __((IGRint recType, IGRdouble     *mat));
extern IGRstar VPpdfWrite3dEndPts  __((IGRint recType, TGRbsp_curve  *bsp));
extern IGRstar VPpdfWrite3dPts     __((IGRint recType, IGRint ptCnt,  IGRdouble *pts));
extern IGRstar VPpdfWrite3dPt      __((IGRint recType, IGRint flag,   IGRdouble *pt));
  
// For internal isdp objects
extern IGRstar VPpdfWriteObjID    __((TGRid *id));
extern IGRstar VPpdfWriteObjClass __((TGRid *id));
extern IGRstar VPpdfWriteObjName  __((TGRid *id));
extern IGRstar VPpdfWriteObjInfo  __((IGRint recType, TGRid *id));

// For line arc curves
extern IGRstar VPpdfAddVtx     __((IGRint type, IGRdouble *vtx));
extern IGRstar VPpdfAddContour __((TGRbsp_curve *bsp));
extern IGRstat VPpdfBegContour __(());
extern IGRstat VPpdfEndContour __((IGRint recType));
  
extern IGRstar VPpdfSetTranslationMatrix __((TGRmdenv_info *mat));

extern IGRstar VPpdfGetCurveMatrix   __((TGRobj_env    *srfOE, 
                                         TGRmdenv_info *srfMat));

extern IGRstar VPpdfGetSurfaceMatrix __((TGRobj_env     *srfOE, 
					 TGRbsp_surface *srfBsp,
                                         TGRmdenv_info  *srfMat));

extern IGRstar VPpdfGetTransMatrix   __((IGRpoint       srfPoint,
                                         IGRvector      srfNormal, 
                                         TGRmdenv_info *srfMat));

#if defined(__cplusplus)
}
#endif

#endif
