/* $Id: VDgeomc.h,v 1.6 2001/11/09 18:10:12 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDgeomc.h
 *
 * Description:	C Geometry Processing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDgeomc.h,v $
 *      Revision 1.6  2001/11/09 18:10:12  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/11/09 14:17:55  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/07/23 16:01:13  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/06/07 18:57:35  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/05/17 14:09:39  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/04/12 14:24:41  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/09/01  ah      Creation
 ***************************************************************************/
#ifndef VDgeomc_include
#define VDgeomc_include

#ifndef   VDtypedefc_include
#include "VDtypedefc.h"
#endif

#ifndef   bserr_include
#define   igrtypedef_include
#include "bserr.h"
#endif

#ifndef   madef_include
#include "madef.h"
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* -----------------------------------------------
 * common bs functions
 */
#include "bsarc3pts.h"
#include "bsarclen2.h"
#include "bsarclnparc.h"

#include "bscirc3pts.h"
#include "bscrossp.h"
#include "bsctrarplcv.h"

#include "bscv_copy.h"
#include "bscveval.h"
#include "bscvmnmxbx.h"

#include "bsdistptpt.h"
#include "bsdotp.h"
#include "bsfndcent.h"

#include "bsiarcln.h"
#include "bsinv_mat.h"

#include "bsmdistcvcv.h"
#include "bsmdistptcv.h"
#include "bsmerge_cv.h"
#include "bsmergarrcv.h"
#include "bsmkvec.h"
#include "bsmult_mats.h"

#include "bspartofcv.h"
#include "bsprepelli.h"
#include "bsptlngen.h"

#include "maidmx.h"
#include "matypemx.h"
#include "maunitvc.h"

/* -----------------------------------------------
 * Some structures
 * Overlaps with some of the .I file stuff
 * Probably need a single file for both
 */
#ifndef VDgeom_include
typedef IGRdouble TVDgeomMat3x3[3][3];
#endif

#ifndef VDtypedef_include
typedef struct IGRbsp_curve   TGRbsp_curve;
typedef struct IGRbsp_surface TGRbsp_surface;
#endif

/* ---------------------------------------------
 * These numbers were determined by using the size routine above
 * they can be used to allocate buffers for certain curves
 */
#define VDGEOM_SIZE_LINE   144
#define VDGEOM_SIZE_CIRCLE 368
#define VDGEOM_SIZE_ARC    368
#define VDGEOM_SIZE_OVAL   688

#define VDGEOM_SIZE_BUF   2048

// Still don't understand why math.h doesn not come along
#define  VDGEOM_M_PI            3.14159265358979323846
#define  VDGEOM_M_PI_2          1.57079632679489661923
#define  VDGEOM_M_PI_4          0.78539816339744830962
 
/* ---------------------------------------------
 * VDgeom2Curve.c
 */
extern IGRstat VDgeom2MakeLineCurve __((IGRpoint pt1, IGRpoint pt2, TGRbsp_curve **crv));
  
extern IGRstat VDgeom2MakeArcCurve  __((IGRpoint pt1, 
					IGRpoint pt2, 
					IGRpoint pt3, 
					TGRbsp_curve **crv));

extern IGRstat VDgeom2MakeCircleCurve  __((IGRpoint pt1, 
					   IGRpoint pt2, 
					   IGRpoint pt3, 
					   TGRbsp_curve **crv));

extern IGRstat VDgeom2MakeEllipseCurve  __((IGRpoint center, 
					    IGRpoint major, 
					    IGRpoint minor, 
					    TGRbsp_curve **crv));

extern IGRstat VDgeom2MakeFlatOvalCurve  __((IGRpoint center, 
					     IGRpoint major, 
					     IGRpoint minor, 
					     TGRbsp_curve **crv));

extern IGRstat VDgeom2MergeTwoCurves __((TGRbsp_curve  *crv1,
					 TGRbsp_curve  *crv2,
					 TGRbsp_curve **crv3));
  
extern IGRstat VDgeom2CopyCurve __((TGRbsp_curve *crv1, TGRbsp_curve **crv2));

extern IGRstat VDgeom2ExtractCurve __((TGRbsp_curve  *crv1, 
				       IGRdouble      par1, 
				       IGRdouble      par2, 
				       TGRbsp_curve **crv2));

extern IGRstat VDgeom2TransformCurve __((TGRbsp_curve  *crv, 
					 TGRmdenv_info *mat, 
					 IGRvector      vec));

extern IGRstat VDgeom2MatrixCurve __((TGRbsp_curve  *crv, 
				      IGRdouble     *matrix4x4));
  
  
extern IGRstat VDgeom2LinkCurves __((TGRbsp_curve *crv1, TGRbsp_curve *crv2));
extern IGRstat VDgeom2CloseCurve __((TGRbsp_curve *crv));
  
  
extern IGRstat VDgeom2AllocCurveMaster __((IGRint order,
					   IGRint num_poles,
					   IGRint rational,
					   IGRint num_boundaries,
					   IGRint flag,
					   TGRbsp_curve **crv,
					   IGRchar       *buf,
					   IGRint         bufSize,
					   IGRint        *crvSize));
  
#define VDgeom2AllocCurveBuf(order,num_poles,rational,crv,buf,bufSize) \
        VDgeom2AllocCurveMaster(order,num_poles,rational,0,0,crv,buf,bufSize,NULL)

#define VDgeom2AllocCurve(order,num_poles,rational,crv) \
        VDgeom2AllocCurveMaster(order,num_poles,rational,0,0,crv,NULL,0,NULL)

extern IGRstat VDgeom2GetCrvPt     __((TGRbsp_curve *crv, IGRdouble u,  IGRpoint pt));
extern IGRstat VDgeom2GetCrvEndPts __((TGRbsp_curve *crv, IGRpoint pt1, IGRpoint pt2));

#define VDgeom2GetCurvePt(crv,u,pt) VDgeom2GetCrvPt(crv,u,pt)

#define VDgeom2GetCurveEndPts(crv,pt1,pt2) VDgeom2GetCrvEndPts(crv,pt1,pt2)

extern IGRstat VDgeom2GetCurveSize __((IGRint order,
				       IGRint num_poles,
				       IGRint rational,
				       IGRint num_boundaries,
				       IGRint *crvSize));

extern void VDgeom2GetCurveCenter __((TGRbsp_curve *crv, IGRpoint center));
extern void VDgeom2GetCurveArea   __((TGRbsp_curve *crv, IGRdouble *area));

extern void VDgeom2GetCurveRange  __((TGRbsp_curve *crv, IGRpoint minPt, IGRpoint maxPt));
  


/* ---------------------------------------------
 * VDgeom2Mat.c
 */
extern IGRstat VDgeom2SetMatrixToIdentity     __((TGRmdenv_info *matrix));
extern IGRstat VDgeom2SetMatrixTypeToIdentity __((IGRshort *matrix_type, IGRmatrix matrix));
extern IGRstat VDgeom2SetMatrixType           __((IGRmatrix matrix, IGRshort *matrix_type));

extern IGRstat VDgeom2MultMat __((TGRmdenv_info *mat1, 
				  TGRmdenv_info *mat2, 
				  TGRmdenv_info *mat3));
  
  
  

/* ---------------------------------------------
 * 
 */
extern IGRstat VDgeom2GetTranForPts __((IGRpoint center1, IGRpoint minor1, IGRpoint major1,
					IGRpoint center2, IGRpoint minor2, IGRpoint major2,
					TVDgeomMat3x3 mat));
  

extern IGRstat VDgeom2TransformPt __((IGRpoint      origin1, 
				      IGRpoint      origin2, 
				      TVDgeomMat3x3 mat,
				      IGRpoint      pt1,
				      IGRpoint      pt2));
  
extern IGRstat VDgeom2GetDisPtPt  __((IGRpoint pt1, IGRpoint pt2, IGRdouble *dis));
  
extern IGRstat VDgeom2GetDisPtCv  __((IGRpoint pt, TGRbsp_curve *crv, IGRdouble *dis));
extern IGRstat VDgeom2GetDisPtCrv __((IGRpoint pt, TGRbsp_curve *crv, IGRdouble *dis));
extern IGRstat VDgeom2GetParPtCrv __((IGRpoint pt, TGRbsp_curve *crv, IGRdouble *par));

extern IGRstat VDgeom2GetDisCvCv  __((TGRbsp_curve *crv1, TGRbsp_curve *crv2, IGRdouble *dis));
  
  
/* ---------------------------------------------
 * VDgeom2Prod.c
 */  
  
extern IGRstat VDgeom2GetAngleFrom3Points __((IGRpoint   pt1,
					      IGRpoint   pt2,
					      IGRpoint   pt3,
					      IGRdouble *angle));

extern IGRstat VDgeom2GetCrvArcLen __((TGRbsp_curve *crv, 
				       IGRdouble     par0, 
				       IGRdouble     par1, 
				       IGRdouble    *len));

extern IGRstat VDgeom2GetCrvArcParPt __((TGRbsp_curve *crv, 
					 IGRdouble     par0, 
					 IGRdouble     par1, 
					 IGRdouble     len,
					 IGRdouble    *par,
					 IGRpoint      pt));

extern IGRdouble VDgeom2RadToDeg __((IGRdouble rad));
extern IGRdouble VDgeom2DegToRad __((IGRdouble deg));

/* ---------------------------------------------
 * VDgeom2Like.c
 */ 
extern IGRstat VDgeom2GetCrvCMM __((TGRbsp_curve *crv,
				    IGRdouble     incAngle,
				    IGRdouble     tolAngle,
				    IGRpoint      center,
				    IGRpoint      minor,
				    IGRpoint      major));
  
extern IGRstat VDgeom2GetCrvCMMMajor __((TGRbsp_curve *crv,
					 IGRdouble     incAngle,
					 IGRdouble     tolAngle,
					 IGRpoint      center,
					 IGRpoint      minor,
					 IGRdouble     totalArcLen,
					 IGRdouble     minorArcLen,
					 IGRint        factor,
					 IGRpoint      major));


/* ----------------------------------------------------
 * Clean up
 */
#if defined(__cplusplus)
}
#endif

#endif
